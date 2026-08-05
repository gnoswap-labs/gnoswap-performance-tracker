// PKGPATH: gno.land/r/demo/main

// Gas and performance metrics for position mint with native GNOT
// Test cases based on tests/integration/testdata/position/position_mint_with_gnot.txtar
package main

import (
	"chain"
	"gno.land/p/gnoswap/gnsmath"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoland/wugnot"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _     = access.GetAddress(prabc.ROLE_POOL.String())
	positionAddr, _ = access.GetAddress(prabc.ROLE_POSITION.String())

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
	poolSetup(cur)

	collectFeeMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})

	gns.Approve(cross(cur), poolAddr, maxInt64)
}

func poolSetup(cur realm) {
	testing.SetRealm(adminRealm)

	pool.CreatePool(
		cross(cur),
		wugnotPath,
		gnsPath,
		3000,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func collectFeeMetric(cur realm) {
	testing.SetRealm(adminRealm)
	gns.Approve(cross(cur), poolAddr, maxInt64)
	wugnot.Approve(cross(cur), poolAddr, maxInt64)
	gns.Approve(cross(cur), positionAddr, maxInt64)
	wugnot.Approve(cross(cur), positionAddr, maxInt64)
	testing.SetOriginSend(chain.Coins{})

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

	metric.PrintMetricsBy("CollectFee (with unwrap)", func() {
		position.CollectFee(
			cross(cur),
			1,
		)
	})
}
