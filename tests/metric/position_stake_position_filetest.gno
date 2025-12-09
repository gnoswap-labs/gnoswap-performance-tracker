// Gas and performance metrics for position staking
// Test cases based on tests/integration/testdata/position/stake_position.txtar
package main

import (
	"strconv"
	"testing"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/staker"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath = "gno.land/r/onbloc/bar"
	fooPath = "gno.land/r/onbloc/foo"

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main() {
	initializeSetup()
	createBarFooPool()
	mintPosition()

	setPoolTierMetric()
	stakePositionMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	bar.Transfer(cross, aliceAddr, 100000000)
	foo.Transfer(cross, aliceAddr, 100000000)

	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
}

func createBarFooPool() {
	testing.SetRealm(adminRealm)

	pool.CreatePool(
		cross,
		barPath,
		fooPath,
		3000,
		common.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func mintPosition() {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)

	position.Mint(
		cross,
		barPath,
		fooPath,
		3000,
		-60,
		60,
		"5000000",
		"5000000",
		"1",
		"1",
		9999999999,
		aliceAddr,
		aliceAddr,
		"",
	)
}

func setPoolTierMetric() {
	testing.SetRealm(adminRealm)

	poolPath := barPath + ":" + fooPath + ":3000"
	metric.PrintMetricsBy("SetPoolTier (tier 1)", func() {
		staker.SetPoolTier(cross, poolPath, 1)
	})
}

func stakePositionMetric() {
	testing.SetRealm(aliceRealm)
	gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.Itoa(1)))

	metric.PrintMetricsBy("StakeToken", func() {
		staker.StakeToken(cross, uint64(1), "")
	})
}
