// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and storage metrics for the persisted staker Tick staked-liquidity-gross field.
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	"gno.land/p/gnoswap/gnsmath"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gnft"
	pl "gno.land/r/gnoswap/pool"
	_ "gno.land/r/gnoswap/pool/v1"
	pn "gno.land/r/gnoswap/position"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/router"
	_ "gno.land/r/gnoswap/router/v1"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/scenarioutils"
	sr "gno.land/r/gnoswap/staker"
	_ "gno.land/r/gnoswap/staker/v1"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
)

const (
	tickGrossFee      uint32 = 3000
	tickGrossMax      int64  = 9223372036854775807
	tickGrossDeadline int64  = 9999999999
	tickGrossLower    int32  = 60
	tickGrossUpper    int32  = 6000
)

var (
	tickGrossAdmin, _  = access.GetAddress(prabc.ROLE_ADMIN.String())
	tickGrossRealm     = testing.NewUserRealm(tickGrossAdmin)
	tickGrossPool, _   = access.GetAddress(prabc.ROLE_POOL.String())
	tickGrossStaker, _ = access.GetAddress(prabc.ROLE_STAKER.String())
	tickGrossRouter, _ = access.GetAddress(prabc.ROLE_ROUTER.String())

	tickGrossPoolPath = "gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/baz.BAZ:3000"
	tickGrossBarPath  = "gno.land/r/onbloc/bar.BAR"
	tickGrossBazPath  = "gno.land/r/onbloc/baz.BAZ"
)

func main(cur realm) {
	setupTickGross(cur)
	mintTickGrossPositions(cur)
	stakeTickGrossPositions(cur)
	crossTickGrossMetric(cur)
	unstakeTickGrossMetric(cur)
}

func setupTickGross(cur realm) {
	testing.SetRealm(tickGrossRealm)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	emission.ChangeDistributionPct(cross(cur), 7500, 2500, 0, 0)
	pl.SetPoolCreationFee(cross(cur), 0)
	sr.SetUnStakingFee(cross(cur), 0)
	testing.SkipHeights(1)
	emission.MintAndDistributeGns(cross(cur))
	pl.CreatePool(cross(cur), tickGrossBarPath, tickGrossBazPath, tickGrossFee, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	sr.SetPoolTier(cross(cur), tickGrossPoolPath, 1)
	bar.Approve(cross(cur), tickGrossPool, tickGrossMax)
	baz.Approve(cross(cur), tickGrossPool, tickGrossMax)
	bar.Approve(cross(cur), tickGrossRouter, tickGrossMax)
	baz.Approve(cross(cur), tickGrossRouter, tickGrossMax)
}

func mintTickGrossPositions(cur realm) {
	testing.SetRealm(tickGrossRealm)
	// This broad position supplies active pool liquidity for the crossing swap.
	pn.Mint(cross(cur), tickGrossBarPath, tickGrossBazPath, tickGrossFee, -6000, 6000, "50000000", "50000000", "0", "0", tickGrossDeadline, tickGrossAdmin, "")
	// Two staked positions share both boundaries, so the lower tick's gross changes twice.
	for i := 0; i < 2; i++ {
		pn.Mint(cross(cur), tickGrossBarPath, tickGrossBazPath, tickGrossFee, tickGrossLower, tickGrossUpper, "1000000", "0", "0", "0", tickGrossDeadline, tickGrossAdmin, "")
	}
}

func stakeTickGrossPositions(cur realm) {
	testing.SetRealm(tickGrossRealm)
	gnft.Approve(cross(cur), tickGrossStaker, grc721.TokenID(strconv.Itoa(2)))
	metric.PrintMetricsBy("Remaining staker tick gross allocation first boundary StakeToken", func() {
		sr.StakeToken(cross(cur), 2, "")
	})

	gnft.Approve(cross(cur), tickGrossStaker, grc721.TokenID(strconv.Itoa(3)))
	metric.PrintMetricsBy("Remaining staker tick gross allocation shared boundary StakeToken", func() {
		sr.StakeToken(cross(cur), 3, "")
	})

	initialized, err := pl.GetTickInitialized(tickGrossPoolPath, tickGrossLower)
	if err != nil {
		panic(err)
	}
	gross, err := pl.GetTickLiquidityGross(tickGrossPoolPath, tickGrossLower)
	if err != nil {
		panic(err)
	}
	println("- State: lower_tick_initialized=" + strconv.FormatBool(initialized) + " lower_tick_gross=" + gross)
}

func crossTickGrossMetric(cur realm) {
	testing.SetRealm(tickGrossRealm)
	runTickGrossSwap(cur, false, tickGrossLower+1, "Remaining staker tick gross repeat crossing 1 call 1")
	for _, count := range []int{10, 100} {
		for i := 0; i < count; i++ {
			zeroForOne := i%2 == 0
			target := tickGrossLower + 1
			if zeroForOne {
				target = tickGrossLower - 1
			}
			runTickGrossSwap(cur, zeroForOne, target, "Remaining staker tick gross repeat crossing "+strconv.Itoa(count)+" call "+strconv.Itoa(i+1))
		}
	}

	slot, err := pl.GetSlot0Tick(tickGrossPoolPath)
	if err != nil {
		panic(err)
	}
	if slot < tickGrossLower {
		panic("swap did not cross shared staked boundary")
	}
	initialized, err := pl.GetTickInitialized(tickGrossPoolPath, tickGrossLower)
	if err != nil {
		panic(err)
	}
	println("- State: slot0_tick=" + strconv.Itoa(int(slot)) + " lower_tick_initialized=" + strconv.FormatBool(initialized))
}

func runTickGrossSwap(cur realm, zeroForOne bool, targetTick int32, label string) {
	input, output := tickGrossBazPath, tickGrossBarPath
	if zeroForOne {
		input, output = tickGrossBarPath, tickGrossBazPath
	}
	route := input + ":" + output + ":3000"
	metric.PrintMetricsBy(label, func() {
		router.ExactInSingleSwapRoute(cross(cur), input, output, "100000000", route, "0", gnsmath.TickMathGetSqrtRatioAtTick(targetTick).ToString(), tickGrossDeadline, "")
	})
}

func unstakeTickGrossMetric(cur realm) {
	testing.SetRealm(tickGrossRealm)
	metric.PrintMetricsBy("Remaining staker tick gross lifecycle UnStakeToken", func() {
		sr.UnStakeToken(cross(cur), 2)
		sr.UnStakeToken(cross(cur), 3)
	})
	if sr.IsStaked(2) || sr.IsStaked(3) {
		panic("staked positions remained after UnStakeToken")
	}
	poolLiquidity, err := sr.GetPoolStakedLiquidity(tickGrossPoolPath)
	if err != nil {
		panic(err)
	}
	println("- State: position2_staked=false position3_staked=false pool_staked=" + poolLiquidity)
}
