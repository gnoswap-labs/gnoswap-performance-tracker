// PKGPATH: gno.land/r/gnoswap/v1/main

// Gas metrics for a long history of ten initialized, staked tick-crosses.
// Thirty-three target swaps are separated by 600 seconds, alternating forward
// and reverse visits so the same checkpoints are revisited with accumulated
// rewards.
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	"gno.land/p/gnoswap/gnsmath"
	prbac "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/ufmt/v0"
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
	tickCrossCount        int32  = 10
	tickSpacing           int32  = 60
	tickCrossFee          uint32 = 3000
	tickCrossMax          int64  = 9223372036854775807
	tickCrossLimit        int64  = 9999999999
	historyVisitCount     int32  = 33
	rewardIntervalHeights int64  = 120 // 600 seconds at five seconds per height
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

	for visit := int32(1); visit <= historyVisitCount; visit++ {
		testing.SkipHeights(rewardIntervalHeights)
		if visit%2 == 1 {
			runTickCrossSwapMetric(cur, visit)
		} else {
			runReverseMetric(cur, visit)
		}
	}
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
	baseID, _, _, _ := pn.Mint(cross(cur), tickCrossBarPath, tickCrossBazPath, tickCrossFee, -6000, 6000, "50000000", "50000000", "0", "0", tickCrossLimit, tickCrossAdmin, "")
	gnft.Approve(cross(cur), tickCrossStaker, grc721.TokenID(strconv.FormatUint(baseID, 10)))
	sr.StakeToken(cross(cur), baseID, "")
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

func runTickCrossSwapMetric(cur realm, visit int32) {
	targetTick := tickCrossCount*tickSpacing + 1
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	metric.PrintMetricsBy(ufmt.Sprintf("Long-history accumulated-reward Swap (%d staked tick-crosses, visit %d)", tickCrossCount, visit), func() {
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
		panic("swap did not cross exactly ten initialized staked ticks")
	}
}

func runReverseMetric(cur realm, visit int32) {
	targetTick := int32(1)
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	metric.PrintMetricsBy(ufmt.Sprintf("Long-history accumulated-reward Reverse swap (%d staked tick-crosses, visit %d)", tickCrossCount, visit), func() {
		pl.Swap(cross(cur), tickCrossBarPath, tickCrossBazPath, tickCrossFee, tickCrossAdmin, true, "100000000", gnsmath.TickMathGetSqrtRatioAtTick(targetTick).ToString(), func(cur realm, amount0Delta, amount1Delta int64, _ *pl.CallbackMarker) error {
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
	if tick != targetTick {
		panic("reverse swap did not return to tick 1")
	}
}

// Output:
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 1)
// - Gas Used: 110358552
// - Storage Diff: 34662
// - CPU Cycles: 105714270
// - Realm gno.land/r/gnoswap/pool: 820
// - Realm gno.land/r/gnoswap/pool/v1: -6
// - Realm gno.land/r/gnoswap/staker: 33848
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 2)
// - Gas Used: 131917735
// - Storage Diff: 15195
// - CPU Cycles: 127223844
// - Realm gno.land/r/gnoswap/pool: 321
// - Realm gno.land/r/gnoswap/staker: 14872
// - Realm gno.land/r/onbloc/bar: 2
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 3)
// - Gas Used: 132794959
// - Storage Diff: 14651
// - CPU Cycles: 128106024
// - Realm gno.land/r/gnoswap/pool: 18
// - Realm gno.land/r/gnoswap/staker: 14632
// - Realm gno.land/r/onbloc/bar: 1
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 4)
// - Gas Used: 137012073
// - Storage Diff: 14630
// - CPU Cycles: 132289101
// - Realm gno.land/r/gnoswap/pool: -2
// - Realm gno.land/r/gnoswap/staker: 14632
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 5)
// - Gas Used: 134206868
// - Storage Diff: 57442
// - CPU Cycles: 129292266
// - Realm gno.land/r/gnoswap/pool: 4
// - Realm gno.land/r/gnoswap/staker: 57438
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 6)
// - Gas Used: 137642343
// - Storage Diff: 15209
// - CPU Cycles: 132826340
// - Realm gno.land/r/gnoswap/pool: -4
// - Realm gno.land/r/gnoswap/staker: 15213
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 7)
// - Gas Used: 133747407
// - Storage Diff: 14740
// - CPU Cycles: 128952423
// - Realm gno.land/r/gnoswap/pool: 7
// - Realm gno.land/r/gnoswap/staker: 14733
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 8)
// - Gas Used: 138800911
// - Storage Diff: 35395
// - CPU Cycles: 133831701
// - Realm gno.land/r/gnoswap/pool: -2
// - Realm gno.land/r/gnoswap/staker: 35397
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 9)
// - Gas Used: 133752928
// - Storage Diff: 14981
// - CPU Cycles: 128953598
// - Realm gno.land/r/gnoswap/pool: 7
// - Realm gno.land/r/gnoswap/staker: 14974
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 10)
// - Gas Used: 137858914
// - Storage Diff: 14736
// - CPU Cycles: 133025666
// - Realm gno.land/r/gnoswap/pool: -4
// - Realm gno.land/r/gnoswap/staker: 14734
// - Realm gno.land/r/onbloc/baz: 6
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 11)
// - Gas Used: 134934670
// - Storage Diff: 35356
// - CPU Cycles: 129981023
// - Realm gno.land/r/gnoswap/pool: 8
// - Realm gno.land/r/gnoswap/staker: 35334
// - Realm gno.land/r/onbloc/baz: 14
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 12)
// - Gas Used: 137987864
// - Storage Diff: 14970
// - CPU Cycles: 133150315
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 14975
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 13)
// - Gas Used: 134071938
// - Storage Diff: 14742
// - CPU Cycles: 129255383
// - Realm gno.land/r/gnoswap/pool: 7
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 14)
// - Gas Used: 140531225
// - Storage Diff: 80756
// - CPU Cycles: 135323964
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 80761
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 15)
// - Gas Used: 134569134
// - Storage Diff: 15463
// - CPU Cycles: 129663660
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 15455
// - Realm gno.land/r/onbloc/baz: 2
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 16)
// - Gas Used: 138644373
// - Storage Diff: 14731
// - CPU Cycles: 133705021
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 14735
// - Realm gno.land/r/onbloc/baz: 1
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 17)
// - Gas Used: 135717654
// - Storage Diff: 35401
// - CPU Cycles: 130657938
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 35395
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 18)
// - Gas Used: 138697302
// - Storage Diff: 14970
// - CPU Cycles: 133753712
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 14975
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 19)
// - Gas Used: 134717858
// - Storage Diff: 14751
// - CPU Cycles: 129795217
// - Realm gno.land/r/gnoswap/pool: 16
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 20)
// - Gas Used: 141258264
// - Storage Diff: 58739
// - CPU Cycles: 136017090
// - Realm gno.land/r/gnoswap/pool: -16
// - Realm gno.land/r/gnoswap/staker: 58755
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 21)
// - Gas Used: 134632688
// - Storage Diff: 15232
// - CPU Cycles: 129711988
// - Realm gno.land/r/gnoswap/pool: 17
// - Realm gno.land/r/gnoswap/staker: 15215
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 22)
// - Gas Used: 138815750
// - Storage Diff: 14719
// - CPU Cycles: 133861213
// - Realm gno.land/r/gnoswap/pool: -16
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 23)
// - Gas Used: 135785129
// - Storage Diff: 35412
// - CPU Cycles: 130710190
// - Realm gno.land/r/gnoswap/pool: 17
// - Realm gno.land/r/gnoswap/staker: 35395
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 24)
// - Gas Used: 138889042
// - Storage Diff: 14969
// - CPU Cycles: 133930218
// - Realm gno.land/r/gnoswap/pool: -6
// - Realm gno.land/r/gnoswap/staker: 14975
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 25)
// - Gas Used: 134947835
// - Storage Diff: 14741
// - CPU Cycles: 130010006
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 26)
// - Gas Used: 141357784
// - Storage Diff: 58689
// - CPU Cycles: 136100430
// - Realm gno.land/r/gnoswap/pool: -6
// - Realm gno.land/r/gnoswap/staker: 58695
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 27)
// - Gas Used: 134869452
// - Storage Diff: 15221
// - CPU Cycles: 129933573
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 15215
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 28)
// - Gas Used: 138959464
// - Storage Diff: 14729
// - CPU Cycles: 133989720
// - Realm gno.land/r/gnoswap/pool: -6
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 29)
// - Gas Used: 136029277
// - Storage Diff: 35401
// - CPU Cycles: 130939168
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 35395
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 30)
// - Gas Used: 138992524
// - Storage Diff: 14969
// - CPU Cycles: 134018550
// - Realm gno.land/r/gnoswap/pool: -6
// - Realm gno.land/r/gnoswap/staker: 14975
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 31)
// - Gas Used: 135084136
// - Storage Diff: 14741
// - CPU Cycles: 130131157
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 32)
// - Gas Used: 142898398
// - Storage Diff: 104110
// - CPU Cycles: 137409074
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 104115
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 33)
// - Gas Used: 135459299
// - Storage Diff: 15715
// - CPU Cycles: 130420055
// - Realm gno.land/r/gnoswap/pool: 20
// - Realm gno.land/r/gnoswap/staker: 15695
