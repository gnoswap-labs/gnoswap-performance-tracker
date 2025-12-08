// Gas and performance metrics for staker CollectReward with varying staked position counts
// Tests how gas changes as the number of staked positions increases
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	"gno.land/p/nt/ufmt"
	"gno.land/r/gnoswap/emission"
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

// Test position counts to measure gas scaling
var testPositionCounts = []int{100, 500, 1000, 5000, 10000, 50000}

var t *testing.T

func main() {
	initializeSetup()
	createPoolAndSetTier()

	// Run tests for different position counts
	for _, count := range testPositionCounts {
		runStressTest(count)
	}
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	bar.Transfer(cross, aliceAddr, 10000000000000)
	foo.Transfer(cross, aliceAddr, 10000000000000)

	testing.SetRealm(aliceRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)

	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func createPoolAndSetTier() {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, barPath, fooPath, 3000, common.TickMathGetSqrtRatioAtTick(0).ToString())

	poolPath := barPath + ":" + fooPath + ":3000"
	staker.SetPoolTier(cross, poolPath, 1)
}

func runStressTest(positionCount int) {
	println(ufmt.Sprintf("\n=== Stress Test: %d Staked Positions ===", positionCount))

	// Mint and stake positions
	startTokenId := mintAndStakePositions(positionCount)

	// Measure CollectReward for the first staked position
	collectRewardMetric(startTokenId, positionCount)
}

func mintAndStakePositions(count int) uint64 {
	testing.SetRealm(aliceRealm)

	startTokenId := uint64(1)

	for i := 0; i < count; i++ {
		// Mint position with different tick ranges to simulate real scenarios
		minTick := int32(-600 - (i%10)*60)
		maxTick := int32(600 + (i%10)*60)

		tokenId, _, _, _ := position.Mint(
			cross,
			barPath,
			fooPath,
			3000,
			minTick,
			maxTick,
			"1000000",
			"1000000",
			"0",
			"0",
			time.Now().Unix()+3600,
			aliceAddr,
			aliceAddr,
			"",
		)

		if i == 0 {
			startTokenId = tokenId
		}

		// Approve and stake
		gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
		staker.StakeToken(cross, tokenId, "")

		if (i+1)%50 == 0 {
			println(ufmt.Sprintf("  Minted and staked %d/%d positions", i+1, count))
		}
	}

	println(ufmt.Sprintf("  Total staked: %d positions (tokenId %d ~ %d)", count, startTokenId, startTokenId+uint64(count)-1))
	return startTokenId
}

func collectRewardMetric(tokenId uint64, totalStaked int) {
	testing.SetRealm(aliceRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectReward (totalStaked=%d)", totalStaked), func() {
		staker.CollectReward(cross, tokenId, false)
	})
}
