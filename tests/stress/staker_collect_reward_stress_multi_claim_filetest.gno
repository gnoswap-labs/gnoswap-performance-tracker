// PKGPATH: gno.land/r/demo/main

// Multi-position stress test for CollectReward after 34 days with continuous tick crosses
// Tests gas usage when claiming rewards from multiple positions simultaneously
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

	// 34 days = 34 * 43200 blocks (assuming ~2s per block)
	daysToSimulate int64 = 34
	blocksPerDay   int64 = 43200
	totalBlocks    int64 = daysToSimulate * blocksPerDay

	// Do a swap every 1000 blocks to ensure regular tick crosses
	swapInterval   int64 = 1000
	swapIterations int64 = totalBlocks / swapInterval

	// Test with increasing number of positions
	maxPositions = 75
	tokenIds     []uint64
)

var t *testing.T

func main() {
	initializeSetup()
	createPoolAndSetTier()

	// Mint and stake multiple positions
	println(ufmt.Sprintf("Minting and staking %d positions...", maxPositions))
	for i := 0; i < maxPositions; i++ {
		tokenId := mintAndStakePosition(i)
		tokenIds = append(tokenIds, tokenId)
		if (i+1)%10 == 0 {
			println(ufmt.Sprintf("  Staked %d/%d positions", i+1, maxPositions))
		}
	}

	// Mint liquidity for swaps
	mintLiquidityPosition()

	// Simulate 34 days with periodic tick crosses
	println(ufmt.Sprintf("Simulating %d days with %d swap iterations (every %d blocks)", daysToSimulate, swapIterations, swapInterval))

	for i := int64(0); i < swapIterations; i++ {
		swapWithTickCross()
		testing.SkipHeights(swapInterval)

		if (i+1)%100 == 0 {
			println(ufmt.Sprintf("Progress: %d/%d swaps completed", i+1, swapIterations))
		}
	}

	println(ufmt.Sprintf("Simulation complete: %d days, %d tick crosses", daysToSimulate, swapIterations))

	// Test CollectReward with different batch sizes
	testBatchSizes := []int{1, 5, 10, 20, 50, 75}

	for _, batchSize := range testBatchSizes {
		testMultiCollectReward(batchSize)
	}
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)
	router.SetSwapFee(cross, 0)

	testing.SetRealm(adminRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)
	bar.Approve(cross, routerAddr, maxInt64)
	foo.Approve(cross, routerAddr, maxInt64)

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

	// Mint position with range that will be crossed by swaps
	// Use slightly different ranges to simulate diverse positions
	tickLower := int32(-300 - (index % 5) * 60)
	tickUpper := int32(300 + (index % 5) * 60)

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

func testMultiCollectReward(batchSize int) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectReward after %d days (batch=%d positions)", daysToSimulate, batchSize), func() {
		for i := 0; i < batchSize; i++ {
			staker.CollectReward(cross, tokenIds[i], false)
		}
	})
}
