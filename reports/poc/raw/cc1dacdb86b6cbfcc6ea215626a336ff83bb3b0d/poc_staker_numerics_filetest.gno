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
// STATE CLOCK staker_setup_before 1234567890
// STATE staker-numerics config unstaking_fee=100 warmup_tiers=4
// STATE CLOCK staker_setup_after 1234567895
// STATE CLOCK staker_pool_after 1234567895
// STATE CLOCK staker_mint_after 1234567895
// STATE CLOCK staker_stake_wide_before 1234567900
// StakerNumbers deposit stake wide (first allocation)
// - Gas Used: 16454569
// - Storage Diff: 33852
// - CPU Cycles: 15056680
// - Realm gno.land/r/gnoswap/gnft: 22
// - Realm gno.land/r/gnoswap/gns: 11
// - Realm gno.land/r/gnoswap/position: 47
// - Realm gno.land/r/gnoswap/scenario/metric/main: 1610
// - Realm gno.land/r/gnoswap/staker: 31295
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_wide_after 1234567900
// STATE CLOCK staker_stake_boundary_01_before 1234567905
// StakerNumbers deposit stake boundary (first allocation)
// - Gas Used: 14511842
// - Storage Diff: 11243
// - CPU Cycles: 13594131
// - Realm gno.land/r/gnoswap/gnft: -2048
// - Realm gno.land/r/gnoswap/position: 46
// - Realm gno.land/r/gnoswap/staker: 12378
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_01_after 1234567905
// STATE CLOCK staker_stake_boundary_2_before 1234567910
// StakerNumbers deposit stake boundary allocation 2/32
// - Gas Used: 14651556
// - Storage Diff: 7384
// - CPU Cycles: 13643370
// - Realm gno.land/r/gnoswap/gnft: -2030
// - Realm gno.land/r/gnoswap/position: 46
// - Realm gno.land/r/gnoswap/staker: 8501
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_2_after 1234567910
// STATE CLOCK staker_stake_boundary_3_before 1234567915
// StakerNumbers deposit stake boundary allocation 3/32
// - Gas Used: 14688819
// - Storage Diff: 7389
// - CPU Cycles: 13678415
// - Realm gno.land/r/gnoswap/gnft: -2013
// - Realm gno.land/r/gnoswap/position: 46
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_3_after 1234567915
// STATE CLOCK staker_stake_boundary_4_before 1234567920
// StakerNumbers deposit stake boundary allocation 4/32
// - Gas Used: 14645231
// - Storage Diff: 7371
// - CPU Cycles: 13639102
// - Realm gno.land/r/gnoswap/gnft: -2031
// - Realm gno.land/r/gnoswap/position: 46
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_4_after 1234567920
// STATE CLOCK staker_stake_boundary_5_before 1234567925
// StakerNumbers deposit stake boundary allocation 5/32
// - Gas Used: 14613707
// - Storage Diff: 7359
// - CPU Cycles: 13613668
// - Realm gno.land/r/gnoswap/gnft: -2043
// - Realm gno.land/r/gnoswap/position: 46
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_5_after 1234567925
// STATE CLOCK staker_stake_boundary_6_before 1234567930
// StakerNumbers deposit stake boundary allocation 6/32
// - Gas Used: 14624106
// - Storage Diff: 7365
// - CPU Cycles: 13620785
// - Realm gno.land/r/gnoswap/gnft: -2037
// - Realm gno.land/r/gnoswap/position: 46
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_6_after 1234567930
// STATE CLOCK staker_stake_boundary_7_before 1234567935
// StakerNumbers deposit stake boundary allocation 7/32
// - Gas Used: 14710234
// - Storage Diff: 7353
// - CPU Cycles: 13690040
// - Realm gno.land/r/gnoswap/gnft: -2049
// - Realm gno.land/r/gnoswap/position: 46
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_7_after 1234567935
// STATE CLOCK staker_stake_boundary_8_before 1234567940
// StakerNumbers deposit stake boundary allocation 8/32
// - Gas Used: 14665205
// - Storage Diff: 7353
// - CPU Cycles: 13651084
// - Realm gno.land/r/gnoswap/gnft: -2049
// - Realm gno.land/r/gnoswap/position: 46
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_8_after 1234567940
// STATE CLOCK staker_stake_boundary_9_before 1234567945
// StakerNumbers deposit stake boundary allocation 9/32
// - Gas Used: 14569861
// - Storage Diff: 7352
// - CPU Cycles: 13568849
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/position: 47
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_9_after 1234567945
// STATE CLOCK staker_stake_boundary_10_before 1234567950
// StakerNumbers deposit stake boundary allocation 10/32
// - Gas Used: 14547261
// - Storage Diff: 7346
// - CPU Cycles: 13544071
// - Realm gno.land/r/gnoswap/gnft: -2057
// - Realm gno.land/r/gnoswap/position: 47
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_10_after 1234567950
// STATE CLOCK staker_stake_boundary_11_before 1234567955
// StakerNumbers deposit stake boundary allocation 11/32
// - Gas Used: 14667598
// - Storage Diff: 7352
// - CPU Cycles: 13644750
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/position: 47
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_11_after 1234567955
// STATE CLOCK staker_stake_boundary_12_before 1234567960
// StakerNumbers deposit stake boundary allocation 12/32
// - Gas Used: 14555971
// - Storage Diff: 7352
// - CPU Cycles: 13547796
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/position: 47
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_12_after 1234567960
// STATE CLOCK staker_stake_boundary_13_before 1234567965
// StakerNumbers deposit stake boundary allocation 13/32
// - Gas Used: 14516159
// - Storage Diff: 7352
// - CPU Cycles: 13513000
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/position: 47
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_13_after 1234567965
// STATE CLOCK staker_stake_boundary_14_before 1234567970
// StakerNumbers deposit stake boundary allocation 14/32
// - Gas Used: 14724571
// - Storage Diff: 13983
// - CPU Cycles: 13671816
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/position: 47
// - Realm gno.land/r/gnoswap/staker: 15120
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_14_after 1234567970
// STATE CLOCK staker_stake_boundary_15_before 1234567975
// StakerNumbers deposit stake boundary allocation 15/32
// - Gas Used: 14428726
// - Storage Diff: 7398
// - CPU Cycles: 13572497
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/position: 45
// - Realm gno.land/r/gnoswap/staker: 8537
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_15_after 1234567975
// STATE CLOCK staker_stake_boundary_16_before 1234567980
// StakerNumbers deposit stake boundary allocation 16/32
// - Gas Used: 14575095
// - Storage Diff: 13856
// - CPU Cycles: 13675624
// - Realm gno.land/r/gnoswap/gnft: -2045
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 14990
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_16_after 1234567980
// STATE CLOCK staker_stake_boundary_17_before 1234567985
// StakerNumbers deposit stake boundary allocation 17/32
// - Gas Used: 15054431
// - Storage Diff: 7403
// - CPU Cycles: 14181413
// - Realm gno.land/r/gnoswap/gnft: -2045
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8537
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_17_after 1234567985
// STATE CLOCK staker_stake_boundary_18_before 1234567990
// StakerNumbers deposit stake boundary allocation 18/32
// - Gas Used: 14474729
// - Storage Diff: 7349
// - CPU Cycles: 13613811
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_18_after 1234567990
// STATE CLOCK staker_stake_boundary_19_before 1234567995
// StakerNumbers deposit stake boundary allocation 19/32
// - Gas Used: 14797342
// - Storage Diff: 7325
// - CPU Cycles: 13902323
// - Realm gno.land/r/gnoswap/gnft: -2075
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_19_after 1234567995
// STATE CLOCK staker_stake_boundary_20_before 1234568000
// StakerNumbers deposit stake boundary allocation 20/32
// - Gas Used: 14507477
// - Storage Diff: 7398
// - CPU Cycles: 13637300
// - Realm gno.land/r/gnoswap/gnft: -2045
// - Realm gno.land/r/gnoswap/gns: 43
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_20_after 1234568000
// STATE CLOCK staker_stake_boundary_21_before 1234568005
// StakerNumbers deposit stake boundary allocation 21/32
// - Gas Used: 14766197
// - Storage Diff: 7353
// - CPU Cycles: 13891948
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/gns: 4
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_21_after 1234568005
// STATE CLOCK staker_stake_boundary_22_before 1234568010
// StakerNumbers deposit stake boundary allocation 22/32
// - Gas Used: 14783049
// - Storage Diff: 10685
// - CPU Cycles: 13863329
// - Realm gno.land/r/gnoswap/gnft: -2069
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 11843
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_22_after 1234568010
// STATE CLOCK staker_stake_boundary_23_before 1234568015
// StakerNumbers deposit stake boundary allocation 23/32
// - Gas Used: 14616701
// - Storage Diff: 7379
// - CPU Cycles: 13752403
// - Realm gno.land/r/gnoswap/gnft: -2045
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8513
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_23_after 1234568015
// STATE CLOCK staker_stake_boundary_24_before 1234568020
// StakerNumbers deposit stake boundary allocation 24/32
// - Gas Used: 14485582
// - Storage Diff: 7349
// - CPU Cycles: 13620807
// - Realm gno.land/r/gnoswap/gnft: -2051
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_24_after 1234568020
// STATE CLOCK staker_stake_boundary_25_before 1234568025
// StakerNumbers deposit stake boundary allocation 25/32
// - Gas Used: 14974761
// - Storage Diff: 7337
// - CPU Cycles: 14089272
// - Realm gno.land/r/gnoswap/gnft: -2063
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_25_after 1234568025
// STATE CLOCK staker_stake_boundary_26_before 1234568030
// StakerNumbers deposit stake boundary allocation 26/32
// - Gas Used: 14445960
// - Storage Diff: 7355
// - CPU Cycles: 13586859
// - Realm gno.land/r/gnoswap/gnft: -2045
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_26_after 1234568030
// STATE CLOCK staker_stake_boundary_27_before 1234568035
// StakerNumbers deposit stake boundary allocation 27/32
// - Gas Used: 14593888
// - Storage Diff: 7355
// - CPU Cycles: 13725843
// - Realm gno.land/r/gnoswap/gnft: -2045
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8489
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_27_after 1234568035
// STATE CLOCK staker_stake_boundary_28_before 1234568040
// StakerNumbers deposit stake boundary allocation 28/32
// - Gas Used: 14579708
// - Storage Diff: 7344
// - CPU Cycles: 13695717
// - Realm gno.land/r/gnoswap/gnft: -2069
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8502
// - Realm gno.land/r/gnoswap/staker/v1: 867
// STATE CLOCK staker_stake_boundary_28_after 1234568040
// STATE CLOCK staker_stake_boundary_29_before 1234568045
// StakerNumbers deposit stake boundary allocation 29/32
// - Gas Used: 14742303
// - Storage Diff: 7414
// - CPU Cycles: 13870380
// - Realm gno.land/r/gnoswap/gnft: -2045
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 8543
// - Realm gno.land/r/gnoswap/staker/v1: 872
// STATE CLOCK staker_stake_boundary_29_after 1234568045
// STATE CLOCK staker_stake_boundary_30_before 1234568050
// StakerNumbers deposit stake boundary allocation 30/32
// - Gas Used: 14617720
// - Storage Diff: 10770
// - CPU Cycles: 13723993
// - Realm gno.land/r/gnoswap/gnft: -2049
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 11903
// - Realm gno.land/r/gnoswap/staker/v1: 872
// STATE CLOCK staker_stake_boundary_30_after 1234568050
// STATE CLOCK staker_stake_boundary_31_before 1234568055
// StakerNumbers deposit stake boundary allocation 31/32
// - Gas Used: 14719623
// - Storage Diff: 10693
// - CPU Cycles: 13824708
// - Realm gno.land/r/gnoswap/gnft: -2057
// - Realm gno.land/r/gnoswap/position: 44
// - Realm gno.land/r/gnoswap/staker: 11834
// - Realm gno.land/r/gnoswap/staker/v1: 872
// STATE CLOCK staker_stake_boundary_31_after 1234568055
// STATE CLOCK staker_stake_boundary_32_before 1234568060
// StakerNumbers deposit stake boundary allocation 32/32
// - Gas Used: 14384576
// - Storage Diff: 6375
// - CPU Cycles: 13522618
// - Realm gno.land/r/gnoswap/gnft: -3130
// - Realm gno.land/r/gnoswap/position: 68
// - Realm gno.land/r/gnoswap/staker: 8565
// - Realm gno.land/r/gnoswap/staker/v1: 872
// STATE CLOCK staker_stake_boundary_32_after 1234568060
// STATE staker-numerics aggregate after_stake deposits=33 boundary_records=32 pool_staked=500000000 expected=500000000 boundary_active=false
// STATE staker-numerics deposit after_stake 1 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 500000000 1234567900 1234567900 0 -887220 887220 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE staker-numerics deposit after_stake_boundary_first 2 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 3903576 1234567905 1234567905 0 60 6000 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE staker-numerics deposit after_stake_boundary_last 33 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 5965197 1234568060 1234568060 0 1920 6000 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE CLOCK staker_stake_phase_after 1234568060
// STATE CLOCK staker_collect_wide_before 1234568065
// StakerNumbers deposit collect
// - Gas Used: 14603604
// - Storage Diff: 11128
// - CPU Cycles: 13313698
// - Realm gno.land/r/gnoswap/gns: 4130
// - Realm gno.land/r/gnoswap/protocol_fee: 6986
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_wide_after 1234568065
// STATE staker-numerics aggregate after_collect deposits=33 boundary_records=32 pool_staked=500000000 expected=500000000 boundary_active=false
// STATE staker-numerics deposit after_collect 1 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 500000000 1234567900 1234568065 441459644 -887220 887220 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE CLOCK staker_collect_wide_repeat_before 1234568070
// StakerNumbers deposit collect repeat
// - Gas Used: 13921278
// - Storage Diff: 40
// - CPU Cycles: 13046670
// - Realm gno.land/r/gnoswap/protocol_fee: 40
// STATE CLOCK staker_collect_wide_repeat_after 1234568070
// STATE staker-numerics aggregate after_collect_repeat deposits=33 boundary_records=32 pool_staked=500000000 expected=500000000 boundary_active=false
// STATE staker-numerics deposit after_collect_repeat 1 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 500000000 1234567900 1234568070 454837209 -887220 887220 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE CLOCK staker_collect_boundary_1_before 1234568075
// StakerNumbers deposit collect boundary allocation 1/32
// - Gas Used: 9184833
// - Storage Diff: 12
// - CPU Cycles: 8599689
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_1_after 1234568075
// STATE CLOCK staker_collect_boundary_2_before 1234568080
// StakerNumbers deposit collect boundary allocation 2/32
// - Gas Used: 9235674
// - Storage Diff: 12
// - CPU Cycles: 8649144
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_2_after 1234568080
// STATE CLOCK staker_collect_boundary_3_before 1234568085
// StakerNumbers deposit collect boundary allocation 3/32
// - Gas Used: 9236412
// - Storage Diff: 12
// - CPU Cycles: 8649882
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_3_after 1234568085
// STATE CLOCK staker_collect_boundary_4_before 1234568090
// StakerNumbers deposit collect boundary allocation 4/32
// - Gas Used: 9236409
// - Storage Diff: 12
// - CPU Cycles: 8649879
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_4_after 1234568090
// STATE CLOCK staker_collect_boundary_5_before 1234568095
// StakerNumbers deposit collect boundary allocation 5/32
// - Gas Used: 9236899
// - Storage Diff: 12
// - CPU Cycles: 8650369
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_5_after 1234568095
// STATE CLOCK staker_collect_boundary_6_before 1234568100
// StakerNumbers deposit collect boundary allocation 6/32
// - Gas Used: 9236173
// - Storage Diff: 12
// - CPU Cycles: 8649643
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_6_after 1234568100
// STATE CLOCK staker_collect_boundary_7_before 1234568105
// StakerNumbers deposit collect boundary allocation 7/32
// - Gas Used: 9238859
// - Storage Diff: 12
// - CPU Cycles: 8652329
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_7_after 1234568105
// STATE CLOCK staker_collect_boundary_8_before 1234568110
// StakerNumbers deposit collect boundary allocation 8/32
// - Gas Used: 9244635
// - Storage Diff: 12
// - CPU Cycles: 8658105
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_8_after 1234568110
// STATE CLOCK staker_collect_boundary_9_before 1234568115
// StakerNumbers deposit collect boundary allocation 9/32
// - Gas Used: 9246108
// - Storage Diff: 12
// - CPU Cycles: 8659578
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_9_after 1234568115
// STATE CLOCK staker_collect_boundary_10_before 1234568120
// StakerNumbers deposit collect boundary allocation 10/32
// - Gas Used: 9236660
// - Storage Diff: 12
// - CPU Cycles: 8650130
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_10_after 1234568120
// STATE CLOCK staker_collect_boundary_11_before 1234568125
// StakerNumbers deposit collect boundary allocation 11/32
// - Gas Used: 9238859
// - Storage Diff: 12
// - CPU Cycles: 8652329
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_11_after 1234568125
// STATE CLOCK staker_collect_boundary_12_before 1234568130
// StakerNumbers deposit collect boundary allocation 12/32
// - Gas Used: 9238369
// - Storage Diff: 12
// - CPU Cycles: 8651839
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_12_after 1234568130
// STATE CLOCK staker_collect_boundary_13_before 1234568135
// StakerNumbers deposit collect boundary allocation 13/32
// - Gas Used: 9237885
// - Storage Diff: 12
// - CPU Cycles: 8651355
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_13_after 1234568135
// STATE CLOCK staker_collect_boundary_14_before 1234568140
// StakerNumbers deposit collect boundary allocation 14/32
// - Gas Used: 9239594
// - Storage Diff: 12
// - CPU Cycles: 8653064
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_14_after 1234568140
// STATE CLOCK staker_collect_boundary_15_before 1234568145
// StakerNumbers deposit collect boundary allocation 15/32
// - Gas Used: 9237144
// - Storage Diff: 12
// - CPU Cycles: 8650614
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_15_after 1234568145
// STATE CLOCK staker_collect_boundary_16_before 1234568150
// StakerNumbers deposit collect boundary allocation 16/32
// - Gas Used: 9244886
// - Storage Diff: 12
// - CPU Cycles: 8658356
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_16_after 1234568150
// STATE CLOCK staker_collect_boundary_17_before 1234568155
// StakerNumbers deposit collect boundary allocation 17/32
// - Gas Used: 9249646
// - Storage Diff: 12
// - CPU Cycles: 8663122
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_17_after 1234568155
// STATE CLOCK staker_collect_boundary_18_before 1234568160
// StakerNumbers deposit collect boundary allocation 18/32
// - Gas Used: 9241910
// - Storage Diff: 12
// - CPU Cycles: 8655386
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_18_after 1234568160
// STATE CLOCK staker_collect_boundary_19_before 1234568165
// StakerNumbers deposit collect boundary allocation 19/32
// - Gas Used: 9240685
// - Storage Diff: 12
// - CPU Cycles: 8654161
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_19_after 1234568165
// STATE CLOCK staker_collect_boundary_20_before 1234568170
// StakerNumbers deposit collect boundary allocation 20/32
// - Gas Used: 9242645
// - Storage Diff: 12
// - CPU Cycles: 8656121
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_20_after 1234568170
// STATE CLOCK staker_collect_boundary_21_before 1234568175
// StakerNumbers deposit collect boundary allocation 21/32
// - Gas Used: 9241910
// - Storage Diff: 12
// - CPU Cycles: 8655386
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_21_after 1234568175
// STATE CLOCK staker_collect_boundary_22_before 1234568180
// StakerNumbers deposit collect boundary allocation 22/32
// - Gas Used: 9243383
// - Storage Diff: 12
// - CPU Cycles: 8656859
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_22_after 1234568180
// STATE CLOCK staker_collect_boundary_23_before 1234568185
// StakerNumbers deposit collect boundary allocation 23/32
// - Gas Used: 9241420
// - Storage Diff: 12
// - CPU Cycles: 8654896
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_23_after 1234568185
// STATE CLOCK staker_collect_boundary_24_before 1234568190
// StakerNumbers deposit collect boundary allocation 24/32
// - Gas Used: 9250871
// - Storage Diff: 12
// - CPU Cycles: 8664347
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_24_after 1234568190
// STATE CLOCK staker_collect_boundary_25_before 1234568195
// StakerNumbers deposit collect boundary allocation 25/32
// - Gas Used: 9251119
// - Storage Diff: 12
// - CPU Cycles: 8664595
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_25_after 1234568195
// STATE CLOCK staker_collect_boundary_26_before 1234568200
// StakerNumbers deposit collect boundary allocation 26/32
// - Gas Used: 9243870
// - Storage Diff: 12
// - CPU Cycles: 8657346
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_26_after 1234568200
// STATE CLOCK staker_collect_boundary_27_before 1234568205
// StakerNumbers deposit collect boundary allocation 27/32
// - Gas Used: 9251606
// - Storage Diff: 12
// - CPU Cycles: 8665082
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_27_after 1234568205
// STATE CLOCK staker_collect_boundary_28_before 1234568210
// StakerNumbers deposit collect boundary allocation 28/32
// - Gas Used: 9252105
// - Storage Diff: 12
// - CPU Cycles: 8665581
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_28_after 1234568210
// STATE CLOCK staker_collect_boundary_29_before 1234568215
// StakerNumbers deposit collect boundary allocation 29/32
// - Gas Used: 9244653
// - Storage Diff: 12
// - CPU Cycles: 8658081
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_29_after 1234568215
// STATE CLOCK staker_collect_boundary_30_before 1234568220
// StakerNumbers deposit collect boundary allocation 30/32
// - Gas Used: 9204434
// - Storage Diff: 12
// - CPU Cycles: 8617862
// - Realm gno.land/r/gnoswap/staker: 12
// STATE CLOCK staker_collect_boundary_30_after 1234568220
// STATE CLOCK staker_collect_boundary_31_before 1234568225
// StakerNumbers deposit collect boundary allocation 31/32
// - Gas Used: 9278297
// - Storage Diff: 18
// - CPU Cycles: 8619335
// - Realm gno.land/r/gnoswap/staker: 18
// STATE CLOCK staker_collect_boundary_31_after 1234568225
// STATE CLOCK staker_collect_boundary_32_before 1234568230
// StakerNumbers deposit collect boundary allocation 32/32
// - Gas Used: 9268849
// - Storage Diff: 18
// - CPU Cycles: 8609887
// - Realm gno.land/r/gnoswap/staker: 18
// STATE CLOCK staker_collect_boundary_32_after 1234568230
// STATE staker-numerics aggregate after_batch_collect deposits=33 boundary_records=32 pool_staked=500000000 expected=500000000 boundary_active=false
// STATE staker-numerics deposit after_batch_collect_boundary_first 2 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 3903576 1234567905 1234567905 0 60 6000 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE staker-numerics deposit after_batch_collect_boundary_last 33 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 5965197 1234568060 1234568060 0 1920 6000 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE CLOCK staker_collect_phase_after 1234568230
// STATE CLOCK staker_tick_positive_before 1234568235
// StakerNumbers tick cross positive (32 lower ticks)
// - Gas Used: 305847709
// - Storage Diff: 106345
// - CPU Cycles: 295005445
// - Realm gno.land/r/gnoswap/pool: 2220
// - Realm gno.land/r/gnoswap/pool/v1: -6
// - Realm gno.land/r/gnoswap/staker: 104124
// - Realm gno.land/r/onbloc/bar: 7
// STATE CLOCK staker_tick_positive_after 1234568235
// STATE staker-numerics tick after_positive_cross current_tick=1921 pool_staked=653902384 expected=653902384 wide_gross=500000000 boundary_gross=153902384 narrow_active=true boundary_records=32 historical_ticks=2
// STATE CLOCK staker_tick_upper_before 1234568240
// StakerNumbers tick cross positive upper rewrite
// - Gas Used: 34561039
// - Storage Diff: 5335
// - CPU Cycles: 33139728
// - Realm gno.land/r/gnoswap/pool: 67
// - Realm gno.land/r/gnoswap/staker: 5268
// STATE CLOCK staker_tick_upper_after 1234568240
// STATE staker-numerics tick after_upper_cross current_tick=6001 pool_staked=500000000 expected=500000000 wide_gross=500000000 boundary_gross=153902384 narrow_active=false boundary_records=32 historical_ticks=3
// STATE CLOCK staker_tick_negative_before 1234568245
// StakerNumbers tick cross negative (32 lower ticks)
// - Gas Used: 387092634
// - Storage Diff: 44449
// - CPU Cycles: 375422166
// - Realm gno.land/r/gnoswap/pool: 1115
// - Realm gno.land/r/gnoswap/staker: 43334
// STATE CLOCK staker_tick_negative_after 1234568245
// STATE staker-numerics tick after_negative_cross current_tick=59 pool_staked=500000000 expected=500000000 wide_gross=500000000 boundary_gross=153902384 narrow_active=false boundary_records=32 historical_ticks=4
// STATE CLOCK staker_tick_phase_after 1234568245
// STATE CLOCK staker_incentive_create_before 1234568245
// StakerNumbers incentive create
// - Gas Used: 6039470
// - Storage Diff: 19763
// - CPU Cycles: 5352414
// - Realm gno.land/r/gnoswap/gns: 3
// - Realm gno.land/r/gnoswap/scenario/metric/main: 10
// - Realm gno.land/r/gnoswap/staker: 17694
// - Realm gno.land/r/onbloc/bar: 2056
// STATE CLOCK staker_incentive_create_after 1234568245
// STATE staker-numerics incentive after_create g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568245:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 194 1234568245 100000000000 90000000000000 90000000000000 0 0 0 3938453320844195178974243141571391336296296296 false 0 0 0 500000000
// STATE CLOCK staker_incentive_collect_before 1234656010
// StakerNumbers incentive collect
// - Gas Used: 11793901
// - Storage Diff: 3620
// - CPU Cycles: 11188175
// - Realm gno.land/r/gnoswap/protocol_fee: 980
// - Realm gno.land/r/gnoswap/scenario/metric/main: 82
// - Realm gno.land/r/gnoswap/staker: 497
// - Realm gno.land/r/onbloc/bar: 2061
// STATE CLOCK staker_incentive_collect_after 1234656010
// STATE staker-numerics incentive after_collect g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568245:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 194 1234568245 100000000000 90000000000000 89999884259260 34722222 81018518 0 3938453320844195178974243141571391336296296296 false 115740740 1234656010 1 500000000
// STATE CLOCK staker_paid_claim_1_1_before 1234656015
// StakerNumbers incentive paid claim 1/1
// - Gas Used: 11641734
// - Storage Diff: 10
// - CPU Cycles: 11109907
// - Realm gno.land/r/gnoswap/protocol_fee: 10
// STATE CLOCK staker_paid_claim_1_1_after 1234656015
// STATE staker-numerics incentive after_paid_claims_1 g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568245:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 194 1234568245 100000000000 90000000000000 89999826388890 52083333 121527777 0 3938453320844195178974243141571391336296296296 false 173611110 1234656015 1 500000000
// STATE CLOCK staker_paid_claim_10_1_before 1234656020
// StakerNumbers incentive paid claim 1/10
// - Gas Used: 11578458
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_10_1_after 1234656020
// STATE CLOCK staker_paid_claim_10_2_before 1234656025
// StakerNumbers incentive paid claim 2/10
// - Gas Used: 11576997
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_10_2_after 1234656025
// STATE CLOCK staker_paid_claim_10_3_before 1234656030
// StakerNumbers incentive paid claim 3/10
// - Gas Used: 11640458
// - Storage Diff: 0
// - CPU Cycles: 11109420
// STATE CLOCK staker_paid_claim_10_3_after 1234656030
// STATE CLOCK staker_paid_claim_10_4_before 1234656035
// StakerNumbers incentive paid claim 4/10
// - Gas Used: 11577971
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_10_4_after 1234656035
// STATE CLOCK staker_paid_claim_10_5_before 1234656040
// StakerNumbers incentive paid claim 5/10
// - Gas Used: 11577971
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_10_5_after 1234656040
// STATE CLOCK staker_paid_claim_10_6_before 1234656045
// StakerNumbers incentive paid claim 6/10
// - Gas Used: 11640945
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_10_6_after 1234656045
// STATE CLOCK staker_paid_claim_10_7_before 1234656050
// StakerNumbers incentive paid claim 7/10
// - Gas Used: 11575163
// - Storage Diff: 0
// - CPU Cycles: 11044125
// STATE CLOCK staker_paid_claim_10_7_after 1234656050
// STATE CLOCK staker_paid_claim_10_8_before 1234656055
// StakerNumbers incentive paid claim 8/10
// - Gas Used: 11574676
// - Storage Diff: 0
// - CPU Cycles: 11043638
// STATE CLOCK staker_paid_claim_10_8_after 1234656055
// STATE CLOCK staker_paid_claim_10_9_before 1234656060
// StakerNumbers incentive paid claim 9/10
// - Gas Used: 11641432
// - Storage Diff: 0
// - CPU Cycles: 11110394
// STATE CLOCK staker_paid_claim_10_9_after 1234656060
// STATE CLOCK staker_paid_claim_10_10_before 1234656065
// StakerNumbers incentive paid claim 10/10
// - Gas Used: 11578458
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_10_10_after 1234656065
// STATE staker-numerics incentive after_paid_claims_10 g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568245:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 194 1234568245 100000000000 90000000000000 89999247685190 225694443 526620367 0 3938453320844195178974243141571391336296296296 false 752314810 1234656065 1 500000000
// STATE CLOCK staker_paid_claim_100_1_before 1234656070
// StakerNumbers incentive paid claim 1/100
// - Gas Used: 11578458
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_1_after 1234656070
// STATE CLOCK staker_paid_claim_100_2_before 1234656075
// StakerNumbers incentive paid claim 2/100
// - Gas Used: 11577484
// - Storage Diff: 0
// - CPU Cycles: 11046446
// STATE CLOCK staker_paid_claim_100_2_after 1234656075
// STATE CLOCK staker_paid_claim_100_3_before 1234656080
// StakerNumbers incentive paid claim 3/100
// - Gas Used: 11640960
// - Storage Diff: 5
// - CPU Cycles: 11109907
// - Realm gno.land/r/onbloc/bar: 5
// STATE CLOCK staker_paid_claim_100_3_after 1234656080
// STATE CLOCK staker_paid_claim_100_4_before 1234656085
// StakerNumbers incentive paid claim 4/100
// - Gas Used: 11578749
// - Storage Diff: 41
// - CPU Cycles: 11047420
// - Realm gno.land/r/onbloc/bar: 41
// STATE CLOCK staker_paid_claim_100_4_after 1234656085
// STATE CLOCK staker_paid_claim_100_5_before 1234656090
// StakerNumbers incentive paid claim 5/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_5_after 1234656090
// STATE CLOCK staker_paid_claim_100_6_before 1234656095
// StakerNumbers incentive paid claim 6/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_6_after 1234656095
// STATE CLOCK staker_paid_claim_100_7_before 1234656100
// StakerNumbers incentive paid claim 7/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_7_after 1234656100
// STATE CLOCK staker_paid_claim_100_8_before 1234656105
// StakerNumbers incentive paid claim 8/100
// - Gas Used: 11577778
// - Storage Diff: 0
// - CPU Cycles: 11046446
// STATE CLOCK staker_paid_claim_100_8_after 1234656105
// STATE CLOCK staker_paid_claim_100_9_before 1234656110
// StakerNumbers incentive paid claim 9/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_9_after 1234656110
// STATE CLOCK staker_paid_claim_100_10_before 1234656115
// StakerNumbers incentive paid claim 10/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_10_after 1234656115
// STATE CLOCK staker_paid_claim_100_11_before 1234656120
// StakerNumbers incentive paid claim 11/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_11_after 1234656120
// STATE CLOCK staker_paid_claim_100_12_before 1234656125
// StakerNumbers incentive paid claim 12/100
// - Gas Used: 11640752
// - Storage Diff: 0
// - CPU Cycles: 11109420
// STATE CLOCK staker_paid_claim_100_12_after 1234656125
// STATE CLOCK staker_paid_claim_100_13_before 1234656130
// StakerNumbers incentive paid claim 13/100
// - Gas Used: 11574970
// - Storage Diff: 0
// - CPU Cycles: 11043638
// STATE CLOCK staker_paid_claim_100_13_after 1234656130
// STATE CLOCK staker_paid_claim_100_14_before 1234656135
// StakerNumbers incentive paid claim 14/100
// - Gas Used: 11573996
// - Storage Diff: 0
// - CPU Cycles: 11042664
// STATE CLOCK staker_paid_claim_100_14_after 1234656135
// STATE CLOCK staker_paid_claim_100_15_before 1234656140
// StakerNumbers incentive paid claim 15/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_15_after 1234656140
// STATE CLOCK staker_paid_claim_100_16_before 1234656145
// StakerNumbers incentive paid claim 16/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_16_after 1234656145
// STATE CLOCK staker_paid_claim_100_17_before 1234656150
// StakerNumbers incentive paid claim 17/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_17_after 1234656150
// STATE CLOCK staker_paid_claim_100_18_before 1234656155
// StakerNumbers incentive paid claim 18/100
// - Gas Used: 11641726
// - Storage Diff: 0
// - CPU Cycles: 11110394
// STATE CLOCK staker_paid_claim_100_18_after 1234656155
// STATE CLOCK staker_paid_claim_100_19_before 1234656160
// StakerNumbers incentive paid claim 19/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_19_after 1234656160
// STATE CLOCK staker_paid_claim_100_20_before 1234656165
// StakerNumbers incentive paid claim 20/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_20_after 1234656165
// STATE CLOCK staker_paid_claim_100_21_before 1234656170
// StakerNumbers incentive paid claim 21/100
// - Gas Used: 11641726
// - Storage Diff: 0
// - CPU Cycles: 11110394
// STATE CLOCK staker_paid_claim_100_21_after 1234656170
// STATE CLOCK staker_paid_claim_100_22_before 1234656175
// StakerNumbers incentive paid claim 22/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_22_after 1234656175
// STATE CLOCK staker_paid_claim_100_23_before 1234656180
// StakerNumbers incentive paid claim 23/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_23_after 1234656180
// STATE CLOCK staker_paid_claim_100_24_before 1234656185
// StakerNumbers incentive paid claim 24/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_24_after 1234656185
// STATE CLOCK staker_paid_claim_100_25_before 1234656190
// StakerNumbers incentive paid claim 25/100
// - Gas Used: 11640752
// - Storage Diff: 0
// - CPU Cycles: 11109420
// STATE CLOCK staker_paid_claim_100_25_after 1234656190
// STATE CLOCK staker_paid_claim_100_26_before 1234656195
// StakerNumbers incentive paid claim 26/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_26_after 1234656195
// STATE CLOCK staker_paid_claim_100_27_before 1234656200
// StakerNumbers incentive paid claim 27/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_27_after 1234656200
// STATE CLOCK staker_paid_claim_100_28_before 1234656205
// StakerNumbers incentive paid claim 28/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_28_after 1234656205
// STATE CLOCK staker_paid_claim_100_29_before 1234656210
// StakerNumbers incentive paid claim 29/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_29_after 1234656210
// STATE CLOCK staker_paid_claim_100_30_before 1234656215
// StakerNumbers incentive paid claim 30/100
// - Gas Used: 11573996
// - Storage Diff: 0
// - CPU Cycles: 11042664
// STATE CLOCK staker_paid_claim_100_30_after 1234656215
// STATE CLOCK staker_paid_claim_100_31_before 1234656220
// StakerNumbers incentive paid claim 31/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_31_after 1234656220
// STATE CLOCK staker_paid_claim_100_32_before 1234656225
// StakerNumbers incentive paid claim 32/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_32_after 1234656225
// STATE CLOCK staker_paid_claim_100_33_before 1234656230
// StakerNumbers incentive paid claim 33/100
// - Gas Used: 11577778
// - Storage Diff: 0
// - CPU Cycles: 11046446
// STATE CLOCK staker_paid_claim_100_33_after 1234656230
// STATE CLOCK staker_paid_claim_100_34_before 1234656235
// StakerNumbers incentive paid claim 34/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_34_after 1234656235
// STATE CLOCK staker_paid_claim_100_35_before 1234656240
// StakerNumbers incentive paid claim 35/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_35_after 1234656240
// STATE CLOCK staker_paid_claim_100_36_before 1234656245
// StakerNumbers incentive paid claim 36/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_36_after 1234656245
// STATE CLOCK staker_paid_claim_100_37_before 1234656250
// StakerNumbers incentive paid claim 37/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_37_after 1234656250
// STATE CLOCK staker_paid_claim_100_38_before 1234656255
// StakerNumbers incentive paid claim 38/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_38_after 1234656255
// STATE CLOCK staker_paid_claim_100_39_before 1234656260
// StakerNumbers incentive paid claim 39/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_39_after 1234656260
// STATE CLOCK staker_paid_claim_100_40_before 1234656265
// StakerNumbers incentive paid claim 40/100
// - Gas Used: 11641726
// - Storage Diff: 0
// - CPU Cycles: 11110394
// STATE CLOCK staker_paid_claim_100_40_after 1234656265
// STATE CLOCK staker_paid_claim_100_41_before 1234656270
// StakerNumbers incentive paid claim 41/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_41_after 1234656270
// STATE CLOCK staker_paid_claim_100_42_before 1234656275
// StakerNumbers incentive paid claim 42/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_42_after 1234656275
// STATE CLOCK staker_paid_claim_100_43_before 1234656280
// StakerNumbers incentive paid claim 43/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_43_after 1234656280
// STATE CLOCK staker_paid_claim_100_44_before 1234656285
// StakerNumbers incentive paid claim 44/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_44_after 1234656285
// STATE CLOCK staker_paid_claim_100_45_before 1234656290
// StakerNumbers incentive paid claim 45/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_45_after 1234656290
// STATE CLOCK staker_paid_claim_100_46_before 1234656295
// StakerNumbers incentive paid claim 46/100
// - Gas Used: 11574970
// - Storage Diff: 0
// - CPU Cycles: 11043638
// STATE CLOCK staker_paid_claim_100_46_after 1234656295
// STATE CLOCK staker_paid_claim_100_47_before 1234656300
// StakerNumbers incentive paid claim 47/100
// - Gas Used: 11632515
// - Storage Diff: 0
// - CPU Cycles: 11101183
// STATE CLOCK staker_paid_claim_100_47_after 1234656300
// STATE CLOCK staker_paid_claim_100_48_before 1234656305
// StakerNumbers incentive paid claim 48/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_48_after 1234656305
// STATE CLOCK staker_paid_claim_100_49_before 1234656310
// StakerNumbers incentive paid claim 49/100
// - Gas Used: 11577778
// - Storage Diff: 0
// - CPU Cycles: 11046446
// STATE CLOCK staker_paid_claim_100_49_after 1234656310
// STATE CLOCK staker_paid_claim_100_50_before 1234656315
// StakerNumbers incentive paid claim 50/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_50_after 1234656315
// STATE CLOCK staker_paid_claim_100_51_before 1234656320
// StakerNumbers incentive paid claim 51/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_51_after 1234656320
// STATE CLOCK staker_paid_claim_100_52_before 1234656325
// StakerNumbers incentive paid claim 52/100
// - Gas Used: 11577778
// - Storage Diff: 0
// - CPU Cycles: 11046446
// STATE CLOCK staker_paid_claim_100_52_after 1234656325
// STATE CLOCK staker_paid_claim_100_53_before 1234656330
// StakerNumbers incentive paid claim 53/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_53_after 1234656330
// STATE CLOCK staker_paid_claim_100_54_before 1234656335
// StakerNumbers incentive paid claim 54/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_54_after 1234656335
// STATE CLOCK staker_paid_claim_100_55_before 1234656340
// StakerNumbers incentive paid claim 55/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_55_after 1234656340
// STATE CLOCK staker_paid_claim_100_56_before 1234656345
// StakerNumbers incentive paid claim 56/100
// - Gas Used: 11640752
// - Storage Diff: 0
// - CPU Cycles: 11109420
// STATE CLOCK staker_paid_claim_100_56_after 1234656345
// STATE CLOCK staker_paid_claim_100_57_before 1234656350
// StakerNumbers incentive paid claim 57/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_57_after 1234656350
// STATE CLOCK staker_paid_claim_100_58_before 1234656355
// StakerNumbers incentive paid claim 58/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_58_after 1234656355
// STATE CLOCK staker_paid_claim_100_59_before 1234656360
// StakerNumbers incentive paid claim 59/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_59_after 1234656360
// STATE CLOCK staker_paid_claim_100_60_before 1234656365
// StakerNumbers incentive paid claim 60/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_60_after 1234656365
// STATE CLOCK staker_paid_claim_100_61_before 1234656370
// StakerNumbers incentive paid claim 61/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_61_after 1234656370
// STATE CLOCK staker_paid_claim_100_62_before 1234656375
// StakerNumbers incentive paid claim 62/100
// - Gas Used: 11637944
// - Storage Diff: 0
// - CPU Cycles: 11106612
// STATE CLOCK staker_paid_claim_100_62_after 1234656375
// STATE CLOCK staker_paid_claim_100_63_before 1234656380
// StakerNumbers incentive paid claim 63/100
// - Gas Used: 11574970
// - Storage Diff: 0
// - CPU Cycles: 11043638
// STATE CLOCK staker_paid_claim_100_63_after 1234656380
// STATE CLOCK staker_paid_claim_100_64_before 1234656385
// StakerNumbers incentive paid claim 64/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_64_after 1234656385
// STATE CLOCK staker_paid_claim_100_65_before 1234656390
// StakerNumbers incentive paid claim 65/100
// - Gas Used: 11641726
// - Storage Diff: 0
// - CPU Cycles: 11110394
// STATE CLOCK staker_paid_claim_100_65_after 1234656390
// STATE CLOCK staker_paid_claim_100_66_before 1234656395
// StakerNumbers incentive paid claim 66/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_66_after 1234656395
// STATE CLOCK staker_paid_claim_100_67_before 1234656400
// StakerNumbers incentive paid claim 67/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_67_after 1234656400
// STATE CLOCK staker_paid_claim_100_68_before 1234656405
// StakerNumbers incentive paid claim 68/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_68_after 1234656405
// STATE CLOCK staker_paid_claim_100_69_before 1234656410
// StakerNumbers incentive paid claim 69/100
// - Gas Used: 11640752
// - Storage Diff: 0
// - CPU Cycles: 11109420
// STATE CLOCK staker_paid_claim_100_69_after 1234656410
// STATE CLOCK staker_paid_claim_100_70_before 1234656415
// StakerNumbers incentive paid claim 70/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_70_after 1234656415
// STATE CLOCK staker_paid_claim_100_71_before 1234656420
// StakerNumbers incentive paid claim 71/100
// - Gas Used: 11577778
// - Storage Diff: 0
// - CPU Cycles: 11046446
// STATE CLOCK staker_paid_claim_100_71_after 1234656420
// STATE CLOCK staker_paid_claim_100_72_before 1234656425
// StakerNumbers incentive paid claim 72/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_72_after 1234656425
// STATE CLOCK staker_paid_claim_100_73_before 1234656430
// StakerNumbers incentive paid claim 73/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_73_after 1234656430
// STATE CLOCK staker_paid_claim_100_74_before 1234656435
// StakerNumbers incentive paid claim 74/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_74_after 1234656435
// STATE CLOCK staker_paid_claim_100_75_before 1234656440
// StakerNumbers incentive paid claim 75/100
// - Gas Used: 11640752
// - Storage Diff: 0
// - CPU Cycles: 11109420
// STATE CLOCK staker_paid_claim_100_75_after 1234656440
// STATE CLOCK staker_paid_claim_100_76_before 1234656445
// StakerNumbers incentive paid claim 76/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_76_after 1234656445
// STATE CLOCK staker_paid_claim_100_77_before 1234656450
// StakerNumbers incentive paid claim 77/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_77_after 1234656450
// STATE CLOCK staker_paid_claim_100_78_before 1234656455
// StakerNumbers incentive paid claim 78/100
// - Gas Used: 11637944
// - Storage Diff: 0
// - CPU Cycles: 11106612
// STATE CLOCK staker_paid_claim_100_78_after 1234656455
// STATE CLOCK staker_paid_claim_100_79_before 1234656460
// StakerNumbers incentive paid claim 79/100
// - Gas Used: 11574970
// - Storage Diff: 0
// - CPU Cycles: 11043638
// STATE CLOCK staker_paid_claim_100_79_after 1234656460
// STATE CLOCK staker_paid_claim_100_80_before 1234656465
// StakerNumbers incentive paid claim 80/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_80_after 1234656465
// STATE CLOCK staker_paid_claim_100_81_before 1234656470
// StakerNumbers incentive paid claim 81/100
// - Gas Used: 11641726
// - Storage Diff: 0
// - CPU Cycles: 11110394
// STATE CLOCK staker_paid_claim_100_81_after 1234656470
// STATE CLOCK staker_paid_claim_100_82_before 1234656475
// StakerNumbers incentive paid claim 82/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_82_after 1234656475
// STATE CLOCK staker_paid_claim_100_83_before 1234656480
// StakerNumbers incentive paid claim 83/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_83_after 1234656480
// STATE CLOCK staker_paid_claim_100_84_before 1234656485
// StakerNumbers incentive paid claim 84/100
// - Gas Used: 11641726
// - Storage Diff: 0
// - CPU Cycles: 11110394
// STATE CLOCK staker_paid_claim_100_84_after 1234656485
// STATE CLOCK staker_paid_claim_100_85_before 1234656490
// StakerNumbers incentive paid claim 85/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_85_after 1234656490
// STATE CLOCK staker_paid_claim_100_86_before 1234656495
// StakerNumbers incentive paid claim 86/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_86_after 1234656495
// STATE CLOCK staker_paid_claim_100_87_before 1234656500
// StakerNumbers incentive paid claim 87/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_87_after 1234656500
// STATE CLOCK staker_paid_claim_100_88_before 1234656505
// StakerNumbers incentive paid claim 88/100
// - Gas Used: 11640752
// - Storage Diff: 0
// - CPU Cycles: 11109420
// STATE CLOCK staker_paid_claim_100_88_after 1234656505
// STATE CLOCK staker_paid_claim_100_89_before 1234656510
// StakerNumbers incentive paid claim 89/100
// - Gas Used: 11578265
// - Storage Diff: 0
// - CPU Cycles: 11046933
// STATE CLOCK staker_paid_claim_100_89_after 1234656510
// STATE CLOCK staker_paid_claim_100_90_before 1234656515
// StakerNumbers incentive paid claim 90/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_90_after 1234656515
// STATE CLOCK staker_paid_claim_100_91_before 1234656520
// StakerNumbers incentive paid claim 91/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_91_after 1234656520
// STATE CLOCK staker_paid_claim_100_92_before 1234656525
// StakerNumbers incentive paid claim 92/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_92_after 1234656525
// STATE CLOCK staker_paid_claim_100_93_before 1234656530
// StakerNumbers incentive paid claim 93/100
// - Gas Used: 11577291
// - Storage Diff: 0
// - CPU Cycles: 11045959
// STATE CLOCK staker_paid_claim_100_93_after 1234656530
// STATE CLOCK staker_paid_claim_100_94_before 1234656535
// StakerNumbers incentive paid claim 94/100
// - Gas Used: 11640752
// - Storage Diff: 0
// - CPU Cycles: 11109420
// STATE CLOCK staker_paid_claim_100_94_after 1234656535
// STATE CLOCK staker_paid_claim_100_95_before 1234656540
// StakerNumbers incentive paid claim 95/100
// - Gas Used: 11574970
// - Storage Diff: 0
// - CPU Cycles: 11043638
// STATE CLOCK staker_paid_claim_100_95_after 1234656540
// STATE CLOCK staker_paid_claim_100_96_before 1234656545
// StakerNumbers incentive paid claim 96/100
// - Gas Used: 11577778
// - Storage Diff: 0
// - CPU Cycles: 11046446
// STATE CLOCK staker_paid_claim_100_96_after 1234656545
// STATE CLOCK staker_paid_claim_100_97_before 1234656550
// StakerNumbers incentive paid claim 97/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_97_after 1234656550
// STATE CLOCK staker_paid_claim_100_98_before 1234656555
// StakerNumbers incentive paid claim 98/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_98_after 1234656555
// STATE CLOCK staker_paid_claim_100_99_before 1234656560
// StakerNumbers incentive paid claim 99/100
// - Gas Used: 11578752
// - Storage Diff: 0
// - CPU Cycles: 11047420
// STATE CLOCK staker_paid_claim_100_99_after 1234656560
// STATE CLOCK staker_paid_claim_100_100_before 1234656565
// StakerNumbers incentive paid claim 100/100
// - Gas Used: 11641239
// - Storage Diff: 0
// - CPU Cycles: 11109907
// STATE CLOCK staker_paid_claim_100_100_after 1234656565
// STATE staker-numerics incentive after_paid_claims_100 g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568245:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 194 1234568245 100000000000 90000000000000 89993460648190 1961805543 4577546267 0 3938453320844195178974243141571391336296296296 false 6539351810 1234656565 1 500000000
// STATE CLOCK staker_incentive_end_before 1242432010
// StakerNumbers incentive end
// - Gas Used: 1925202
// - Storage Diff: 36
// - CPU Cycles: 1754520
// - Realm gno.land/r/gnoswap/staker: 24
// - Realm gno.land/r/onbloc/bar: 12
// STATE CLOCK staker_incentive_end_after 1242432010
// STATE staker-numerics incentive after_end g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568245:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 194 1234568245 100000000000 90000000000000 89993460648189 1961805544 4577546267 0 3938453320844195178974243141571391336296296296 true 6539351810 1234656565 1 500000000
// STATE CLOCK staker_unstake_wide_before 1242432015
// StakerNumbers deposit unstake delete
// - Gas Used: 55843851
// - Storage Diff: -16120
// - CPU Cycles: 53533181
// - Realm gno.land/r/gnoswap/gnft: 2055
// - Realm gno.land/r/gnoswap/gns: 14
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -17278
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_wide_after 1242432015
// STATE staker-numerics deposit after_unstake 1 present=false pool_staked=0
// STATE CLOCK staker_unstake_boundary_1_before 1242432020
// StakerNumbers deposit unstake boundary allocation 1/32
// - Gas Used: 42459076
// - Storage Diff: -13859
// - CPU Cycles: 40646057
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_1_after 1242432020
// STATE CLOCK staker_unstake_boundary_2_before 1242432025
// StakerNumbers deposit unstake boundary allocation 2/32
// - Gas Used: 42748874
// - Storage Diff: -13859
// - CPU Cycles: 40932697
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_2_after 1242432025
// STATE CLOCK staker_unstake_boundary_3_before 1242432030
// StakerNumbers deposit unstake boundary allocation 3/32
// - Gas Used: 42750983
// - Storage Diff: -13859
// - CPU Cycles: 40937815
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_3_after 1242432030
// STATE CLOCK staker_unstake_boundary_4_before 1242432035
// StakerNumbers deposit unstake boundary allocation 4/32
// - Gas Used: 42708981
// - Storage Diff: -13859
// - CPU Cycles: 40905486
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_4_after 1242432035
// STATE CLOCK staker_unstake_boundary_5_before 1242432040
// StakerNumbers deposit unstake boundary allocation 5/32
// - Gas Used: 42717937
// - Storage Diff: -13859
// - CPU Cycles: 40917538
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_5_after 1242432040
// STATE CLOCK staker_unstake_boundary_6_before 1242432045
// StakerNumbers deposit unstake boundary allocation 6/32
// - Gas Used: 42715376
// - Storage Diff: -13859
// - CPU Cycles: 40918160
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_6_after 1242432045
// STATE CLOCK staker_unstake_boundary_7_before 1242432050
// StakerNumbers deposit unstake boundary allocation 7/32
// - Gas Used: 42854913
// - Storage Diff: -13847
// - CPU Cycles: 41017173
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12936
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_7_after 1242432050
// STATE CLOCK staker_unstake_boundary_8_before 1242432055
// StakerNumbers deposit unstake boundary allocation 8/32
// - Gas Used: 42962795
// - Storage Diff: -17327
// - CPU Cycles: 41111355
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -16416
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_8_after 1242432055
// STATE CLOCK staker_unstake_boundary_9_before 1242432060
// StakerNumbers deposit unstake boundary allocation 9/32
// - Gas Used: 42789608
// - Storage Diff: -13859
// - CPU Cycles: 40952767
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_9_after 1242432060
// STATE CLOCK staker_unstake_boundary_10_before 1242432065
// StakerNumbers deposit unstake boundary allocation 10/32
// - Gas Used: 42766956
// - Storage Diff: -13859
// - CPU Cycles: 40933298
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_10_after 1242432065
// STATE CLOCK staker_unstake_boundary_11_before 1242432070
// StakerNumbers deposit unstake boundary allocation 11/32
// - Gas Used: 42767535
// - Storage Diff: -13859
// - CPU Cycles: 40936973
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_11_after 1242432070
// STATE CLOCK staker_unstake_boundary_12_before 1242432075
// StakerNumbers deposit unstake boundary allocation 12/32
// - Gas Used: 42722206
// - Storage Diff: -13859
// - CPU Cycles: 40901227
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_12_after 1242432075
// STATE CLOCK staker_unstake_boundary_13_before 1242432080
// StakerNumbers deposit unstake boundary allocation 13/32
// - Gas Used: 42723246
// - Storage Diff: -13859
// - CPU Cycles: 40905363
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_13_after 1242432080
// STATE CLOCK staker_unstake_boundary_14_before 1242432085
// StakerNumbers deposit unstake boundary allocation 14/32
// - Gas Used: 42722072
// - Storage Diff: -17337
// - CPU Cycles: 40916855
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -16426
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_14_after 1242432085
// STATE CLOCK staker_unstake_boundary_15_before 1242432090
// StakerNumbers deposit unstake boundary allocation 15/32
// - Gas Used: 42604194
// - Storage Diff: -13859
// - CPU Cycles: 40806695
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_15_after 1242432090
// STATE CLOCK staker_unstake_boundary_16_before 1242432095
// StakerNumbers deposit unstake boundary allocation 16/32
// - Gas Used: 42726074
// - Storage Diff: -13859
// - CPU Cycles: 40902998
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_16_after 1242432095
// STATE CLOCK staker_unstake_boundary_17_before 1242432100
// StakerNumbers deposit unstake boundary allocation 17/32
// - Gas Used: 43297648
// - Storage Diff: -13859
// - CPU Cycles: 41465485
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_17_after 1242432100
// STATE CLOCK staker_unstake_boundary_18_before 1242432105
// StakerNumbers deposit unstake boundary allocation 18/32
// - Gas Used: 42748997
// - Storage Diff: -20469
// - CPU Cycles: 40945344
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -19558
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_18_after 1242432105
// STATE CLOCK staker_unstake_boundary_19_before 1242432110
// StakerNumbers deposit unstake boundary allocation 19/32
// - Gas Used: 42492524
// - Storage Diff: -13859
// - CPU Cycles: 40699490
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_19_after 1242432110
// STATE CLOCK staker_unstake_boundary_20_before 1242432115
// StakerNumbers deposit unstake boundary allocation 20/32
// - Gas Used: 42317812
// - Storage Diff: -13859
// - CPU Cycles: 40535748
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_20_after 1242432115
// STATE CLOCK staker_unstake_boundary_21_before 1242432120
// StakerNumbers deposit unstake boundary allocation 21/32
// - Gas Used: 42613355
// - Storage Diff: -13859
// - CPU Cycles: 40825213
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_21_after 1242432120
// STATE CLOCK staker_unstake_boundary_22_before 1242432125
// StakerNumbers deposit unstake boundary allocation 22/32
// - Gas Used: 42441445
// - Storage Diff: -20287
// - CPU Cycles: 40661241
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -19376
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_22_after 1242432125
// STATE CLOCK staker_unstake_boundary_23_before 1242432130
// StakerNumbers deposit unstake boundary allocation 23/32
// - Gas Used: 42323508
// - Storage Diff: -13859
// - CPU Cycles: 40558300
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_23_after 1242432130
// STATE CLOCK staker_unstake_boundary_24_before 1242432135
// StakerNumbers deposit unstake boundary allocation 24/32
// - Gas Used: 42139004
// - Storage Diff: -13859
// - CPU Cycles: 40378540
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_24_after 1242432135
// STATE CLOCK staker_unstake_boundary_25_before 1242432140
// StakerNumbers deposit unstake boundary allocation 25/32
// - Gas Used: 42518218
// - Storage Diff: -13859
// - CPU Cycles: 40756428
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_25_after 1242432140
// STATE CLOCK staker_unstake_boundary_26_before 1242432145
// StakerNumbers deposit unstake boundary allocation 26/32
// - Gas Used: 42070818
// - Storage Diff: -13859
// - CPU Cycles: 40322946
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_26_after 1242432145
// STATE CLOCK staker_unstake_boundary_27_before 1242432150
// StakerNumbers deposit unstake boundary allocation 27/32
// - Gas Used: 42211488
// - Storage Diff: -13859
// - CPU Cycles: 40452792
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12948
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_27_after 1242432150
// STATE CLOCK staker_unstake_boundary_28_before 1242432155
// StakerNumbers deposit unstake boundary allocation 28/32
// - Gas Used: 42085773
// - Storage Diff: -13873
// - CPU Cycles: 40331638
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12962
// - Realm gno.land/r/gnoswap/staker/v1: -867
// STATE CLOCK staker_unstake_boundary_28_after 1242432155
// STATE CLOCK staker_unstake_boundary_29_before 1242432160
// StakerNumbers deposit unstake boundary allocation 29/32
// - Gas Used: 42347364
// - Storage Diff: -13915
// - CPU Cycles: 40593161
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -12999
// - Realm gno.land/r/gnoswap/staker/v1: -872
// STATE CLOCK staker_unstake_boundary_29_after 1242432160
// STATE CLOCK staker_unstake_boundary_30_before 1242432165
// StakerNumbers deposit unstake boundary allocation 30/32
// - Gas Used: 42029262
// - Storage Diff: -13916
// - CPU Cycles: 40281289
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -13000
// - Realm gno.land/r/gnoswap/staker/v1: -872
// STATE CLOCK staker_unstake_boundary_30_after 1242432165
// STATE CLOCK staker_unstake_boundary_31_before 1242432170
// StakerNumbers deposit unstake boundary allocation 31/32
// - Gas Used: 42126220
// - Storage Diff: -13917
// - CPU Cycles: 40379875
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -13001
// - Realm gno.land/r/gnoswap/staker/v1: -872
// STATE CLOCK staker_unstake_boundary_31_after 1242432170
// STATE CLOCK staker_unstake_boundary_32_before 1242432175
// StakerNumbers deposit unstake boundary allocation 32/32
// - Gas Used: 41956306
// - Storage Diff: -31220
// - CPU Cycles: 40209469
// - Realm gno.land/r/gnoswap/gnft: -2055
// - Realm gno.land/r/gnoswap/position: -44
// - Realm gno.land/r/gnoswap/staker: -28249
// - Realm gno.land/r/gnoswap/staker/v1: -872
// STATE CLOCK staker_unstake_boundary_32_after 1242432175
// STATE staker-numerics cleanup after_unstake_all active_deposits=0 active_rewards=0 active_ticks=0 pending_protocol_fee_tokens=0 historical_ticks=4 pool_staked=0
// STATE CLOCK staker_lifecycle_after 1242432175
