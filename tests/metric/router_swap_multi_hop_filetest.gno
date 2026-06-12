// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for multi-hop and multi-route stress test
// Tests: 2 hops, 3 hops, and multi-route (split across multiple paths)
// Uses gns, wugnot, obl, and bar tokens
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
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/obl"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	routerAddr, _ = access.GetAddress(prabc.ROLE_ROUTER.String())

	wugnotPath = "gno.land/r/gnoland/wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns"
	oblPath    = "gno.land/r/onbloc/obl"
	barPath    = "gno.land/r/onbloc/bar"

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	wugnot.Deposit(cross(cur))
	testing.SetOriginSend(chain.Coins{})
	createPools(cur)
	mintPositions(cur)

	// 2 hops: gns -> obl -> wugnot
	doubleHopExactIn(cur)
	doubleHopExactOut(cur)

	// 3 hops: gns -> obl -> bar -> wugnot
	tripleHopExactIn(cur)
	tripleHopExactOut(cur)

	// Multi-route: 50% direct (gns -> wugnot) + 50% via obl (gns -> obl -> wugnot)
	multiRouteExactIn(cur)
	multiRouteExactOut(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})

	gns.Approve(cross(cur), poolAddr, maxInt64)
	wugnot.Approve(cross(cur), poolAddr, maxInt64)
	obl.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	gns.Approve(cross(cur), routerAddr, maxInt64)
	wugnot.Approve(cross(cur), routerAddr, maxInt64)
	obl.Approve(cross(cur), routerAddr, maxInt64)
	bar.Approve(cross(cur), routerAddr, maxInt64)
}

func createPools(cur realm) {
	testing.SetRealm(adminRealm)

	// Pool 1: gns <-> wugnot (for direct route)
	pool.CreatePool(
		cross(cur),
		wugnotPath,
		gnsPath,
		3000,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)

	// Pool 2: gns <-> obl
	pool.CreatePool(
		cross(cur),
		gnsPath,
		oblPath,
		3000,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)

	// Pool 3: obl <-> wugnot
	pool.CreatePool(
		cross(cur),
		wugnotPath,
		oblPath,
		3000,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)

	// Pool 4: obl <-> bar (for 3-hop)
	pool.CreatePool(
		cross(cur),
		oblPath,
		barPath,
		3000,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)

	// Pool 5: bar <-> wugnot (for 3-hop)
	pool.CreatePool(
		cross(cur),
		wugnotPath,
		barPath,
		3000,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func mintPositions(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	// Mint position for gns <-> wugnot pool
	position.Mint(
		cross(cur),
		wugnotPath,
		gnsPath,
		3000,
		-887220,
		887220,
		"1000000000",
		"1000000000",
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)

	// Mint position for gns <-> obl pool
	position.Mint(
		cross(cur),
		gnsPath,
		oblPath,
		3000,
		-887220,
		887220,
		"1000000000",
		"1000000000",
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)

	// Mint position for obl <-> wugnot pool
	position.Mint(
		cross(cur),
		wugnotPath,
		oblPath,
		3000,
		-887220,
		887220,
		"1000000000",
		"1000000000",
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)

	// Mint position for obl <-> bar pool
	position.Mint(
		cross(cur),
		oblPath,
		barPath,
		3000,
		-887220,
		887220,
		"1000000000",
		"1000000000",
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)

	// Mint position for bar <-> wugnot pool
	position.Mint(
		cross(cur),
		wugnotPath,
		barPath,
		3000,
		-887220,
		887220,
		"1000000000",
		"1000000000",
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)
}

func doubleHopExactIn(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("MultiHop ExactIn (2 hops)", func() {
		router.ExactInSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"10000000",
			"gno.land/r/gnoswap/gns:gno.land/r/onbloc/obl:3000*POOL*gno.land/r/onbloc/obl:gno.land/r/gnoland/wugnot:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func doubleHopExactOut(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("MultiHop ExactOut (2 hops)", func() {
		router.ExactOutSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"10000000",
			"gno.land/r/gnoswap/gns:gno.land/r/onbloc/obl:3000*POOL*gno.land/r/onbloc/obl:gno.land/r/gnoland/wugnot:3000",
			"100",
			"100000000",
			9999999999,
			"",
		)
	})
}

func tripleHopExactIn(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("MultiHop ExactIn (3 hops)", func() {
		router.ExactInSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"10000000",
			"gno.land/r/gnoswap/gns:gno.land/r/onbloc/obl:3000*POOL*gno.land/r/onbloc/obl:gno.land/r/onbloc/bar:3000*POOL*gno.land/r/onbloc/bar:gno.land/r/gnoland/wugnot:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func tripleHopExactOut(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("MultiHop ExactOut (3 hops)", func() {
		router.ExactOutSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"10000000",
			"gno.land/r/gnoswap/gns:gno.land/r/onbloc/obl:3000*POOL*gno.land/r/onbloc/obl:gno.land/r/onbloc/bar:3000*POOL*gno.land/r/onbloc/bar:gno.land/r/gnoland/wugnot:3000",
			"100",
			"100000000",
			9999999999,
			"",
		)
	})
}

func multiRouteExactIn(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	// Multi-route: 50% direct + 50% via obl
	// Route 1: gns -> wugnot (direct)
	// Route 2: gns -> obl -> wugnot (2 hops)
	metric.PrintMetricsBy("MultiRoute ExactIn (50:50 split)", func() {
		router.ExactInSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"10000000",
			"gno.land/r/gnoswap/gns:gno.land/r/gnoland/wugnot:3000,gno.land/r/gnoswap/gns:gno.land/r/onbloc/obl:3000*POOL*gno.land/r/onbloc/obl:gno.land/r/gnoland/wugnot:3000",
			"50,50",
			"0",
			9999999999,
			"",
		)
	})
}

func multiRouteExactOut(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	// Multi-route: 50% direct + 50% via obl
	metric.PrintMetricsBy("MultiRoute ExactOut (50:50 split)", func() {
		router.ExactOutSwapRoute(
			cross(cur),
			gnsPath,
			wugnotPath,
			"10000000",
			"gno.land/r/gnoswap/gns:gno.land/r/gnoland/wugnot:3000,gno.land/r/gnoswap/gns:gno.land/r/onbloc/obl:3000*POOL*gno.land/r/onbloc/obl:gno.land/r/gnoland/wugnot:3000",
			"50,50",
			"100000000",
			9999999999,
			"",
		)
	})
}
