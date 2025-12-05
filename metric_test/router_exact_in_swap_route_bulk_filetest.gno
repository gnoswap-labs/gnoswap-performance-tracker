// Gas and performance metrics for router exact in swap route
// Test cases based on tests/integration/testdata/router/exact_in_swap_route.txtar
package main

import (
	"chain"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/ufmt"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/router/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
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

	wugnotPath = "gno.land/r/gnoland/wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns"

	maxInt64 int64 = 9223372036854775807
)

var (
	minTick          = int32(-887220)
	maxTick          = int32(887220)
	tickSpacing      = int32(60)
	tickCompressSize = maxTick / tickSpacing

	iterationAdjustment = int32(100)
	iterations          = tickCompressSize / iterationAdjustment
)

var t *testing.T

func main() {
	initializeSetup()

	// setup pool and mint position
	createPool()

	for i := int32(0); i < iterations; i++ {
		tickDiff := i * tickSpacing * iterationAdjustment
		minTick := minTick + tickDiff
		maxTick := tickDiff
		gas, _, _ := mintPosition(minTick, maxTick, "10000000", "10000000")
		println(ufmt.Sprintf("minted position (%d/%d) - gas: %d", i, iterations, gas))
	}

	mintPositionMetric()
	exactInSwapGnsToWugnotMetric()
	exactInSwapWugnotToGnsWithNativeMetric()
	exactInSwapGnsToWugnotAccumulateFeesMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	testing.SetRealm(adminRealm)
	wugnot.Deposit(cross)

	gns.Approve(cross, poolAddr, maxInt64)
	wugnot.Approve(cross, poolAddr, maxInt64)
	gns.Approve(cross, routerAddr, maxInt64)
	wugnot.Approve(cross, routerAddr, maxInt64)
}

func createPool() {
	testing.SetRealm(adminRealm)

	pool.CreatePool(
		cross,
		wugnotPath,
		gnsPath,
		3000,
		common.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func mintPosition(minTick int32, maxTick int32, amount0 string, amount1 string) (int64, int64, int64) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	gas, realmStorageDiff, cycles := metric.MetricsBy("Mint Position", func() {
		position.Mint(
			cross,
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
			adminAddr,
			"",
		)
	})

	return gas, realmStorageDiff, cycles
}

func mintPositionMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Exact In Swap Route Bulk - Mint Position", func() {
		position.Mint(
			cross,
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
			adminAddr,
			"",
		)
	})
}

func exactInSwapGnsToWugnotMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Exact In Swap Route Bulk (gns -> wugnot)", func() {
		router.ExactInSwapRoute(
			cross,
			gnsPath,
			wugnotPath,
			"1000000000",
			"gno.land/r/gnoswap/gns:gno.land/r/gnoland/wugnot:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func exactInSwapWugnotToGnsWithNativeMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Exact In Swap Route Bulk (wugnot -> gns)", func() {
		router.ExactInSwapRoute(
			cross,
			wugnotPath,
			gnsPath,
			"1000000000",
			"gno.land/r/gnoland/wugnot:gno.land/r/gnoswap/gns:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func exactInSwapGnsToWugnotAccumulateFeesMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Exact In Swap Route Bulk (gns -> wugnot, accumulate fees)", func() {
		router.ExactInSwapRoute(
			cross,
			gnsPath,
			wugnotPath,
			"1000000000",
			"gno.land/r/gnoswap/gns:gno.land/r/gnoland/wugnot:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}
