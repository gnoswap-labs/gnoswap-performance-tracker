// PKGPATH: gno.land/r/gnoswap/scenario/stress/main

// Gas and performance metrics for router swap routes (stress test)
// Creates 1478 positions with different tick ranges, then runs ExactIn/ExactOut swaps
package main

import (
	"chain"
	"gno.land/p/gnoswap/gnsmath"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/router/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/router"

	"gno.land/r/gnoland/wugnot"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	routerAddr, _ = access.GetAddress(prabc.ROLE_ROUTER.String())

	wugnotPath = "gno.land/r/gnoland/wugnot.wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns.GNS"

	maxInt64 int64 = 9223372036854775807
)

var (
	minTick          = int32(-887220)
	maxTick          = int32(887220)
	tickSpacing      = int32(60)
	tickCompressSize = maxTick / tickSpacing

	iterationAdjustment = int32(10) // 100 -> 140  10 -> 1400, 1 -> 14000
	iterations          = tickCompressSize / iterationAdjustment
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)

	// setup pool and mint position
	createPool(cur)

	for i := int32(0); i < iterations; i++ {
		tickDiff := i * tickSpacing * iterationAdjustment
		minTick := minTick + tickDiff
		maxTick := tickDiff
		gas, _, _ := mintPosition(cur, minTick, maxTick, "10000000", "10000000")
		println(ufmt.Sprintf("minted position (%d/%d) - gas: %d", i, iterations, gas))
	}

	mintPositionMetric(cur)

	// ExactIn swaps
	exactInSwapGnsToWugnotMetric(cur)
	exactInSwapWugnotToGnsMetric(cur)
	exactInSwapAccumulateFeesMetric(cur)

	// ExactOut swaps
	exactOutSwapGnsToWugnotMetric(cur)
	exactOutSwapWugnotToGnsMetric(cur)
	exactOutSwapAccumulateFeesMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	testing.SetRealm(adminRealm)
	wugnot.Deposit(cross(cur))

	gns.Approve(cross(cur), poolAddr, maxInt64)
	wugnot.Approve(cross(cur), poolAddr, maxInt64)
	gns.Approve(cross(cur), routerAddr, maxInt64)
	wugnot.Approve(cross(cur), routerAddr, maxInt64)
}

func createPool(cur realm) {
	testing.SetRealm(adminRealm)

	pool.CreatePool(
		cross(cur),
		wugnotPath,
		gnsPath,
		3000,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func mintPosition(cur realm, minTick int32, maxTick int32, amount0 string, amount1 string) (int64, int64, int64) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	gas, realmStorageDiff, cycles := metric.MetricsBy("Mint Position", func() {
		position.Mint(
			cross(cur),
			wugnotPath,
			gnsPath,
			3000,
			minTick,
			maxTick,
			amount0,
			amount1,
			"0",
			"0",
			9999999999,
			adminAddr,
			"",
		)
	})

	return gas, realmStorageDiff, cycles
}

func mintPositionMetric(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Mint Position(for stress swap)", func() {
		position.Mint(
			cross(cur),
			wugnotPath,
			gnsPath,
			3000,
			-887220,
			887220,
			"50000000",
			"50000000",
			"1",
			"1",
			9999999999,
			adminAddr,
			"",
		)
	})
}

func exactInSwapGnsToWugnotMetric(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Stress ExactInSwapRoute(grc20) gns->wugnot", func() {
		router.ExactInSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"1000000000",
			"gno.land/r/gnoswap/gns.GNS:gno.land/r/gnoland/wugnot.wugnot:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func exactInSwapWugnotToGnsMetric(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Stress ExactInSwapRoute(grc20) wugnot->gns", func() {
		router.ExactInSwapRoute(
			cross(cur),
			wugnotPath,
			gnsPath,
			"1000000000",
			"gno.land/r/gnoland/wugnot.wugnot:gno.land/r/gnoswap/gns.GNS:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func exactOutSwapGnsToWugnotMetric(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Stress ExactOutSwapRoute(grc20) gns->wugnot", func() {
		router.ExactOutSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"100000000",
			"gno.land/r/gnoswap/gns.GNS:gno.land/r/gnoland/wugnot.wugnot:3000",
			"100",
			"1000000000",
			9999999999,
			"",
		)
	})
}

func exactOutSwapWugnotToGnsMetric(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Stress ExactOutSwapRoute(grc20) wugnot->gns", func() {
		router.ExactOutSwapRoute(
			cross(cur),
			wugnotPath,
			gnsPath,
			"100000000",
			"gno.land/r/gnoland/wugnot.wugnot:gno.land/r/gnoswap/gns.GNS:3000",
			"100",
			"1000000000",
			9999999999,
			"",
		)
	})
}

func exactInSwapAccumulateFeesMetric(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Stress ExactInSwapRoute(grc20) gns->wugnot (accumulate fees)", func() {
		router.ExactInSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"1000000000",
			"gno.land/r/gnoswap/gns.GNS:gno.land/r/gnoland/wugnot.wugnot:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func exactOutSwapAccumulateFeesMetric(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Stress ExactOutSwapRoute(grc20) gns->wugnot (accumulate fees)", func() {
		router.ExactOutSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"100000000",
			"gno.land/r/gnoswap/gns.GNS:gno.land/r/gnoland/wugnot.wugnot:3000",
			"100",
			"1000000000",
			9999999999,
			"",
		)
	})
}
