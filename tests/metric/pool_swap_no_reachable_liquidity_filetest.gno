// PKGPATH: gno.land/r/demo/main
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/pool"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
	_ "gno.land/r/gnoswap/staker/v1"
)

const maxSqrtRatio = "1461446703485210103287273052203988822378723970341"

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	wugnotPath = "gno.land/r/gnoland/wugnot.wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns.GNS"
)

func main(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	pool.CreatePool(cross(cur), wugnotPath, gnsPath, 500, "79228162514264337593543950336")

	metric.PrintMetricsBy("Swap with no reachable liquidity (gns -> wugnot, fee:500)", func() {
		testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
		func(cur realm) {
			amount0, amount1 := pool.Swap(
				cross(cur),
				wugnotPath,
				gnsPath,
				500,
				adminAddr,
				false,
				"1000",
				maxSqrtRatio,
				func(_ realm, amount0Delta, amount1Delta int64, _ *pool.CallbackMarker) error {
					if amount0Delta != 0 || amount1Delta != 0 {
						panic("no-liquidity swap produced token deltas")
					}
					return nil
				},
			)
			if amount0 != "0" || amount1 != "0" {
				panic("no-liquidity swap produced token amounts")
			}
		}(cross(cur))
	})
}
