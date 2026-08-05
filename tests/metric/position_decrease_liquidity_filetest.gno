// PKGPATH: gno.land/r/demo/main

// position increase decrease test

package main

import (
	"chain"
	"testing"

	prbac "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"

	"gno.land/r/gnoland/wugnot"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"

	"gno.land/r/gnoswap/scenario/metric"
)

const MIN_PRICE string = "4295128740"

var (
	adminAddr  = access.MustGetAddress(prbac.ROLE_ADMIN.String())
	adminRealm = testing.NewUserRealm(adminAddr)
	poolAddr   = access.MustGetAddress(prbac.ROLE_POOL.String())

	barPath = "gno.land/r/onbloc/bar.BAR"
	fooPath = "gno.land/r/onbloc/foo.FOO"

	fee500 uint32 = 500
)

func main(cur realm) {
	initPool(cur)
	mintInitialPosition(cur)
	executeSwap(cur)
	decreasePositionLiquidity(cur)
}

func initPool(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	pool.CreatePool(
		cross(cur),
		barPath,
		fooPath,
		fee500,
		"130621891405341611593710811006",
	)
}

func mintInitialPosition(cur realm) {
	testing.SetRealm(adminRealm)
	bar.Approve(cross(cur), poolAddr, 18394892)
	foo.Approve(cross(cur), poolAddr, 50000000)

	_, _, _, _ = position.Mint(
		cross(cur),
		barPath,
		fooPath,
		fee500,
		8000,
		12000,
		"50000000",
		"50000000",
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)
}

func increasePositionLiquidity(cur realm) {
	testing.SetRealm(adminRealm)
	bar.Approve(cross(cur), poolAddr, 18394892)
	foo.Approve(cross(cur), poolAddr, 50000000)

	_, _, _, _, _ = position.IncreaseLiquidity(
		cross(cur),
		1,
		"50000000",
		"50000000",
		"0",
		"0",
		9999999999,
	)
}

func executeSwap(cur realm) {
	testing.SetRealm(adminRealm)
	bar.Approve(cross(cur), poolAddr, 20000000)

	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	_, _ = pool.Swap(
		cross(cur),
		barPath,
		fooPath,
		fee500,
		adminAddr,
		true,
		"20000000",
		MIN_PRICE,
		func(cur realm, amount0Delta, amount1Delta int64, callbackMarker *pool.CallbackMarker) error {
			return mockSwapCallback(cur, barPath, fooPath, amount0Delta, amount1Delta, true)
		},
	)
}

func decreasePositionLiquidity(cur realm) {
	testing.SetRealm(adminRealm)

	bar.Approve(cross(cur), poolAddr, 100000000)
	foo.Approve(cross(cur), poolAddr, 100000000)

	_, _, _, _, _, _ = position.CollectFee(cross(cur), 1)

	metric.PrintMetricsBy("DecreaseLiquidity", func() {
		_, _, _, _, _, _, _ = position.DecreaseLiquidity(
			cross(cur),
			1,
			"100000000",
			"0",
			"0",
			9999999999,
		)
	})
}

func mockSwapCallback(cur realm, token0Path string, token1Path string, amount0Delta int64, amount1Delta int64, zeroForOne bool) error {
	testing.SetRealm(adminRealm)

	const wugnotPath = "gno.land/r/gnoland/wugnot.wugnot"
	const ugnotDenom = "ugnot"

	if zeroForOne {
		if token0Path == wugnotPath {
			testing.SetOriginSend(chain.Coins{{ugnotDenom, amount0Delta}})
			wugnot.Deposit(cross(cur))
		}

		common.SafeGRC20Transfer(cross(cur), token0Path, poolAddr, amount0Delta)
	} else {
		if token1Path == wugnotPath {
			testing.SetOriginSend(chain.Coins{{ugnotDenom, amount1Delta}})
			wugnot.Deposit(cross(cur))
		}

		common.SafeGRC20Transfer(cross(cur), token1Path, poolAddr, amount1Delta)
	}

	return nil
}
