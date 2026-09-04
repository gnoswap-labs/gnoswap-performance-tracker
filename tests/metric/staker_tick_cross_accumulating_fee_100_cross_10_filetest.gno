// PKGPATH: gno.land/r/gnoswap/v1/main

// Fee-tier metric for a reward-accumulated swap crossing initialized, staked ticks.

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
    crossCount int32 = 10
    tickSpacing int32 = 1
    poolFee uint32 = 100
    maxAmount int64 = 9223372036854775807
    amountLimit int64 = 9999999999
)

var (
    admin, _ = access.GetAddress(prbac.ROLE_ADMIN.String())
    userRealm = testing.NewUserRealm(admin)
    poolAddress, _ = access.GetAddress(prbac.ROLE_POOL.String())
    stakerAddress, _ = access.GetAddress(prbac.ROLE_STAKER.String())
    poolPath = "gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/baz.BAZ:100"
    barPath = "gno.land/r/onbloc/bar.BAR"
    bazPath = "gno.land/r/onbloc/baz.BAZ"
)

func main(cur realm) {
    setup(cur)
    mintLiquidity(cur)
    stakePositions(cur)
    testing.SkipHeights(1)
    runSwap(cur)
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

func stakePositions(cur realm) {
    testing.SetRealm(userRealm)
    activeTokenID, _, _, _ := pn.Mint(cross(cur), barPath, bazPath, poolFee, -6000, 6000, "1000000", "1000000", "0", "0", amountLimit, admin, "")
    gnft.Approve(cross(cur), stakerAddress, grc721.TokenID(strconv.FormatUint(activeTokenID, 10)))
    sr.StakeToken(cross(cur), activeTokenID, "")
    for i := int32(1); i <= crossCount; i++ {
        tickLower := i * tickSpacing
        tokenID, _, _, _ := pn.Mint(cross(cur), barPath, bazPath, poolFee, tickLower, 6000, "1000000", "0", "0", "0", amountLimit, admin, "")
        gnft.Approve(cross(cur), stakerAddress, grc721.TokenID(strconv.FormatUint(tokenID, 10)))
        sr.StakeToken(cross(cur), tokenID, "")
    }
}

func runSwap(cur realm) {
    targetTick := crossCount*tickSpacing + 1
    testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
    metric.PrintMetricsBy("Swap (fee 100, 10 staked tick-crosses after accumulation)", func() {
        pl.Swap(cross(cur), barPath, bazPath, poolFee, admin, false, "100000000", gnsmath.TickMathGetSqrtRatioAtTick(targetTick).ToString(), func(cur realm, amount0Delta, amount1Delta int64, _ *pl.CallbackMarker) error {
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
    tick, _ := pl.GetSlot0Tick(poolPath)
    if tick < crossCount*tickSpacing || tick > targetTick {
        panic("swap did not cross the requested initialized ticks")
    }
}
