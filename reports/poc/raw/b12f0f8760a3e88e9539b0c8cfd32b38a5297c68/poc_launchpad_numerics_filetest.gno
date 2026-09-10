// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and storage metrics for launchpad Q128 numeric value fields.
// The fixture scales one real project through staged deposits, repeated reward
// claims, and sampled-to-complete withdrawals. State checks cover every tier,
// the reward manager, and first/middle/last deposit records without dumping
// the full reward tree.
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
	launchpadNumericsTier90              int64 = 90
	launchpadNumericsTier180             int64 = 180
	launchpadNumericsDepositAmount       int64 = 1_000_000
	launchpadNumericsProjectAmount       int64 = 1_000_000_000

	// Three stages make both the first (cold) record and warm tree traversals
	// visible while keeping one fixture bounded for the benchmark runner.
	launchpadNumericsStage32  int = 32
	launchpadNumericsStage128 int = 128
	launchpadNumericsStage256 int = 256
)

var (
	launchpadNumericsAdminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	launchpadNumericsAdminRealm   = testing.NewUserRealm(launchpadNumericsAdminAddr)

	launchpadNumericsLaunchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	launchpadNumericsAliceAddr  = testutils.TestAddress("lp-num-alice")
	launchpadNumericsAliceRealm = testing.NewUserRealm(launchpadNumericsAliceAddr)

	launchpadNumericsProjectAddr = testutils.TestAddress("lp-num-project")

	launchpadNumericsMaxInt64 int64 = 9223372036854775807
)

func main(cur realm) {
	launchpadNumericsInitialize(cur)

	projectID := launchpadNumericsCreateProject(cur)
	tierID := projectID + ":30"
	launchpadNumericsAssertCreated(projectID)
	launchpadNumericsPrintState("created", projectID, "", "")

	launchpadNumericsFundDeposits(cur)
	depositIDs := launchpadNumericsCreateDeposits(cur, tierID, projectID)

	launchpadNumericsSkipToClaimable(depositIDs[len(depositIDs)-1])
	firstClaim := launchpadNumericsCollectReward(cur, depositIDs[0], "first")
	middleIndex := len(depositIDs) / 2
	middleClaim := launchpadNumericsCollectReward(cur, depositIDs[middleIndex], "middle")
	lastIndex := len(depositIDs) - 1
	lastClaim := launchpadNumericsCollectReward(cur, depositIDs[lastIndex], "last")
	if firstClaim <= 0 || middleClaim <= 0 || lastClaim <= 0 {
		panic("sampled launchpad reward claims should be positive")
	}
	launchpadNumericsAssertClaims(projectID, tierID, depositIDs, firstClaim, middleClaim, lastClaim)
	launchpadNumericsPrintState("claimed-first", projectID, depositIDs[0], depositIDs[0])
	launchpadNumericsPrintState("claimed-middle", projectID, depositIDs[middleIndex], depositIDs[middleIndex])
	launchpadNumericsPrintState("claimed-last", projectID, depositIDs[lastIndex], depositIDs[lastIndex])

	// Advance the reward cursor and repeat each sampled claim. The manager and
	// reward states are warm by now, so these calls measure repeated updates.
	testing.SkipHeights(launchpadNumericsDaySeconds/launchpadNumericsBlockTimeSeconds + 1)
	firstRepeat := launchpadNumericsCollectReward(cur, depositIDs[0], "repeat-first")
	middleRepeat := launchpadNumericsCollectReward(cur, depositIDs[middleIndex], "repeat-middle")
	lastRepeat := launchpadNumericsCollectReward(cur, depositIDs[lastIndex], "repeat-last")
	if firstRepeat <= 0 || middleRepeat <= 0 || lastRepeat <= 0 {
		panic("repeated launchpad reward claims should be positive")
	}
	launchpadNumericsAssertClaims(
		projectID,
		tierID,
		depositIDs,
		firstClaim+firstRepeat,
		middleClaim+middleRepeat,
		lastClaim+lastRepeat,
	)
	launchpadNumericsPrintState("claimed-repeat-first", projectID, depositIDs[0], depositIDs[0])
	launchpadNumericsPrintState("claimed-repeat-middle", projectID, depositIDs[middleIndex], depositIDs[middleIndex])
	launchpadNumericsPrintState("claimed-repeat-last", projectID, depositIDs[lastIndex], depositIDs[lastIndex])

	launchpadNumericsSkipToTierEnd(projectID)
	firstWithdrawal := launchpadNumericsCollectDeposit(cur, depositIDs[0], "first")
	if firstWithdrawal != launchpadNumericsDepositAmount {
		panic("first launchpad withdrawal did not return the deposit amount")
	}
	launchpadNumericsAssertWithdrawal(projectID, tierID, depositIDs, 1, depositIDs[0])
	launchpadNumericsPrintState("withdrawn-first", projectID, "", depositIDs[0])

	// Complete the lifecycle without adding one metric row per record. The
	// measured middle and last calls still see the progressively smaller warm
	// reward tree, while every deposit is verified through the public API.
	for i := 1; i < middleIndex; i++ {
		launchpadNumericsCollectDepositUnmeasured(cur, depositIDs[i])
	}

	middleWithdrawal := launchpadNumericsCollectDeposit(cur, depositIDs[middleIndex], "middle")
	if middleWithdrawal != launchpadNumericsDepositAmount {
		panic("middle launchpad withdrawal did not return the deposit amount")
	}
	launchpadNumericsAssertWithdrawal(projectID, tierID, depositIDs, middleIndex+1, depositIDs[middleIndex])
	launchpadNumericsPrintState("withdrawn-middle", projectID, "", depositIDs[middleIndex])

	for i := middleIndex + 1; i < lastIndex; i++ {
		launchpadNumericsCollectDepositUnmeasured(cur, depositIDs[i])
	}

	lastWithdrawal := launchpadNumericsCollectDeposit(cur, depositIDs[lastIndex], "last")
	if lastWithdrawal != launchpadNumericsDepositAmount {
		panic("last launchpad withdrawal did not return the deposit amount")
	}
	launchpadNumericsAssertWithdrawal(projectID, tierID, depositIDs, len(depositIDs), depositIDs[lastIndex])
	launchpadNumericsPrintState("withdrawn-final-zero-active", projectID, "", depositIDs[lastIndex])
}

func launchpadNumericsInitialize(cur realm) {
	testing.SetRealm(launchpadNumericsAdminRealm)
	obl.Approve(cross(cur), launchpadNumericsLaunchpadAddr, launchpadNumericsMaxInt64)
}

func launchpadNumericsCreateProject(cur realm) string {
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
	return projectID
}

func launchpadNumericsFundDeposits(cur realm) {
	testing.SetRealm(launchpadNumericsAdminRealm)
	gns.Transfer(cross(cur), launchpadNumericsAliceAddr, launchpadNumericsDepositAmount*int64(launchpadNumericsStage256))

	testing.SetRealm(launchpadNumericsAliceRealm)
	gns.Approve(cross(cur), launchpadNumericsLaunchpadAddr, launchpadNumericsDepositAmount*int64(launchpadNumericsStage256))
}

func launchpadNumericsCreateDeposits(cur realm, tierID, projectID string) []string {
	depositIDs := make([]string, 0, launchpadNumericsStage256)

	depositIDs = launchpadNumericsMeasureDeposit(cur, tierID, depositIDs, "1 (cold)")
	launchpadNumericsAssertDepositStage(projectID, tierID, depositIDs)
	launchpadNumericsPrintState("deposited-stage-1", projectID, depositIDs[0], depositIDs[0])

	depositIDs = launchpadNumericsAppendDeposits(cur, tierID, depositIDs, launchpadNumericsStage32-1)
	depositIDs = launchpadNumericsMeasureDeposit(cur, tierID, depositIDs, "32 (warm)")
	launchpadNumericsAssertDepositStage(projectID, tierID, depositIDs)

	depositIDs = launchpadNumericsAppendDeposits(cur, tierID, depositIDs, launchpadNumericsStage128-1)
	depositIDs = launchpadNumericsMeasureDeposit(cur, tierID, depositIDs, "128 (warm)")
	launchpadNumericsAssertDepositStage(projectID, tierID, depositIDs)

	depositIDs = launchpadNumericsAppendDeposits(cur, tierID, depositIDs, launchpadNumericsStage256-1)
	depositIDs = launchpadNumericsMeasureDeposit(cur, tierID, depositIDs, "256 (warm)")
	launchpadNumericsAssertDepositStage(projectID, tierID, depositIDs)
	middleIndex := len(depositIDs) / 2
	lastIndex := len(depositIDs) - 1
	launchpadNumericsPrintState("deposited-stage-256-first", projectID, depositIDs[0], depositIDs[0])
	launchpadNumericsPrintState("deposited-stage-256-middle", projectID, depositIDs[middleIndex], depositIDs[middleIndex])
	launchpadNumericsPrintState("deposited-stage-256-last", projectID, depositIDs[lastIndex], depositIDs[lastIndex])

	return depositIDs
}

func launchpadNumericsAppendDeposits(cur realm, tierID string, depositIDs []string, targetCount int) []string {
	testing.SetRealm(launchpadNumericsAliceRealm)
	for len(depositIDs) < targetCount {
		depositIDs = append(depositIDs, launchpad.DepositGns(cross(cur), tierID, launchpadNumericsDepositAmount, ""))
		testing.SkipHeights(1)
	}
	return depositIDs
}

func launchpadNumericsMeasureDeposit(cur realm, tierID string, depositIDs []string, label string) []string {
	testing.SetRealm(launchpadNumericsAliceRealm)
	depositID := ""
	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad Numerics DepositGns %s", label), func() {
		depositID = launchpad.DepositGns(cross(cur), tierID, launchpadNumericsDepositAmount, "")
	})
	testing.SkipHeights(1)
	return append(depositIDs, depositID)
}

func launchpadNumericsCollectReward(cur realm, depositID, label string) int64 {
	testing.SetRealm(launchpadNumericsAliceRealm)
	reward := int64(0)
	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad Numerics CollectReward %s (records=%d)", label, launchpadNumericsStage256), func() {
		reward = launchpad.CollectRewardByDepositId(cross(cur), depositID)
	})
	return reward
}

func launchpadNumericsCollectDeposit(cur realm, depositID, label string) int64 {
	testing.SetRealm(launchpadNumericsAliceRealm)
	withdrawal := int64(0)
	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad Numerics CollectDepositGns %s (records=%d)", label, launchpadNumericsStage256), func() {
		var err error
		withdrawal, err = launchpad.CollectDepositGns(cross(cur), depositID)
		if err != nil {
			panic(err)
		}
	})
	return withdrawal
}

func launchpadNumericsCollectDepositUnmeasured(cur realm, depositID string) {
	testing.SetRealm(launchpadNumericsAliceRealm)
	withdrawal, err := launchpad.CollectDepositGns(cross(cur), depositID)
	if err != nil {
		panic(err)
	}
	if withdrawal != launchpadNumericsDepositAmount {
		panic("unmeasured launchpad withdrawal did not return the deposit amount")
	}
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
	if state == nil {
		panic("launchpad sampled reward state is unexpectedly absent")
	}
	launchpadNumericsSkipUntil(state.ClaimableTime())
}

func launchpadNumericsSkipToTierEnd(projectID string) {
	tier := launchpadNumericsMustTier(projectID, launchpadNumericsTier30)
	launchpadNumericsSkipUntil(tier.EndTime() + 1)
}

func launchpadNumericsMustTier(projectID string, duration int64) *launchpad.ProjectTier {
	tier, err := launchpad.GetProjectTier(projectID, duration)
	if err != nil {
		panic(err)
	}
	if tier == nil {
		panic("launchpad tier is unexpectedly absent")
	}
	return tier
}

func launchpadNumericsMustManager(tierID string) *launchpad.RewardManager {
	manager, err := launchpad.GetProjectTierRewardManager(tierID)
	if err != nil {
		panic(err)
	}
	if manager == nil {
		panic("launchpad reward manager is unexpectedly absent")
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
	if deposit == nil {
		panic("launchpad deposit is unexpectedly absent")
	}
	return deposit
}

func launchpadNumericsAssertCreated(projectID string) {
	if launchpad.GetProjects() == nil || launchpad.GetProjects().Size() != 1 {
		panic("launchpad project tree size is incorrect")
	}
	name, err := launchpad.GetProjectName(projectID)
	if err != nil || name != "Launchpad Numeric Value Project" {
		panic("launchpad project name changed")
	}
	projectAmount, err := launchpad.GetProjectDepositAmount(projectID)
	if err != nil || projectAmount != launchpadNumericsProjectAmount {
		panic("launchpad project amount changed")
	}
	ratioMap, err := launchpad.GetProjectTiersRatios(projectID)
	if err != nil || ratioMap[launchpadNumericsTier30] != 25 || ratioMap[launchpadNumericsTier90] != 25 || ratioMap[launchpadNumericsTier180] != 50 {
		panic("launchpad project tier ratios changed")
	}

	durations := []int64{launchpadNumericsTier30, launchpadNumericsTier90, launchpadNumericsTier180}
	ratios := []int64{25, 25, 50}
	for i, duration := range durations {
		tier := launchpadNumericsMustTier(projectID, duration)
		expectedAmount := launchpadNumericsProjectAmount * ratios[i] / 100
		if tier.TotalDistributeAmount() != expectedAmount || tier.TotalDepositAmount() != 0 || tier.TotalWithdrawAmount() != 0 || tier.TotalDepositCount() != 0 || tier.TotalWithdrawCount() != 0 || tier.TotalCollectedAmount() != 0 {
			panic("new launchpad tier accounting is not zero")
		}

		manager := launchpadNumericsMustManager(tier.ID())
		tierRate, tierErr := launchpad.GetProjectTierDistributeAmountPerSecondX128(projectID, duration)
		if tierErr != nil {
			panic(tierErr)
		}
		managerRate := manager.DistributeAmountPerSecondX128()
		if tierRate == nil || tierRate.IsZero() || managerRate == nil || !tierRate.Eq(managerRate) {
			panic("launchpad tier and reward manager rates differ")
		}
		if manager.TotalDistributeAmount() != expectedAmount || manager.TotalClaimedAmount() != 0 || manager.ActiveDepositAmount() != 0 || manager.ActiveClaimedAmount() != 0 || !manager.AccumulatedRewardPerDepositX128().IsZero() || manager.AccumulatedTime() != 0 || manager.AccumulatedDistributeAmount() != 0 || manager.Rewards().Size() != 0 || !manager.ActivePriceDebtX128().IsZero() {
			panic("new launchpad reward manager accounting is incorrect")
		}
		if manager.DistributeStartTime() != tier.StartTime() || manager.DistributeEndTime() != tier.EndTime() || manager.RewardClaimableDuration() != launchpadNumericsDaySeconds {
			panic("launchpad reward manager window changed")
		}
		if tier.EndTime()-tier.StartTime() != duration*launchpadNumericsDaySeconds || !tier.IsActivated(tier.StartTime()) || tier.IsActivated(tier.EndTime()) || tier.IsEnded(tier.EndTime()) || !tier.IsEnded(tier.EndTime()+1) {
			panic("launchpad tier boundary state changed")
		}
	}
}

func launchpadNumericsAssertDepositStage(projectID, tierID string, depositIDs []string) {
	count := int64(len(depositIDs))
	tier := launchpadNumericsMustTier(projectID, launchpadNumericsTier30)
	manager := launchpadNumericsMustManager(tierID)
	if launchpad.GetDepositCount() != len(depositIDs) || launchpad.GetCurrentDepositId() != count {
		panic("launchpad deposit counter changed")
	}
	if tier.TotalDepositAmount() != launchpadNumericsDepositAmount*count || tier.TotalDepositCount() != count || tier.TotalWithdrawAmount() != 0 || tier.TotalWithdrawCount() != 0 || tier.TotalCollectedAmount() != 0 {
		panic("launchpad tier deposit accounting is incorrect")
	}
	if manager.ActiveDepositAmount() != launchpadNumericsDepositAmount*count || manager.ActiveClaimedAmount() != 0 || manager.TotalClaimedAmount() != 0 || manager.Rewards().Size() != len(depositIDs) {
		panic("launchpad active deposit accounting is incorrect")
	}
	if launchpad.GetTotalGNSStakedAmount() != launchpadNumericsDepositAmount*count {
		panic("launchpad global staked amount is incorrect")
	}
	launchpadNumericsAssertActiveDebt(manager)

	middleIndex := len(depositIDs) / 2
	lastIndex := len(depositIDs) - 1
	launchpadNumericsAssertDepositSample(projectID, tierID, depositIDs[0], tier, true)
	if middleIndex != 0 {
		launchpadNumericsAssertDepositSample(projectID, tierID, depositIDs[middleIndex], tier, false)
	}
	if lastIndex != 0 && lastIndex != middleIndex {
		launchpadNumericsAssertDepositSample(projectID, tierID, depositIDs[lastIndex], tier, false)
	}
}

func launchpadNumericsAssertDepositSample(projectID, tierID, depositID string, tier *launchpad.ProjectTier, first bool) {
	deposit := launchpadNumericsMustDeposit(depositID)
	state := launchpadNumericsMustRewardState(tierID, depositID)
	if deposit.ProjectID() != projectID || deposit.DepositAmount() != launchpadNumericsDepositAmount || deposit.Tier() != launchpadNumericsTier30 || deposit.EndTime() != tier.EndTime() || deposit.CreatedAt() < tier.StartTime() || deposit.CreatedAt() >= tier.EndTime() || deposit.CreatedHeight() <= 0 {
		panic("launchpad sampled deposit record is incorrect")
	}
	if state.DepositAmount() != launchpadNumericsDepositAmount || state.DistributeEndTime() != tier.EndTime() || state.ClaimableTime()-deposit.CreatedAt() != launchpadNumericsDaySeconds || state.AccumulatedRewardAmount() != 0 || state.ClaimedAmount() != 0 || state.PriceDebtX128() == nil {
		panic("launchpad sampled reward state is incorrect")
	}
	if state.DistributeStartTime() < tier.StartTime() || state.DistributeStartTime() > deposit.CreatedAt() {
		panic("launchpad sampled reward start time is incorrect")
	}
	if first && state.AccumulatedTime() != tier.StartTime() {
		panic("launchpad first reward state cursor is incorrect")
	}
	if !first && state.AccumulatedTime() != 0 {
		panic("launchpad later reward state cursor is unexpectedly initialized")
	}
}

func launchpadNumericsAssertActiveDebt(manager *launchpad.RewardManager) {
	expectedDebt := u256.Zero()
	manager.Rewards().Iterate("", "", func(_ string, value interface{}) bool {
		state, ok := value.(*launchpad.RewardState)
		if !ok {
			panic("launchpad reward tree contains an invalid state")
		}
		debt := u256.Zero().Mul(state.PriceDebtX128(), u256.NewUintFromInt64(state.DepositAmount()))
		expectedDebt = u256.Zero().Add(expectedDebt, debt)
		return false
	})
	if !manager.ActivePriceDebtX128().Eq(expectedDebt) {
		panic("launchpad active price debt does not conserve reward-state debts")
	}
}

func launchpadNumericsAssertClaims(projectID, tierID string, depositIDs []string, firstClaim, middleClaim, lastClaim int64) {
	manager := launchpadNumericsMustManager(tierID)
	tier := launchpadNumericsMustTier(projectID, launchpadNumericsTier30)
	middleIndex := len(depositIDs) / 2
	lastIndex := len(depositIDs) - 1
	totalClaimed := firstClaim + middleClaim + lastClaim
	if manager.TotalClaimedAmount() != totalClaimed || manager.ActiveClaimedAmount() != totalClaimed || tier.TotalCollectedAmount() != totalClaimed {
		panic("launchpad sampled claim accounting is inconsistent")
	}
	if manager.AccumulatedTime() < manager.DistributeStartTime() || manager.AccumulatedTime() > manager.DistributeEndTime() || manager.AccumulatedRewardPerDepositX128().IsZero() || manager.AccumulatedDistributeAmount() != 0 {
		panic("launchpad reward cursor is outside its expected window")
	}
	if launchpadNumericsMustRewardState(tierID, depositIDs[0]).ClaimedAmount() != firstClaim || launchpadNumericsMustRewardState(tierID, depositIDs[middleIndex]).ClaimedAmount() != middleClaim || launchpadNumericsMustRewardState(tierID, depositIDs[lastIndex]).ClaimedAmount() != lastClaim {
		panic("launchpad sampled reward state claim totals are inconsistent")
	}
	if manager.ActiveDepositAmount() != launchpadNumericsDepositAmount*int64(len(depositIDs)) || manager.Rewards().Size() != len(depositIDs) {
		panic("launchpad active reward tree changed during claim")
	}
	launchpadNumericsAssertActiveDebt(manager)
}

func launchpadNumericsAssertWithdrawal(projectID, tierID string, depositIDs []string, withdrawnCount int, sampledDepositID string) {
	tier := launchpadNumericsMustTier(projectID, launchpadNumericsTier30)
	manager := launchpadNumericsMustManager(tierID)
	withdrawnAmount := launchpadNumericsDepositAmount * int64(withdrawnCount)
	activeCount := len(depositIDs) - withdrawnCount
	if tier.TotalDepositAmount() != launchpadNumericsDepositAmount*int64(len(depositIDs)) || tier.TotalWithdrawAmount() != withdrawnAmount || tier.TotalWithdrawCount() != int64(withdrawnCount) || manager.ActiveDepositAmount() != launchpadNumericsDepositAmount*int64(activeCount) || manager.Rewards().Size() != activeCount || launchpad.GetTotalGNSStakedAmount() != launchpadNumericsDepositAmount*int64(activeCount) {
		panic("launchpad withdrawal accounting is incorrect")
	}
	if !launchpadNumericsMustDeposit(sampledDepositID).IsWithdrawn() {
		panic("launchpad sampled withdrawal record is not marked withdrawn")
	}
	if manager.TotalClaimedAmount() < tier.TotalCollectedAmount() || tier.TotalCollectedAmount() != manager.TotalClaimedAmount() {
		panic("launchpad withdrawal reward conservation is incorrect")
	}
	if withdrawnCount < len(depositIDs) {
		launchpadNumericsAssertActiveDebt(manager)
		return
	}
	if manager.ActiveDepositAmount() != 0 || manager.ActiveClaimedAmount() != 0 || !manager.ActivePriceDebtX128().IsZero() || manager.Rewards().Size() != 0 || launchpad.GetTotalGNSStakedAmount() != 0 {
		panic("launchpad final active reward state is not zero")
	}
	if tier.TotalWithdrawAmount() != tier.TotalDepositAmount() || tier.TotalWithdrawCount() != tier.TotalDepositCount() || tier.TotalCollectedAmount() != manager.TotalClaimedAmount() || manager.TotalClaimedAmount() > manager.TotalDistributeAmount() {
		panic("launchpad final reward conservation is incorrect")
	}
}

func launchpadNumericsPrintState(phase, projectID, rewardDepositID, recordDepositID string) {
	tier := launchpadNumericsMustTier(projectID, launchpadNumericsTier30)
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

// Output:
// Launchpad Numerics CreateProject
// - Gas Used: 6818137
// - Storage Diff: 32744
// - CPU Cycles: 4930933
// STATE launchpad-numerics phase=created global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=0 tier_total_withdraw=0 tier_deposit_count=0 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=0 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=-1234913490 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=0 record_amount=0 record_tier=0 record_created_height=-1 record_created_offset=-1 record_end_offset=-1 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// Launchpad Numerics DepositGns 1 (cold)
// - Gas Used: 6393085
// - Storage Diff: 27369
// - CPU Cycles: 4155046
// STATE launchpad-numerics phase=deposited-stage-1 global_staked=1000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=1000000 tier_total_withdraw=0 tier_deposit_count=1 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=0 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=1000000 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=-1234913490 manager_accumulated_distribute=0 manager_rewards=1 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// Launchpad Numerics DepositGns 32 (warm)
// - Gas Used: 6072479
// - Storage Diff: 3929
// - CPU Cycles: 5226120
// Launchpad Numerics DepositGns 128 (warm)
// - Gas Used: 6131903
// - Storage Diff: 3956
// - CPU Cycles: 5277526
// Launchpad Numerics DepositGns 256 (warm)
// - Gas Used: 6481645
// - Storage Diff: 7526
// - CPU Cycles: 5557872
// STATE launchpad-numerics phase=deposited-stage-256-first global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1168479812265116018988177298603093692 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=256000000 manager_active_claimed=0 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=1280 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=deposited-stage-256-middle global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1168479812265116018988177298603093692 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=256000000 manager_active_claimed=0 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=1280 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1055693730428625212693294031947141929 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=645 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69372 record_created_offset=645 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=deposited-stage-256-last global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1168479812265116018988177298603093692 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=256000000 manager_active_claimed=0 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=1280 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1168479812265116018988177298603093692 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=1280 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// Launchpad Numerics CollectReward first (records=256)
// - Gas Used: 3183372
// - Storage Diff: 2046
// - CPU Cycles: 2882027
// Launchpad Numerics CollectReward middle (records=256)
// - Gas Used: 2827088
// - Storage Diff: 12
// - CPU Cycles: 2604879
// Launchpad Numerics CollectReward last (records=256)
// - Gas Used: 2927430
// - Storage Diff: 36
// - CPU Cycles: 2595895
// STATE launchpad-numerics phase=claimed-first global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=101425 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12246020801442937778078980639992288627 manager_total_distribute=250000000 manager_total_claimed=101425 manager_active_deposit=256000000 manager_active_claimed=101425 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=87685 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=35987 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-middle global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=101425 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12246020801442937778078980639992288627 manager_total_distribute=250000000 manager_total_claimed=101425 manager_active_deposit=256000000 manager_active_claimed=101425 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=87685 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1055693730428625212693294031947141929 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=645 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=32885 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69372 record_created_offset=645 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-last global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=101425 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12246020801442937778078980639992288627 manager_total_distribute=250000000 manager_total_claimed=101425 manager_active_deposit=256000000 manager_active_claimed=101425 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=87685 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1168479812265116018988177298603093692 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=1280 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=32553 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// Launchpad Numerics CollectReward repeat-first (records=256)
// - Gas Used: 3156409
// - Storage Diff: 0
// - CPU Cycles: 2878993
// Launchpad Numerics CollectReward repeat-middle (records=256)
// - Gas Used: 2827088
// - Storage Diff: 0
// - CPU Cycles: 2604879
// Launchpad Numerics CollectReward repeat-last (records=256)
// - Gas Used: 2927430
// - Storage Diff: 0
// - CPU Cycles: 2595895
// STATE launchpad-numerics phase=claimed-repeat-first global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=199087 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=23323561790620759537169783981381483562 manager_total_distribute=250000000 manager_total_claimed=199087 manager_active_deposit=256000000 manager_active_claimed=199087 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=174090 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=68541 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-repeat-middle global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=199087 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=23323561790620759537169783981381483562 manager_total_distribute=250000000 manager_total_claimed=199087 manager_active_deposit=256000000 manager_active_claimed=199087 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=174090 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1055693730428625212693294031947141929 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=645 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=65439 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69372 record_created_offset=645 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-repeat-last global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=199087 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=23323561790620759537169783981381483562 manager_total_distribute=250000000 manager_total_claimed=199087 manager_active_deposit=256000000 manager_active_claimed=199087 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=174090 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1168479812265116018988177298603093692 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=1280 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=65107 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// Launchpad Numerics CollectDepositGns first (records=256)
// - Gas Used: 8027025
// - Storage Diff: -3652
// - CPU Cycles: 6914946
// STATE launchpad-numerics phase=withdrawn-first global_staked=255000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=1000000 tier_deposit_count=256 tier_withdraw_count=1 tier_collected=1110060 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096385 manager_total_distribute=250000000 manager_total_claimed=1110060 manager_active_deposit=255000000 manager_active_claimed=130546 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=255 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// Launchpad Numerics CollectDepositGns middle (records=256)
// - Gas Used: 7411475
// - Storage Diff: -2292
// - CPU Cycles: 6451628
// STATE launchpad-numerics phase=withdrawn-middle global_staked=127000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=129000000 tier_deposit_count=256 tier_withdraw_count=129 tier_collected=126084364 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096385 manager_total_distribute=250000000 manager_total_claimed=126084364 manager_active_deposit=127000000 manager_active_claimed=65107 manager_active_debt=142105358558443182268133088363728742556000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=127 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69372 record_created_offset=645 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2591360 record_withdrawn_height_offset=518272
// Launchpad Numerics CollectDepositGns last (records=256)
// - Gas Used: 7218799
// - Storage Diff: -8824
// - CPU Cycles: 6192818
// STATE launchpad-numerics phase=withdrawn-final-zero-active global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=256000000 tier_deposit_count=256 tier_withdraw_count=256 tier_collected=249999871 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096385 manager_total_distribute=250000000 manager_total_claimed=249999871 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2590725 record_withdrawn_height_offset=518145
