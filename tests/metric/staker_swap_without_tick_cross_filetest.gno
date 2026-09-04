// PKGPATH: gno.land/r/gnoswap/v1/main

// Gas metric for a swap in a staked pool that does not cross a staked boundary.
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
	noCrossTickSpacing int32  = 60
	noCrossFee         uint32 = 3000
	noCrossMax         int64  = 9223372036854775807
	noCrossLimit       int64  = 9999999999
)

var (
	noCrossAdmin, _  = access.GetAddress(prbac.ROLE_ADMIN.String())
	noCrossRealm     = testing.NewUserRealm(noCrossAdmin)
	noCrossPool, _   = access.GetAddress(prbac.ROLE_POOL.String())
	noCrossStaker, _ = access.GetAddress(prbac.ROLE_STAKER.String())
	noCrossPoolPath  = "gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/baz.BAZ:3000"
	noCrossBarPath   = "gno.land/r/onbloc/bar.BAR"
	noCrossBazPath   = "gno.land/r/onbloc/baz.BAZ"
)

func main(cur realm) {
	setupNoCrossMetric(cur)
	mintNoCrossLiquidity(cur)
	stakeNoCrossPosition(cur)
	runNoCrossSwapMetric(cur)
}

func setupNoCrossMetric(cur realm) {
	testing.SetRealm(noCrossRealm)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	emission.ChangeDistributionPct(cross(cur), 7500, 2500, 0, 0)
	pl.SetPoolCreationFee(cross(cur), 0)
	sr.SetUnStakingFee(cross(cur), 0)
	testing.SkipHeights(1)
	emission.MintAndDistributeGns(cross(cur))
	pl.CreatePool(cross(cur), noCrossBarPath, noCrossBazPath, noCrossFee, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	sr.SetPoolTier(cross(cur), noCrossPoolPath, 1)
	bar.Approve(cross(cur), noCrossPool, noCrossMax)
	baz.Approve(cross(cur), noCrossPool, noCrossMax)
}

func mintNoCrossLiquidity(cur realm) {
	testing.SetRealm(noCrossRealm)
	pn.Mint(cross(cur), noCrossBarPath, noCrossBazPath, noCrossFee, -6000, 6000, "50000000", "50000000", "0", "0", noCrossLimit, noCrossAdmin, "")
}

func stakeNoCrossPosition(cur realm) {
	testing.SetRealm(noCrossRealm)
	tokenID, _, _, _ := pn.Mint(cross(cur), noCrossBarPath, noCrossBazPath, noCrossFee, noCrossTickSpacing, 6000, "1000000", "0", "0", "0", noCrossLimit, noCrossAdmin, "")
	gnft.Approve(cross(cur), noCrossStaker, grc721.TokenID(strconv.FormatUint(tokenID, 10)))
	sr.StakeToken(cross(cur), tokenID, "")
}

func runNoCrossSwapMetric(cur realm) {
	targetTick := noCrossTickSpacing - 1
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	metric.PrintMetricsBy("Swap (staked pool, no staked tick-cross)", func() {
		pl.Swap(cross(cur), noCrossBarPath, noCrossBazPath, noCrossFee, noCrossAdmin, false, "100000000", gnsmath.TickMathGetSqrtRatioAtTick(targetTick).ToString(), func(cur realm, amount0Delta, amount1Delta int64, _ *pl.CallbackMarker) error {
			testing.SetRealm(noCrossRealm)
			if amount0Delta > 0 {
				common.SafeGRC20Transfer(0, cur, noCrossBarPath, noCrossPool, amount0Delta)
			}
			if amount1Delta > 0 {
				common.SafeGRC20Transfer(0, cur, noCrossBazPath, noCrossPool, amount1Delta)
			}
			return nil
		})
	})
	tick, _ := pl.GetSlot0Tick(noCrossPoolPath)
	if tick < 0 || tick >= noCrossTickSpacing {
		panic("swap crossed a staked tick")
	}
}
