// Gas and performance metrics for staker collect reward on multi positions
// Test cases based on tests/integration/testdata/staker/collect_reward_immediately_after_stake_token.txtar
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gns"
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

	metricIndex int64 = 8
)

const (
	positionCount = 3
)

var positionIDs = []uint64{1, 2, 3}

var t *testing.T

func main() {
	initializeSetup()
	createPoolMetric()
	mintMultiPositionMetric()
	setPoolTierSetup()
	stakeMultiTokenSetup()

	testing.SkipHeights(1)
	collectRewardMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)
	testing.SkipHeights(1)

	bar.Transfer(cross, aliceAddr, 10_000_000_000)
	foo.Transfer(cross, aliceAddr, 10_000_000_000)
	gns.Transfer(cross, aliceAddr, 10_000_000_000)

	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)
	gns.Approve(cross, stakerAddr, maxInt64)

	testing.SetRealm(aliceRealm)
	gns.Approve(cross, stakerAddr, maxInt64)
}

func createPoolMetric() {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, barPath, fooPath, 3000, common.TickMathGetSqrtRatioAtTick(0).ToString())
}

func mintMultiPositionMetric() {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)

	for i := 0; i < positionCount; i++ {
		position.Mint(cross, barPath, fooPath, 3000, -60, 60, "5000000", "5000000", "1", "1", time.Now().Unix()+3600, aliceAddr, aliceAddr, "")
	}
}

func setPoolTierSetup() {
	testing.SetRealm(adminRealm)

	poolPath := barPath + ":" + fooPath + ":3000"
	staker.SetPoolTier(cross, poolPath, 1)
}

func stakeMultiTokenSetup() {
	testing.SetRealm(aliceRealm)

	for tokenID := 1; tokenID <= positionCount; tokenID++ {
		gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.Itoa(tokenID)))
		staker.StakeToken(cross, uint64(tokenID), "")
	}
}

func collectRewardMetric() {
	testing.SetRealm(aliceRealm)

	metric.PrintCollectRewardMetricsMulti(metricIndex, positionIDs, true, 0)
}
