// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Real pool lifecycle and repeated swap metrics for the remaining persisted uint256 fields.
package main

import (
	"testing"

	"gno.land/p/gnoswap/gnsmath"
	"gno.land/p/nt/ufmt/v0"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	_ "gno.land/r/gnoswap/router/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/router"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	routerAddr, _ = access.GetAddress(prabc.ROLE_ROUTER.String())

	token0Path   = "gno.land/r/onbloc/bar.BAR"
	token1Path   = "gno.land/r/onbloc/foo.FOO"
	poolPath     = token0Path + ":" + token1Path + ":3000"
	forwardRoute = token1Path + ":" + token0Path + ":3000"
	reverseRoute = token0Path + ":" + token1Path + ":3000"

	maxInt64 int64 = 9223372036854775807
	deadline       = int64(9999999999)
)

func main(cur realm) {
	initializeSetup(cur)
	createPoolMetric(cur)

	wideID, wideLiquidity := mintPositionMetric(cur, "Remaining pool allocation mint-wide", -887220, 887220, "50000000")
	narrowID, narrowLiquidity := mintPositionMetric(cur, "Remaining pool allocation mint-crossing-range", -600, 600, "1000000")
	if wideID == 0 || narrowID == 0 || wideLiquidity == "" || narrowLiquidity == "" {
		panic("pool mint did not return a usable position")
	}
	emitPoolState("after-mint")

	// Three batch sizes make both first-call and amortized same-pool costs visible.
	runExactInStages(cur, token1Path, token0Path, forwardRoute, "forward")
	runExactInStages(cur, token0Path, token1Path, reverseRoute, "reverse")
	emitPoolState("after-no-cross")

	// Exact-out swaps exercise the opposite amount solver without replacing the paid path.
	runExactOutStage(cur, token1Path, token0Path, forwardRoute, "Remaining pool repeat exact-out forward control")
	runExactOutStage(cur, token0Path, token1Path, reverseRoute, "Remaining pool repeat exact-out reverse control")
	emitPoolState("after-exact-out")

	// The second position is narrow enough for these trades to cross initialized ticks;
	// the 1/10/100 batches above remain below that range and are no-cross controls.
	runCrossingStage(cur, token1Path, token0Path, forwardRoute, "Remaining pool repeat crossing exact-in forward")
	runCrossingStage(cur, token0Path, token1Path, reverseRoute, "Remaining pool repeat crossing exact-in reverse")
	emitPoolState("after-crossing")

	collectFees(cur, wideID)
	removePosition(cur, "Remaining pool lifecycle burn-wide", wideID, wideLiquidity)
	removePosition(cur, "Remaining pool lifecycle burn-crossing-range", narrowID, narrowLiquidity)
	emitPoolState("after-removal")
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	// Use existing funded GRC20 realms; native wrapping is outside this experiment.
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), routerAddr, maxInt64)
	foo.Approve(cross(cur), routerAddr, maxInt64)
}

func createPoolMetric(cur realm) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Remaining pool allocation create", func() {
		pool.CreatePool(
			cross(cur),
			token0Path,
			token1Path,
			3000,
			gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
		)
	})
	if !pool.ExistsPoolPath(poolPath) {
		panic("pool creation state was not persisted")
	}
	ufmt.Printf("- State: pool-created path=%s\n", poolPath)
	emitPoolState("after-create")
}

func emitPoolState(label string) {
	fee0, err := pool.GetFeeGrowthGlobal0X128(poolPath)
	if err != nil {
		panic(err)
	}
	fee1, err := pool.GetFeeGrowthGlobal1X128(poolPath)
	if err != nil {
		panic(err)
	}
	liquidity, err := pool.GetLiquidity(poolPath)
	if err != nil {
		panic(err)
	}
	price, err := pool.GetSlot0SqrtPriceX96(poolPath)
	if err != nil {
		panic(err)
	}
	tick, err := pool.GetSlot0Tick(poolPath)
	if err != nil {
		panic(err)
	}
	unlocked, err := pool.GetSlot0Unlocked(poolPath)
	if err != nil {
		panic(err)
	}
	ufmt.Printf("- State: pool-state label=%s fee0=%s fee1=%s liquidity=%s price=%s tick=%d unlocked=%t\n", label, fee0, fee1, liquidity, price, tick, unlocked)
}

func mintPositionMetric(cur realm, label string, tickLower, tickUpper int32, amount string) (uint64, string) {
	testing.SetRealm(adminRealm)
	var positionID uint64
	var liquidity, amount0, amount1 string
	metric.PrintMetricsBy(label, func() {
		positionID, liquidity, amount0, amount1 = position.Mint(
			cross(cur),
			token1Path,
			token0Path,
			3000,
			tickLower,
			tickUpper,
			amount,
			amount,
			"0",
			"0",
			deadline,
			adminAddr,
			"",
		)
	})
	ufmt.Printf("- State: position-minted label=%s id=%d liquidity=%s amounts=%s/%s\n", label, positionID, liquidity, amount0, amount1)
	return positionID, liquidity
}

func runExactInStages(cur realm, inputToken, outputToken, route, direction string) {
	runExactInStage(cur, inputToken, outputToken, route, "Remaining pool repeat no-cross exact-in "+direction+" stage-1", "1000", 1)
	runExactInStage(cur, inputToken, outputToken, route, "Remaining pool repeat no-cross exact-in "+direction+" stage-10", "1000", 10)
	runExactInStage(cur, inputToken, outputToken, route, "Remaining pool repeat no-cross exact-in "+direction+" stage-100", "1000", 100)
	runExactInStage(cur, inputToken, outputToken, route, "Remaining pool repeat no-cross exact-in "+direction+" stage-1000", "1000", 1000)
}

func runExactInStage(cur realm, inputToken, outputToken, route, label, amount string, count int) {
	testing.SetRealm(adminRealm)
	var amountIn, amountOut string
	metric.PrintMetricsBy(label, func() {
		for i := 0; i < count; i++ {
			amountIn, amountOut = router.ExactInSingleSwapRoute(
				cross(cur),
				inputToken,
				outputToken,
				amount,
				route,
				"1",
				"0",
				deadline,
				"",
			)
		}
	})
	if amountIn == "" || amountOut == "" {
		panic(ufmt.Sprintf("%s returned an empty swap result", label))
	}
	ufmt.Printf("- State: swap label=%s amountIn=%s amountOut=%s\n", label, amountIn, amountOut)
}

func runCrossingStage(cur realm, inputToken, outputToken, route, label string) {
	before, err := pool.GetSlot0Tick(poolPath)
	if err != nil {
		panic(err)
	}
	runExactInStage(cur, inputToken, outputToken, route, label, "3000000", 1)
	after, err := pool.GetSlot0Tick(poolPath)
	if err != nil {
		panic(err)
	}
	for _, boundary := range []int32{-600, 600} {
		if (before < boundary && after >= boundary) || (before >= boundary && after < boundary) {
			return
		}
	}
	panic("crossing workload did not cross an initialized boundary")
}

func runExactOutStage(cur realm, inputToken, outputToken, route, label string) {
	testing.SetRealm(adminRealm)
	var amountIn, amountOut string
	metric.PrintMetricsBy(label, func() {
		amountIn, amountOut = router.ExactOutSingleSwapRoute(
			cross(cur),
			inputToken,
			outputToken,
			"1000",
			route,
			"1000000",
			"0",
			deadline,
			"",
		)
	})
	if amountIn == "" || amountOut == "" {
		panic(ufmt.Sprintf("%s returned an empty swap result", label))
	}
	ufmt.Printf("- State: swap label=%s amountIn=%s amountOut=%s\n", label, amountIn, amountOut)
}

func collectFees(cur realm, positionID uint64) {
	testing.SetRealm(adminRealm)
	var fee0, fee1 string
	metric.PrintMetricsBy("Remaining pool lifecycle collect-fee", func() {
		_, fee0, fee1, _, _, _ = position.CollectFee(cross(cur), positionID)
	})
	ufmt.Printf("- State: fees-collected id=%d token0=%s token1=%s\n", positionID, fee0, fee1)
}

func removePosition(cur realm, label string, positionID uint64, liquidity string) {
	testing.SetRealm(adminRealm)
	var removed, fee0, fee1, principal0, principal1, poolKey string
	metric.PrintMetricsBy(label, func() {
		_, removed, fee0, fee1, principal0, principal1, poolKey = position.DecreaseLiquidity(
			cross(cur),
			positionID,
			liquidity,
			"0",
			"0",
			deadline,
		)
	})
	if removed != liquidity {
		panic(ufmt.Sprintf("%s removed %s, want %s", label, removed, liquidity))
	}
	ufmt.Printf("- State: position-removed label=%s id=%d liquidity=%s fees=%s/%s principal=%s/%s pool=%s\n", label, positionID, removed, fee0, fee1, principal0, principal1, poolKey)
}
