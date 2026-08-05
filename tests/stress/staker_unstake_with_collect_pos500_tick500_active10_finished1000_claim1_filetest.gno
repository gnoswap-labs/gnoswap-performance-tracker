// PKGPATH: gno.land/r/demo/main

// Multi-position stress test for CollectReward with all finished incentives
// Tests gas usage when claiming rewards with 10 total incentives (all 10 finished)
package main

import (
	"gno.land/p/gnoswap/gnsmath"
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/ufmt/v0"
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

	barPath  = "gno.land/r/onbloc/bar.BAR"
	fooPath  = "gno.land/r/onbloc/foo.FOO"
	poolPath = barPath + ":" + fooPath + ":3000"

	maxInt64 int64 = 9223372036854775807

	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60

	// 100 days = ~1,764,000 blocks (to ensure 90-day incentives expire)
	blocksFor100Days int64 = 1764000
	tickCrossCount   int64 = 500

	// Number of positions to stake
	positionCount = 500
	// Number of positions to claim rewards from
	claimBatchCount      = 1
	tokenIds             []uint64
	finishedIncentiveIds []string

	activeIncentiveCount   = 10
	finishedIncentiveCount = 1000
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createPoolAndSetTier(cur)

	// Create incentives first (before staking positions)
	incentiveStartTime := createExternalIncentives(cur, finishedIncentiveCount)
	testing.SkipHeights((incentiveStartTime-time.Now().Unix())/5 + 1)

	// Mint and stake multiple positions
	println(ufmt.Sprintf("Minting and staking %d positions...", positionCount))
	for i := 0; i < positionCount; i++ {
		tokenId := mintAndStakePosition(cur, i)
		tokenIds = append(tokenIds, tokenId)
		if (i+1)%10 == 0 {
			println(ufmt.Sprintf("  Staked %d/%d positions", i+1, positionCount))
		}
	}

	// Skip to the end of the 90-day incentive
	testing.SkipHeights(TIMESTAMP_90DAYS + 1)

	testMultiCollectReward(cur, claimBatchCount, false)

	// Create active incentives
	incentiveStartTime = createExternalIncentives(cur, activeIncentiveCount)
	testing.SkipHeights((incentiveStartTime-time.Now().Unix())/5 + 1)

	// Mint liquidity for swaps
	mintLiquidityPosition(cur)

	// Perform tick crosses
	for i := int64(0); i < tickCrossCount; i++ {
		swapWithTickCross(cur)
		testing.SkipHeights(1)
	}

	// Wait 100 days total - all 90-day incentives will be finished
	testing.SkipHeights(blocksFor100Days - tickCrossCount)

	testMultiUnstake(cur, claimBatchCount, true)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	testing.SetRealm(adminRealm)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
	bar.Approve(cross(cur), routerAddr, maxInt64)
	foo.Approve(cross(cur), routerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64)

	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func createPoolAndSetTier(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	staker.SetPoolTier(cross(cur), poolPath, 1)
}

func mintAndStakePosition(cur realm, index int) uint64 {
	testing.SetRealm(adminRealm)

	// Mint full-range position
	tickLower := int32(-887220)
	tickUpper := int32(887220)

	tokenId, _, _, _ := position.Mint(
		cross(cur),
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
		"",
	)

	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
	staker.StakeToken(cross(cur), tokenId, "")

	return tokenId
}

func mintLiquidityPosition(cur realm) {
	testing.SetRealm(adminRealm)
	// Full-range position for liquidity
	position.Mint(
		cross(cur),
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
		"",
	)
}

func createExternalIncentives(cur realm, creationCount int) int64 {
	testing.SetRealm(adminRealm)

	// Record currentTime before creating incentives
	currentTime := time.Now().Unix()
	incentiveStartTime := time.Now().AddDate(0, 0, 1).Truncate(24 * time.Hour).Unix()

	// Create all 10 incentives with 90 days (all will be finished when we test)
	endTime := incentiveStartTime + TIMESTAMP_90DAYS
	for i := 0; i < creationCount; i++ {
		staker.CreateExternalIncentive(
			cross(cur),
			poolPath,
			barPath,
			1_000_000_000,
			incentiveStartTime,
			endTime,
		)
		// Track incentive ID: {creator}:{currentTime}:{counter}
		// Counter is 1-based: 1, 2, 3, ..., 10
		incentiveId := ufmt.Sprintf("%s:%d:%d", adminAddr, currentTime, i+1)
		finishedIncentiveIds = append(finishedIncentiveIds, incentiveId)
	}

	testing.SkipHeights(1)

	return incentiveStartTime
}

func swapWithTickCross(cur realm) {
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))

	// Swap to cross ticks in one direction
	pool.Swap(
		cross(cur),
		barPath,
		fooPath,
		3000,
		adminAddr,
		true,
		"1000000",
		gnsmath.TickMathGetSqrtRatioAtTick(-887220).ToString(),
		adminAddr,
		func(cur realm, amount0Delta, amount1Delta int64, _ *pool.CallbackMarker) error {
			testing.SetRealm(adminRealm)
			if amount0Delta > 0 {
				common.SafeGRC20Transfer(cross(cur), barPath, poolAddr, amount0Delta)
			}
			if amount1Delta > 0 {
				common.SafeGRC20Transfer(cross(cur), fooPath, poolAddr, amount1Delta)
			}
			return nil
		},
	)

	// Swap back to cross ticks in other direction
	pool.Swap(
		cross(cur),
		barPath,
		fooPath,
		3000,
		adminAddr,
		false,
		"1000000",
		gnsmath.TickMathGetSqrtRatioAtTick(887220).ToString(),
		adminAddr,
		func(cur realm, amount0Delta, amount1Delta int64, _ *pool.CallbackMarker) error {
			testing.SetRealm(adminRealm)
			if amount0Delta > 0 {
				common.SafeGRC20Transfer(cross(cur), barPath, poolAddr, amount0Delta)
			}
			if amount1Delta > 0 {
				common.SafeGRC20Transfer(cross(cur), fooPath, poolAddr, amount1Delta)
			}
			return nil
		},
	)
}

func testMultiCollectReward(cur realm, claimBatchCount int, withMetrics bool) {
	testing.SetRealm(adminRealm)

	if withMetrics {
		metric.PrintMetricsBy(ufmt.Sprintf("CollectReward (pos=%d, tick=%d, claim=%d, active=%d, finished=%d)", positionCount, tickCrossCount, claimBatchCount, activeIncentiveCount, finishedIncentiveCount), func() {
			for i := 0; i < claimBatchCount; i++ {
				staker.CollectReward(cross(cur), tokenIds[i])
			}
		})
	} else {
		for i := 0; i < claimBatchCount; i++ {
			staker.CollectReward(cross(cur), tokenIds[i])
		}
	}
}

func testMultiUnstake(cur realm, claimBatchCount int, withMetrics bool) {
	testing.SetRealm(adminRealm)

	if withMetrics {
		metric.PrintMetricsBy(ufmt.Sprintf("UnstakeToken with collect (pos=%d, tick=%d, claim=%d, active=%d, finished=%d)", positionCount, tickCrossCount, claimBatchCount, activeIncentiveCount, finishedIncentiveCount), func() {
			for i := 0; i < claimBatchCount; i++ {
				staker.UnStakeToken(cross(cur), tokenIds[i])
			}
		})
	} else {
		for i := 0; i < claimBatchCount; i++ {
			staker.UnStakeToken(cross(cur), tokenIds[i])
		}
	}
}
