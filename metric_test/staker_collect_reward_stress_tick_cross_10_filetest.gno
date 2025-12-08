// PKGPATH: gno.land/r/demo/main

// Gas and performance metrics for staker CollectReward with varying staked position counts
// Tests how gas changes as the number of staked positions increases
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

	iterations int64 = 10
)

// Test position counts to measure gas scaling

var t *testing.T

func main() {
	initializeSetup()
	createPoolAndSetTier()

	mintAndStakePositions()
	mintPositionWithFullRange()

	// Run tests for different position counts
	for i := int64(0); i < iterations; i++ {
		println(ufmt.Sprintf("swap with cross range (%d/%d) - position %d", i+1, iterations, i+1))
		swapWithCrossRange()
	}

	collectRewardMetric(1, iterations)
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

	poolPath := barPath + ":" + fooPath + ":3000"
	staker.SetPoolTier(cross, poolPath, 1)
}

func mintAndStakePositions() uint64 {
	testing.SetRealm(adminRealm)

	startTokenId := uint64(1)

	// Mint position with different tick ranges to simulate real scenarios
	tokenId, _, _, _ := position.Mint(
		cross,
		barPath,
		fooPath,
		3000,
		-240,
		240,
		"50",
		"50",
		"0",
		"0",
		time.Now().Unix()+3600,
		adminAddr,
		adminAddr,
		"",
	)

	// Approve and stake
	gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
	staker.StakeToken(cross, tokenId, "")

	return startTokenId
}

func mintPositionWithFullRange() {
	testing.SetRealm(adminRealm)

	position.Mint(
		cross,
		barPath,
		fooPath,
		3000,
		-6960,
		6960,
		"10000000",
		"10000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		adminAddr,
		adminAddr,
		"",
	)
}

func swapWithCrossRange() {
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	pool.Swap(
		cross,
		barPath,
		fooPath,
		3000,
		adminAddr,
		false,
		"-500000",
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
	testing.SkipHeights(1)

	beforeTick := pool.GetSlot0Tick(poolPath)

	pool.Swap(
		cross,
		barPath,
		fooPath,
		3000,
		adminAddr,
		true,
		"501505",
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

	testing.SkipHeights(1)
	println(ufmt.Sprintf("(in range) pool current tick: %d -> %d", beforeTick, pool.GetSlot0Tick(poolPath)))
}

func collectRewardMetric(tokenId uint64, iterations int64) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectReward tick cross (iterations=%d)", iterations), func() {
		staker.CollectReward(cross, tokenId, false)
	})
}
