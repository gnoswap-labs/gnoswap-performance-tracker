// PKGPATH: gno.land/r/demo/main

// Multi-position stress test for CollectReward with mixed active/finished incentives
// Tests gas usage when claiming rewards with 20 total incentives (10 finished, 10 active)
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
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
	routerAddr, _ = access.GetAddress(prabc.ROLE_ROUTER.String())

	barPath  = "gno.land/r/onbloc/bar"
	fooPath  = "gno.land/r/onbloc/foo"
	poolPath = barPath + ":" + fooPath + ":3000"

	maxInt64 int64 = 9223372036854775807

	TIMESTAMP_90DAYS  int64 = 90 * 24 * 60 * 60
	TIMESTAMP_180DAYS int64 = 180 * 24 * 60 * 60

	// 100 days = ~1,764,000 blocks (to ensure 90-day incentives expire)
	blocksFor100Days int64 = 1764000
	tickCrossCount   int64 = 500

	// Number of positions to stake
	positionCount = 500
	// Number of positions to claim rewards from
	claimBatchCount = 1
	tokenIds        []uint64
)

var t *testing.T

func main() {
	initializeSetup()
	createPoolAndSetTier()

	// Mint and stake multiple positions
	println(ufmt.Sprintf("Minting and staking %d positions...", positionCount))
	for i := 0; i < positionCount; i++ {
		tokenId := mintAndStakePosition(i)
		tokenIds = append(tokenIds, tokenId)
		if (i+1)%10 == 0 {
			println(ufmt.Sprintf("  Staked %d/%d positions", i+1, positionCount))
		}
	}

	// Mint liquidity for swaps
	mintLiquidityPosition()

	createExternalIncentives()

	// Perform tick crosses
	for i := int64(0); i < tickCrossCount; i++ {
		swapWithTickCross()
		testing.SkipHeights(1)
	}

	// Wait 100 days total - 90-day incentives will be finished, 180-day still active
	testing.SkipHeights(blocksFor100Days - tickCrossCount)

	testMultiCollectReward(claimBatchCount)
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	testing.SetRealm(adminRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)
	bar.Approve(cross, routerAddr, maxInt64)
	foo.Approve(cross, routerAddr, maxInt64)
	gns.Approve(cross, stakerAddr, maxInt64)

	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func createPoolAndSetTier() {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, barPath, fooPath, 3000, common.TickMathGetSqrtRatioAtTick(0).ToString())
	staker.SetPoolTier(cross, poolPath, 1)
}

func mintAndStakePosition(index int) uint64 {
	testing.SetRealm(adminRealm)

	// Mint full-range position
	tickLower := int32(-887220)
	tickUpper := int32(887220)

	tokenId, _, _, _ := position.Mint(
		cross,
		barPath,
		fooPath,
		3000,
		tickLower,
		tickUpper,
		"1000000",
		"1000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		adminAddr,
		adminAddr,
		"",
	)

	gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
	staker.StakeToken(cross, tokenId, "")

	return tokenId
}

func mintLiquidityPosition() {
	testing.SetRealm(adminRealm)
	// Full-range position for liquidity
	position.Mint(
		cross,
		barPath,
		fooPath,
		3000,
		-887220,
		887220,
		"100000000",
		"100000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		adminAddr,
		adminAddr,
		"",
	)
}

func createExternalIncentives() {
	testing.SetRealm(adminRealm)

	incentiveStartTime := time.Now().AddDate(0, 0, 1).Truncate(24 * time.Hour).Unix()

	// Create first 10 incentives with 90 days (will be finished when we test)
	shortEndTime := incentiveStartTime + TIMESTAMP_90DAYS
	for i := 0; i < 10; i++ {
		staker.CreateExternalIncentive(
			cross,
			poolPath,
			barPath,
			1_000_000_000,
			incentiveStartTime,
			shortEndTime,
		)
	}

	// Create next 10 incentives with 180 days (will still be active when we test)
	longEndTime := incentiveStartTime + TIMESTAMP_180DAYS
	for i := 0; i < 10; i++ {
		staker.CreateExternalIncentive(
			cross,
			poolPath,
			barPath,
			1_000_000_000,
			incentiveStartTime,
			longEndTime,
		)
	}

	testing.SkipHeights((incentiveStartTime-time.Now().Unix())/5 + 1)
}

func swapWithTickCross() {
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))

	// Swap to cross ticks in one direction
	pool.Swap(
		cross,
		barPath,
		fooPath,
		3000,
		adminAddr,
		true,
		"1000000",
		common.TickMathGetSqrtRatioAtTick(-887220).ToString(),
		adminAddr,
		func(cur realm, amount0Delta, amount1Delta int64) error {
			testing.SetRealm(adminRealm)
			if amount0Delta > 0 {
				common.SafeGRC20Transfer(cross, barPath, poolAddr, amount0Delta)
			}
			if amount1Delta > 0 {
				common.SafeGRC20Transfer(cross, fooPath, poolAddr, amount1Delta)
			}
			return nil
		},
	)

	// Swap back to cross ticks in other direction
	pool.Swap(
		cross,
		barPath,
		fooPath,
		3000,
		adminAddr,
		false,
		"1000000",
		common.TickMathGetSqrtRatioAtTick(887220).ToString(),
		adminAddr,
		func(cur realm, amount0Delta, amount1Delta int64) error {
			testing.SetRealm(adminRealm)
			if amount0Delta > 0 {
				common.SafeGRC20Transfer(cross, barPath, poolAddr, amount0Delta)
			}
			if amount1Delta > 0 {
				common.SafeGRC20Transfer(cross, fooPath, poolAddr, amount1Delta)
			}
			return nil
		},
	)
}

func testMultiCollectReward(claimBatchCount int) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectReward (pos=%d, tick=%d, claim=%d, inc=20, finished=10)", positionCount, tickCrossCount, claimBatchCount), func() {
		for i := 0; i < claimBatchCount; i++ {
			staker.CollectReward(cross, tokenIds[i], false)
		}
	})
}
