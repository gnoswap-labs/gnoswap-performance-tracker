// PKGPATH: gno.land/r/gnoswap/v1/main

// Measures the first post-split checkpoint write at every candidate fanout boundary.
package main

import (
    "strconv"
    "testing"
    "time"

    "gno.land/p/demo/tokens/grc721"
    "gno.land/p/gnoswap/gnsmath"
    prbac "gno.land/p/gnoswap/rbac"
    "gno.land/r/gnoswap/access"
    "gno.land/r/gnoswap/common"
    "gno.land/r/gnoswap/emission"
    "gno.land/r/gnoswap/gnft"
    pl "gno.land/r/gnoswap/pool"
    _ "gno.land/r/gnoswap/pool/v1"
    pn "gno.land/r/gnoswap/position"
    _ "gno.land/r/gnoswap/position/v1"
    _ "gno.land/r/gnoswap/rbac"
    "gno.land/r/gnoswap/scenario/metric"
    "gno.land/r/gnoswap/scenarioutils"
    sr "gno.land/r/gnoswap/staker"
    _ "gno.land/r/gnoswap/staker/v1"
    "gno.land/r/onbloc/bar"
    "gno.land/r/onbloc/baz"
)

const (
	tickSpacing int32  = 10
	poolFee     uint32 = 500
	maxAmount   int64  = 9223372036854775807
	amountLimit int64  = 9999999999
)

var (
    admin, _ = access.GetAddress(prbac.ROLE_ADMIN.String())
    userRealm = testing.NewUserRealm(admin)
    poolAddress, _ = access.GetAddress(prbac.ROLE_POOL.String())
    stakerAddress, _ = access.GetAddress(prbac.ROLE_STAKER.String())
    poolPath = "gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/baz.BAZ:500"
    barPath = "gno.land/r/onbloc/bar.BAR"
	bazPath         = "gno.land/r/onbloc/baz.BAZ"
	boundaryTokenID uint64
)

func main(cur realm) {
	setup(cur)
	mintLiquidity(cur)
	stakeBoundary(cur)

	previousHistoryCrosses := int32(0)
	for historyCrosses := int32(0); historyCrosses <= 20; historyCrosses++ {
		buildHistory(cur, previousHistoryCrosses, historyCrosses)
		measureNextCross(cur, historyCrosses)
		previousHistoryCrosses = historyCrosses + 1
	}
	for _, historyCrosses := range []int32{32, 64} {
		buildHistory(cur, previousHistoryCrosses, historyCrosses)
		measureNextCross(cur, historyCrosses)
		previousHistoryCrosses = historyCrosses + 1
	}
	testing.SkipHeights(1)
	testing.SetRealm(userRealm)
	metric.PrintMetricsBy("CollectReward after 65 tick checkpoints", func() {
		sr.CollectReward(cross(cur), boundaryTokenID)
	})
}

func setup(cur realm) {
    testing.SetRealm(userRealm)
    scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
    emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
    emission.ChangeDistributionPct(cross(cur), 7500, 2500, 0, 0)
    pl.SetPoolCreationFee(cross(cur), 0)
    sr.SetUnStakingFee(cross(cur), 0)
    testing.SkipHeights(1)
    emission.MintAndDistributeGns(cross(cur))
    pl.CreatePool(cross(cur), barPath, bazPath, poolFee, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
    sr.SetPoolTier(cross(cur), poolPath, 1)
    bar.Approve(cross(cur), poolAddress, maxAmount)
    baz.Approve(cross(cur), poolAddress, maxAmount)
}

func mintLiquidity(cur realm) {
    testing.SetRealm(userRealm)
    pn.Mint(cross(cur), barPath, bazPath, poolFee, -6000, 6000, "50000000", "50000000", "0", "0", amountLimit, admin, "")
}

func stakeBoundary(cur realm) {
    testing.SetRealm(userRealm)
    activeTokenID, _, _, _ := pn.Mint(cross(cur), barPath, bazPath, poolFee, -6000, 6000, "1000000", "1000000", "0", "0", amountLimit, admin, "")
    gnft.Approve(cross(cur), stakerAddress, grc721.TokenID(strconv.FormatUint(activeTokenID, 10)))
    sr.StakeToken(cross(cur), activeTokenID, "")

	boundaryTokenID, _, _, _ = pn.Mint(cross(cur), barPath, bazPath, poolFee, tickSpacing, 6000, "1000000", "0", "0", "0", amountLimit, admin, "")
	gnft.Approve(cross(cur), stakerAddress, grc721.TokenID(strconv.FormatUint(boundaryTokenID, 10)))
	sr.StakeToken(cross(cur), boundaryTokenID, "")
}

func buildHistory(cur realm, start, end int32) {
	for i := start; i < end; i++ {
		testing.SkipHeights(1)
		testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
		if i%2 == 0 {
			swapTo(cur, false, tickSpacing+1)
		} else {
			swapTo(cur, true, tickSpacing-1)
		}
	}
}

func measureNextCross(cur realm, historyCrosses int32) {
	testing.SkipHeights(1)
	zeroForOne := historyCrosses%2 != 0
	targetTick := tickSpacing + 1
	if zeroForOne {
		targetTick = tickSpacing - 1
	}
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	metric.PrintMetricsBy("Swap (1 staked tick-cross after "+strconv.Itoa(int(historyCrosses))+" prior tick checkpoints)", func() {
		pl.Swap(cross(cur), barPath, bazPath, poolFee, admin, zeroForOne, "100000000", gnsmath.TickMathGetSqrtRatioAtTick(targetTick).ToString(), func(cur realm, amount0Delta, amount1Delta int64, _ *pl.CallbackMarker) error {
			testing.SetRealm(userRealm)
			if amount0Delta > 0 {
				common.SafeGRC20Transfer(0, cur, barPath, poolAddress, amount0Delta)
			}
			if amount1Delta > 0 {
				common.SafeGRC20Transfer(0, cur, bazPath, poolAddress, amount1Delta)
			}
			return nil
		})
	})
}

func swapTo(cur realm, zeroForOne bool, targetTick int32) {
    pl.Swap(cross(cur), barPath, bazPath, poolFee, admin, zeroForOne, "100000000", gnsmath.TickMathGetSqrtRatioAtTick(targetTick).ToString(), func(cur realm, amount0Delta, amount1Delta int64, _ *pl.CallbackMarker) error {
        testing.SetRealm(userRealm)
        if amount0Delta > 0 {
            common.SafeGRC20Transfer(0, cur, barPath, poolAddress, amount0Delta)
        }
        if amount1Delta > 0 {
            common.SafeGRC20Transfer(0, cur, bazPath, poolAddress, amount1Delta)
        }
        return nil
    })
}
