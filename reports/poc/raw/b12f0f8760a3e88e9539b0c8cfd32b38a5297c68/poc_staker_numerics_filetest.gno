// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Real-contract PoC for value-backed staker numerics. The fixture exercises
// deposit creation and repeated updates, signed tick crossing, and external
// incentive creation/collection/refund before deleting the deposit.
//
// The 32-position lower-tick ladder is large enough to span multiple tree
// nodes while keeping this single lifecycle executable; the high reward amount
// remains below the BAR fixture's finite 100T supply.
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	"gno.land/p/gnoswap/gnsmath"
	u256 "gno.land/p/gnoswap/uint256"
	prbac "gno.land/p/gnoswap/rbac"
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
	numericBoundaryCount int32  = 32
	numericTickSpacing    int32  = 60
	numericBoundaryUpper int32  = 6000
	numericWideAmount     string = "500000000"
	numericBoundaryAmount string = "1000000"
	numericRewardAmount   int64  = 90000000000000
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
	initializeStakerNumericSetup(cur)
	createStakerNumericPool(cur)
	mintStakerNumericPositions(cur)
	stakeStakerNumericPositions(cur)
	measureStakerNumericDeposits(cur)
	measureStakerNumericTicks(cur)
	measureStakerNumericIncentive(cur)
}

func initializeStakerNumericSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pl.SetPoolCreationFee(cross(cur), 0)
	staker.SetUnStakingFee(cross(cur), 0)
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

	testing.SkipHeights(1)
	metric.PrintMetricsBy("StakerNumbers deposit stake wide (first allocation)", func() {
		staker.StakeToken(cross(cur), widePositionID, "")
	})
	if !staker.IsStaked(widePositionID) {
		panic("wide position was not staked")
	}

	testing.SkipHeights(1)
	metric.PrintMetricsBy("StakerNumbers deposit stake boundary (first allocation)", func() {
		staker.StakeToken(cross(cur), narrowPositionID, "")
	})
	if !staker.IsStaked(narrowPositionID) {
		panic("narrow position was not staked")
	}

	testing.SkipHeights(1)
	metric.PrintMetricsBy("StakerNumbers deposit stake boundary (31 allocations)", func() {
		for i := 1; i < len(numericPositionIDs); i++ {
			testing.SkipHeights(1)
			staker.StakeToken(cross(cur), numericPositionIDs[i], "")
		}
	})
	assertStakerNumericAggregate("after_stake", false)
	printStakerNumericDepositState("after_stake", widePositionID)
	printStakerNumericDepositState("after_stake_boundary_first", narrowPositionID)
	printStakerNumericDepositState("after_stake_boundary_last", numericPositionIDs[len(numericPositionIDs)-1])
}

func measureStakerNumericDeposits(cur realm) {
	testing.SetRealm(aliceRealm)
	testing.SkipHeights(1)
	metric.PrintMetricsBy("StakerNumbers deposit collect", func() {
		staker.CollectReward(cross(cur), widePositionID)
	})
	if !staker.IsStaked(widePositionID) {
		panic("collect removed the wide deposit")
	}
	assertStakerNumericAggregate("after_collect", false)
	printStakerNumericDepositState("after_collect", widePositionID)

	testing.SkipHeights(1)
	metric.PrintMetricsBy("StakerNumbers deposit collect repeat", func() {
		staker.CollectReward(cross(cur), widePositionID)
	})
	if !staker.IsStaked(widePositionID) {
		panic("repeat collect removed the wide deposit")
	}
	assertStakerNumericAggregate("after_collect_repeat", false)
	printStakerNumericDepositState("after_collect_repeat", widePositionID)

	// Rewrite every staged deposit once after its first allocation. Keeping
	// this separate from the stake metrics isolates value-field rewrites.
	testing.SkipHeights(1)
	metric.PrintMetricsBy("StakerNumbers deposit collect batch rewrite (32 deposits)", func() {
		for _, positionID := range numericPositionIDs {
			testing.SkipHeights(1)
			staker.CollectReward(cross(cur), positionID)
		}
	})
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
	metric.PrintMetricsBy("StakerNumbers tick cross positive (32 lower ticks)", func() {
		pl.Swap(
			cross(cur), barPath, fooPath, 3000, adminAddr, false,
			"500000000", gnsmath.TickMathGetSqrtRatioAtTick(numericBoundaryCount*numericTickSpacing + 1).ToString(),
			stakerNumericSwapCallback,
		)
	})
	currentTick, _ := pl.GetSlot0Tick(poolPath)
	if currentTick < numericBoundaryCount*numericTickSpacing || currentTick >= numericBoundaryUpper {
		panic("positive swap did not activate all staged lower ticks")
	}
	printStakerNumericTickState("after_positive_cross", true)

	metric.PrintMetricsBy("StakerNumbers tick cross positive upper rewrite", func() {
		pl.Swap(
			cross(cur), barPath, fooPath, 3000, adminAddr, false,
			"500000000", gnsmath.TickMathGetSqrtRatioAtTick(numericBoundaryUpper+1).ToString(),
			stakerNumericSwapCallback,
		)
	})
	currentTick, _ = pl.GetSlot0Tick(poolPath)
	if currentTick < numericBoundaryUpper {
		panic("positive swap did not cross the shared upper tick")
	}
	printStakerNumericTickState("after_upper_cross", false)

	metric.PrintMetricsBy("StakerNumbers tick cross negative (32 lower ticks)", func() {
		pl.Swap(
			cross(cur), barPath, fooPath, 3000, adminAddr, true,
			"500000000", gnsmath.TickMathGetSqrtRatioAtTick(59).ToString(),
			stakerNumericSwapCallback,
		)
	})
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

	metric.PrintMetricsBy("StakerNumbers incentive create", func() {
		staker.CreateExternalIncentive(
			cross(cur), poolPath, barPath, numericRewardAmount,
			incentiveStart, incentiveEnd,
		)
	})

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
	metric.PrintMetricsBy("StakerNumbers incentive collect", func() {
		staker.CollectExternalIncentiveReward(cross(cur), widePositionID, incentiveID)
	})
	if !staker.IsStaked(widePositionID) {
		panic("external collect removed the wide deposit")
	}
	printStakerNumericIncentiveState("after_collect")

	testing.SkipHeights((incentiveEnd-time.Now().Unix())/5 + 2)
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("StakerNumbers incentive end", func() {
		staker.EndExternalIncentive(cross(cur), poolPath, incentiveID, adminAddr)
	})
	refunded, err := staker.GetIncentiveRefunded(poolPath, incentiveID)
	if err != nil || !refunded {
		panic("external incentive was not refunded")
	}
	printStakerNumericIncentiveState("after_end")

	testing.SetRealm(aliceRealm)
	metric.PrintMetricsBy("StakerNumbers deposit unstake delete", func() {
		staker.UnStakeToken(cross(cur), widePositionID)
	})
	if staker.IsStaked(widePositionID) {
		panic("unstake did not delete the wide deposit")
	}
	poolStaked, err := staker.GetPoolStakedLiquidity(poolPath)
	if err != nil {
		panic("failed to read pool liquidity after unstake")
	}
	if u256.MustFromDecimal(poolStaked).Sign() != 0 {
		panic("wide unstake left active pool liquidity")
	}
	println(ufmt.Sprintf("STATE staker-numerics deposit after_unstake %d present=false pool_staked=%s", widePositionID, poolStaked))
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
// StakerNumbers deposit stake wide (first allocation)
// - Gas Used: 16445968
// - Storage Diff: 35653
// - CPU Cycles: 15040606
// StakerNumbers deposit stake boundary (first allocation)
// - Gas Used: 14497051
// - Storage Diff: 13044
// - CPU Cycles: 13578057
// StakerNumbers deposit stake boundary (31 allocations)
// - Gas Used: 455216852
// - Storage Diff: 284182
// - CPU Cycles: 426115451
// STATE staker-numerics aggregate after_stake deposits=33 boundary_records=32 pool_staked=500000000 expected=500000000 boundary_active=false
// STATE staker-numerics deposit after_stake 1 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 500000000 1234567900 1234567900 0 -887220 887220 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE staker-numerics deposit after_stake_boundary_first 2 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 3903576 1234567905 1234567905 0 60 6000 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE staker-numerics deposit after_stake_boundary_last 33 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 5965197 1234568065 1234568065 0 1920 6000 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// StakerNumbers deposit collect
// - Gas Used: 12254913
// - Storage Diff: 2073
// - CPU Cycles: 11487797
// STATE staker-numerics aggregate after_collect deposits=33 boundary_records=32 pool_staked=500000000 expected=500000000 boundary_active=false
// STATE staker-numerics deposit after_collect 1 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 500000000 1234567900 1234568070 454837209 -887220 887220 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// StakerNumbers deposit collect repeat
// - Gas Used: 12091096
// - Storage Diff: 0
// - CPU Cycles: 11374928
// STATE staker-numerics aggregate after_collect_repeat deposits=33 boundary_records=32 pool_staked=500000000 expected=500000000 boundary_active=false
// STATE staker-numerics deposit after_collect_repeat 1 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 500000000 1234567900 1234568075 468214773 -887220 887220 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// StakerNumbers deposit collect batch rewrite (32 deposits)
// - Gas Used: 296660940
// - Storage Diff: 396
// - CPU Cycles: 277850651
// STATE staker-numerics aggregate after_batch_collect deposits=33 boundary_records=32 pool_staked=500000000 expected=500000000 boundary_active=false
// STATE staker-numerics deposit after_batch_collect_boundary_first 2 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 3903576 1234567905 1234567905 0 60 6000 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// STATE staker-numerics deposit after_batch_collect_boundary_last 33 g1v9kxjcm9ta047h6lta047h6lta047h6lzd40gh 5965197 1234568065 1234568065 0 1920 6000 gno.land/r/onbloc/bar.BAR:gno.land/r/onbloc/foo.FOO:3000 500000000
// StakerNumbers tick cross positive (32 lower ticks)
// - Gas Used: 305082520
// - Storage Diff: 106532
// - CPU Cycles: 294102902
// STATE staker-numerics tick after_positive_cross current_tick=1921 pool_staked=653902384 expected=653902384 wide_gross=500000000 boundary_gross=153902384 narrow_active=true boundary_records=32 historical_ticks=2
// StakerNumbers tick cross positive upper rewrite
// - Gas Used: 31093064
// - Storage Diff: 3266
// - CPU Cycles: 29795886
// STATE staker-numerics tick after_upper_cross current_tick=6001 pool_staked=500000000 expected=500000000 wide_gross=500000000 boundary_gross=153902384 narrow_active=false boundary_records=32 historical_ticks=2
// StakerNumbers tick cross negative (32 lower ticks)
// - Gas Used: 347508379
// - Storage Diff: 917
// - CPU Cycles: 336753576
// STATE staker-numerics tick after_negative_cross current_tick=59 pool_staked=500000000 expected=500000000 wide_gross=500000000 boundary_gross=153902384 narrow_active=false boundary_records=32 historical_ticks=2
// StakerNumbers incentive create
// - Gas Used: 3435195
// - Storage Diff: 20135
// - CPU Cycles: 3027795
// STATE staker-numerics incentive after_create g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568240:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 193 1234568240 100000000000 90000000000000 90000000000000 0 0 0 3938453320844195178974243141571391336296296296 false 0 0 0 500000000
// StakerNumbers incentive collect
// - Gas Used: 9611770
// - Storage Diff: 579
// - CPU Cycles: 9225130
// STATE staker-numerics incentive after_collect g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568240:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 193 1234568240 100000000000 90000000000000 89999884259260 34722222 81018518 0 3938453320844195178974243141571391336296296296 false 115740740 1234656010 1 500000000
// StakerNumbers incentive end
// - Gas Used: 1853144
// - Storage Diff: 24
// - CPU Cycles: 1692128
// STATE staker-numerics incentive after_end g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5:1234568240:1 gno.land/r/onbloc/bar.BAR 1234656000 1242432000 193 1234568240 100000000000 90000000000000 89999884259259 34722223 81018518 0 3938453320844195178974243141571391336296296296 true 115740740 1234656010 1 500000000
// StakerNumbers deposit unstake delete
// - Gas Used: 51630932
// - Storage Diff: -17929
// - CPU Cycles: 49665807
// STATE staker-numerics deposit after_unstake 1 present=false pool_staked=0
