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
// - Gas Used: 110239052
// - Storage Diff: 34662
// - CPU Cycles: 105610490
// - Realm gno.land/r/gnoswap/pool: 820
// - Realm gno.land/r/gnoswap/pool/v1: -6
// - Realm gno.land/r/gnoswap/staker: 33848
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 2)
// - Gas Used: 131798241
// - Storage Diff: 15195
// - CPU Cycles: 127120064
// - Realm gno.land/r/gnoswap/pool: 321
// - Realm gno.land/r/gnoswap/staker: 14872
// - Realm gno.land/r/onbloc/bar: 2
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 3)
// - Gas Used: 132675459
// - Storage Diff: 14651
// - CPU Cycles: 128002244
// - Realm gno.land/r/gnoswap/pool: 18
// - Realm gno.land/r/gnoswap/staker: 14632
// - Realm gno.land/r/onbloc/bar: 1
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 4)
// - Gas Used: 136892573
// - Storage Diff: 14630
// - CPU Cycles: 132185321
// - Realm gno.land/r/gnoswap/pool: -2
// - Realm gno.land/r/gnoswap/staker: 14632
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 5)
// - Gas Used: 134087458
// - Storage Diff: 57472
// - CPU Cycles: 129188486
// - Realm gno.land/r/gnoswap/pool: 4
// - Realm gno.land/r/gnoswap/staker: 57468
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 6)
// - Gas Used: 137522897
// - Storage Diff: 15210
// - CPU Cycles: 132722560
// - Realm gno.land/r/gnoswap/pool: -4
// - Realm gno.land/r/gnoswap/staker: 15214
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 7)
// - Gas Used: 133627961
// - Storage Diff: 14741
// - CPU Cycles: 128848643
// - Realm gno.land/r/gnoswap/pool: 7
// - Realm gno.land/r/gnoswap/staker: 14734
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 8)
// - Gas Used: 138681468
// - Storage Diff: 35392
// - CPU Cycles: 133727921
// - Realm gno.land/r/gnoswap/pool: -2
// - Realm gno.land/r/gnoswap/staker: 35394
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 9)
// - Gas Used: 133633446
// - Storage Diff: 14981
// - CPU Cycles: 128849818
// - Realm gno.land/r/gnoswap/pool: 7
// - Realm gno.land/r/gnoswap/staker: 14974
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 10)
// - Gas Used: 137739432
// - Storage Diff: 14736
// - CPU Cycles: 132921886
// - Realm gno.land/r/gnoswap/pool: -4
// - Realm gno.land/r/gnoswap/staker: 14734
// - Realm gno.land/r/onbloc/baz: 6
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 11)
// - Gas Used: 134815194
// - Storage Diff: 35357
// - CPU Cycles: 129877243
// - Realm gno.land/r/gnoswap/pool: 8
// - Realm gno.land/r/gnoswap/staker: 35335
// - Realm gno.land/r/onbloc/baz: 14
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 12)
// - Gas Used: 137868382
// - Storage Diff: 14970
// - CPU Cycles: 133046535
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 14975
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 13)
// - Gas Used: 133952456
// - Storage Diff: 14742
// - CPU Cycles: 129151603
// - Realm gno.land/r/gnoswap/pool: 7
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 14)
// - Gas Used: 140411746
// - Storage Diff: 80752
// - CPU Cycles: 135220184
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 80757
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 15)
// - Gas Used: 134449634
// - Storage Diff: 15463
// - CPU Cycles: 129559880
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 15455
// - Realm gno.land/r/onbloc/baz: 2
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 16)
// - Gas Used: 138524873
// - Storage Diff: 14731
// - CPU Cycles: 133601241
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 14735
// - Realm gno.land/r/onbloc/baz: 1
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 17)
// - Gas Used: 135598154
// - Storage Diff: 35401
// - CPU Cycles: 130554158
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 35395
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 18)
// - Gas Used: 138577802
// - Storage Diff: 14970
// - CPU Cycles: 133649932
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 14975
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 19)
// - Gas Used: 134598358
// - Storage Diff: 14751
// - CPU Cycles: 129691437
// - Realm gno.land/r/gnoswap/pool: 16
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 20)
// - Gas Used: 141138770
// - Storage Diff: 58739
// - CPU Cycles: 135913310
// - Realm gno.land/r/gnoswap/pool: -16
// - Realm gno.land/r/gnoswap/staker: 58755
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 21)
// - Gas Used: 134513188
// - Storage Diff: 15232
// - CPU Cycles: 129608208
// - Realm gno.land/r/gnoswap/pool: 17
// - Realm gno.land/r/gnoswap/staker: 15215
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 22)
// - Gas Used: 138696250
// - Storage Diff: 14719
// - CPU Cycles: 133757433
// - Realm gno.land/r/gnoswap/pool: -16
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 23)
// - Gas Used: 135665629
// - Storage Diff: 35412
// - CPU Cycles: 130606410
// - Realm gno.land/r/gnoswap/pool: 17
// - Realm gno.land/r/gnoswap/staker: 35395
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 24)
// - Gas Used: 138769542
// - Storage Diff: 14969
// - CPU Cycles: 133826438
// - Realm gno.land/r/gnoswap/pool: -6
// - Realm gno.land/r/gnoswap/staker: 14975
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 25)
// - Gas Used: 134828335
// - Storage Diff: 14741
// - CPU Cycles: 129906226
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 26)
// - Gas Used: 141238284
// - Storage Diff: 58689
// - CPU Cycles: 135996650
// - Realm gno.land/r/gnoswap/pool: -6
// - Realm gno.land/r/gnoswap/staker: 58695
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 27)
// - Gas Used: 134749952
// - Storage Diff: 15221
// - CPU Cycles: 129829793
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 15215
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 28)
// - Gas Used: 138839964
// - Storage Diff: 14729
// - CPU Cycles: 133885940
// - Realm gno.land/r/gnoswap/pool: -6
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 29)
// - Gas Used: 135909777
// - Storage Diff: 35401
// - CPU Cycles: 130835388
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 35395
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 30)
// - Gas Used: 138873024
// - Storage Diff: 14969
// - CPU Cycles: 133914770
// - Realm gno.land/r/gnoswap/pool: -6
// - Realm gno.land/r/gnoswap/staker: 14975
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 31)
// - Gas Used: 134964636
// - Storage Diff: 14741
// - CPU Cycles: 130027377
// - Realm gno.land/r/gnoswap/pool: 6
// - Realm gno.land/r/gnoswap/staker: 14735
// Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 32)
// - Gas Used: 142778898
// - Storage Diff: 104110
// - CPU Cycles: 137305294
// - Realm gno.land/r/gnoswap/pool: -5
// - Realm gno.land/r/gnoswap/staker: 104115
// Long-history accumulated-reward Swap (10 staked tick-crosses, visit 33)
// - Gas Used: 135339799
// - Storage Diff: 15715
// - CPU Cycles: 130316275
// - Realm gno.land/r/gnoswap/pool: 20
// - Realm gno.land/r/gnoswap/staker: 15695
