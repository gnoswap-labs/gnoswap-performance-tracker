// PKGPATH: gno.land/r/gnoswap/v1/main

// Gas and performance metrics for router ExactInSingleSwapRoute(grc20) - fee:500

package main

import (
	"chain"
	"gno.land/p/gnoswap/gnsmath"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
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

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	wugnot.Deposit(cross(cur))
	testing.SetOriginSend(chain.Coins{})
	createPool(cur)
	mintPosition(cur)
	doSwap(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})

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
		500,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func mintPosition(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	position.Mint(
		cross(cur),
		gnsPath,
		wugnotPath,
		500,
		-887220,
		887220,
		"50000000",
		"50000000",
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)
}

func doSwap(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("ExactInSingleSwapRoute(grc20) - fee:500", func() {
		router.ExactInSingleSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"1000000",
			"gno.land/r/gnoswap/gns.GNS:gno.land/r/gnoland/wugnot.wugnot:500",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}
