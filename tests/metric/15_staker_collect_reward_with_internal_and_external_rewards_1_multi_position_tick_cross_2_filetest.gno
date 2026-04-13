// Gas and performance metrics for staker collect reward
// Test cases based on tests/integration/testdata/staker/collect_reward_immediately_after_stake_token.txtar
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	"gno.land/r/gnoswap/emission"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/router"

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

	"gno.land/r/gnoswap/gns"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())
	routerAddr, _ = access.GetAddress(prabc.ROLE_ROUTER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath  = "gno.land/r/onbloc/bar"
	fooPath  = "gno.land/r/onbloc/foo"
	poolPath = barPath + ":" + fooPath + ":3000"

	maxInt64       int64 = 9223372036854775807
	metricIndex    int64 = 16
	incentiveCount int64 = 1
	tickCross      int64 = 2

	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60
)

const positionCount = 3

var (
	positionIDs = []uint64{1, 2, 3}
)

var t *testing.T

func main() {
	initializeSetup()
	createPoolSetup()
	mintPositionSetup()
	setPoolTierSetup()
	stakeTokenSetup()
	createExternalIncentivesSetup()

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

func createExternalIncentivesSetup() {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross, stakerAddr, maxInt64)

	incentiveStartTime := time.Now().AddDate(0, 0, 1).Truncate(24 * time.Hour).Unix()
	incentiveEndTime := incentiveStartTime + TIMESTAMP_90DAYS

	for i := 0; i < int(incentiveCount); i++ {
		staker.CreateExternalIncentive(
			cross,
			poolPath,
			barPath,
			1_000_000_000,
			incentiveStartTime,
			incentiveEndTime,
		)
	}
	testing.SkipHeights((incentiveStartTime-time.Now().Unix())/5 + 1)
}

func createPoolSetup() {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, barPath, fooPath, 3000, common.TickMathGetSqrtRatioAtTick(0).ToString())
}

func mintPositionSetup() {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)

	for i := 0; i < positionCount; i++ {
		position.Mint(cross, barPath, fooPath, 3000, -60, 60, "5000000", "5000000", "1", "1", time.Now().Unix()+3600, aliceAddr, aliceAddr, "")
	}

	position.Mint(cross, barPath, fooPath, 3000, -887220, 887220, "10000000", "10000000", "1", "1", time.Now().Unix()+3600, aliceAddr, aliceAddr, "")
}

func setPoolTierSetup() {
	testing.SetRealm(adminRealm)

	poolPath := barPath + ":" + fooPath + ":3000"
	staker.SetPoolTier(cross, poolPath, 1)
}

func stakeTokenSetup() {
	testing.SetRealm(aliceRealm)
	for tokenID := 1; tokenID <= positionCount; tokenID++ {
		gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.Itoa(tokenID)))
		staker.StakeToken(cross, uint64(tokenID), "")
	}
}

func tickCrossSetup() {
	testing.SetRealm(adminRealm)
	common.Approve(cross, barPath, routerAddr, maxInt64)
	common.Approve(cross, fooPath, routerAddr, maxInt64)

	amount := int64(5_000_000 * tickCross * 2)
	for i := int64(0); i < tickCross; i++ {
		testing.SkipHeights(1)
		router.ExactInSwapRoute(
			cross,
			barPath,
			fooPath,
			strconv.FormatInt(amount, 10),
			"gno.land/r/onbloc/bar:gno.land/r/onbloc/foo:3000",
			"100",
			"1",
			time.Now().Unix()+3600,
			"",
		)

		testing.SkipHeights(1)
		router.ExactInSwapRoute(
			cross,
			fooPath,
			barPath,
			strconv.FormatInt(amount, 10),
			"gno.land/r/onbloc/foo:gno.land/r/onbloc/bar:3000",
			"100",
			"1",
			time.Now().Unix()+3600,
			"",
		)
	}
}

func collectRewardMetric() {
	testing.SetRealm(aliceRealm)

	metric.PrintCollectRewardMetricsMultiWithTickCross(metricIndex, positionIDs, true, incentiveCount, tickCross, tickCrossSetup)
}
