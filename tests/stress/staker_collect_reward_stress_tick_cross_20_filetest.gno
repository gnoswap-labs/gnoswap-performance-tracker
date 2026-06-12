// PKGPATH: gno.land/r/demo/main

// Gas and performance metrics for staker CollectReward with varying staked position counts
// Tests how gas changes as the number of staked positions increases
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

	iterations int64 = 20
)

// Test position counts to measure gas scaling

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createPoolAndSetTier(cur)

	mintAndStakePositions(cur)
	mintPositionWithFullRange(cur)

	// Run tests for different position counts
	for i := int64(0); i < iterations; i++ {
		println(ufmt.Sprintf("swap with cross range (%d/%d) - position %d", i+1, iterations, i+1))
		swapWithCrossRange(cur)
	}

	testing.SkipHeights(600000)
	collectRewardMetric(cur, 1, iterations)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	router.SetSwapFee(cross(cur), 0)

	testing.SetRealm(adminRealm)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
	bar.Approve(cross(cur), routerAddr, maxInt64)
	foo.Approve(cross(cur), routerAddr, maxInt64)

	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func createPoolAndSetTier(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())

	poolPath := barPath + ":" + fooPath + ":3000"
	staker.SetPoolTier(cross(cur), poolPath, 1)
}

func mintAndStakePositions(cur realm) uint64 {
	testing.SetRealm(adminRealm)

	startTokenId := uint64(1)

	// Mint position with different tick ranges to simulate real scenarios
	tokenId, _, _, _ := position.Mint(
		cross(cur),
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
		"",
	)

	// Approve and stake
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
	staker.StakeToken(cross(cur), tokenId, "")

	return startTokenId
}

func mintPositionWithFullRange(cur realm) {
	testing.SetRealm(adminRealm)

	position.Mint(
		cross(cur),
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
		"",
	)
}

func swapWithCrossRange(cur realm) {
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	pool.Swap(
		cross(cur),
		barPath,
		fooPath,
		3000,
		adminAddr,
		false,
		"-500000",
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
	testing.SkipHeights(1)

	beforeTick := pool.GetSlot0Tick(poolPath)

	pool.Swap(
		cross(cur),
		barPath,
		fooPath,
		3000,
		adminAddr,
		true,
		"501505",
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

	testing.SkipHeights(1)
	println(ufmt.Sprintf("(in range) pool current tick: %d -> %d", beforeTick, pool.GetSlot0Tick(poolPath)))
}

func collectRewardMetric(cur realm, tokenId uint64, iterations int64) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectReward tick cross (iterations=%d)", iterations), func() {
		staker.CollectReward(cross(cur), tokenId)
	})
}
