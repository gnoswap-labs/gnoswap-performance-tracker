// Gas and performance metrics for router exact in single swap route
// Test cases based on tests/integration/testdata/router/exact_in_single_swap_route.txtar
package main

import (
	"chain"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
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

var t *testing.T

func main() {
	initializeSetup()

	createPool500Metric()
	mintPosition500Metric()
	exactInSingleSwapRouteMetric()
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
	wugnot.Approve(cross, routerAddr, maxInt64)
}

func createPool500Metric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("CreatePool (wugnot:gns:500)", func() {
		pool.CreatePool(
			cross,
			wugnotPath,
			gnsPath,
			500,
			common.TickMathGetSqrtRatioAtTick(0).ToString(),
		)
	})
}

func mintPosition500Metric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Mint (fee:500, range:-6960~6960)", func() {
		position.Mint(
			cross,
			gnsPath,
			wugnotPath,
			500,
			-6960,
			6960,
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

func exactInSingleSwapRouteMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("ExactInSingleSwapRoute (wugnot -> gns)", func() {
		router.ExactInSingleSwapRoute(
			cross,
			wugnotPath,
			gnsPath,
			"10000000",
			"gno.land/r/gnoland/wugnot:gno.land/r/gnoswap/gns:500",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}
