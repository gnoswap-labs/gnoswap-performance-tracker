// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and storage metrics for launchpad Q128 numeric value fields.
// The fixture exercises project/tier creation, two deposits, repeated reward
// claims, and full withdrawals through the public launchpad proxy.
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/gov/staker"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/launchpad/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/onbloc/obl"
)

const (
	launchpadNumericsBlockTimeSeconds    int64 = 5
	launchpadNumericsDaySeconds          int64 = 24 * 60 * 60
	launchpadNumericsActivationDelayDays int64 = 4
	launchpadNumericsTier30              int64 = 30
	launchpadNumericsDepositAmount       int64 = 1_000_000
	launchpadNumericsProjectAmount       int64 = 1_000_000_000
)

var (
	launchpadNumericsAdminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	launchpadNumericsAdminRealm   = testing.NewUserRealm(launchpadNumericsAdminAddr)

	launchpadNumericsLaunchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	launchpadNumericsAliceAddr  = testutils.TestAddress("launchpad-numerics-alice")
	launchpadNumericsAliceRealm = testing.NewUserRealm(launchpadNumericsAliceAddr)

	launchpadNumericsProjectAddr = testutils.TestAddress("launchpad-numerics-project")

	launchpadNumericsMaxInt64 int64 = 9223372036854775807
)

func main(cur realm) {
	launchpadNumericsInitialize(cur)
	projectID, tierID := launchpadNumericsCreateProject(cur)
	launchpadNumericsAssertCreated(projectID, tierID)
	launchpadNumericsPrintState("created", projectID, "", "")

	firstDepositID, secondDepositID := launchpadNumericsDepositTwice(cur, tierID)
	launchpadNumericsAssertDeposited(projectID, tierID, firstDepositID, secondDepositID)
	launchpadNumericsPrintState("deposited-first", projectID, firstDepositID, firstDepositID)
	launchpadNumericsPrintState("deposited-second", projectID, secondDepositID, secondDepositID)

	launchpadNumericsSkipToClaimable(firstDepositID)
	firstClaim := launchpadNumericsCollectReward(cur, firstDepositID, "first")
	if firstClaim <= 0 {
		panic("first launchpad reward claim should be positive")
	}
	launchpadNumericsAssertClaimed(projectID, tierID, firstDepositID, firstClaim)
	launchpadNumericsPrintState("claimed-first", projectID, firstDepositID, firstDepositID)

	testing.SkipHeights(launchpadNumericsDaySeconds/launchpadNumericsBlockTimeSeconds + 1)
	secondClaim := launchpadNumericsCollectReward(cur, firstDepositID, "repeat")
	if secondClaim <= 0 {
		panic("repeated launchpad reward claim should be positive")
	}
	launchpadNumericsAssertRepeatedClaim(projectID, tierID, firstDepositID, firstClaim, secondClaim)
	launchpadNumericsPrintState("claimed-repeat", projectID, firstDepositID, firstDepositID)

	launchpadNumericsSkipToTierEnd(projectID)
	firstWithdrawal := launchpadNumericsCollectDeposit(cur, firstDepositID, "first")
	if firstWithdrawal != launchpadNumericsDepositAmount {
		panic("first launchpad withdrawal did not return the deposit amount")
	}
	launchpadNumericsAssertFirstWithdrawal(projectID, tierID, firstDepositID, secondDepositID)
	launchpadNumericsPrintState("withdrawn-first", projectID, "", firstDepositID)

	secondWithdrawal := launchpadNumericsCollectDeposit(cur, secondDepositID, "second")
	if secondWithdrawal != launchpadNumericsDepositAmount {
		panic("second launchpad withdrawal did not return the deposit amount")
	}
	launchpadNumericsAssertZeroActive(projectID, tierID, secondDepositID)
	launchpadNumericsPrintState("withdrawn-final-zero-active", projectID, "", secondDepositID)
}

func launchpadNumericsInitialize(cur realm) {
	testing.SetRealm(launchpadNumericsAdminRealm)
	obl.Approve(cross(cur), launchpadNumericsLaunchpadAddr, launchpadNumericsMaxInt64)
}

func launchpadNumericsCreateProject(cur realm) (string, string) {
	testing.SetRealm(launchpadNumericsAdminRealm)

	startTime := time.Now().Unix() + launchpadNumericsActivationDelayDays*launchpadNumericsDaySeconds
	projectID := ""
	metric.PrintMetricsBy("Launchpad Numerics CreateProject", func() {
		projectID = launchpad.CreateProject(
			cross(cur),
			"Launchpad Numeric Value Project",
			"gno.land/r/onbloc/obl.OBL",
			launchpadNumericsProjectAddr,
			launchpadNumericsProjectAmount,
			"",
			"",
			int64(25),
			int64(25),
			int64(50),
			startTime,
		)
	})

	launchpadNumericsSkipUntil(startTime)
	return projectID, projectID + ":30"
}

func launchpadNumericsDepositTwice(cur realm, tierID string) (string, string) {
	testing.SetRealm(launchpadNumericsAdminRealm)
	gns.Transfer(cross(cur), launchpadNumericsAliceAddr, launchpadNumericsDepositAmount*2)

	testing.SetRealm(launchpadNumericsAliceRealm)
	gns.Approve(cross(cur), launchpadNumericsLaunchpadAddr, launchpadNumericsDepositAmount*2)

	firstDepositID := ""
	metric.PrintMetricsBy("Launchpad Numerics DepositGns 1", func() {
		firstDepositID = launchpad.DepositGns(cross(cur), tierID, launchpadNumericsDepositAmount, "")
	})
	testing.SkipHeights(1)

	secondDepositID := ""
	metric.PrintMetricsBy("Launchpad Numerics DepositGns 2", func() {
		secondDepositID = launchpad.DepositGns(cross(cur), tierID, launchpadNumericsDepositAmount, "")
	})
	testing.SkipHeights(1)

	return firstDepositID, secondDepositID
}

func launchpadNumericsCollectReward(cur realm, depositID, label string) int64 {
	testing.SetRealm(launchpadNumericsAliceRealm)
	reward := int64(0)
	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad Numerics CollectReward %s", label), func() {
		reward = launchpad.CollectRewardByDepositId(cross(cur), depositID)
	})
	return reward
}

func launchpadNumericsCollectDeposit(cur realm, depositID, label string) int64 {
	testing.SetRealm(launchpadNumericsAliceRealm)
	withdrawal := int64(0)
	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad Numerics CollectDepositGns %s", label), func() {
		withdrawal, _ = launchpad.CollectDepositGns(cross(cur), depositID)
	})
	return withdrawal
}

func launchpadNumericsSkipUntil(targetTime int64) {
	remaining := targetTime - time.Now().Unix()
	if remaining <= 0 {
		testing.SkipHeights(1)
		return
	}
	testing.SkipHeights(remaining/launchpadNumericsBlockTimeSeconds + 1)
}

func launchpadNumericsSkipToClaimable(depositID string) {
	deposit, depositErr := launchpad.GetDeposit(depositID)
	if depositErr != nil {
		panic(depositErr)
	}
	state, stateErr := launchpad.GetRewardState(deposit.ProjectTierID(), depositID)
	if stateErr != nil {
		panic(stateErr)
	}
	launchpadNumericsSkipUntil(state.ClaimableTime())
}

func launchpadNumericsSkipToTierEnd(projectID string) {
	tier, err := launchpad.GetProjectTier(projectID, launchpadNumericsTier30)
	if err != nil {
		panic(err)
	}
	launchpadNumericsSkipUntil(tier.EndTime() + 1)
}

func launchpadNumericsMustTier(projectID string) *launchpad.ProjectTier {
	tier, err := launchpad.GetProjectTier(projectID, launchpadNumericsTier30)
	if err != nil {
		panic(err)
	}
	return tier
}

func launchpadNumericsMustManager(tierID string) *launchpad.RewardManager {
	manager, err := launchpad.GetProjectTierRewardManager(tierID)
	if err != nil {
		panic(err)
	}
	return manager
}

func launchpadNumericsMustRewardState(tierID, depositID string) *launchpad.RewardState {
	state, err := launchpad.GetRewardState(tierID, depositID)
	if err != nil {
		panic(err)
	}
	if state == nil {
		panic("launchpad reward state is unexpectedly absent")
	}
	return state
}

func launchpadNumericsMustDeposit(depositID string) *launchpad.Deposit {
	deposit, err := launchpad.GetDeposit(depositID)
	if err != nil {
		panic(err)
	}
	return deposit
}

func launchpadNumericsAssertCreated(projectID, tierID string) {
	tier := launchpadNumericsMustTier(projectID)
	if tier.TotalDistributeAmount() != launchpadNumericsProjectAmount/4 {
		panic("30-day tier allocation changed")
	}
	if tier.TotalDepositAmount() != 0 || tier.TotalWithdrawAmount() != 0 || tier.TotalDepositCount() != 0 || tier.TotalWithdrawCount() != 0 {
		panic("new launchpad tier accounting is not zero")
	}

	manager := launchpadNumericsMustManager(tierID)
	tierRate, err := launchpad.GetProjectTierDistributeAmountPerSecondX128(projectID, launchpadNumericsTier30)
	if err != nil {
		panic(err)
	}
	if tierRate == nil || tierRate.IsZero() {
		panic("30-day tier rate is unexpectedly zero")
	}
	if !tierRate.Eq(manager.DistributeAmountPerSecondX128()) {
		panic("tier and reward manager rates differ")
	}
	if manager.TotalDistributeAmount() != tier.TotalDistributeAmount() || manager.TotalClaimedAmount() != 0 {
		panic("new launchpad reward manager accounting is incorrect")
	}
	if manager.DistributeStartTime() != tier.StartTime() || manager.DistributeEndTime() != tier.EndTime() {
		panic("launchpad reward manager window differs from tier window")
	}
	if !tier.IsActivated(tier.StartTime()) || tier.IsActivated(tier.EndTime()) || tier.IsEnded(tier.EndTime()) || !tier.IsEnded(tier.EndTime()+1) {
		panic("launchpad tier boundary state changed")
	}
}

func launchpadNumericsAssertDeposited(projectID, tierID, firstDepositID, secondDepositID string) {
	tier := launchpadNumericsMustTier(projectID)
	manager := launchpadNumericsMustManager(tierID)
	firstDeposit := launchpadNumericsMustDeposit(firstDepositID)
	secondDeposit := launchpadNumericsMustDeposit(secondDepositID)
	firstState := launchpadNumericsMustRewardState(tierID, firstDepositID)
	secondState := launchpadNumericsMustRewardState(tierID, secondDepositID)

	if tier.TotalDepositAmount() != launchpadNumericsDepositAmount*2 || tier.TotalDepositCount() != 2 || tier.TotalWithdrawAmount() != 0 || tier.TotalWithdrawCount() != 0 {
		panic("launchpad tier deposit accounting is incorrect")
	}
	if manager.ActiveDepositAmount() != launchpadNumericsDepositAmount*2 || manager.Rewards().Size() != 2 {
		panic("launchpad active deposit accounting is incorrect")
	}
	if launchpad.GetTotalGNSStakedAmount() != launchpadNumericsDepositAmount*2 {
		panic("launchpad global staked amount is incorrect")
	}
	if firstDeposit.DepositAmount() != launchpadNumericsDepositAmount || secondDeposit.DepositAmount() != launchpadNumericsDepositAmount || firstDeposit.Tier() != launchpadNumericsTier30 || secondDeposit.Tier() != launchpadNumericsTier30 {
		panic("launchpad deposit records are incorrect")
	}
	if firstState.DepositAmount() != launchpadNumericsDepositAmount || secondState.DepositAmount() != launchpadNumericsDepositAmount {
		panic("launchpad reward state deposit amounts are incorrect")
	}
	if firstState.ClaimableTime()-firstDeposit.CreatedAt() != launchpadNumericsDaySeconds || secondState.ClaimableTime()-secondDeposit.CreatedAt() != launchpadNumericsDaySeconds {
		panic("launchpad claimable boundary changed")
	}

	firstDebt := u256.Zero().Mul(firstState.PriceDebtX128(), u256.NewUintFromInt64(launchpadNumericsDepositAmount))
	secondDebt := u256.Zero().Mul(secondState.PriceDebtX128(), u256.NewUintFromInt64(launchpadNumericsDepositAmount))
	expectedActiveDebt := u256.Zero().Add(firstDebt, secondDebt)
	if !manager.ActivePriceDebtX128().Eq(expectedActiveDebt) {
		panic("launchpad active price debt does not conserve reward-state debts")
	}
	if manager.ActiveClaimedAmount() != 0 || manager.TotalClaimedAmount() != 0 {
		panic("launchpad claim accounting changed before collection")
	}
}

func launchpadNumericsAssertClaimed(projectID, tierID, depositID string, claimed int64) {
	manager := launchpadNumericsMustManager(tierID)
	state := launchpadNumericsMustRewardState(tierID, depositID)
	tier := launchpadNumericsMustTier(projectID)
	if state.ClaimedAmount() != claimed || manager.TotalClaimedAmount() != claimed || manager.ActiveClaimedAmount() != claimed {
		panic("launchpad first claim accounting is inconsistent")
	}
	if tier.TotalCollectedAmount() != claimed {
		panic("launchpad tier collected amount does not match first claim")
	}
	if manager.AccumulatedTime() < manager.DistributeStartTime() || manager.AccumulatedTime() > manager.DistributeEndTime() {
		panic("launchpad reward cursor is outside its distribution window")
	}
}

func launchpadNumericsAssertRepeatedClaim(projectID, tierID, depositID string, firstClaim, secondClaim int64) {
	manager := launchpadNumericsMustManager(tierID)
	state := launchpadNumericsMustRewardState(tierID, depositID)
	tier := launchpadNumericsMustTier(projectID)
	expectedClaimed := firstClaim + secondClaim
	if state.ClaimedAmount() != expectedClaimed || manager.TotalClaimedAmount() != expectedClaimed || manager.ActiveClaimedAmount() != expectedClaimed {
		panic("launchpad repeated claim accounting is inconsistent")
	}
	if tier.TotalCollectedAmount() != expectedClaimed {
		panic("launchpad tier collected amount does not match repeated claims")
	}
	if manager.AccumulatedTime() < manager.DistributeStartTime() || manager.AccumulatedTime() > manager.DistributeEndTime() {
		panic("launchpad repeated-claim cursor is outside its distribution window")
	}
}

func launchpadNumericsAssertFirstWithdrawal(projectID, tierID, firstDepositID, secondDepositID string) {
	tier := launchpadNumericsMustTier(projectID)
	manager := launchpadNumericsMustManager(tierID)
	firstDeposit := launchpadNumericsMustDeposit(firstDepositID)
	secondState := launchpadNumericsMustRewardState(tierID, secondDepositID)
	if !firstDeposit.IsWithdrawn() {
		panic("first launchpad deposit is not marked withdrawn")
	}
	if tier.TotalWithdrawAmount() != launchpadNumericsDepositAmount || tier.TotalWithdrawCount() != 1 || tier.TotalDepositAmount() != launchpadNumericsDepositAmount*2 {
		panic("launchpad first withdrawal tier accounting is incorrect")
	}
	if manager.ActiveDepositAmount() != launchpadNumericsDepositAmount || manager.Rewards().Size() != 1 {
		panic("launchpad first withdrawal active deposit accounting is incorrect")
	}
	if launchpad.GetTotalGNSStakedAmount() != launchpadNumericsDepositAmount {
		panic("launchpad first withdrawal global stake accounting is incorrect")
	}
	expectedDebt := u256.Zero().Mul(secondState.PriceDebtX128(), u256.NewUintFromInt64(launchpadNumericsDepositAmount))
	if !manager.ActivePriceDebtX128().Eq(expectedDebt) {
		panic("launchpad first withdrawal active debt is inconsistent")
	}
}

func launchpadNumericsAssertZeroActive(projectID, tierID, secondDepositID string) {
	tier := launchpadNumericsMustTier(projectID)
	manager := launchpadNumericsMustManager(tierID)
	secondDeposit := launchpadNumericsMustDeposit(secondDepositID)
	if !secondDeposit.IsWithdrawn() {
		panic("second launchpad deposit is not marked withdrawn")
	}
	if tier.TotalWithdrawAmount() != launchpadNumericsDepositAmount*2 || tier.TotalWithdrawCount() != 2 || tier.TotalDepositAmount() != launchpadNumericsDepositAmount*2 || tier.TotalDepositCount() != 2 {
		panic("launchpad final tier accounting is incorrect")
	}
	if manager.ActiveDepositAmount() != 0 || manager.ActiveClaimedAmount() != 0 || !manager.ActivePriceDebtX128().IsZero() || manager.Rewards().Size() != 0 {
		panic("launchpad final active reward state is not zero")
	}
	if launchpad.GetTotalGNSStakedAmount() != 0 {
		panic("launchpad final global staked amount is not zero")
	}
	if tier.TotalCollectedAmount() != manager.TotalClaimedAmount() || manager.TotalClaimedAmount() > manager.TotalDistributeAmount() {
		panic("launchpad final reward conservation is incorrect")
	}
}

func launchpadNumericsPrintState(phase, projectID, rewardDepositID, recordDepositID string) {
	tier := launchpadNumericsMustTier(projectID)
	tierID := projectID + ":30"
	manager := launchpadNumericsMustManager(tierID)

	tierRate, err := launchpad.GetProjectTierDistributeAmountPerSecondX128(projectID, launchpadNumericsTier30)
	if err != nil {
		panic(err)
	}
	tierRateText := "-"
	if tierRate != nil {
		tierRateText = tierRate.ToString()
	}
	globalStaked := launchpad.GetTotalGNSStakedAmount()

	rewardPresent := int64(0)
	rewardDebtText := "-"
	rewardClaimableOffset := int64(-1)
	rewardDepositAmount := int64(0)
	rewardStartOffset := int64(0)
	rewardEndOffset := int64(0)
	rewardAccumulatedAmount := int64(0)
	rewardCursorOffset := int64(-1)
	rewardClaimed := int64(0)
	if rewardDepositID != "" {
		state := launchpadNumericsMustRewardState(tierID, rewardDepositID)
		deposit := launchpadNumericsMustDeposit(rewardDepositID)
		rewardPresent = 1
		rewardDebtText = state.PriceDebtX128().ToString()
		rewardClaimableOffset = state.ClaimableTime() - deposit.CreatedAt()
		rewardDepositAmount = state.DepositAmount()
		rewardStartOffset = state.DistributeStartTime() - tier.StartTime()
		rewardEndOffset = state.DistributeEndTime() - tier.StartTime()
		rewardAccumulatedAmount = state.AccumulatedRewardAmount()
		rewardClaimed = state.ClaimedAmount()
		if state.AccumulatedTime() > 0 {
			rewardCursorOffset = state.AccumulatedTime() - tier.StartTime()
		}
	}

	recordPresent := int64(0)
	recordCreatedHeight := int64(-1)
	recordAmount := int64(0)
	recordTier := int64(0)
	recordCreatedOffset := int64(-1)
	recordEndOffset := int64(-1)
	recordWithdrawnHeightOffset := int64(-1)
	recordWithdrawn := int64(0)
	recordWithdrawnOffset := int64(-1)
	if recordDepositID != "" {
		deposit := launchpadNumericsMustDeposit(recordDepositID)
		recordPresent = 1
		recordAmount = deposit.DepositAmount()
		recordTier = deposit.Tier()
		recordCreatedHeight = deposit.CreatedHeight()
		recordCreatedOffset = deposit.CreatedAt() - tier.StartTime()
		recordEndOffset = deposit.EndTime() - tier.StartTime()
		if deposit.IsWithdrawn() {
			recordWithdrawn = 1
			recordWithdrawnOffset = deposit.WithdrawnTime() - deposit.CreatedAt()
			recordWithdrawnHeightOffset = deposit.WithdrawnHeight() - deposit.CreatedHeight()
		}
	}

	tierAtStart := int64(0)
	if tier.IsActivated(tier.StartTime()) {
		tierAtStart = 1
	}
	tierAtEnd := int64(0)
	if tier.IsActivated(tier.EndTime()) {
		tierAtEnd = 1
	}
	tierEndedAtEnd := int64(0)
	if tier.IsEnded(tier.EndTime()) {
		tierEndedAtEnd = 1
	}
	tierEndedAfterEnd := int64(0)
	if tier.IsEnded(tier.EndTime() + 1) {
		tierEndedAfterEnd = 1
	}
	println(ufmt.Sprintf(
		"STATE launchpad-numerics phase=%s global_staked=%d tier_rate=%s tier_total_distribute=%d tier_total_deposit=%d tier_total_withdraw=%d tier_deposit_count=%d tier_withdraw_count=%d tier_collected=%d tier_window=%d tier_at_start=%d tier_at_end=%d tier_ended_at_end=%d tier_ended_after_end=%d manager_rate=%s manager_accumulator=%s manager_total_distribute=%d manager_total_claimed=%d manager_active_deposit=%d manager_active_claimed=%d manager_active_debt=%s manager_window=%d manager_cursor_offset=%d manager_accumulated_distribute=%d manager_rewards=%d reward_present=%d reward_debt=%s reward_claimable_offset=%d reward_deposit_amount=%d reward_start_offset=%d reward_end_offset=%d reward_accumulated_amount=%d reward_cursor_offset=%d reward_claimed=%d record_present=%d record_amount=%d record_tier=%d record_created_height=%d record_created_offset=%d record_end_offset=%d record_withdrawn=%d record_withdrawn_offset=%d record_withdrawn_height_offset=%d",
		phase,
		globalStaked,
		tierRateText,
		tier.TotalDistributeAmount(),
		tier.TotalDepositAmount(),
		tier.TotalWithdrawAmount(),
		tier.TotalDepositCount(),
		tier.TotalWithdrawCount(),
		tier.TotalCollectedAmount(),
		tier.EndTime()-tier.StartTime(),
		tierAtStart,
		tierAtEnd,
		tierEndedAtEnd,
		tierEndedAfterEnd,
		manager.DistributeAmountPerSecondX128().ToString(),
		manager.AccumulatedRewardPerDepositX128().ToString(),
		manager.TotalDistributeAmount(),
		manager.TotalClaimedAmount(),
		manager.ActiveDepositAmount(),
		manager.ActiveClaimedAmount(),
		manager.ActivePriceDebtX128().ToString(),
		manager.DistributeEndTime()-manager.DistributeStartTime(),
		manager.AccumulatedTime()-manager.DistributeStartTime(),
		manager.AccumulatedDistributeAmount(),
		int64(manager.Rewards().Size()),
		rewardPresent,
		rewardDebtText,
		rewardClaimableOffset,
		rewardDepositAmount,
		rewardStartOffset,
		rewardEndOffset,
		rewardAccumulatedAmount,
		rewardCursorOffset,
		rewardClaimed,
		recordPresent,
		recordAmount,
		recordTier,
		recordCreatedHeight,
		recordCreatedOffset,
		recordEndOffset,
		recordWithdrawn,
		recordWithdrawnOffset,
		recordWithdrawnHeightOffset,
	))
}
