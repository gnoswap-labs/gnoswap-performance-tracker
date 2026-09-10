// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Real-contract PoC for value-backed staker numerics. The fixture exercises
// deposit creation and repeated updates, signed tick crossing, and external
// incentive creation/collection/refund before deleting every deposit.
//
// The 32-position lower-tick ladder plus one wide position measures all 33
// allocations while keeping this single lifecycle executable; the high reward
// amount remains below the BAR fixture's finite 100T supply.
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	"gno.land/p/gnoswap/gnsmath"
	prbac "gno.land/p/gnoswap/rbac"
	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/gns"
	pl "gno.land/r/gnoswap/pool"
	_ "gno.land/r/gnoswap/pool/v1"
	"gno.land/r/gnoswap/position"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/scenarioutils"
	"gno.land/r/gnoswap/staker"
	_ "gno.land/r/gnoswap/staker/v1"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"
)

const (
	numericBoundaryCount  int32  = 32
	numericTickSpacing    int32  = 60
	numericBoundaryUpper  int32  = 6000
	numericWideAmount     string = "500000000"
	numericBoundaryAmount string = "1000000"
	numericRewardAmount   int64  = 90000000000000
	numericUnstakingFee   uint64 = 100 // 1% protocol fee on paid rewards
)

var (
	adminAddr, _ = access.GetAddress(prbac.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prbac.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prbac.ROLE_STAKER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath  = "gno.land/r/onbloc/bar.BAR"
	fooPath  = "gno.land/r/onbloc/foo.FOO"
	poolPath = barPath + ":" + fooPath + ":3000"

	maxInt64 int64 = 9223372036854775807

	widePositionID     uint64
	narrowPositionID   uint64
	numericPositionIDs []uint64
	incentiveID        string
	incentiveStart     int64
	incentiveEnd       int64
)

func main(cur realm) {
	printStakerNumericClock("staker_setup_before")
	initializeStakerNumericSetup(cur)
	printStakerNumericClock("staker_setup_after")
	createStakerNumericPool(cur)
	printStakerNumericClock("staker_pool_after")
	mintStakerNumericPositions(cur)
	printStakerNumericClock("staker_mint_after")
	stakeStakerNumericPositions(cur)
	printStakerNumericClock("staker_stake_phase_after")
	measureStakerNumericDeposits(cur)
	printStakerNumericClock("staker_collect_phase_after")
	measureStakerNumericTicks(cur)
	printStakerNumericClock("staker_tick_phase_after")
	measureStakerNumericIncentive(cur)
	printStakerNumericClock("staker_lifecycle_after")
}

func initializeStakerNumericSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pl.SetPoolCreationFee(cross(cur), 0)
	staker.SetUnStakingFee(cross(cur), numericUnstakingFee)
	if staker.GetUnstakingFee() != numericUnstakingFee {
		panic("staker unstaking fee was not configured")
	}
	warmupTemplate := staker.GetWarmupTemplate()
	if len(warmupTemplate) == 0 {
		panic("staker warmup template was not configured")
	}
	println(ufmt.Sprintf("STATE staker-numerics config unstaking_fee=%d warmup_tiers=%d", staker.GetUnstakingFee(), len(warmupTemplate)))
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))

	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(1)
	_, distributed := emission.MintAndDistributeGns(cross(cur))
	if !distributed {
		panic("GNS distribution did not execute")
	}

	bar.Transfer(cross(cur), aliceAddr, 2000000000)
	foo.Transfer(cross(cur), aliceAddr, 2000000000)

	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64)
}

func createStakerNumericPool(cur realm) {
	testing.SetRealm(adminRealm)
	pl.CreatePool(cross(cur), barPath, fooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	staker.SetPoolTier(cross(cur), poolPath, 1)
}

func mintStakerNumericPositions(cur realm) {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)

	// Use fee-tier-aligned extremes for the wide record and smaller
	// out-of-range records for the staged lower-tick workload.
	widePositionID, _, _, _ = position.Mint(
		cross(cur), barPath, fooPath, 3000,
		-887220, 887220,
		numericWideAmount, numericWideAmount, "0", "0",
		9999999999, aliceAddr, "",
	)

	numericPositionIDs = make([]uint64, 0, numericBoundaryCount)
	for i := int32(1); i <= numericBoundaryCount; i++ {
		tickLower := i * numericTickSpacing
		positionID, _, _, _ := position.Mint(
			cross(cur), barPath, fooPath, 3000,
			tickLower, numericBoundaryUpper,
			numericBoundaryAmount, "0", "0", "0",
			9999999999, aliceAddr, "",
		)
		numericPositionIDs = append(numericPositionIDs, positionID)
		if i == 1 {
			narrowPositionID = positionID
		}
	}
}

func stakeStakerNumericPositions(cur realm) {
	testing.SetRealm(aliceRealm)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(widePositionID, 10)))
	for _, positionID := range numericPositionIDs {
		gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(positionID, 10)))
	}

	stakeOne := func(label, clockLabel string, positionID uint64) {
		testing.SkipHeights(1)
		printStakerNumericClock(clockLabel + "_before")
		metric.PrintMetricsBy(label, func() {
			staker.StakeToken(cross(cur), positionID, "")
		})
		printStakerNumericClock(clockLabel + "_after")
		if !staker.IsStaked(positionID) {
			panic("position was not staked")
		}
	}

	stakeOne(
		"StakerNumbers deposit stake wide (first allocation)",
		"staker_stake_wide",
		widePositionID,
	)
	stakeOne(
		"StakerNumbers deposit stake boundary (first allocation)",
		"staker_stake_boundary_01",
		numericPositionIDs[0],
	)
	for i := 1; i < len(numericPositionIDs); i++ {
		stakeOne(
			ufmt.Sprintf("StakerNumbers deposit stake boundary allocation %02d/32", i+1),
			ufmt.Sprintf("staker_stake_boundary_%02d", i+1),
			numericPositionIDs[i],
		)
	}

	assertStakerNumericAggregate("after_stake", false)
	printStakerNumericDepositState("after_stake", widePositionID)
	printStakerNumericDepositState("after_stake_boundary_first", narrowPositionID)
	printStakerNumericDepositState("after_stake_boundary_last", numericPositionIDs[len(numericPositionIDs)-1])
}

func measureStakerNumericDeposits(cur realm) {
	testing.SetRealm(aliceRealm)

	collectOne := func(label, clockLabel string, positionID uint64) {
		testing.SkipHeights(1)
		printStakerNumericClock(clockLabel + "_before")
		metric.PrintMetricsBy(label, func() {
			staker.CollectReward(cross(cur), positionID)
		})
		printStakerNumericClock(clockLabel + "_after")
		if !staker.IsStaked(positionID) {
			panic("collect removed the deposit")
		}
	}

	collectOne(
		"StakerNumbers deposit collect",
		"staker_collect_wide",
		widePositionID,
	)
	assertStakerNumericAggregate("after_collect", false)
	printStakerNumericDepositState("after_collect", widePositionID)

	collectOne(
		"StakerNumbers deposit collect repeat",
		"staker_collect_wide_repeat",
		widePositionID,
	)
	assertStakerNumericAggregate("after_collect_repeat", false)
	printStakerNumericDepositState("after_collect_repeat", widePositionID)

	// Rewrite every staged deposit once after its first allocation. Keeping
	// each public call separate isolates value-field rewrites.
	for i, positionID := range numericPositionIDs {
		collectOne(
			ufmt.Sprintf("StakerNumbers deposit collect boundary allocation %02d/32", i+1),
			ufmt.Sprintf("staker_collect_boundary_%02d", i+1),
			positionID,
		)
	}
	assertStakerNumericAggregate("after_batch_collect", false)
	printStakerNumericDepositState("after_batch_collect_boundary_first", narrowPositionID)
	printStakerNumericDepositState("after_batch_collect_boundary_last", numericPositionIDs[len(numericPositionIDs)-1])
}

func stakerNumericSwapCallback(cur realm, amount0Delta, amount1Delta int64, _ *pl.CallbackMarker) error {
	testing.SetRealm(adminRealm)
	if amount0Delta > 0 {
		common.SafeGRC20Transfer(0, cur, barPath, poolAddr, amount0Delta)
	}
	if amount1Delta > 0 {
		common.SafeGRC20Transfer(0, cur, fooPath, poolAddr, amount1Delta)
	}
	return nil
}

func measureStakerNumericTicks(cur realm) {
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
	testing.SkipHeights(1)
	printStakerNumericClock("staker_tick_positive_before")
	metric.PrintMetricsBy("StakerNumbers tick cross positive (32 lower ticks)", func() {
		pl.Swap(
			cross(cur), barPath, fooPath, 3000, adminAddr, false,
			"500000000", gnsmath.TickMathGetSqrtRatioAtTick(numericBoundaryCount*numericTickSpacing+1).ToString(),
			stakerNumericSwapCallback,
		)
	})
	printStakerNumericClock("staker_tick_positive_after")
	currentTick, _ := pl.GetSlot0Tick(poolPath)
	if currentTick < numericBoundaryCount*numericTickSpacing || currentTick >= numericBoundaryUpper {
		panic("positive swap did not activate all staged lower ticks")
	}
	printStakerNumericTickState("after_positive_cross", true)

	testing.SkipHeights(1)
	printStakerNumericClock("staker_tick_upper_before")
	metric.PrintMetricsBy("StakerNumbers tick cross positive upper rewrite", func() {
		pl.Swap(
			cross(cur), barPath, fooPath, 3000, adminAddr, false,
			"500000000", gnsmath.TickMathGetSqrtRatioAtTick(numericBoundaryUpper+1).ToString(),
			stakerNumericSwapCallback,
		)
	})
	printStakerNumericClock("staker_tick_upper_after")
	currentTick, _ = pl.GetSlot0Tick(poolPath)
	if currentTick < numericBoundaryUpper {
		panic("positive swap did not cross the shared upper tick")
	}
	printStakerNumericTickState("after_upper_cross", false)

	testing.SkipHeights(1)
	printStakerNumericClock("staker_tick_negative_before")
	metric.PrintMetricsBy("StakerNumbers tick cross negative (32 lower ticks)", func() {
		pl.Swap(
			cross(cur), barPath, fooPath, 3000, adminAddr, true,
			"500000000", gnsmath.TickMathGetSqrtRatioAtTick(59).ToString(),
			stakerNumericSwapCallback,
		)
	})
	printStakerNumericClock("staker_tick_negative_after")
	currentTick, _ = pl.GetSlot0Tick(poolPath)
	if currentTick < 0 || currentTick >= numericTickSpacing {
		panic("negative swap did not deactivate the staged lower ticks")
	}
	printStakerNumericTickState("after_negative_cross", false)
}

func measureStakerNumericIncentive(cur realm) {
	testing.SetRealm(adminRealm)
	incentiveStart = (time.Now().Unix()/86400 + 2) * 86400
	incentiveEnd = incentiveStart + 90*24*60*60

	printStakerNumericClock("staker_incentive_create_before")
	metric.PrintMetricsBy("StakerNumbers incentive create", func() {
		staker.CreateExternalIncentive(
			cross(cur), poolPath, barPath, numericRewardAmount,
			incentiveStart, incentiveEnd,
		)
	})
	printStakerNumericClock("staker_incentive_create_after")

	incentives, err := staker.GetExternalIncentiveByPoolPath(poolPath)
	if err != nil || len(incentives) != 1 {
		panic("external incentive record was not created")
	}
	incentiveID = incentives[0].IncentiveId()
	if incentives[0].RewardPerSecondX128().IsZero() {
		panic("external incentive reward rate was zero")
	}
	printStakerNumericIncentiveState("after_create")

	testing.SkipHeights((incentiveStart-time.Now().Unix())/5 + 2)
	testing.SetRealm(aliceRealm)
	printStakerNumericClock("staker_incentive_collect_before")
	metric.PrintMetricsBy("StakerNumbers incentive collect", func() {
		staker.CollectExternalIncentiveReward(cross(cur), widePositionID, incentiveID)
	})
	printStakerNumericClock("staker_incentive_collect_after")
	if !staker.IsStaked(widePositionID) {
		panic("external collect removed the wide deposit")
	}
	printStakerNumericIncentiveState("after_collect")

	measureStakerNumericPaidClaims(cur)

	testing.SkipHeights((incentiveEnd-time.Now().Unix())/5 + 2)
	testing.SetRealm(adminRealm)
	printStakerNumericClock("staker_incentive_end_before")
	metric.PrintMetricsBy("StakerNumbers incentive end", func() {
		staker.EndExternalIncentive(cross(cur), poolPath, incentiveID, adminAddr)
	})
	printStakerNumericClock("staker_incentive_end_after")
	refunded, err := staker.GetIncentiveRefunded(poolPath, incentiveID)
	if err != nil || !refunded {
		panic("external incentive was not refunded")
	}
	printStakerNumericIncentiveState("after_end")

	unstakeStakerNumericPositions(cur)
}

func measureStakerNumericPaidClaims(cur realm) {
	testing.SetRealm(aliceRealm)
	for _, pattern := range []int{1, 10, 100} {
		for call := 1; call <= pattern; call++ {
			testing.SkipHeights(1)
			clockLabel := ufmt.Sprintf("staker_paid_claim_%d_%03d", pattern, call)
			printStakerNumericClock(clockLabel + "_before")
			metric.PrintMetricsBy(
				ufmt.Sprintf("StakerNumbers incentive paid claim %d/%d", call, pattern),
				func() {
					staker.CollectExternalIncentiveReward(cross(cur), widePositionID, incentiveID)
				},
			)
			printStakerNumericClock(clockLabel + "_after")
		}
		printStakerNumericIncentiveState(ufmt.Sprintf("after_paid_claims_%d", pattern))
	}
}

func unstakeStakerNumericPositions(cur realm) {
	testing.SetRealm(aliceRealm)

	unstakeOne := func(label, clockLabel string, positionID uint64) {
		testing.SkipHeights(1)
		printStakerNumericClock(clockLabel + "_before")
		metric.PrintMetricsBy(label, func() {
			staker.UnStakeToken(cross(cur), positionID)
		})
		printStakerNumericClock(clockLabel + "_after")
		if staker.IsStaked(positionID) {
			panic("unstake did not delete the deposit")
		}
	}

	unstakeOne(
		"StakerNumbers deposit unstake delete",
		"staker_unstake_wide",
		widePositionID,
	)
	poolStaked, err := staker.GetPoolStakedLiquidity(poolPath)
	if err != nil {
		panic("failed to read pool liquidity after wide unstake")
	}
	println(ufmt.Sprintf("STATE staker-numerics deposit after_unstake %d present=false pool_staked=%s", widePositionID, poolStaked))

	for i, positionID := range numericPositionIDs {
		unstakeOne(
			ufmt.Sprintf("StakerNumbers deposit unstake boundary allocation %02d/32", i+1),
			ufmt.Sprintf("staker_unstake_boundary_%02d", i+1),
			positionID,
		)
	}

	assertStakerNumericCleanup("after_unstake_all")
}

func printStakerNumericClock(label string) {
	println(ufmt.Sprintf("STATE CLOCK %s %d", label, time.Now().Unix()))
}

func printStakerNumericDepositState(label string, positionID uint64) {
	deposit, err := staker.GetDeposit(positionID)
	if err != nil || deposit == nil {
		panic("failed to read staker deposit")
	}
	liquidity := deposit.Liquidity()
	if liquidity == nil || liquidity.IsZero() {
		panic("staker deposit liquidity disappeared")
	}
	poolStaked, err := staker.GetPoolStakedLiquidity(poolPath)
	if err != nil {
		panic("failed to read staked liquidity")
	}
	println(ufmt.Sprintf(
		"STATE staker-numerics deposit %s %d %s %s %d %d %d %d %d %s %s",
		label, positionID, deposit.Owner().String(), liquidity.ToString(),
		deposit.StakeTime(), deposit.InternalRewardLastCollectTime(),
		deposit.CollectedInternalReward(), deposit.TickLower(), deposit.TickUpper(),
		deposit.TargetPoolPath(), poolStaked,
	))
}

func printStakerNumericTickState(label string, narrowActive bool) {
	currentTick, err := pl.GetSlot0Tick(poolPath)
	if err != nil {
		panic("failed to read pool tick")
	}
	poolStaked, err := staker.GetPoolStakedLiquidity(poolPath)
	if err != nil {
		panic("failed to read staked liquidity for ticks")
	}

	wideDeposit, err := staker.GetDeposit(widePositionID)
	if err != nil || wideDeposit == nil {
		panic("failed to read wide deposit for tick state")
	}
	wideGross := wideDeposit.Liquidity()
	if wideGross == nil || wideGross.IsZero() {
		panic("wide staked gross liquidity disappeared")
	}

	boundaryGross := u256.Zero()
	for _, positionID := range numericPositionIDs {
		deposit, depositErr := staker.GetDeposit(positionID)
		if depositErr != nil || deposit == nil {
			panic("failed to read staged deposit for tick state")
		}
		if deposit.TickUpper() != numericBoundaryUpper {
			panic("staged deposit upper boundary changed")
		}
		gross := deposit.Liquidity()
		if gross == nil || gross.IsZero() {
			panic("staged deposit gross liquidity disappeared")
		}
		boundaryGross.Add(boundaryGross, gross)
	}

	expected := u256.Zero().Set(wideGross)
	if narrowActive {
		expected.Add(expected, boundaryGross)
	}
	actual := u256.MustFromDecimal(poolStaked)
	if !actual.Eq(expected) {
		panic("signed boundary delta did not produce expected active gross liquidity")
	}
	historicalTicks := staker.GetPoolHistoricalTicks(poolPath)
	if historicalTicks == nil || historicalTicks.Size() < 2 {
		panic("pool historical tick cursor disappeared")
	}
	println(ufmt.Sprintf(
		"STATE staker-numerics tick %s current_tick=%d pool_staked=%s expected=%s wide_gross=%s boundary_gross=%s narrow_active=%t boundary_records=%d historical_ticks=%d",
		label, currentTick, poolStaked, expected.ToString(), wideGross.ToString(),
		boundaryGross.ToString(), narrowActive, len(numericPositionIDs), historicalTicks.Size(),
	))
}

func assertStakerNumericAggregate(label string, boundaryActive bool) {
	if len(numericPositionIDs) != int(numericBoundaryCount) {
		panic("staged deposit count changed")
	}

	wideDeposit, err := staker.GetDeposit(widePositionID)
	if err != nil || wideDeposit == nil {
		panic("failed to read wide deposit aggregate")
	}
	wideGross := wideDeposit.Liquidity()
	if wideGross == nil || wideGross.IsZero() {
		panic("wide aggregate liquidity disappeared")
	}

	boundaryGross := u256.Zero()
	for i, positionID := range numericPositionIDs {
		deposit, depositErr := staker.GetDeposit(positionID)
		if depositErr != nil || deposit == nil {
			panic("failed to read staged deposit aggregate")
		}
		expectedLower := int32(i+1) * numericTickSpacing
		if deposit.TickLower() != expectedLower || deposit.TickUpper() != numericBoundaryUpper {
			panic("staged deposit tick boundary changed")
		}
		gross := deposit.Liquidity()
		if gross == nil || gross.IsZero() {
			panic("staged aggregate liquidity disappeared")
		}
		boundaryGross.Add(boundaryGross, gross)
	}

	expected := u256.Zero().Set(wideGross)
	if boundaryActive {
		expected.Add(expected, boundaryGross)
	}
	poolStaked, err := staker.GetPoolStakedLiquidity(poolPath)
	if err != nil {
		panic("failed to read aggregate pool liquidity")
	}
	actual := u256.MustFromDecimal(poolStaked)
	if !actual.Eq(expected) {
		panic("aggregate pool liquidity changed unexpectedly")
	}
	println(ufmt.Sprintf(
		"STATE staker-numerics aggregate %s deposits=%d boundary_records=%d pool_staked=%s expected=%s boundary_active=%t",
		label, len(numericPositionIDs)+1, len(numericPositionIDs),
		poolStaked, expected.ToString(), boundaryActive,
	))
}

func assertStakerNumericCleanup(label string) {
	activeDeposits := 0
	positionIDs := make([]uint64, 0, len(numericPositionIDs)+1)
	positionIDs = append(positionIDs, widePositionID)
	positionIDs = append(positionIDs, numericPositionIDs...)
	for _, positionID := range positionIDs {
		if staker.IsStaked(positionID) {
			activeDeposits++
		}
		deposit, err := staker.GetDeposit(positionID)
		if err == nil || deposit != nil {
			panic("unstaked deposit remained addressable")
		}
	}
	if activeDeposits != 0 {
		panic("active staker deposits remained")
	}

	poolStaked, err := staker.GetPoolStakedLiquidity(poolPath)
	if err != nil {
		panic("failed to read cleanup pool liquidity")
	}
	if u256.MustFromDecimal(poolStaked).Sign() != 0 {
		panic("active tick liquidity remained after full unstake")
	}
	poolSnapshot, err := staker.GetPool(poolPath)
	if err != nil || poolSnapshot == nil {
		panic("failed to read cleanup pool snapshot")
	}
	activeTicks := poolSnapshot.Ticks().Tree().Size()
	if activeTicks != 0 {
		panic("staked tick objects remained after full unstake")
	}

	pendingProtocolFees := staker.GetPendingProtocolFees()
	if len(pendingProtocolFees) != 0 {
		panic("pending reward fees remained after full unstake")
	}

	historicalTicks := staker.GetPoolHistoricalTicks(poolPath)
	historicalTickCount := 0
	if historicalTicks != nil {
		historicalTickCount = historicalTicks.Size()
	}
	println(ufmt.Sprintf(
		"STATE staker-numerics cleanup %s active_deposits=%d active_rewards=%d active_ticks=%d pending_protocol_fee_tokens=%d historical_ticks=%d pool_staked=%s",
		label, activeDeposits, 0, activeTicks, len(pendingProtocolFees), historicalTickCount, poolStaked,
	))
}

func printStakerNumericIncentiveState(label string) {
	incentives, err := staker.GetExternalIncentiveByPoolPath(poolPath)
	if err != nil || len(incentives) != 1 {
		panic("failed to read external incentive state")
	}
	incentive := incentives[0]
	if incentive.IncentiveId() != incentiveID {
		panic("external incentive id changed")
	}
	poolStaked, err := staker.GetPoolStakedLiquidity(poolPath)
	if err != nil {
		panic("failed to read incentive pool liquidity")
	}
	collected := int64(0)
	externalLast := int64(0)
	externalIDs := 0
	if staker.IsStaked(widePositionID) {
		deposit, depositErr := staker.GetDeposit(widePositionID)
		if depositErr != nil {
			panic("failed to read deposit external reward")
		}
		collected, _ = deposit.GetCollectedExternalReward(incentiveID)
		externalLast, _ = deposit.GetExternalRewardLastCollectTime(incentiveID)
		externalIDs = len(deposit.GetExternalIncentiveIdList())
	}
	println(ufmt.Sprintf(
		"STATE staker-numerics incentive %s %s %s %d %d %d %d %d %d %d %d %d %d %s %t %d %d %d %s",
		label, incentive.IncentiveId(), incentive.RewardToken(),
		incentive.StartTimestamp(), incentive.EndTimestamp(), incentive.CreatedHeight(),
		incentive.CreatedTimestamp(), incentive.DepositGnsAmount(),
		incentive.TotalRewardAmount(), incentive.RewardAmount(),
		incentive.DistributedRewardAmount(), incentive.AccumulatedPenaltyAmount(),
		incentive.UnclaimableSeconds(), incentive.RewardPerSecondX128().ToString(),
		incentive.Refunded(), collected, externalLast, externalIDs, poolStaked,
	))
}

// Output:
