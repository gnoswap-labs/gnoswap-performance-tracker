// Gas and performance metrics for staker CollectReward with varying external incentive counts
// Tests how gas changes as the number of external incentives increases
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	"gno.land/p/nt/ufmt"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/gns"
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

	poolPath = barPath + ":" + fooPath + ":3000"

	maxInt64 int64 = 9223372036854775807

	// external incentive deposit fee
	depositGnsAmount int64 = 1_000_000_000 // 1_000 GNS

	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60
)

// Test incentive counts to measure gas scaling
var testIncentiveCounts = []int{1, 5, 10, 50, 100}

func main() {
	initializeSetup()
	createPoolAndSetTier()

	// Run tests for different incentive counts
	for _, count := range testIncentiveCounts {
		runIncentiveStressTest(count)
	}
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)
	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)

	// Transfer tokens to alice for positions and external incentive rewards
	// Need: position liquidity + 1_000_000_000 bar per incentive * 100 incentives = 100_000_000_000
	bar.Transfer(cross, aliceAddr, 200_000_000_000)
	foo.Transfer(cross, aliceAddr, 10000000000000)

	// Transfer GNS to alice for external incentive deposits
	// 1_000_000_000 (1000 GNS) per incentive deposit * 100 incentives = 100_000_000_000
	gns.Transfer(cross, aliceAddr, 200_000_000_000) // enough GNS for 100+ incentive deposits

	testing.SetRealm(aliceRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)
	gns.Approve(cross, stakerAddr, maxInt64)
}

func createPoolAndSetTier() {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, barPath, fooPath, 3000, common.TickMathGetSqrtRatioAtTick(0).ToString())

	staker.SetPoolTier(cross, poolPath, 1)
}

func runIncentiveStressTest(incentiveCount int) {
	println(ufmt.Sprintf("\n=== Stress Test: %d External Incentives ===", incentiveCount))

	// Mint and stake a position
	tokenId := mintAndStakePosition()

	// Create external incentives
	createExternalIncentives(incentiveCount)

	// Skip some blocks to accumulate rewards
	testing.SkipHeights(10)

	// Measure CollectReward gas
	collectRewardMetric(tokenId, incentiveCount)
}

func mintAndStakePosition() uint64 {
	testing.SetRealm(aliceRealm)

	tokenId, _, _, _ := position.Mint(
		cross,
		barPath,
		fooPath,
		3000,
		int32(-600),
		int32(600),
		"1000000",
		"1000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		aliceAddr,
		aliceAddr,
		"",
	)

	gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
	staker.StakeToken(cross, tokenId, "")

	testing.SkipHeights(1)

	println(ufmt.Sprintf("  Minted and staked position: tokenId=%d", tokenId))
	return tokenId
}

func createExternalIncentives(count int) {
	testing.SetRealm(aliceRealm)

	// Use midnight timestamp (must be at least +1 day from now)
	startTime := int64(1234569600) // midnight timestamp

	for i := 0; i < count; i++ {
		// Each incentive has different start time to create unique incentiveIds
		incentiveStartTime := startTime + int64(i*86400) // +1 day for each incentive
		incentiveEndTime := incentiveStartTime + TIMESTAMP_90DAYS

		staker.CreateExternalIncentive(
			cross,
			poolPath,
			barPath,            // reward token
			1_000_000_000,      // reward amount (1000 bar per incentive, minimum required)
			incentiveStartTime,
			incentiveEndTime,
		)

		if (i+1)%10 == 0 {
			println(ufmt.Sprintf("  Created %d/%d incentives", i+1, count))
		}
	}

	println(ufmt.Sprintf("  Total created: %d external incentives", count))
}

func collectRewardMetric(tokenId uint64, totalIncentives int) {
	testing.SetRealm(aliceRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectReward (incentives=%d)", totalIncentives), func() {
		staker.CollectReward(cross, tokenId, false)
	})
}
