// PKGPATH: gno.land/r/demo/main
package main

import (
	"chain"
	"testing"

	"gno.land/p/gnoswap/gnsmath"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoland/wugnot"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	_ "gno.land/r/gnoswap/pool/v1"
	"gno.land/r/gnoswap/position"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
	_ "gno.land/r/gnoswap/staker/v1"
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

func main(cur realm) {
	initializeSwapSetup(cur)
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	wugnot.Deposit(cross(cur))
	testing.SetOriginSend(chain.Coins{})
	createPool500(cur)
	mintPosition500(cur)

	swapGnsToWugnotDustMetric(cur)
}

func initializeSwapSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 1000000000000000}})

	gns.Approve(cross(cur), poolAddr, maxInt64)
	wugnot.Approve(cross(cur), poolAddr, maxInt64)
	gns.Approve(cross(cur), positionAddr, maxInt64)
	wugnot.Approve(cross(cur), positionAddr, maxInt64)
}

func createPool500(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(
		cross(cur),
		wugnotPath,
		gnsPath,
		500,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func mintPosition500(cur realm) {
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
		"1",
		"1",
		9999999999,
		adminAddr,
		"",
	)
}

func swapGnsToWugnotDustMetric(cur realm) {
	testing.SetRealm(adminRealm)
	gns.Approve(cross(cur), poolAddr, maxInt64)

	metric.PrintMetricsBy("Swap dust zero-output (gns -> wugnot, fee:500)", func() {
		testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
		func(cur realm) {
			amount0, _ := pool.Swap(
				cross(cur),
				wugnotPath,
				gnsPath,
				500,
				adminAddr,
				false,
				"1",
				"1461446703485210103287273052203988822378723970341",
				func(cur realm, amount0Delta, amount1Delta int64, callbackMarker *pool.CallbackMarker) error {
					testing.SetRealm(adminRealm)
					if amount0Delta > 0 {
						common.SafeGRC20Transfer(0, cur, wugnotPath, poolAddr, amount0Delta)
					}
					if amount1Delta > 0 {
						common.SafeGRC20Transfer(0, cur, gnsPath, poolAddr, amount1Delta)
					}
					return nil
				},
			)
			if amount0 != "0" {
				panic("dust swap produced output")
			}
		}(cross(cur))
	})
}
