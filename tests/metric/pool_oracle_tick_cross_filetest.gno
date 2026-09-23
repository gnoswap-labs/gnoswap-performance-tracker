// PKGPATH: gno.land/r/demo/oracle_tick_cross/main

// Measures a swap that crosses one initialized tick. Setup and capacity
// reservation are outside the metric blocks so the recorded cost includes the
// swap loop, tickCross oracle read, and the single final observation write.
package main

import (
	"testing"

	"gno.land/p/gnoswap/gnsmath"
	prbac "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	_ "gno.land/r/gnoswap/staker/v1"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/foo"
)

const (
	maxInt64              int64  = 9223372036854775807
	cardinalityLarge      uint16 = 1024
	fullRangeLiquidity           = "50000000"
	boundaryRangeLiquidity       = "50000000"
	swapAmount            string = "100000000"
)

var (
	adminAddr  = access.MustGetAddress(prbac.ROLE_ADMIN.String())
	adminRealm = testing.NewUserRealm(adminAddr)
	poolAddr   = access.MustGetAddress(prbac.ROLE_POOL.String())

	barPath = "gno.land/r/onbloc/bar.BAR"
	bazPath = "gno.land/r/onbloc/baz.BAZ"
	fooPath = "gno.land/r/onbloc/foo.FOO"
)

func main(cur realm) {
	initialize(cur)
	createAndSeedPool(cur, barPath, fooPath)
	createAndSeedPool(cur, barPath, bazPath)

	testing.SetRealm(adminRealm)
	pool.IncreaseObservationCardinalityNext(cross(cur), barPath, bazPath, 500, cardinalityLarge)

	// Move to a later block: the measured swap must write a new observation.
	testing.SkipHeights(1)

	measureTickCross(cur, barPath, fooPath, "Swap crossing initialized tick (cardinality:1)")
	measureTickCross(cur, barPath, bazPath, "Swap crossing initialized tick (cardinality:1024)")
}

func initialize(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	baz.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
}

func createAndSeedPool(cur realm, token0Path, token1Path string) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(
		cross(cur),
		token0Path,
		token1Path,
		500,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)

	// Full-range liquidity keeps the swap executable after it crosses the
	// initialized upper boundary of the second position.
	mint(cur, token0Path, token1Path, -887220, 887220, fullRangeLiquidity)
	mint(cur, token0Path, token1Path, -100, 100, boundaryRangeLiquidity)
}

func mint(cur realm, token0Path, token1Path string, lower, upper int32, liquidity string) {
	testing.SetRealm(adminRealm)
	_, _, _, _ = position.Mint(
		cross(cur),
		token0Path,
		token1Path,
		500,
		lower,
		upper,
		liquidity,
		liquidity,
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)
}

func measureTickCross(cur realm, token0Path, token1Path, name string) {
	printMetric(name, func() {
		testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
		// Match the router-to-pool crossing used by production swap scenarios:
		// the anonymous realm frame makes router, rather than the user realm,
		// the pool's immediate caller.
		func(cur realm) {
			pool.Swap(
				cross(cur),
				token0Path,
				token1Path,
				500,
				adminAddr,
				false,
				swapAmount,
				gnsmath.TickMathGetSqrtRatioAtTick(887220).ToString(),
				func(cur realm, amount0Delta, amount1Delta int64, _ *pool.CallbackMarker) error {
					testing.SetRealm(adminRealm)
					if amount0Delta > 0 {
						common.SafeGRC20Transfer(0, cur, token0Path, poolAddr, amount0Delta)
					}
					if amount1Delta > 0 {
						common.SafeGRC20Transfer(0, cur, token1Path, poolAddr, amount1Delta)
					}
					return nil
				},
			)
		}(cross(cur))
	})

	tick, err := pool.GetSlot0Tick(poolPath(token0Path, token1Path))
	if err != nil {
		panic(err)
	}
	if tick <= 100 {
		panic("metric swap did not cross the initialized upper tick")
	}
}

func poolPath(token0Path, token1Path string) string {
	return token0Path + ":" + token1Path + ":500"
}

func printMetric(name string, fn func()) {
	beforeGas := testing.GetGas()
	beforeCycles := testing.GetCycles()
	beforeStorage := testing.GetRealmStorageDiffs()

	fn()

	afterStorage := testing.GetRealmStorageDiffs()
	storageDiff := int64(0)
	for _, diff := range afterStorage {
		storageDiff += diff
	}
	for _, diff := range beforeStorage {
		storageDiff -= diff
	}

	println(name)
	println("- Gas Used:", testing.GetGas()-beforeGas)
	println("- Storage Diff:", storageDiff)
	println("- CPU Cycles:", testing.GetCycles()-beforeCycles)
}

// Output:
