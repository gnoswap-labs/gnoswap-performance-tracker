// PKGPATH: gno.land/r/gnoswap/v1/main

// Gas metric for fifty initialized, staked tick-crosses within a constant reward-rate interval.

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
	tickCrossCount int32  = 50
	tickSpacing    int32  = 60
	tickCrossFee   uint32 = 3000
	tickCrossMax   int64  = 9223372036854775807
	tickCrossLimit int64  = 9999999999
)

var (
	tickCrossAdmin, _  = access.GetAddress(prbac.ROLE_ADMIN.String())
	tickCrossRealm     = testing.NewUserRealm(tickCrossAdmin)
	tickCrossPool, _   = access.GetAddress(prbac.ROLE_POOL.String())
	tickCrossStaker, _ = access.GetAddress(prbac.ROLE_STAKER.String())
	tickCrossPoolPath  = "gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/baz.BAZ:3000"
	tickCrossBarPath   = "gno.land/r/onbloc/bar.BAR"
	tickCrossBazPath   = "gno.land/r/onbloc/baz.BAZ"
)

func main(cur realm) {
	setupTickCrossMetric(cur)
	mintTickCrossLiquidity(cur)
	stakeTickCrossPositions(cur)
	runTickCrossSwapMetric(cur)
}

func setupTickCrossMetric(cur realm) {
	testing.SetRealm(tickCrossRealm)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	emission.ChangeDistributionPct(cross(cur), 7500, 2500, 0, 0)
	pl.SetPoolCreationFee(cross(cur), 0)
	sr.SetUnStakingFee(cross(cur), 0)
	testing.SkipHeights(1)
	emission.MintAndDistributeGns(cross(cur))
	pl.CreatePool(cross(cur), tickCrossBarPath, tickCrossBazPath, tickCrossFee, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	sr.SetPoolTier(cross(cur), tickCrossPoolPath, 1)
	bar.Approve(cross(cur), tickCrossPool, tickCrossMax)
	baz.Approve(cross(cur), tickCrossPool, tickCrossMax)
}

func mintTickCrossLiquidity(cur realm) {
	testing.SetRealm(tickCrossRealm)
	pn.Mint(cross(cur), tickCrossBarPath, tickCrossBazPath, tickCrossFee, -6000, 6000, "50000000", "50000000", "0", "0", tickCrossLimit, tickCrossAdmin, "")
}

func stakeTickCrossPositions(cur realm) {
	testing.SetRealm(tickCrossRealm)
	for i := int32(1); i <= tickCrossCount; i++ {
		tickLower := i * tickSpacing
		tokenID, _, _, _ := pn.Mint(cross(cur), tickCrossBarPath, tickCrossBazPath, tickCrossFee, tickLower, 6000, "1000000", "0", "0", "0", tickCrossLimit, tickCrossAdmin, "")
		gnft.Approve(cross(cur), tickCrossStaker, grc721.TokenID(strconv.FormatUint(tokenID, 10)))
		sr.StakeToken(cross(cur), tokenID, "")
	}
}

func runTickCrossSwapMetric(cur realm) {
	targetTick := tickCrossCount*tickSpacing + 1
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	metric.PrintMetricsBy("Swap (no halving, 50 staked tick-crosses)", func() {
		pl.Swap(cross(cur), tickCrossBarPath, tickCrossBazPath, tickCrossFee, tickCrossAdmin, false, "100000000", gnsmath.TickMathGetSqrtRatioAtTick(targetTick).ToString(), func(cur realm, amount0Delta, amount1Delta int64, _ *pl.CallbackMarker) error {
			testing.SetRealm(tickCrossRealm)
			if amount0Delta > 0 {
				common.SafeGRC20Transfer(0, cur, tickCrossBarPath, tickCrossPool, amount0Delta)
			}
			if amount1Delta > 0 {
				common.SafeGRC20Transfer(0, cur, tickCrossBazPath, tickCrossPool, amount1Delta)
			}
			return nil
		})
	})
	tick, _ := pl.GetSlot0Tick(tickCrossPoolPath)
	if tick < tickCrossCount*tickSpacing || tick >= (tickCrossCount+1)*tickSpacing {
		panic("swap did not cross exactly fifty initialized staked ticks")
	}
}
