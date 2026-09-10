// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and storage metrics for launchpad Q128 numeric value fields.
// Every deposit and withdrawal is measured in its own paid-call window. The
// lifecycle also measures 1/10/100 paid reward-claim patterns and settles the
// remaining project balance through the admin refund path.
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

	// Boundary snapshots expose cold, warm, and full 256-record states.
	launchpadNumericsStage1   int = 1
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
	initialAdminObl := obl.BalanceOf(launchpadNumericsAdminAddr)
	initialLaunchpadObl := obl.BalanceOf(launchpadNumericsLaunchpadAddr)
	initialProjectRecipientObl := obl.BalanceOf(launchpadNumericsProjectAddr)
	initialAdminGns := gns.BalanceOf(launchpadNumericsAdminAddr)
	initialAliceGns := gns.BalanceOf(launchpadNumericsAliceAddr)
	initialLaunchpadGns := gns.BalanceOf(launchpadNumericsLaunchpadAddr)
	initialAliceObl := obl.BalanceOf(launchpadNumericsAliceAddr)

	launchpadNumericsInitialize(cur)

	projectID := launchpadNumericsCreateProject(cur)
	tierID := projectID + ":30"
	launchpadNumericsAssertProjectFunding(initialAdminObl, initialLaunchpadObl)
	launchpadNumericsAssertCreated(projectID)
	launchpadNumericsPrintState("created", projectID, "", "")

	launchpadNumericsFundDeposits(cur)
	launchpadNumericsAssertDepositFunding(initialAdminGns, initialAliceGns, initialLaunchpadGns)
	depositIDs := launchpadNumericsCreateDeposits(cur, tierID, projectID)

	launchpadNumericsSkipToClaimable(depositIDs[len(depositIDs)-1])
	claimedAmount := launchpadNumericsMeasureClaimPatterns(cur, tierID, depositIDs)
	launchpadNumericsAssertClaims(projectID, tierID, depositIDs, claimedAmount)
	launchpadNumericsPrintState("claimed-pattern-1", projectID, depositIDs[0], depositIDs[0])
	launchpadNumericsPrintState("claimed-pattern-10", projectID, depositIDs[10], depositIDs[10])
	launchpadNumericsPrintState("claimed-pattern-100", projectID, depositIDs[110], depositIDs[110])

	launchpadNumericsSkipToTierEnd(projectID)
	launchpadNumericsWithdrawDeposits(cur, projectID, tierID, depositIDs)
	launchpadNumericsAssertCompleteExit(projectID, tierID, depositIDs)
	launchpadNumericsPrintState("withdrawn-final-zero-active", projectID, "", depositIDs[len(depositIDs)-1])

	launchpadNumericsSkipToProjectEnd(projectID)
	refundedAmount := launchpadNumericsTransferLeftFromProject(cur, projectID)
	if refundedAmount <= 0 {
		panic("launchpad admin refund should return a positive remaining amount")
	}
	launchpadNumericsAssertRefundBalances(
		projectID,
		initialAdminObl,
		initialLaunchpadObl,
		initialProjectRecipientObl,
		initialAliceObl,
		initialAdminGns,
		initialAliceGns,
		initialLaunchpadGns,
		refundedAmount,
	)
	launchpadNumericsPrintState("refunded-final-zero-active", projectID, "", "")
}

func launchpadNumericsInitialize(cur realm) {
	testing.SetRealm(launchpadNumericsAdminRealm)
	obl.Approve(cross(cur), launchpadNumericsLaunchpadAddr, launchpadNumericsMaxInt64)
}

func launchpadNumericsAssertProjectFunding(initialAdminObl, initialLaunchpadObl int64) {
	if obl.BalanceOf(launchpadNumericsAdminAddr) != initialAdminObl-launchpadNumericsProjectAmount {
		panic("launchpad project funding changed admin OBL balance incorrectly")
	}
	if obl.BalanceOf(launchpadNumericsLaunchpadAddr) != initialLaunchpadObl+launchpadNumericsProjectAmount {
		panic("launchpad project funding changed launchpad OBL balance incorrectly")
	}
}

func launchpadNumericsAssertDepositFunding(initialAdminGns, initialAliceGns, initialLaunchpadGns int64) {
	total := launchpadNumericsDepositAmount * int64(launchpadNumericsStage256)
	if gns.BalanceOf(launchpadNumericsAdminAddr) != initialAdminGns-total {
		panic("launchpad deposit funding changed admin GNS balance incorrectly")
	}
	if gns.BalanceOf(launchpadNumericsAliceAddr) != initialAliceGns+total {
		panic("launchpad deposit funding changed Alice GNS balance incorrectly")
	}
	if gns.BalanceOf(launchpadNumericsLaunchpadAddr) != initialLaunchpadGns {
		panic("launchpad deposit funding unexpectedly changed launchpad GNS balance")
	}
}

func launchpadNumericsCreateProject(cur realm) string {
	testing.SetRealm(launchpadNumericsAdminRealm)

	startTime := time.Now().Unix() + launchpadNumericsActivationDelayDays*launchpadNumericsDaySeconds
	projectID := ""
	launchpadNumericsPrintClock("launchpad_create_project_before")
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
	launchpadNumericsPrintClock("launchpad_create_project_after")

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
	for i := 0; i < launchpadNumericsStage256; i++ {
		depositIDs = launchpadNumericsMeasureDeposit(
			cur,
			tierID,
			depositIDs,
			ufmt.Sprintf("call=%03d/256", i+1),
		)
		count := i + 1
		if count == launchpadNumericsStage1 || count == launchpadNumericsStage32 || count == launchpadNumericsStage128 || count == launchpadNumericsStage256 {
			launchpadNumericsAssertDepositStage(projectID, tierID, depositIDs)
			launchpadNumericsPrintState(
				ufmt.Sprintf("deposited-stage-%d", count),
				projectID,
				depositIDs[0],
				depositIDs[len(depositIDs)-1],
			)
		}
	}
	return depositIDs
}

func launchpadNumericsMeasureDeposit(cur realm, tierID string, depositIDs []string, label string) []string {
	testing.SetRealm(launchpadNumericsAliceRealm)
	depositID := ""
	launchpadNumericsPrintClock(ufmt.Sprintf("launchpad_deposit_%s_before", label))
	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad Numerics DepositGns %s", label), func() {
		depositID = launchpad.DepositGns(cross(cur), tierID, launchpadNumericsDepositAmount, "")
	})
	launchpadNumericsPrintClock(ufmt.Sprintf("launchpad_deposit_%s_after", label))
	testing.SkipHeights(1)
	return append(depositIDs, depositID)
}

func launchpadNumericsMeasureClaimPatterns(cur realm, tierID string, depositIDs []string) int64 {
	claimedAmount := int64(0)
	claimedAmount += launchpadNumericsMeasureClaimPattern(cur, tierID, depositIDs, 0, 1, "pattern=1")
	claimedAmount += launchpadNumericsMeasureClaimPattern(cur, tierID, depositIDs, 1, 10, "pattern=10")
	claimedAmount += launchpadNumericsMeasureClaimPattern(cur, tierID, depositIDs, 11, 100, "pattern=100")
	return claimedAmount
}

func launchpadNumericsMeasureClaimPattern(cur realm, tierID string, depositIDs []string, start, count int, label string) int64 {
	if start < 0 || start+count > len(depositIDs) {
		panic("launchpad claim pattern exceeds deposit records")
	}

	claimedAmount := int64(0)
	for offset := 0; offset < count; offset++ {
		index := start + offset
		metricLabel := ufmt.Sprintf("%s call=%03d/%03d", label, offset+1, count)
		clockLabel := ufmt.Sprintf("launchpad_claim_%d_%03d", count, index+1)
		reward := launchpadNumericsCollectReward(cur, depositIDs[index], metricLabel, clockLabel)
		if reward <= 0 {
			panic("launchpad reward claim should be positive")
		}
		state := launchpadNumericsMustRewardState(tierID, depositIDs[index])
		if state.ClaimedAmount() < reward {
			panic("launchpad reward claim was not persisted")
		}
		claimedAmount += reward
		testing.SkipHeights(1)
	}
	return claimedAmount
}

func launchpadNumericsCollectReward(cur realm, depositID, metricLabel, clockLabel string) int64 {
	testing.SetRealm(launchpadNumericsAliceRealm)
	reward := int64(0)
	launchpadNumericsPrintClock(clockLabel + "_before")
	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad Numerics CollectReward %s", metricLabel), func() {
		reward = launchpad.CollectRewardByDepositId(cross(cur), depositID)
	})
	launchpadNumericsPrintClock(clockLabel + "_after")
	return reward
}

func launchpadNumericsWithdrawDeposits(cur realm, projectID, tierID string, depositIDs []string) {
	for i, depositID := range depositIDs {
		metricLabel := ufmt.Sprintf("call=%03d/256", i+1)
		clockLabel := ufmt.Sprintf("launchpad_withdraw_%03d", i+1)
		withdrawal := launchpadNumericsCollectDeposit(cur, depositID, metricLabel, clockLabel)
		if withdrawal != launchpadNumericsDepositAmount {
			panic("launchpad withdrawal did not return the deposit amount")
		}
		launchpadNumericsAssertWithdrawal(projectID, tierID, depositIDs, i+1, depositID)
		if i+1 == 1 || i+1 == launchpadNumericsStage32 || i+1 == launchpadNumericsStage128 || i+1 == launchpadNumericsStage256 {
			launchpadNumericsPrintState(
				ufmt.Sprintf("withdrawn-stage-%d", i+1),
				projectID,
				"",
				depositID,
			)
		}
		testing.SkipHeights(1)
	}
}

func launchpadNumericsCollectDeposit(cur realm, depositID, metricLabel, clockLabel string) int64 {
	testing.SetRealm(launchpadNumericsAliceRealm)
	withdrawal := int64(0)
	launchpadNumericsPrintClock(clockLabel + "_before")
	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad Numerics CollectDepositGns %s", metricLabel), func() {
		var err error
		withdrawal, err = launchpad.CollectDepositGns(cross(cur), depositID)
		if err != nil {
			panic(err)
		}
	})
	launchpadNumericsPrintClock(clockLabel + "_after")
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

func launchpadNumericsPrintClock(label string) {
	println(ufmt.Sprintf("STATE CLOCK %s %d", label, time.Now().Unix()))
}

func launchpadNumericsSkipToProjectEnd(projectID string) {
	tier := launchpadNumericsMustTier(projectID, launchpadNumericsTier180)
	launchpadNumericsSkipUntil(tier.EndTime() + 1)
}

func launchpadNumericsTransferLeftFromProject(cur realm, projectID string) int64 {
	testing.SetRealm(launchpadNumericsAdminRealm)
	refundedAmount := int64(0)
	launchpadNumericsPrintClock("launchpad_refund_before")
	metric.PrintMetricsBy("Launchpad Numerics TransferLeftFromProjectByAdmin", func() {
		refundedAmount = launchpad.TransferLeftFromProjectByAdmin(
			cross(cur),
			projectID,
			launchpadNumericsProjectAddr,
		)
	})
	launchpadNumericsPrintClock("launchpad_refund_after")
	return refundedAmount
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

func launchpadNumericsAssertClaims(projectID, tierID string, depositIDs []string, expectedClaimed int64) {
	manager := launchpadNumericsMustManager(tierID)
	tier := launchpadNumericsMustTier(projectID, launchpadNumericsTier30)
	if manager.TotalClaimedAmount() != expectedClaimed || manager.ActiveClaimedAmount() != expectedClaimed || tier.TotalCollectedAmount() != expectedClaimed {
		panic("launchpad claim accounting is inconsistent")
	}
	if manager.AccumulatedTime() < manager.DistributeStartTime() || manager.AccumulatedTime() > manager.DistributeEndTime() || manager.AccumulatedRewardPerDepositX128().IsZero() || manager.AccumulatedDistributeAmount() != 0 {
		panic("launchpad reward cursor is outside its expected window")
	}
	if manager.ActiveDepositAmount() != launchpadNumericsDepositAmount*int64(len(depositIDs)) || manager.Rewards().Size() != len(depositIDs) {
		panic("launchpad active reward tree changed during claim")
	}
	launchpadNumericsAssertActiveDebt(manager)
}

func launchpadNumericsAssertCompleteExit(projectID, tierID string, depositIDs []string) {
	tier := launchpadNumericsMustTier(projectID, launchpadNumericsTier30)
	manager := launchpadNumericsMustManager(tierID)
	if launchpad.GetDepositCount() != len(depositIDs) || launchpad.GetCurrentDepositId() != int64(len(depositIDs)) {
		panic("launchpad final deposit count changed")
	}
	for _, depositID := range depositIDs {
		if !launchpadNumericsMustDeposit(depositID).IsWithdrawn() {
			panic("launchpad final deposit is still active")
		}
	}
	if tier.TotalWithdrawAmount() != tier.TotalDepositAmount() || tier.TotalWithdrawCount() != tier.TotalDepositCount() || manager.ActiveDepositAmount() != 0 || manager.ActiveClaimedAmount() != 0 || !manager.ActivePriceDebtX128().IsZero() || manager.Rewards().Size() != 0 || launchpad.GetTotalGNSStakedAmount() != 0 {
		panic("launchpad final active reward state is not zero")
	}
	if tier.TotalCollectedAmount() != manager.TotalClaimedAmount() || manager.TotalClaimedAmount() > manager.TotalDistributeAmount() {
		panic("launchpad final reward conservation is incorrect")
	}
	for _, duration := range []int64{launchpadNumericsTier30, launchpadNumericsTier90, launchpadNumericsTier180} {
		tierManager := launchpadNumericsMustManager(projectID + ":" + ufmt.Sprintf("%d", duration))
		if tierManager.ActiveDepositAmount() != 0 || tierManager.ActiveClaimedAmount() != 0 || !tierManager.ActivePriceDebtX128().IsZero() || tierManager.Rewards().Size() != 0 {
			panic("launchpad final tier manager still has active state")
		}
	}
}

func launchpadNumericsAssertRefundBalances(projectID string, initialAdminObl, initialLaunchpadObl, initialProjectRecipientObl, initialAliceObl, initialAdminGns, initialAliceGns, initialLaunchpadGns, refundedAmount int64) {
	manager := launchpadNumericsMustManager(projectID + ":30")
	totalDeposited := launchpadNumericsDepositAmount * int64(launchpadNumericsStage256)
	if manager.TotalClaimedAmount()+refundedAmount != launchpadNumericsProjectAmount {
		panic("launchpad project OBL distribution is not conserved")
	}
	if gns.BalanceOf(launchpadNumericsAdminAddr) != initialAdminGns-totalDeposited || gns.BalanceOf(launchpadNumericsAliceAddr) != initialAliceGns+totalDeposited || gns.BalanceOf(launchpadNumericsLaunchpadAddr) != initialLaunchpadGns {
		panic("launchpad final GNS balances are not conserved")
	}
	if obl.BalanceOf(launchpadNumericsAdminAddr) != initialAdminObl-launchpadNumericsProjectAmount || obl.BalanceOf(launchpadNumericsAliceAddr) != initialAliceObl+manager.TotalClaimedAmount() || obl.BalanceOf(launchpadNumericsProjectAddr) != initialProjectRecipientObl+refundedAmount || obl.BalanceOf(launchpadNumericsLaunchpadAddr) != initialLaunchpadObl {
		panic("launchpad final OBL balances are not conserved")
	}
	if manager.ActiveDepositAmount() != 0 || manager.ActiveClaimedAmount() != 0 || !manager.ActivePriceDebtX128().IsZero() || manager.Rewards().Size() != 0 || launchpad.GetTotalGNSStakedAmount() != 0 {
		panic("launchpad refund changed zero-active state")
	}
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
	state, stateErr := launchpad.GetRewardState(tierID, sampledDepositID)
	if stateErr == nil || state != nil {
		panic("launchpad withdrawn reward state was not removed")
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
// STATE CLOCK launchpad_create_project_before 1234567890
// Launchpad Numerics CreateProject
// - Gas Used: 6822113
// - Storage Diff: 32744
// - CPU Cycles: 4994040
// - Realm gno.land/r/gnoswap/launchpad: 30291
// - Realm gno.land/r/gnoswap/launchpad/v1: 419
// - Realm gno.land/r/onbloc/obl: 2034
// STATE CLOCK launchpad_create_project_after 1234567890
// STATE launchpad-numerics phase=created global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=0 tier_total_withdraw=0 tier_deposit_count=0 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=0 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=-1234913490 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=0 record_amount=0 record_tier=0 record_created_height=-1 record_created_offset=-1 record_end_offset=-1 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=1/256_before 1234913495
// Launchpad Numerics DepositGns call=1/256
// - Gas Used: 6401763
// - Storage Diff: 27008
// - CPU Cycles: 4164770
// - Realm gno.land/r/gnoswap/gns: 2059
// - Realm gno.land/r/gnoswap/gov/staker: 14243
// - Realm gno.land/r/gnoswap/gov/xgns: 1043
// - Realm gno.land/r/gnoswap/launchpad: 9663
// STATE CLOCK launchpad_deposit_call=1/256_after 1234913495
// STATE launchpad-numerics phase=deposited-stage-1 global_staked=1000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=1000000 tier_total_withdraw=0 tier_deposit_count=1 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=0 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=1000000 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=-1234913490 manager_accumulated_distribute=0 manager_rewards=1 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=2/256_before 1234913500
// Launchpad Numerics DepositGns call=2/256
// - Gas Used: 5985183
// - Storage Diff: 3709
// - CPU Cycles: 5179879
// - Realm gno.land/r/gnoswap/gov/staker: 96
// - Realm gno.land/r/gnoswap/launchpad: 3613
// STATE CLOCK launchpad_deposit_call=2/256_after 1234913500
// STATE CLOCK launchpad_deposit_call=3/256_before 1234913505
// Launchpad Numerics DepositGns call=3/256
// - Gas Used: 5979475
// - Storage Diff: 3568
// - CPU Cycles: 5178285
// - Realm gno.land/r/gnoswap/gns: 3
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=3/256_after 1234913505
// STATE CLOCK launchpad_deposit_call=4/256_before 1234913510
// Launchpad Numerics DepositGns call=4/256
// - Gas Used: 5985895
// - Storage Diff: 3567
// - CPU Cycles: 5183757
// - Realm gno.land/r/gnoswap/gns: 2
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=4/256_after 1234913510
// STATE CLOCK launchpad_deposit_call=5/256_before 1234913515
// Launchpad Numerics DepositGns call=5/256
// - Gas Used: 5987811
// - Storage Diff: 3565
// - CPU Cycles: 5184731
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=5/256_after 1234913515
// STATE CLOCK launchpad_deposit_call=6/256_before 1234913520
// Launchpad Numerics DepositGns call=6/256
// - Gas Used: 5987292
// - Storage Diff: 3565
// - CPU Cycles: 5183270
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=6/256_after 1234913520
// STATE CLOCK launchpad_deposit_call=7/256_before 1234913525
// Launchpad Numerics DepositGns call=7/256
// - Gas Used: 5989695
// - Storage Diff: 3565
// - CPU Cycles: 5184731
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=7/256_after 1234913525
// STATE CLOCK launchpad_deposit_call=8/256_before 1234913530
// Launchpad Numerics DepositGns call=8/256
// - Gas Used: 5996109
// - Storage Diff: 3565
// - CPU Cycles: 5190203
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=8/256_after 1234913530
// STATE CLOCK launchpad_deposit_call=9/256_before 1234913535
// Launchpad Numerics DepositGns call=9/256
// - Gas Used: 5997538
// - Storage Diff: 3565
// - CPU Cycles: 5190690
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=9/256_after 1234913535
// STATE CLOCK launchpad_deposit_call=10/256_before 1234913540
// Launchpad Numerics DepositGns call=10/256
// - Gas Used: 6029687
// - Storage Diff: 3664
// - CPU Cycles: 5203071
// - Realm gno.land/r/gnoswap/launchpad: 3664
// STATE CLOCK launchpad_deposit_call=10/256_after 1234913540
// STATE CLOCK launchpad_deposit_call=11/256_before 1234913545
// Launchpad Numerics DepositGns call=11/256
// - Gas Used: 6024681
// - Storage Diff: 3568
// - CPU Cycles: 5197117
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=11/256_after 1234913545
// STATE CLOCK launchpad_deposit_call=12/256_before 1234913550
// Launchpad Numerics DepositGns call=12/256
// - Gas Used: 6031585
// - Storage Diff: 3568
// - CPU Cycles: 5203073
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=12/256_after 1234913550
// STATE CLOCK launchpad_deposit_call=13/256_before 1234913555
// Launchpad Numerics DepositGns call=13/256
// - Gas Used: 6033020
// - Storage Diff: 3568
// - CPU Cycles: 5203560
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=13/256_after 1234913555
// STATE CLOCK launchpad_deposit_call=14/256_before 1234913560
// Launchpad Numerics DepositGns call=14/256
// - Gas Used: 6033973
// - Storage Diff: 3568
// - CPU Cycles: 5203565
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=14/256_after 1234913560
// STATE CLOCK launchpad_deposit_call=15/256_before 1234913565
// Launchpad Numerics DepositGns call=15/256
// - Gas Used: 6034921
// - Storage Diff: 3568
// - CPU Cycles: 5203565
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=15/256_after 1234913565
// STATE CLOCK launchpad_deposit_call=16/256_before 1234913570
// Launchpad Numerics DepositGns call=16/256
// - Gas Used: 6036361
// - Storage Diff: 3568
// - CPU Cycles: 5204057
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=16/256_after 1234913570
// STATE CLOCK launchpad_deposit_call=17/256_before 1234913575
// Launchpad Numerics DepositGns call=17/256
// - Gas Used: 6324708
// - Storage Diff: 16742
// - CPU Cycles: 5425114
// - Realm gno.land/r/gnoswap/launchpad: 16742
// STATE CLOCK launchpad_deposit_call=17/256_after 1234913575
// STATE CLOCK launchpad_deposit_call=18/256_before 1234913580
// Launchpad Numerics DepositGns call=18/256
// - Gas Used: 6084793
// - Storage Diff: 3664
// - CPU Cycles: 5240181
// - Realm gno.land/r/gnoswap/launchpad: 3664
// STATE CLOCK launchpad_deposit_call=18/256_after 1234913580
// STATE CLOCK launchpad_deposit_call=19/256_before 1234913585
// Launchpad Numerics DepositGns call=19/256
// - Gas Used: 6076977
// - Storage Diff: 3568
// - CPU Cycles: 5231417
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=19/256_after 1234913585
// STATE CLOCK launchpad_deposit_call=20/256_before 1234913590
// Launchpad Numerics DepositGns call=20/256
// - Gas Used: 6084667
// - Storage Diff: 3568
// - CPU Cycles: 5240511
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=20/256_after 1234913590
// STATE CLOCK launchpad_deposit_call=21/256_before 1234913595
// Launchpad Numerics DepositGns call=21/256
// - Gas Used: 6085615
// - Storage Diff: 3568
// - CPU Cycles: 5240511
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=21/256_after 1234913595
// STATE CLOCK launchpad_deposit_call=22/256_before 1234913600
// Launchpad Numerics DepositGns call=22/256
// - Gas Used: 6081094
// - Storage Diff: 3568
// - CPU Cycles: 5235042
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=22/256_after 1234913600
// STATE CLOCK launchpad_deposit_call=23/256_before 1234913605
// Launchpad Numerics DepositGns call=23/256
// - Gas Used: 6088490
// - Storage Diff: 3568
// - CPU Cycles: 5241490
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=23/256_after 1234913605
// STATE CLOCK launchpad_deposit_call=24/256_before 1234913610
// Launchpad Numerics DepositGns call=24/256
// - Gas Used: 6088943
// - Storage Diff: 3568
// - CPU Cycles: 5240995
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=24/256_after 1234913610
// STATE CLOCK launchpad_deposit_call=25/256_before 1234913615
// Launchpad Numerics DepositGns call=25/256
// - Gas Used: 6390635
// - Storage Diff: 10260
// - CPU Cycles: 5490847
// - Realm gno.land/r/gnoswap/launchpad: 10260
// STATE CLOCK launchpad_deposit_call=25/256_after 1234913615
// STATE CLOCK launchpad_deposit_call=26/256_before 1234913620
// Launchpad Numerics DepositGns call=26/256
// - Gas Used: 6077567
// - Storage Diff: 3616
// - CPU Cycles: 5234065
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=26/256_after 1234913620
// STATE CLOCK launchpad_deposit_call=27/256_before 1234913625
// Launchpad Numerics DepositGns call=27/256
// - Gas Used: 6084958
// - Storage Diff: 3568
// - CPU Cycles: 5240508
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=27/256_after 1234913625
// STATE CLOCK launchpad_deposit_call=28/256_before 1234913630
// Launchpad Numerics DepositGns call=28/256
// - Gas Used: 6086885
// - Storage Diff: 3568
// - CPU Cycles: 5241487
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=28/256_after 1234913630
// STATE CLOCK launchpad_deposit_call=29/256_before 1234913635
// Launchpad Numerics DepositGns call=29/256
// - Gas Used: 6083077
// - Storage Diff: 3568
// - CPU Cycles: 5236731
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=29/256_after 1234913635
// STATE CLOCK launchpad_deposit_call=30/256_before 1234913640
// Launchpad Numerics DepositGns call=30/256
// - Gas Used: 6085288
// - Storage Diff: 3568
// - CPU Cycles: 5240346
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=30/256_after 1234913640
// STATE CLOCK launchpad_deposit_call=31/256_before 1234913645
// Launchpad Numerics DepositGns call=31/256
// - Gas Used: 6086725
// - Storage Diff: 3568
// - CPU Cycles: 5240835
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=31/256_after 1234913645
// STATE CLOCK launchpad_deposit_call=32/256_before 1234913650
// Launchpad Numerics DepositGns call=32/256
// - Gas Used: 6084383
// - Storage Diff: 3568
// - CPU Cycles: 5237545
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=32/256_after 1234913650
// STATE launchpad-numerics phase=deposited-stage-32 global_staked=32000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=32000000 tier_total_withdraw=0 tier_deposit_count=32 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=824982105611041150227923453007644893 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=32000000 manager_active_claimed=0 manager_active_debt=21148156285094389901994559640816115053000000 manager_window=2592000 manager_cursor_offset=160 manager_accumulated_distribute=0 manager_rewards=32 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69275 record_created_offset=160 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=33/256_before 1234913655
// Launchpad Numerics DepositGns call=33/256
// - Gas Used: 6393339
// - Storage Diff: 10248
// - CPU Cycles: 5492153
// - Realm gno.land/r/gnoswap/launchpad: 10248
// STATE CLOCK launchpad_deposit_call=33/256_after 1234913655
// STATE CLOCK launchpad_deposit_call=34/256_before 1234913660
// Launchpad Numerics DepositGns call=34/256
// - Gas Used: 6083230
// - Storage Diff: 3616
// - CPU Cycles: 5240838
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=34/256_after 1234913660
// STATE CLOCK launchpad_deposit_call=35/256_before 1234913665
// Launchpad Numerics DepositGns call=35/256
// - Gas Used: 6090139
// - Storage Diff: 3568
// - CPU Cycles: 5246799
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=35/256_after 1234913665
// STATE CLOCK launchpad_deposit_call=36/256_before 1234913670
// Launchpad Numerics DepositGns call=36/256
// - Gas Used: 6085618
// - Storage Diff: 3568
// - CPU Cycles: 5241330
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=36/256_after 1234913670
// STATE CLOCK launchpad_deposit_call=37/256_before 1234913675
// Launchpad Numerics DepositGns call=37/256
// - Gas Used: 6078909
// - Storage Diff: 3568
// - CPU Cycles: 5233673
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=37/256_after 1234913675
// STATE CLOCK launchpad_deposit_call=38/256_before 1234913680
// Launchpad Numerics DepositGns call=38/256
// - Gas Used: 6089196
// - Storage Diff: 3568
// - CPU Cycles: 5243012
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=38/256_after 1234913680
// STATE CLOCK launchpad_deposit_call=39/256_before 1234913685
// Launchpad Numerics DepositGns call=39/256
// - Gas Used: 6093457
// - Storage Diff: 3574
// - CPU Cycles: 5246307
// - Realm gno.land/r/gnoswap/gov/xgns: 6
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=39/256_after 1234913685
// STATE CLOCK launchpad_deposit_call=40/256_before 1234913690
// Launchpad Numerics DepositGns call=40/256
// - Gas Used: 6093357
// - Storage Diff: 3568
// - CPU Cycles: 5247611
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=40/256_after 1234913690
// STATE CLOCK launchpad_deposit_call=41/256_before 1234913695
// Launchpad Numerics DepositGns call=41/256
// - Gas Used: 6396772
// - Storage Diff: 10248
// - CPU Cycles: 5494170
// - Realm gno.land/r/gnoswap/launchpad: 10248
// STATE CLOCK launchpad_deposit_call=41/256_after 1234913695
// STATE CLOCK launchpad_deposit_call=42/256_before 1234913700
// Launchpad Numerics DepositGns call=42/256
// - Gas Used: 6081977
// - Storage Diff: 3616
// - CPU Cycles: 5240683
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=42/256_after 1234913700
// STATE CLOCK launchpad_deposit_call=43/256_before 1234913705
// Launchpad Numerics DepositGns call=43/256
// - Gas Used: 6083899
// - Storage Diff: 3568
// - CPU Cycles: 5241657
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=43/256_after 1234913705
// STATE CLOCK launchpad_deposit_call=44/256_before 1234913710
// Launchpad Numerics DepositGns call=44/256
// - Gas Used: 6089337
// - Storage Diff: 3568
// - CPU Cycles: 5246147
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=44/256_after 1234913710
// STATE CLOCK launchpad_deposit_call=45/256_before 1234913715
// Launchpad Numerics DepositGns call=45/256
// - Gas Used: 6091259
// - Storage Diff: 3568
// - CPU Cycles: 5247121
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=45/256_after 1234913715
// STATE CLOCK launchpad_deposit_call=46/256_before 1234913720
// Launchpad Numerics DepositGns call=46/256
// - Gas Used: 6091725
// - Storage Diff: 3568
// - CPU Cycles: 5246639
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=46/256_after 1234913720
// STATE CLOCK launchpad_deposit_call=47/256_before 1234913725
// Launchpad Numerics DepositGns call=47/256
// - Gas Used: 6092673
// - Storage Diff: 3568
// - CPU Cycles: 5246639
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=47/256_after 1234913725
// STATE CLOCK launchpad_deposit_call=48/256_before 1234913730
// Launchpad Numerics DepositGns call=48/256
// - Gas Used: 6094595
// - Storage Diff: 3568
// - CPU Cycles: 5247613
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=48/256_after 1234913730
// STATE CLOCK launchpad_deposit_call=49/256_before 1234913735
// Launchpad Numerics DepositGns call=49/256
// - Gas Used: 6401946
// - Storage Diff: 10248
// - CPU Cycles: 5497952
// - Realm gno.land/r/gnoswap/launchpad: 10248
// STATE CLOCK launchpad_deposit_call=49/256_after 1234913735
// STATE CLOCK launchpad_deposit_call=50/256_before 1234913740
// Launchpad Numerics DepositGns call=50/256
// - Gas Used: 6086169
// - Storage Diff: 3616
// - CPU Cycles: 5245985
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=50/256_after 1234913740
// STATE CLOCK launchpad_deposit_call=51/256_before 1234913745
// Launchpad Numerics DepositGns call=51/256
// - Gas Used: 6087732
// - Storage Diff: 3605
// - CPU Cycles: 5246474
// - Realm gno.land/r/gnoswap/launchpad: 3605
// STATE CLOCK launchpad_deposit_call=51/256_after 1234913745
// STATE CLOCK launchpad_deposit_call=52/256_before 1234913750
// Launchpad Numerics DepositGns call=52/256
// - Gas Used: 6089193
// - Storage Diff: 3587
// - CPU Cycles: 5246966
// - Realm gno.land/r/gnoswap/launchpad: 3587
// STATE CLOCK launchpad_deposit_call=52/256_after 1234913750
// STATE CLOCK launchpad_deposit_call=53/256_before 1234913755
// Launchpad Numerics DepositGns call=53/256
// - Gas Used: 6089666
// - Storage Diff: 3588
// - CPU Cycles: 5246479
// - Realm gno.land/r/gnoswap/gov/xgns: 1
// - Realm gno.land/r/gnoswap/launchpad: 3587
// STATE CLOCK launchpad_deposit_call=53/256_after 1234913755
// STATE CLOCK launchpad_deposit_call=54/256_before 1234913760
// Launchpad Numerics DepositGns call=54/256
// - Gas Used: 6091600
// - Storage Diff: 3589
// - CPU Cycles: 5247453
// - Realm gno.land/r/gnoswap/gov/xgns: 2
// - Realm gno.land/r/gnoswap/launchpad: 3587
// STATE CLOCK launchpad_deposit_call=54/256_after 1234913760
// STATE CLOCK launchpad_deposit_call=55/256_before 1234913765
// Launchpad Numerics DepositGns call=55/256
// - Gas Used: 6092554
// - Storage Diff: 3587
// - CPU Cycles: 5247453
// - Realm gno.land/r/gnoswap/launchpad: 3587
// STATE CLOCK launchpad_deposit_call=55/256_after 1234913765
// STATE CLOCK launchpad_deposit_call=56/256_before 1234913770
// Launchpad Numerics DepositGns call=56/256
// - Gas Used: 6093513
// - Storage Diff: 3587
// - CPU Cycles: 5247458
// - Realm gno.land/r/gnoswap/launchpad: 3587
// STATE CLOCK launchpad_deposit_call=56/256_after 1234913770
// STATE CLOCK launchpad_deposit_call=57/256_before 1234913775
// Launchpad Numerics DepositGns call=57/256
// - Gas Used: 6403056
// - Storage Diff: 10299
// - CPU Cycles: 5497310
// - Realm gno.land/r/gnoswap/launchpad: 10299
// STATE CLOCK launchpad_deposit_call=57/256_after 1234913775
// STATE CLOCK launchpad_deposit_call=58/256_before 1234913780
// Launchpad Numerics DepositGns call=58/256
// - Gas Used: 6088645
// - Storage Diff: 3637
// - CPU Cycles: 5246961
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=58/256_after 1234913780
// STATE CLOCK launchpad_deposit_call=59/256_before 1234913785
// Launchpad Numerics DepositGns call=59/256
// - Gas Used: 6089112
// - Storage Diff: 3589
// - CPU Cycles: 5246474
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=59/256_after 1234913785
// STATE CLOCK launchpad_deposit_call=60/256_before 1234913790
// Launchpad Numerics DepositGns call=60/256
// - Gas Used: 6081601
// - Storage Diff: 3589
// - CPU Cycles: 5240361
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=60/256_after 1234913790
// STATE CLOCK launchpad_deposit_call=61/256_before 1234913795
// Launchpad Numerics DepositGns call=61/256
// - Gas Used: 6083531
// - Storage Diff: 3589
// - CPU Cycles: 5241337
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=61/256_after 1234913795
// STATE CLOCK launchpad_deposit_call=62/256_before 1234913800
// Launchpad Numerics DepositGns call=62/256
// - Gas Used: 6087151
// - Storage Diff: 3589
// - CPU Cycles: 5244003
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=62/256_after 1234913800
// STATE CLOCK launchpad_deposit_call=63/256_before 1234913805
// Launchpad Numerics DepositGns call=63/256
// - Gas Used: 6091885
// - Storage Diff: 3589
// - CPU Cycles: 5247783
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=63/256_after 1234913805
// STATE CLOCK launchpad_deposit_call=64/256_before 1234913810
// Launchpad Numerics DepositGns call=64/256
// - Gas Used: 6092347
// - Storage Diff: 3589
// - CPU Cycles: 5247291
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=64/256_after 1234913810
// STATE CLOCK launchpad_deposit_call=65/256_before 1234913815
// Launchpad Numerics DepositGns call=65/256
// - Gas Used: 6405467
// - Storage Diff: 10291
// - CPU Cycles: 5498119
// - Realm gno.land/r/gnoswap/launchpad: 10291
// STATE CLOCK launchpad_deposit_call=65/256_after 1234913815
// STATE CLOCK launchpad_deposit_call=66/256_before 1234913820
// Launchpad Numerics DepositGns call=66/256
// - Gas Used: 6093838
// - Storage Diff: 3637
// - CPU Cycles: 5253252
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=66/256_after 1234913820
// STATE CLOCK launchpad_deposit_call=67/256_before 1234913825
// Launchpad Numerics DepositGns call=67/256
// - Gas Used: 6094792
// - Storage Diff: 3589
// - CPU Cycles: 5253252
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=67/256_after 1234913825
// STATE CLOCK launchpad_deposit_call=68/256_before 1234913830
// Launchpad Numerics DepositGns call=68/256
// - Gas Used: 6090277
// - Storage Diff: 3589
// - CPU Cycles: 5247783
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=68/256_after 1234913830
// STATE CLOCK launchpad_deposit_call=69/256_before 1234913835
// Launchpad Numerics DepositGns call=69/256
// - Gas Used: 6090257
// - Storage Diff: 3589
// - CPU Cycles: 5246809
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=69/256_after 1234913835
// STATE CLOCK launchpad_deposit_call=70/256_before 1234913840
// Launchpad Numerics DepositGns call=70/256
// - Gas Used: 6094653
// - Storage Diff: 3589
// - CPU Cycles: 5252603
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=70/256_after 1234913840
// STATE CLOCK launchpad_deposit_call=71/256_before 1234913845
// Launchpad Numerics DepositGns call=71/256
// - Gas Used: 6095609
// - Storage Diff: 3589
// - CPU Cycles: 5252605
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=71/256_after 1234913845
// STATE CLOCK launchpad_deposit_call=72/256_before 1234913850
// Launchpad Numerics DepositGns call=72/256
// - Gas Used: 6097542
// - Storage Diff: 3589
// - CPU Cycles: 5253584
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=72/256_after 1234913850
// STATE CLOCK launchpad_deposit_call=73/256_before 1234913855
// Launchpad Numerics DepositGns call=73/256
// - Gas Used: 6413210
// - Storage Diff: 10291
// - CPU Cycles: 5504410
// - Realm gno.land/r/gnoswap/launchpad: 10291
// STATE CLOCK launchpad_deposit_call=73/256_after 1234913855
// STATE CLOCK launchpad_deposit_call=74/256_before 1234913860
// Launchpad Numerics DepositGns call=74/256
// - Gas Used: 6086612
// - Storage Diff: 3637
// - CPU Cycles: 5247136
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=74/256_after 1234913860
// STATE CLOCK launchpad_deposit_call=75/256_before 1234913865
// Launchpad Numerics DepositGns call=75/256
// - Gas Used: 6088053
// - Storage Diff: 3589
// - CPU Cycles: 5247623
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=75/256_after 1234913865
// STATE CLOCK launchpad_deposit_call=76/256_before 1234913870
// Launchpad Numerics DepositGns call=76/256
// - Gas Used: 6094476
// - Storage Diff: 3589
// - CPU Cycles: 5253092
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=76/256_after 1234913870
// STATE CLOCK launchpad_deposit_call=77/256_before 1234913875
// Launchpad Numerics DepositGns call=77/256
// - Gas Used: 6095430
// - Storage Diff: 3589
// - CPU Cycles: 5253092
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=77/256_after 1234913875
// STATE CLOCK launchpad_deposit_call=78/256_before 1234913880
// Launchpad Numerics DepositGns call=78/256
// - Gas Used: 6095897
// - Storage Diff: 3589
// - CPU Cycles: 5252605
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=78/256_after 1234913880
// STATE CLOCK launchpad_deposit_call=79/256_before 1234913885
// Launchpad Numerics DepositGns call=79/256
// - Gas Used: 6097338
// - Storage Diff: 3589
// - CPU Cycles: 5253092
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=79/256_after 1234913885
// STATE CLOCK launchpad_deposit_call=80/256_before 1234913890
// Launchpad Numerics DepositGns call=80/256
// - Gas Used: 6096270
// - Storage Diff: 3589
// - CPU Cycles: 5253422
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=80/256_after 1234913890
// STATE CLOCK launchpad_deposit_call=81/256_before 1234913895
// Launchpad Numerics DepositGns call=81/256
// - Gas Used: 6413474
// - Storage Diff: 10291
// - CPU Cycles: 5503276
// - Realm gno.land/r/gnoswap/launchpad: 10291
// STATE CLOCK launchpad_deposit_call=81/256_after 1234913895
// STATE CLOCK launchpad_deposit_call=82/256_before 1234913900
// Launchpad Numerics DepositGns call=82/256
// - Gas Used: 6085354
// - Storage Diff: 3637
// - CPU Cycles: 5246976
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=82/256_after 1234913900
// STATE CLOCK launchpad_deposit_call=83/256_before 1234913905
// Launchpad Numerics DepositGns call=83/256
// - Gas Used: 6082524
// - Storage Diff: 3589
// - CPU Cycles: 5243192
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=83/256_after 1234913905
// STATE CLOCK launchpad_deposit_call=84/256_before 1234913910
// Launchpad Numerics DepositGns call=84/256
// - Gas Used: 6093221
// - Storage Diff: 3589
// - CPU Cycles: 5252935
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=84/256_after 1234913910
// STATE CLOCK launchpad_deposit_call=85/256_before 1234913915
// Launchpad Numerics DepositGns call=85/256
// - Gas Used: 6090882
// - Storage Diff: 3589
// - CPU Cycles: 5249642
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=85/256_after 1234913915
// STATE CLOCK launchpad_deposit_call=86/256_before 1234913920
// Launchpad Numerics DepositGns call=86/256
// - Gas Used: 6095618
// - Storage Diff: 3589
// - CPU Cycles: 5253424
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=86/256_after 1234913920
// STATE CLOCK launchpad_deposit_call=87/256_before 1234913925
// Launchpad Numerics DepositGns call=87/256
// - Gas Used: 6095598
// - Storage Diff: 3589
// - CPU Cycles: 5252450
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=87/256_after 1234913925
// STATE CLOCK launchpad_deposit_call=88/256_before 1234913930
// Launchpad Numerics DepositGns call=88/256
// - Gas Used: 6097039
// - Storage Diff: 3589
// - CPU Cycles: 5252937
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=88/256_after 1234913930
// STATE CLOCK launchpad_deposit_call=89/256_before 1234913935
// Launchpad Numerics DepositGns call=89/256
// - Gas Used: 6416363
// - Storage Diff: 10291
// - CPU Cycles: 5504737
// - Realm gno.land/r/gnoswap/launchpad: 10291
// STATE CLOCK launchpad_deposit_call=89/256_after 1234913935
// STATE CLOCK launchpad_deposit_call=90/256_before 1234913940
// Launchpad Numerics DepositGns call=90/256
// - Gas Used: 6082534
// - Storage Diff: 3650
// - CPU Cycles: 5245215
// - Realm gno.land/r/gnoswap/gns: 13
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=90/256_after 1234913940
// STATE CLOCK launchpad_deposit_call=91/256_before 1234913945
// Launchpad Numerics DepositGns call=91/256
// - Gas Used: 6082559
// - Storage Diff: 3604
// - CPU Cycles: 5244241
// - Realm gno.land/r/gnoswap/gns: 15
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=91/256_after 1234913945
// STATE CLOCK launchpad_deposit_call=92/256_before 1234913950
// Launchpad Numerics DepositGns call=92/256
// - Gas Used: 6080218
// - Storage Diff: 3589
// - CPU Cycles: 5240946
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=92/256_after 1234913950
// STATE CLOCK launchpad_deposit_call=93/256_before 1234913955
// Launchpad Numerics DepositGns call=93/256
// - Gas Used: 6086510
// - Storage Diff: 3589
// - CPU Cycles: 5246284
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=93/256_after 1234913955
// STATE CLOCK launchpad_deposit_call=94/256_before 1234913960
// Launchpad Numerics DepositGns call=94/256
// - Gas Used: 6086490
// - Storage Diff: 3589
// - CPU Cycles: 5245310
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=94/256_after 1234913960
// STATE CLOCK launchpad_deposit_call=95/256_before 1234913965
// Launchpad Numerics DepositGns call=95/256
// - Gas Used: 6082595
// - Storage Diff: 3589
// - CPU Cycles: 5240461
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=95/256_after 1234913965
// STATE CLOCK launchpad_deposit_call=96/256_before 1234913970
// Launchpad Numerics DepositGns call=96/256
// - Gas Used: 6094846
// - Storage Diff: 3589
// - CPU Cycles: 5251758
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=96/256_after 1234913970
// STATE CLOCK launchpad_deposit_call=97/256_before 1234913975
// Launchpad Numerics DepositGns call=97/256
// - Gas Used: 6341096
// - Storage Diff: 10011
// - CPU Cycles: 5428798
// - Realm gno.land/r/gnoswap/launchpad: 10011
// STATE CLOCK launchpad_deposit_call=97/256_after 1234913975
// STATE CLOCK launchpad_deposit_call=98/256_before 1234913980
// Launchpad Numerics DepositGns call=98/256
// - Gas Used: 6064841
// - Storage Diff: 3637
// - CPU Cycles: 5232901
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=98/256_after 1234913980
// STATE CLOCK launchpad_deposit_call=99/256_before 1234913985
// Launchpad Numerics DepositGns call=99/256
// - Gas Used: 6072243
// - Storage Diff: 3589
// - CPU Cycles: 5239349
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=99/256_after 1234913985
// STATE CLOCK launchpad_deposit_call=100/256_before 1234913990
// Launchpad Numerics DepositGns call=100/256
// - Gas Used: 6135944
// - Storage Diff: 3574
// - CPU Cycles: 5282322
// - Realm gno.land/r/gnoswap/launchpad: 3574
// STATE CLOCK launchpad_deposit_call=100/256_after 1234913990
// STATE CLOCK launchpad_deposit_call=101/256_before 1234913995
// Launchpad Numerics DepositGns call=101/256
// - Gas Used: 6135812
// - Storage Diff: 3550
// - CPU Cycles: 5281350
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=101/256_after 1234913995
// STATE CLOCK launchpad_deposit_call=102/256_before 1234914000
// Launchpad Numerics DepositGns call=102/256
// - Gas Used: 6143589
// - Storage Diff: 3550
// - CPU Cycles: 5288287
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=102/256_after 1234914000
// STATE CLOCK launchpad_deposit_call=103/256_before 1234914005
// Launchpad Numerics DepositGns call=103/256
// - Gas Used: 6138471
// - Storage Diff: 3550
// - CPU Cycles: 5282329
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=103/256_after 1234914005
// STATE CLOCK launchpad_deposit_call=104/256_before 1234914010
// Launchpad Numerics DepositGns call=104/256
// - Gas Used: 6139311
// - Storage Diff: 3550
// - CPU Cycles: 5282329
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=104/256_after 1234914010
// STATE CLOCK launchpad_deposit_call=105/256_before 1234914015
// Launchpad Numerics DepositGns call=105/256
// - Gas Used: 6145617
// - Storage Diff: 3550
// - CPU Cycles: 5287795
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=105/256_after 1234914015
// STATE CLOCK launchpad_deposit_call=106/256_before 1234914020
// Launchpad Numerics DepositGns call=106/256
// - Gas Used: 6145970
// - Storage Diff: 3550
// - CPU Cycles: 5287308
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=106/256_after 1234914020
// STATE CLOCK launchpad_deposit_call=107/256_before 1234914025
// Launchpad Numerics DepositGns call=107/256
// - Gas Used: 6148276
// - Storage Diff: 3550
// - CPU Cycles: 5288774
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=107/256_after 1234914025
// STATE CLOCK launchpad_deposit_call=108/256_before 1234914030
// Launchpad Numerics DepositGns call=108/256
// - Gas Used: 6457300
// - Storage Diff: 10036
// - CPU Cycles: 5539680
// - Realm gno.land/r/gnoswap/launchpad: 10036
// STATE CLOCK launchpad_deposit_call=108/256_after 1234914030
// STATE CLOCK launchpad_deposit_call=109/256_before 1234914035
// Launchpad Numerics DepositGns call=109/256
// - Gas Used: 6137248
// - Storage Diff: 3640
// - CPU Cycles: 5282816
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=109/256_after 1234914035
// STATE CLOCK launchpad_deposit_call=110/256_before 1234914040
// Launchpad Numerics DepositGns call=110/256
// - Gas Used: 6132398
// - Storage Diff: 3592
// - CPU Cycles: 5279364
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=110/256_after 1234914040
// STATE CLOCK launchpad_deposit_call=111/256_before 1234914045
// Launchpad Numerics DepositGns call=111/256
// - Gas Used: 6138826
// - Storage Diff: 3592
// - CPU Cycles: 5284832
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=111/256_after 1234914045
// STATE CLOCK launchpad_deposit_call=112/256_before 1234914050
// Launchpad Numerics DepositGns call=112/256
// - Gas Used: 6143568
// - Storage Diff: 3592
// - CPU Cycles: 5288614
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=112/256_after 1234914050
// STATE CLOCK launchpad_deposit_call=113/256_before 1234914055
// Launchpad Numerics DepositGns call=113/256
// - Gas Used: 6145020
// - Storage Diff: 3592
// - CPU Cycles: 5289106
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=113/256_after 1234914055
// STATE CLOCK launchpad_deposit_call=114/256_before 1234914060
// Launchpad Numerics DepositGns call=114/256
// - Gas Used: 6144519
// - Storage Diff: 3592
// - CPU Cycles: 5287645
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=114/256_after 1234914060
// STATE CLOCK launchpad_deposit_call=115/256_before 1234914065
// Launchpad Numerics DepositGns call=115/256
// - Gas Used: 6146940
// - Storage Diff: 3592
// - CPU Cycles: 5289106
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=115/256_after 1234914065
// STATE CLOCK launchpad_deposit_call=116/256_before 1234914070
// Launchpad Numerics DepositGns call=116/256
// - Gas Used: 6480967
// - Storage Diff: 10296
// - CPU Cycles: 5542085
// - Realm gno.land/r/gnoswap/launchpad: 10296
// STATE CLOCK launchpad_deposit_call=116/256_after 1234914070
// STATE CLOCK launchpad_deposit_call=117/256_before 1234914075
// Launchpad Numerics DepositGns call=117/256
// - Gas Used: 6135502
// - Storage Diff: 3640
// - CPU Cycles: 5282174
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=117/256_after 1234914075
// STATE CLOCK launchpad_deposit_call=118/256_before 1234914080
// Launchpad Numerics DepositGns call=118/256
// - Gas Used: 6136949
// - Storage Diff: 3592
// - CPU Cycles: 5282661
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=118/256_after 1234914080
// STATE CLOCK launchpad_deposit_call=119/256_before 1234914085
// Launchpad Numerics DepositGns call=119/256
// - Gas Used: 6143862
// - Storage Diff: 3592
// - CPU Cycles: 5288614
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=119/256_after 1234914085
// STATE CLOCK launchpad_deposit_call=120/256_before 1234914090
// Launchpad Numerics DepositGns call=120/256
// - Gas Used: 6142794
// - Storage Diff: 3592
// - CPU Cycles: 5288944
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=120/256_after 1234914090
// STATE CLOCK launchpad_deposit_call=121/256_before 1234914095
// Launchpad Numerics DepositGns call=121/256
// - Gas Used: 6143269
// - Storage Diff: 3592
// - CPU Cycles: 5288459
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=121/256_after 1234914095
// STATE CLOCK launchpad_deposit_call=122/256_before 1234914100
// Launchpad Numerics DepositGns call=122/256
// - Gas Used: 6144227
// - Storage Diff: 3592
// - CPU Cycles: 5288457
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=122/256_after 1234914100
// STATE CLOCK launchpad_deposit_call=123/256_before 1234914105
// Launchpad Numerics DepositGns call=123/256
// - Gas Used: 6145679
// - Storage Diff: 3592
// - CPU Cycles: 5288949
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=123/256_after 1234914105
// STATE CLOCK launchpad_deposit_call=124/256_before 1234914110
// Launchpad Numerics DepositGns call=124/256
// - Gas Used: 6482240
// - Storage Diff: 10296
// - CPU Cycles: 5541930
// - Realm gno.land/r/gnoswap/launchpad: 10296
// STATE CLOCK launchpad_deposit_call=124/256_after 1234914110
// STATE CLOCK launchpad_deposit_call=125/256_before 1234914115
// Launchpad Numerics DepositGns call=125/256
// - Gas Used: 6141170
// - Storage Diff: 3640
// - CPU Cycles: 5288946
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=125/256_after 1234914115
// STATE CLOCK launchpad_deposit_call=126/256_before 1234914120
// Launchpad Numerics DepositGns call=126/256
// - Gas Used: 6138835
// - Storage Diff: 3592
// - CPU Cycles: 5285651
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=126/256_after 1234914120
// STATE CLOCK launchpad_deposit_call=127/256_before 1234914125
// Launchpad Numerics DepositGns call=127/256
// - Gas Used: 6139800
// - Storage Diff: 3592
// - CPU Cycles: 5285656
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=127/256_after 1234914125
// STATE CLOCK launchpad_deposit_call=128/256_before 1234914130
// Launchpad Numerics DepositGns call=128/256
// - Gas Used: 6144055
// - Storage Diff: 3592
// - CPU Cycles: 5288951
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=128/256_after 1234914130
// STATE launchpad-numerics phase=deposited-stage-128 global_staked=128000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=128000000 tier_total_withdraw=0 tier_deposit_count=128 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1054411681821579576241805020507828326 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=128000000 manager_active_claimed=0 manager_active_debt=113959610895326478137755079203287942984000000 manager_window=2592000 manager_cursor_offset=640 manager_accumulated_distribute=0 manager_rewards=128 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69371 record_created_offset=640 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=129/256_before 1234914135
// Launchpad Numerics DepositGns call=129/256
// - Gas Used: 6145015
// - Storage Diff: 3592
// - CPU Cycles: 5288951
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=129/256_after 1234914135
// STATE CLOCK launchpad_deposit_call=130/256_before 1234914140
// Launchpad Numerics DepositGns call=130/256
// - Gas Used: 6143947
// - Storage Diff: 3592
// - CPU Cycles: 5289281
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=130/256_after 1234914140
// STATE CLOCK launchpad_deposit_call=131/256_before 1234914145
// Launchpad Numerics DepositGns call=131/256
// - Gas Used: 6144904
// - Storage Diff: 3592
// - CPU Cycles: 5289278
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=131/256_after 1234914145
// STATE CLOCK launchpad_deposit_call=132/256_before 1234914150
// Launchpad Numerics DepositGns call=132/256
// - Gas Used: 6483995
// - Storage Diff: 10296
// - CPU Cycles: 5542257
// - Realm gno.land/r/gnoswap/launchpad: 10296
// STATE CLOCK launchpad_deposit_call=132/256_after 1234914150
// STATE CLOCK launchpad_deposit_call=133/256_before 1234914155
// Launchpad Numerics DepositGns call=133/256
// - Gas Used: 6139894
// - Storage Diff: 3640
// - CPU Cycles: 5288786
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=133/256_after 1234914155
// STATE CLOCK launchpad_deposit_call=134/256_before 1234914160
// Launchpad Numerics DepositGns call=134/256
// - Gas Used: 6140367
// - Storage Diff: 3592
// - CPU Cycles: 5288299
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=134/256_after 1234914160
// STATE CLOCK launchpad_deposit_call=135/256_before 1234914165
// Launchpad Numerics DepositGns call=135/256
// - Gas Used: 6135856
// - Storage Diff: 3592
// - CPU Cycles: 5282828
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=135/256_after 1234914165
// STATE CLOCK launchpad_deposit_call=136/256_before 1234914170
// Launchpad Numerics DepositGns call=136/256
// - Gas Used: 6136329
// - Storage Diff: 3592
// - CPU Cycles: 5282341
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=136/256_after 1234914170
// STATE CLOCK launchpad_deposit_call=137/256_before 1234914175
// Launchpad Numerics DepositGns call=137/256
// - Gas Used: 6143252
// - Storage Diff: 3592
// - CPU Cycles: 5288304
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=137/256_after 1234914175
// STATE CLOCK launchpad_deposit_call=138/256_before 1234914180
// Launchpad Numerics DepositGns call=138/256
// - Gas Used: 6144699
// - Storage Diff: 3592
// - CPU Cycles: 5288791
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=138/256_after 1234914180
// STATE CLOCK launchpad_deposit_call=139/256_before 1234914185
// Launchpad Numerics DepositGns call=139/256
// - Gas Used: 6144193
// - Storage Diff: 3592
// - CPU Cycles: 5287325
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=139/256_after 1234914185
// STATE CLOCK launchpad_deposit_call=140/256_before 1234914190
// Launchpad Numerics DepositGns call=140/256
// - Gas Used: 6879923
// - Storage Diff: 23858
// - CPU Cycles: 5879003
// - Realm gno.land/r/gnoswap/launchpad: 23858
// STATE CLOCK launchpad_deposit_call=140/256_after 1234914190
// STATE CLOCK launchpad_deposit_call=141/256_before 1234914195
// Launchpad Numerics DepositGns call=141/256
// - Gas Used: 6170800
// - Storage Diff: 3712
// - CPU Cycles: 5313300
// - Realm gno.land/r/gnoswap/launchpad: 3712
// STATE CLOCK launchpad_deposit_call=141/256_after 1234914195
// STATE CLOCK launchpad_deposit_call=142/256_before 1234914200
// Launchpad Numerics DepositGns call=142/256
// - Gas Used: 6168463
// - Storage Diff: 3592
// - CPU Cycles: 5310003
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=142/256_after 1234914200
// STATE CLOCK launchpad_deposit_call=143/256_before 1234914205
// Launchpad Numerics DepositGns call=143/256
// - Gas Used: 6179163
// - Storage Diff: 3592
// - CPU Cycles: 5319743
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=143/256_after 1234914205
// STATE CLOCK launchpad_deposit_call=144/256_before 1234914210
// Launchpad Numerics DepositGns call=144/256
// - Gas Used: 6180125
// - Storage Diff: 3592
// - CPU Cycles: 5319745
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=144/256_after 1234914210
// STATE CLOCK launchpad_deposit_call=145/256_before 1234914215
// Launchpad Numerics DepositGns call=145/256
// - Gas Used: 6181085
// - Storage Diff: 3592
// - CPU Cycles: 5319745
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=145/256_after 1234914215
// STATE CLOCK launchpad_deposit_call=146/256_before 1234914220
// Launchpad Numerics DepositGns call=146/256
// - Gas Used: 6181558
// - Storage Diff: 3592
// - CPU Cycles: 5319258
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=146/256_after 1234914220
// STATE CLOCK launchpad_deposit_call=147/256_before 1234914225
// Launchpad Numerics DepositGns call=147/256
// - Gas Used: 6183010
// - Storage Diff: 3592
// - CPU Cycles: 5319750
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=147/256_after 1234914225
// STATE CLOCK launchpad_deposit_call=148/256_before 1234914230
// Launchpad Numerics DepositGns call=148/256
// - Gas Used: 6504973
// - Storage Diff: 10270
// - CPU Cycles: 5571543
// - Realm gno.land/r/gnoswap/launchpad: 10270
// STATE CLOCK launchpad_deposit_call=148/256_after 1234914230
// STATE CLOCK launchpad_deposit_call=149/256_before 1234914235
// Launchpad Numerics DepositGns call=149/256
// - Gas Used: 6172541
// - Storage Diff: 3640
// - CPU Cycles: 5313787
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=149/256_after 1234914235
// STATE CLOCK launchpad_deposit_call=150/256_before 1234914240
// Launchpad Numerics DepositGns call=150/256
// - Gas Used: 6170981
// - Storage Diff: 3592
// - CPU Cycles: 5313625
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=150/256_after 1234914240
// STATE CLOCK launchpad_deposit_call=151/256_before 1234914245
// Launchpad Numerics DepositGns call=151/256
// - Gas Used: 6177904
// - Storage Diff: 3592
// - CPU Cycles: 5319588
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=151/256_after 1234914245
// STATE CLOCK launchpad_deposit_call=152/256_before 1234914250
// Launchpad Numerics DepositGns call=152/256
// - Gas Used: 6178866
// - Storage Diff: 3592
// - CPU Cycles: 5319590
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=152/256_after 1234914250
// STATE CLOCK launchpad_deposit_call=153/256_before 1234914255
// Launchpad Numerics DepositGns call=153/256
// - Gas Used: 6179826
// - Storage Diff: 3592
// - CPU Cycles: 5319590
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=153/256_after 1234914255
// STATE CLOCK launchpad_deposit_call=154/256_before 1234914260
// Launchpad Numerics DepositGns call=154/256
// - Gas Used: 6181273
// - Storage Diff: 3592
// - CPU Cycles: 5320077
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=154/256_after 1234914260
// STATE CLOCK launchpad_deposit_call=155/256_before 1234914265
// Launchpad Numerics DepositGns call=155/256
// - Gas Used: 6182233
// - Storage Diff: 3592
// - CPU Cycles: 5320077
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=155/256_after 1234914265
// STATE CLOCK launchpad_deposit_call=156/256_before 1234914270
// Launchpad Numerics DepositGns call=156/256
// - Gas Used: 6505626
// - Storage Diff: 10256
// - CPU Cycles: 5570894
// - Realm gno.land/r/gnoswap/launchpad: 10256
// STATE CLOCK launchpad_deposit_call=156/256_after 1234914270
// STATE CLOCK launchpad_deposit_call=157/256_before 1234914275
// Launchpad Numerics DepositGns call=157/256
// - Gas Used: 6171750
// - Storage Diff: 3640
// - CPU Cycles: 5314112
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=157/256_after 1234914275
// STATE CLOCK launchpad_deposit_call=158/256_before 1234914280
// Launchpad Numerics DepositGns call=158/256
// - Gas Used: 6172223
// - Storage Diff: 3592
// - CPU Cycles: 5313625
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=158/256_after 1234914280
// STATE CLOCK launchpad_deposit_call=159/256_before 1234914285
// Launchpad Numerics DepositGns call=159/256
// - Gas Used: 6180120
// - Storage Diff: 3592
// - CPU Cycles: 5320562
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=159/256_after 1234914285
// STATE CLOCK launchpad_deposit_call=160/256_before 1234914290
// Launchpad Numerics DepositGns call=160/256
// - Gas Used: 6170024
// - Storage Diff: 3592
// - CPU Cycles: 5311864
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=160/256_after 1234914290
// STATE CLOCK launchpad_deposit_call=161/256_before 1234914295
// Launchpad Numerics DepositGns call=161/256
// - Gas Used: 6170499
// - Storage Diff: 3592
// - CPU Cycles: 5311379
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=161/256_after 1234914295
// STATE CLOCK launchpad_deposit_call=162/256_before 1234914300
// Launchpad Numerics DepositGns call=162/256
// - Gas Used: 6171457
// - Storage Diff: 3592
// - CPU Cycles: 5311377
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=162/256_after 1234914300
// STATE CLOCK launchpad_deposit_call=163/256_before 1234914305
// Launchpad Numerics DepositGns call=163/256
// - Gas Used: 6178867
// - Storage Diff: 3592
// - CPU Cycles: 5317827
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=163/256_after 1234914305
// STATE CLOCK launchpad_deposit_call=164/256_before 1234914310
// Launchpad Numerics DepositGns call=164/256
// - Gas Used: 6433335
// - Storage Diff: 9978
// - CPU Cycles: 5498159
// - Realm gno.land/r/gnoswap/launchpad: 9978
// STATE CLOCK launchpad_deposit_call=164/256_after 1234914310
// STATE CLOCK launchpad_deposit_call=165/256_before 1234914315
// Launchpad Numerics DepositGns call=165/256
// - Gas Used: 6147820
// - Storage Diff: 3640
// - CPU Cycles: 5297994
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=165/256_after 1234914315
// STATE CLOCK launchpad_deposit_call=166/256_before 1234914320
// Launchpad Numerics DepositGns call=166/256
// - Gas Used: 6154743
// - Storage Diff: 3592
// - CPU Cycles: 5303957
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=166/256_after 1234914320
// STATE CLOCK launchpad_deposit_call=167/256_before 1234914325
// Launchpad Numerics DepositGns call=167/256
// - Gas Used: 6156677
// - Storage Diff: 3592
// - CPU Cycles: 5304931
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=167/256_after 1234914325
// STATE CLOCK launchpad_deposit_call=168/256_before 1234914330
// Launchpad Numerics DepositGns call=168/256
// - Gas Used: 6149493
// - Storage Diff: 3592
// - CPU Cycles: 5296787
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=168/256_after 1234914330
// STATE CLOCK launchpad_deposit_call=169/256_before 1234914335
// Launchpad Numerics DepositGns call=169/256
// - Gas Used: 6158597
// - Storage Diff: 3592
// - CPU Cycles: 5304931
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=169/256_after 1234914335
// STATE CLOCK launchpad_deposit_call=170/256_before 1234914340
// Launchpad Numerics DepositGns call=170/256
// - Gas Used: 6177585
// - Storage Diff: 3574
// - CPU Cycles: 5320049
// - Realm gno.land/r/gnoswap/launchpad: 3574
// STATE CLOCK launchpad_deposit_call=170/256_after 1234914340
// STATE CLOCK launchpad_deposit_call=171/256_before 1234914345
// Launchpad Numerics DepositGns call=171/256
// - Gas Used: 6171980
// - Storage Diff: 3550
// - CPU Cycles: 5313604
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=171/256_after 1234914345
// STATE CLOCK launchpad_deposit_call=172/256_before 1234914350
// Launchpad Numerics DepositGns call=172/256
// - Gas Used: 6174996
// - Storage Diff: 3550
// - CPU Cycles: 5315780
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=172/256_after 1234914350
// STATE CLOCK launchpad_deposit_call=173/256_before 1234914355
// Launchpad Numerics DepositGns call=173/256
// - Gas Used: 6180112
// - Storage Diff: 3550
// - CPU Cycles: 5320056
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=173/256_after 1234914355
// STATE CLOCK launchpad_deposit_call=174/256_before 1234914360
// Launchpad Numerics DepositGns call=174/256
// - Gas Used: 6181926
// - Storage Diff: 3550
// - CPU Cycles: 5321030
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=174/256_after 1234914360
// STATE CLOCK launchpad_deposit_call=175/256_before 1234914365
// Launchpad Numerics DepositGns call=175/256
// - Gas Used: 6175834
// - Storage Diff: 3550
// - CPU Cycles: 5314098
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=175/256_after 1234914365
// STATE CLOCK launchpad_deposit_call=176/256_before 1234914370
// Launchpad Numerics DepositGns call=176/256
// - Gas Used: 6184098
// - Storage Diff: 3550
// - CPU Cycles: 5321522
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=176/256_after 1234914370
// STATE CLOCK launchpad_deposit_call=177/256_before 1234914375
// Launchpad Numerics DepositGns call=177/256
// - Gas Used: 6183467
// - Storage Diff: 3550
// - CPU Cycles: 5320051
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=177/256_after 1234914375
// STATE CLOCK launchpad_deposit_call=178/256_before 1234914380
// Launchpad Numerics DepositGns call=178/256
// - Gas Used: 6483845
// - Storage Diff: 9986
// - CPU Cycles: 5568557
// - Realm gno.land/r/gnoswap/launchpad: 9986
// STATE CLOCK launchpad_deposit_call=178/256_after 1234914380
// STATE CLOCK launchpad_deposit_call=179/256_before 1234914385
// Launchpad Numerics DepositGns call=179/256
// - Gas Used: 6194743
// - Storage Diff: 3640
// - CPU Cycles: 5320539
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=179/256_after 1234914385
// STATE CLOCK launchpad_deposit_call=180/256_before 1234914390
// Launchpad Numerics DepositGns call=180/256
// - Gas Used: 6199146
// - Storage Diff: 3592
// - CPU Cycles: 5326340
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=180/256_after 1234914390
// STATE CLOCK launchpad_deposit_call=181/256_before 1234914395
// Launchpad Numerics DepositGns call=181/256
// - Gas Used: 6194639
// - Storage Diff: 3592
// - CPU Cycles: 5320873
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=181/256_after 1234914395
// STATE CLOCK launchpad_deposit_call=182/256_before 1234914400
// Launchpad Numerics DepositGns call=182/256
// - Gas Used: 6195597
// - Storage Diff: 3592
// - CPU Cycles: 5320871
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=182/256_after 1234914400
// STATE CLOCK launchpad_deposit_call=183/256_before 1234914405
// Launchpad Numerics DepositGns call=183/256
// - Gas Used: 6202510
// - Storage Diff: 3592
// - CPU Cycles: 5326824
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=183/256_after 1234914405
// STATE CLOCK launchpad_deposit_call=184/256_before 1234914410
// Launchpad Numerics DepositGns call=184/256
// - Gas Used: 6202983
// - Storage Diff: 3592
// - CPU Cycles: 5326337
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=184/256_after 1234914410
// STATE CLOCK launchpad_deposit_call=185/256_before 1234914415
// Launchpad Numerics DepositGns call=185/256
// - Gas Used: 6204924
// - Storage Diff: 3592
// - CPU Cycles: 5327318
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=185/256_after 1234914415
// STATE CLOCK launchpad_deposit_call=186/256_before 1234914420
// Launchpad Numerics DepositGns call=186/256
// - Gas Used: 6514315
// - Storage Diff: 10258
// - CPU Cycles: 5577897
// - Realm gno.land/r/gnoswap/launchpad: 10258
// STATE CLOCK launchpad_deposit_call=186/256_after 1234914420
// STATE CLOCK launchpad_deposit_call=187/256_before 1234914425
// Launchpad Numerics DepositGns call=187/256
// - Gas Used: 6193479
// - Storage Diff: 3640
// - CPU Cycles: 5320379
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=187/256_after 1234914425
// STATE CLOCK launchpad_deposit_call=188/256_before 1234914430
// Launchpad Numerics DepositGns call=188/256
// - Gas Used: 6200402
// - Storage Diff: 3592
// - CPU Cycles: 5326342
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=188/256_after 1234914430
// STATE CLOCK launchpad_deposit_call=189/256_before 1234914435
// Launchpad Numerics DepositGns call=189/256
// - Gas Used: 6196380
// - Storage Diff: 3592
// - CPU Cycles: 5321360
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=189/256_after 1234914435
// STATE CLOCK launchpad_deposit_call=190/256_before 1234914440
// Launchpad Numerics DepositGns call=190/256
// - Gas Used: 6199310
// - Storage Diff: 3592
// - CPU Cycles: 5325688
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=190/256_after 1234914440
// STATE CLOCK launchpad_deposit_call=191/256_before 1234914445
// Launchpad Numerics DepositGns call=191/256
// - Gas Used: 6201249
// - Storage Diff: 3592
// - CPU Cycles: 5326667
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=191/256_after 1234914445
// STATE CLOCK launchpad_deposit_call=192/256_before 1234914450
// Launchpad Numerics DepositGns call=192/256
// - Gas Used: 6202698
// - Storage Diff: 3592
// - CPU Cycles: 5327156
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=192/256_after 1234914450
// STATE CLOCK launchpad_deposit_call=193/256_before 1234914455
// Launchpad Numerics DepositGns call=193/256
// - Gas Used: 6202684
// - Storage Diff: 3592
// - CPU Cycles: 5326182
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=193/256_after 1234914455
// STATE CLOCK launchpad_deposit_call=194/256_before 1234914460
// Launchpad Numerics DepositGns call=194/256
// - Gas Used: 6515461
// - Storage Diff: 10258
// - CPU Cycles: 5577735
// - Realm gno.land/r/gnoswap/launchpad: 10258
// STATE CLOCK launchpad_deposit_call=194/256_after 1234914460
// STATE CLOCK launchpad_deposit_call=195/256_before 1234914465
// Launchpad Numerics DepositGns call=195/256
// - Gas Used: 6192220
// - Storage Diff: 3640
// - CPU Cycles: 5320224
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=195/256_after 1234914465
// STATE CLOCK launchpad_deposit_call=196/256_before 1234914470
// Launchpad Numerics DepositGns call=196/256
// - Gas Used: 6193667
// - Storage Diff: 3592
// - CPU Cycles: 5320711
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=196/256_after 1234914470
// STATE CLOCK launchpad_deposit_call=197/256_before 1234914475
// Launchpad Numerics DepositGns call=197/256
// - Gas Used: 6196311
// - Storage Diff: 3592
// - CPU Cycles: 5322395
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=197/256_after 1234914475
// STATE CLOCK launchpad_deposit_call=198/256_before 1234914480
// Launchpad Numerics DepositGns call=198/256
// - Gas Used: 6197758
// - Storage Diff: 3592
// - CPU Cycles: 5322882
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=198/256_after 1234914480
// STATE CLOCK launchpad_deposit_call=199/256_before 1234914485
// Launchpad Numerics DepositGns call=199/256
// - Gas Used: 6199697
// - Storage Diff: 3592
// - CPU Cycles: 5323861
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=199/256_after 1234914485
// STATE CLOCK launchpad_deposit_call=200/256_before 1234914490
// Launchpad Numerics DepositGns call=200/256
// - Gas Used: 6198430
// - Storage Diff: 3592
// - CPU Cycles: 5326350
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=200/256_after 1234914490
// STATE CLOCK launchpad_deposit_call=201/256_before 1234914495
// Launchpad Numerics DepositGns call=201/256
// - Gas Used: 6199391
// - Storage Diff: 3592
// - CPU Cycles: 5326351
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=201/256_after 1234914495
// STATE CLOCK launchpad_deposit_call=202/256_before 1234914500
// Launchpad Numerics DepositGns call=202/256
// - Gas Used: 6516938
// - Storage Diff: 10258
// - CPU Cycles: 5577904
// - Realm gno.land/r/gnoswap/launchpad: 10258
// STATE CLOCK launchpad_deposit_call=202/256_after 1234914500
// STATE CLOCK launchpad_deposit_call=203/256_before 1234914505
// Launchpad Numerics DepositGns call=203/256
// - Gas Used: 6194388
// - Storage Diff: 3640
// - CPU Cycles: 5325866
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=203/256_after 1234914505
// STATE CLOCK launchpad_deposit_call=204/256_before 1234914510
// Launchpad Numerics DepositGns call=204/256
// - Gas Used: 6195835
// - Storage Diff: 3592
// - CPU Cycles: 5326353
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=204/256_after 1234914510
// STATE CLOCK launchpad_deposit_call=205/256_before 1234914515
// Launchpad Numerics DepositGns call=205/256
// - Gas Used: 6190350
// - Storage Diff: 3592
// - CPU Cycles: 5319908
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=205/256_after 1234914515
// STATE CLOCK launchpad_deposit_call=206/256_before 1234914520
// Launchpad Numerics DepositGns call=206/256
// - Gas Used: 6191797
// - Storage Diff: 3592
// - CPU Cycles: 5320395
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=206/256_after 1234914520
// STATE CLOCK launchpad_deposit_call=207/256_before 1234914525
// Launchpad Numerics DepositGns call=207/256
// - Gas Used: 6199207
// - Storage Diff: 3592
// - CPU Cycles: 5326845
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=207/256_after 1234914525
// STATE CLOCK launchpad_deposit_call=208/256_before 1234914530
// Launchpad Numerics DepositGns call=208/256
// - Gas Used: 6200167
// - Storage Diff: 3592
// - CPU Cycles: 5326845
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=208/256_after 1234914530
// STATE CLOCK launchpad_deposit_call=209/256_before 1234914535
// Launchpad Numerics DepositGns call=209/256
// - Gas Used: 6200635
// - Storage Diff: 3592
// - CPU Cycles: 5326353
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=209/256_after 1234914535
// STATE CLOCK launchpad_deposit_call=210/256_before 1234914540
// Launchpad Numerics DepositGns call=210/256
// - Gas Used: 6518067
// - Storage Diff: 10258
// - CPU Cycles: 5577749
// - Realm gno.land/r/gnoswap/launchpad: 10258
// STATE CLOCK launchpad_deposit_call=210/256_after 1234914540
// STATE CLOCK launchpad_deposit_call=211/256_before 1234914545
// Launchpad Numerics DepositGns call=211/256
// - Gas Used: 6187671
// - Storage Diff: 3640
// - CPU Cycles: 5320235
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=211/256_after 1234914545
// STATE CLOCK launchpad_deposit_call=212/256_before 1234914550
// Launchpad Numerics DepositGns call=212/256
// - Gas Used: 6189137
// - Storage Diff: 3597
// - CPU Cycles: 5320720
// - Realm gno.land/r/gnoswap/gov/staker: 5
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=212/256_after 1234914550
// STATE CLOCK launchpad_deposit_call=213/256_before 1234914555
// Launchpad Numerics DepositGns call=213/256
// - Gas Used: 6196091
// - Storage Diff: 3597
// - CPU Cycles: 5326678
// - Realm gno.land/r/gnoswap/gov/staker: 5
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=213/256_after 1234914555
// STATE CLOCK launchpad_deposit_call=214/256_before 1234914560
// Launchpad Numerics DepositGns call=214/256
// - Gas Used: 6196079
// - Storage Diff: 3592
// - CPU Cycles: 5325706
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=214/256_after 1234914560
// STATE CLOCK launchpad_deposit_call=215/256_before 1234914565
// Launchpad Numerics DepositGns call=215/256
// - Gas Used: 6194231
// - Storage Diff: 3592
// - CPU Cycles: 5322898
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=215/256_after 1234914565
// STATE CLOCK launchpad_deposit_call=216/256_before 1234914570
// Launchpad Numerics DepositGns call=216/256
// - Gas Used: 6198486
// - Storage Diff: 3592
// - CPU Cycles: 5326193
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=216/256_after 1234914570
// STATE CLOCK launchpad_deposit_call=217/256_before 1234914575
// Launchpad Numerics DepositGns call=217/256
// - Gas Used: 6199451
// - Storage Diff: 3592
// - CPU Cycles: 5326198
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=217/256_after 1234914575
// STATE CLOCK launchpad_deposit_call=218/256_before 1234914580
// Launchpad Numerics DepositGns call=218/256
// - Gas Used: 6929497
// - Storage Diff: 17170
// - CPU Cycles: 5941882
// - Realm gno.land/r/gnoswap/launchpad: 17170
// STATE CLOCK launchpad_deposit_call=218/256_after 1234914580
// STATE CLOCK launchpad_deposit_call=219/256_before 1234914585
// Launchpad Numerics DepositGns call=219/256
// - Gas Used: 6180523
// - Storage Diff: 3688
// - CPU Cycles: 5320722
// - Realm gno.land/r/gnoswap/launchpad: 3688
// STATE CLOCK launchpad_deposit_call=219/256_after 1234914585
// STATE CLOCK launchpad_deposit_call=220/256_before 1234914590
// Launchpad Numerics DepositGns call=220/256
// - Gas Used: 6178963
// - Storage Diff: 3592
// - CPU Cycles: 5320560
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=220/256_after 1234914590
// STATE CLOCK launchpad_deposit_call=221/256_before 1234914595
// Launchpad Numerics DepositGns call=221/256
// - Gas Used: 6185886
// - Storage Diff: 3592
// - CPU Cycles: 5326523
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=221/256_after 1234914595
// STATE CLOCK launchpad_deposit_call=222/256_before 1234914600
// Launchpad Numerics DepositGns call=222/256
// - Gas Used: 6186848
// - Storage Diff: 3592
// - CPU Cycles: 5326525
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=222/256_after 1234914600
// STATE CLOCK launchpad_deposit_call=223/256_before 1234914605
// Launchpad Numerics DepositGns call=223/256
// - Gas Used: 6188295
// - Storage Diff: 3592
// - CPU Cycles: 5327012
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=223/256_after 1234914605
// STATE CLOCK launchpad_deposit_call=224/256_before 1234914610
// Launchpad Numerics DepositGns call=224/256
// - Gas Used: 6188768
// - Storage Diff: 3592
// - CPU Cycles: 5326525
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=224/256_after 1234914610
// STATE CLOCK launchpad_deposit_call=225/256_before 1234914615
// Launchpad Numerics DepositGns call=225/256
// - Gas Used: 6189728
// - Storage Diff: 3592
// - CPU Cycles: 5326525
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=225/256_after 1234914615
// STATE CLOCK launchpad_deposit_call=226/256_before 1234914620
// Launchpad Numerics DepositGns call=226/256
// - Gas Used: 6510272
// - Storage Diff: 10308
// - CPU Cycles: 5577589
// - Realm gno.land/r/gnoswap/launchpad: 10308
// STATE CLOCK launchpad_deposit_call=226/256_after 1234914620
// STATE CLOCK launchpad_deposit_call=227/256_before 1234914625
// Launchpad Numerics DepositGns call=227/256
// - Gas Used: 6178758
// - Storage Diff: 3640
// - CPU Cycles: 5320073
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=227/256_after 1234914625
// STATE CLOCK launchpad_deposit_call=228/256_before 1234914630
// Launchpad Numerics DepositGns call=228/256
// - Gas Used: 6179231
// - Storage Diff: 3592
// - CPU Cycles: 5319586
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=228/256_after 1234914630
// STATE CLOCK launchpad_deposit_call=229/256_before 1234914635
// Launchpad Numerics DepositGns call=229/256
// - Gas Used: 6187615
// - Storage Diff: 3592
// - CPU Cycles: 5327010
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=229/256_after 1234914635
// STATE CLOCK launchpad_deposit_call=230/256_before 1234914640
// Launchpad Numerics DepositGns call=230/256
// - Gas Used: 6176545
// - Storage Diff: 3592
// - CPU Cycles: 5317338
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=230/256_after 1234914640
// STATE CLOCK launchpad_deposit_call=231/256_before 1234914645
// Launchpad Numerics DepositGns call=231/256
// - Gas Used: 6174212
// - Storage Diff: 3592
// - CPU Cycles: 5314045
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=231/256_after 1234914645
// STATE CLOCK launchpad_deposit_call=232/256_before 1234914650
// Launchpad Numerics DepositGns call=232/256
// - Gas Used: 6178952
// - Storage Diff: 3592
// - CPU Cycles: 5317825
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=232/256_after 1234914650
// STATE CLOCK launchpad_deposit_call=233/256_before 1234914655
// Launchpad Numerics DepositGns call=233/256
// - Gas Used: 6186849
// - Storage Diff: 3592
// - CPU Cycles: 5324762
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=233/256_after 1234914655
// STATE CLOCK launchpad_deposit_call=234/256_before 1234914660
// Launchpad Numerics DepositGns call=234/256
// - Gas Used: 6438101
// - Storage Diff: 10018
// - CPU Cycles: 5504854
// - Realm gno.land/r/gnoswap/launchpad: 10018
// STATE CLOCK launchpad_deposit_call=234/256_after 1234914660
// STATE CLOCK launchpad_deposit_call=235/256_before 1234914665
// Launchpad Numerics DepositGns call=235/256
// - Gas Used: 6155802
// - Storage Diff: 3640
// - CPU Cycles: 5304929
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=235/256_after 1234914665
// STATE CLOCK launchpad_deposit_call=236/256_before 1234914670
// Launchpad Numerics DepositGns call=236/256
// - Gas Used: 6163212
// - Storage Diff: 3592
// - CPU Cycles: 5311379
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=236/256_after 1234914670
// STATE CLOCK launchpad_deposit_call=237/256_before 1234914675
// Launchpad Numerics DepositGns call=237/256
// - Gas Used: 6164659
// - Storage Diff: 3592
// - CPU Cycles: 5311866
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=237/256_after 1234914675
// STATE CLOCK launchpad_deposit_call=238/256_before 1234914680
// Launchpad Numerics DepositGns call=238/256
// - Gas Used: 6165619
// - Storage Diff: 3592
// - CPU Cycles: 5311866
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=238/256_after 1234914680
// STATE CLOCK launchpad_deposit_call=239/256_before 1234914685
// Launchpad Numerics DepositGns call=239/256
// - Gas Used: 6166092
// - Storage Diff: 3592
// - CPU Cycles: 5311379
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=239/256_after 1234914685
// STATE CLOCK launchpad_deposit_call=240/256_before 1234914690
// Launchpad Numerics DepositGns call=240/256
// - Gas Used: 6201442
// - Storage Diff: 3574
// - CPU Cycles: 5326989
// - Realm gno.land/r/gnoswap/launchpad: 3574
// STATE CLOCK launchpad_deposit_call=240/256_after 1234914690
// STATE CLOCK launchpad_deposit_call=241/256_before 1234914695
// Launchpad Numerics DepositGns call=241/256
// - Gas Used: 6196813
// - Storage Diff: 3550
// - CPU Cycles: 5321520
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=241/256_after 1234914695
// STATE CLOCK launchpad_deposit_call=242/256_before 1234914700
// Launchpad Numerics DepositGns call=242/256
// - Gas Used: 6202637
// - Storage Diff: 3550
// - CPU Cycles: 5326504
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=242/256_after 1234914700
// STATE CLOCK launchpad_deposit_call=243/256_before 1234914705
// Launchpad Numerics DepositGns call=243/256
// - Gas Used: 6204456
// - Storage Diff: 3550
// - CPU Cycles: 5327483
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=243/256_after 1234914705
// STATE CLOCK launchpad_deposit_call=244/256_before 1234914710
// Launchpad Numerics DepositGns call=244/256
// - Gas Used: 6205296
// - Storage Diff: 3550
// - CPU Cycles: 5327483
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=244/256_after 1234914710
// STATE CLOCK launchpad_deposit_call=245/256_before 1234914715
// Launchpad Numerics DepositGns call=245/256
// - Gas Used: 6200178
// - Storage Diff: 3550
// - CPU Cycles: 5321525
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=245/256_after 1234914715
// STATE CLOCK launchpad_deposit_call=246/256_before 1234914720
// Launchpad Numerics DepositGns call=246/256
// - Gas Used: 6207955
// - Storage Diff: 3550
// - CPU Cycles: 5328462
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=246/256_after 1234914720
// STATE CLOCK launchpad_deposit_call=247/256_before 1234914725
// Launchpad Numerics DepositGns call=247/256
// - Gas Used: 6206837
// - Storage Diff: 3550
// - CPU Cycles: 5326504
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=247/256_after 1234914725
// STATE CLOCK launchpad_deposit_call=248/256_before 1234914730
// Launchpad Numerics DepositGns call=248/256
// - Gas Used: 6488736
// - Storage Diff: 10026
// - CPU Cycles: 5575257
// - Realm gno.land/r/gnoswap/launchpad: 10026
// STATE CLOCK launchpad_deposit_call=248/256_after 1234914730
// STATE CLOCK launchpad_deposit_call=249/256_before 1234914735
// Launchpad Numerics DepositGns call=249/256
// - Gas Used: 6196286
// - Storage Diff: 3640
// - CPU Cycles: 5321035
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=249/256_after 1234914735
// STATE CLOCK launchpad_deposit_call=250/256_before 1234914740
// Launchpad Numerics DepositGns call=250/256
// - Gas Used: 6201663
// - Storage Diff: 3592
// - CPU Cycles: 5327810
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=250/256_after 1234914740
// STATE CLOCK launchpad_deposit_call=251/256_before 1234914745
// Launchpad Numerics DepositGns call=251/256
// - Gas Used: 6195693
// - Storage Diff: 3592
// - CPU Cycles: 5320880
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=251/256_after 1234914745
// STATE CLOCK launchpad_deposit_call=252/256_before 1234914750
// Launchpad Numerics DepositGns call=252/256
// - Gas Used: 6197138
// - Storage Diff: 3592
// - CPU Cycles: 5321365
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=252/256_after 1234914750
// STATE CLOCK launchpad_deposit_call=253/256_before 1234914755
// Launchpad Numerics DepositGns call=253/256
// - Gas Used: 6204053
// - Storage Diff: 3592
// - CPU Cycles: 5327320
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=253/256_after 1234914755
// STATE CLOCK launchpad_deposit_call=254/256_before 1234914760
// Launchpad Numerics DepositGns call=254/256
// - Gas Used: 6205013
// - Storage Diff: 3592
// - CPU Cycles: 5327320
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=254/256_after 1234914760
// STATE CLOCK launchpad_deposit_call=255/256_before 1234914765
// Launchpad Numerics DepositGns call=255/256
// - Gas Used: 6206465
// - Storage Diff: 3592
// - CPU Cycles: 5327812
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=255/256_after 1234914765
// STATE CLOCK launchpad_deposit_call=256/256_before 1234914770
// Launchpad Numerics DepositGns call=256/256
// - Gas Used: 6493803
// - Storage Diff: 7162
// - CPU Cycles: 5569297
// - Realm gno.land/r/gnoswap/gns: -3136
// - Realm gno.land/r/gnoswap/launchpad: 10298
// STATE CLOCK launchpad_deposit_call=256/256_after 1234914770
// STATE launchpad-numerics phase=deposited-stage-256 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1168479812265116018988177298603093692 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=256000000 manager_active_claimed=0 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=1280 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_claim_1_1_before 1235001175
// Launchpad Numerics CollectReward pattern=1 call=1/1
// - Gas Used: 3211789
// - Storage Diff: 2046
// - CPU Cycles: 2908106
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2034
// STATE CLOCK launchpad_claim_1_1_after 1235001175
// STATE CLOCK launchpad_claim_10_2_before 1235001180
// Launchpad Numerics CollectReward pattern=10 call=1/10
// - Gas Used: 3199647
// - Storage Diff: 12
// - CPU Cycles: 2920413
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_2_after 1235001180
// STATE CLOCK launchpad_claim_10_3_before 1235001185
// Launchpad Numerics CollectReward pattern=10 call=2/10
// - Gas Used: 3178274
// - Storage Diff: 12
// - CPU Cycles: 2899040
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_3_after 1235001185
// STATE CLOCK launchpad_claim_10_4_before 1235001190
// Launchpad Numerics CollectReward pattern=10 call=3/10
// - Gas Used: 3186753
// - Storage Diff: 12
// - CPU Cycles: 2907525
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_4_after 1235001190
// STATE CLOCK launchpad_claim_10_5_before 1235001195
// Launchpad Numerics CollectReward pattern=10 call=4/10
// - Gas Used: 3160618
// - Storage Diff: 12
// - CPU Cycles: 2881390
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_5_after 1235001195
// STATE CLOCK launchpad_claim_10_6_before 1235001200
// Launchpad Numerics CollectReward pattern=10 call=5/10
// - Gas Used: 3164400
// - Storage Diff: 12
// - CPU Cycles: 2885172
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_6_after 1235001200
// STATE CLOCK launchpad_claim_10_7_before 1235001205
// Launchpad Numerics CollectReward pattern=10 call=6/10
// - Gas Used: 3163420
// - Storage Diff: 12
// - CPU Cycles: 2884192
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_7_after 1235001205
// STATE CLOCK launchpad_claim_10_8_before 1235001210
// Launchpad Numerics CollectReward pattern=10 call=7/10
// - Gas Used: 3163970
// - Storage Diff: 31
// - CPU Cycles: 2884685
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 19
// STATE CLOCK launchpad_claim_10_8_after 1235001210
// STATE CLOCK launchpad_claim_10_9_before 1235001215
// Launchpad Numerics CollectReward pattern=10 call=8/10
// - Gas Used: 3176393
// - Storage Diff: 20
// - CPU Cycles: 2897084
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 8
// STATE CLOCK launchpad_claim_10_9_after 1235001215
// STATE CLOCK launchpad_claim_10_10_before 1235001220
// Launchpad Numerics CollectReward pattern=10 call=9/10
// - Gas Used: 3184910
// - Storage Diff: 12
// - CPU Cycles: 2905601
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_10_after 1235001220
// STATE CLOCK launchpad_claim_10_11_before 1235001225
// Launchpad Numerics CollectReward pattern=10 call=10/10
// - Gas Used: 3172165
// - Storage Diff: 14
// - CPU Cycles: 2892841
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2
// STATE CLOCK launchpad_claim_10_11_after 1235001225
// STATE CLOCK launchpad_claim_100_12_before 1235001230
// Launchpad Numerics CollectReward pattern=100 call=1/100
// - Gas Used: 3175466
// - Storage Diff: 14
// - CPU Cycles: 2896136
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2
// STATE CLOCK launchpad_claim_100_12_after 1235001230
// STATE CLOCK launchpad_claim_100_13_before 1235001235
// Launchpad Numerics CollectReward pattern=100 call=2/100
// - Gas Used: 3174486
// - Storage Diff: 12
// - CPU Cycles: 2895156
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_13_after 1235001235
// STATE CLOCK launchpad_claim_100_14_before 1235001240
// Launchpad Numerics CollectReward pattern=100 call=3/100
// - Gas Used: 3175466
// - Storage Diff: 12
// - CPU Cycles: 2896136
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_14_after 1235001240
// STATE CLOCK launchpad_claim_100_15_before 1235001245
// Launchpad Numerics CollectReward pattern=100 call=4/100
// - Gas Used: 3186895
// - Storage Diff: 12
// - CPU Cycles: 2907565
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_15_after 1235001245
// STATE CLOCK launchpad_claim_100_16_before 1235001250
// Launchpad Numerics CollectReward pattern=100 call=5/100
// - Gas Used: 3189835
// - Storage Diff: 12
// - CPU Cycles: 2910505
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_16_after 1235001250
// STATE CLOCK launchpad_claim_100_17_before 1235001255
// Launchpad Numerics CollectReward pattern=100 call=6/100
// - Gas Used: 3198308
// - Storage Diff: 12
// - CPU Cycles: 2918984
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_17_after 1235001255
// STATE CLOCK launchpad_claim_100_18_before 1235001260
// Launchpad Numerics CollectReward pattern=100 call=7/100
// - Gas Used: 3187378
// - Storage Diff: 12
// - CPU Cycles: 2908048
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_18_after 1235001260
// STATE CLOCK launchpad_claim_100_19_before 1235001265
// Launchpad Numerics CollectReward pattern=100 call=8/100
// - Gas Used: 3188851
// - Storage Diff: 12
// - CPU Cycles: 2909521
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_19_after 1235001265
// STATE CLOCK launchpad_claim_100_20_before 1235001270
// Launchpad Numerics CollectReward pattern=100 call=9/100
// - Gas Used: 3188354
// - Storage Diff: 12
// - CPU Cycles: 2909024
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_20_after 1235001270
// STATE CLOCK launchpad_claim_100_21_before 1235001275
// Launchpad Numerics CollectReward pattern=100 call=10/100
// - Gas Used: 3175959
// - Storage Diff: 12
// - CPU Cycles: 2896629
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_21_after 1235001275
// STATE CLOCK launchpad_claim_100_22_before 1235001280
// Launchpad Numerics CollectReward pattern=100 call=11/100
// - Gas Used: 3195512
// - Storage Diff: 12
// - CPU Cycles: 2916182
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_22_after 1235001280
// STATE CLOCK launchpad_claim_100_23_before 1235001285
// Launchpad Numerics CollectReward pattern=100 call=12/100
// - Gas Used: 3202234
// - Storage Diff: 12
// - CPU Cycles: 2922904
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_23_after 1235001285
// STATE CLOCK launchpad_claim_100_24_before 1235001290
// Launchpad Numerics CollectReward pattern=100 call=13/100
// - Gas Used: 3199288
// - Storage Diff: 12
// - CPU Cycles: 2919964
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_24_after 1235001290
// STATE CLOCK launchpad_claim_100_25_before 1235001295
// Launchpad Numerics CollectReward pattern=100 call=14/100
// - Gas Used: 3188851
// - Storage Diff: 12
// - CPU Cycles: 2909521
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_25_after 1235001295
// STATE CLOCK launchpad_claim_100_26_before 1235001300
// Launchpad Numerics CollectReward pattern=100 call=15/100
// - Gas Used: 3177426
// - Storage Diff: 12
// - CPU Cycles: 2898096
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_26_after 1235001300
// STATE CLOCK launchpad_claim_100_27_before 1235001305
// Launchpad Numerics CollectReward pattern=100 call=16/100
// - Gas Used: 3177919
// - Storage Diff: 12
// - CPU Cycles: 2898589
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_27_after 1235001305
// STATE CLOCK launchpad_claim_100_28_before 1235001310
// Launchpad Numerics CollectReward pattern=100 call=17/100
// - Gas Used: 3185556
// - Storage Diff: 12
// - CPU Cycles: 2906226
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_28_after 1235001310
// STATE CLOCK launchpad_claim_100_29_before 1235001315
// Launchpad Numerics CollectReward pattern=100 call=18/100
// - Gas Used: 3190318
// - Storage Diff: 12
// - CPU Cycles: 2910988
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_29_after 1235001315
// STATE CLOCK launchpad_claim_100_30_before 1235001320
// Launchpad Numerics CollectReward pattern=100 call=19/100
// - Gas Used: 3178402
// - Storage Diff: 12
// - CPU Cycles: 2899072
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_30_after 1235001320
// STATE CLOCK launchpad_claim_100_31_before 1235001325
// Launchpad Numerics CollectReward pattern=100 call=20/100
// - Gas Used: 3184929
// - Storage Diff: 12
// - CPU Cycles: 2905605
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_31_after 1235001325
// STATE CLOCK launchpad_claim_100_32_before 1235001330
// Launchpad Numerics CollectReward pattern=100 call=21/100
// - Gas Used: 3186396
// - Storage Diff: 12
// - CPU Cycles: 2907072
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_32_after 1235001330
// STATE CLOCK launchpad_claim_100_33_before 1235001335
// Launchpad Numerics CollectReward pattern=100 call=22/100
// - Gas Used: 3173993
// - Storage Diff: 12
// - CPU Cycles: 2894669
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_33_after 1235001335
// STATE CLOCK launchpad_claim_100_34_before 1235001340
// Launchpad Numerics CollectReward pattern=100 call=23/100
// - Gas Used: 3174480
// - Storage Diff: 12
// - CPU Cycles: 2895156
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_34_after 1235001340
// STATE CLOCK launchpad_claim_100_35_before 1235001345
// Launchpad Numerics CollectReward pattern=100 call=24/100
// - Gas Used: 3175460
// - Storage Diff: 12
// - CPU Cycles: 2896136
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_35_after 1235001345
// STATE CLOCK launchpad_claim_100_36_before 1235001350
// Launchpad Numerics CollectReward pattern=100 call=25/100
// - Gas Used: 3174480
// - Storage Diff: 12
// - CPU Cycles: 2895156
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_36_after 1235001350
// STATE CLOCK launchpad_claim_100_37_before 1235001355
// Launchpad Numerics CollectReward pattern=100 call=26/100
// - Gas Used: 3174973
// - Storage Diff: 12
// - CPU Cycles: 2895649
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_37_after 1235001355
// STATE CLOCK launchpad_claim_100_38_before 1235001360
// Launchpad Numerics CollectReward pattern=100 call=27/100
// - Gas Used: 3174973
// - Storage Diff: 12
// - CPU Cycles: 2895649
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_38_after 1235001360
// STATE CLOCK launchpad_claim_100_39_before 1235001365
// Launchpad Numerics CollectReward pattern=100 call=28/100
// - Gas Used: 3182610
// - Storage Diff: 12
// - CPU Cycles: 2903286
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_39_after 1235001365
// STATE CLOCK launchpad_claim_100_40_before 1235001370
// Launchpad Numerics CollectReward pattern=100 call=29/100
// - Gas Used: 3175456
// - Storage Diff: 12
// - CPU Cycles: 2896132
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_40_after 1235001370
// STATE CLOCK launchpad_claim_100_41_before 1235001375
// Launchpad Numerics CollectReward pattern=100 call=30/100
// - Gas Used: 3175460
// - Storage Diff: 12
// - CPU Cycles: 2896136
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_41_after 1235001375
// STATE CLOCK launchpad_claim_100_42_before 1235001380
// Launchpad Numerics CollectReward pattern=100 call=31/100
// - Gas Used: 3175953
// - Storage Diff: 12
// - CPU Cycles: 2896629
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_42_after 1235001380
// STATE CLOCK launchpad_claim_100_43_before 1235001385
// Launchpad Numerics CollectReward pattern=100 call=32/100
// - Gas Used: 3175460
// - Storage Diff: 12
// - CPU Cycles: 2896136
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_43_after 1235001385
// STATE CLOCK launchpad_claim_100_44_before 1235001390
// Launchpad Numerics CollectReward pattern=100 call=33/100
// - Gas Used: 3175953
// - Storage Diff: 12
// - CPU Cycles: 2896629
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_44_after 1235001390
// STATE CLOCK launchpad_claim_100_45_before 1235001395
// Launchpad Numerics CollectReward pattern=100 call=34/100
// - Gas Used: 3171591
// - Storage Diff: 12
// - CPU Cycles: 2892267
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_45_after 1235001395
// STATE CLOCK launchpad_claim_100_46_before 1235001400
// Launchpad Numerics CollectReward pattern=100 call=35/100
// - Gas Used: 3174480
// - Storage Diff: 12
// - CPU Cycles: 2895156
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_46_after 1235001400
// STATE CLOCK launchpad_claim_100_47_before 1235001405
// Launchpad Numerics CollectReward pattern=100 call=36/100
// - Gas Used: 3175460
// - Storage Diff: 12
// - CPU Cycles: 2896136
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_47_after 1235001405
// STATE CLOCK launchpad_claim_100_48_before 1235001410
// Launchpad Numerics CollectReward pattern=100 call=37/100
// - Gas Used: 3163057
// - Storage Diff: 12
// - CPU Cycles: 2883733
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_48_after 1235001410
// STATE CLOCK launchpad_claim_100_49_before 1235001415
// Launchpad Numerics CollectReward pattern=100 call=38/100
// - Gas Used: 3163544
// - Storage Diff: 12
// - CPU Cycles: 2884220
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_49_after 1235001415
// STATE CLOCK launchpad_claim_100_50_before 1235001420
// Launchpad Numerics CollectReward pattern=100 call=39/100
// - Gas Used: 3163057
// - Storage Diff: 12
// - CPU Cycles: 2883733
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_50_after 1235001420
// STATE CLOCK launchpad_claim_100_51_before 1235001425
// Launchpad Numerics CollectReward pattern=100 call=40/100
// - Gas Used: 3164563
// - Storage Diff: 12
// - CPU Cycles: 2885200
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_51_after 1235001425
// STATE CLOCK launchpad_claim_100_52_before 1235001430
// Launchpad Numerics CollectReward pattern=100 call=41/100
// - Gas Used: 3164563
// - Storage Diff: 12
// - CPU Cycles: 2885200
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_52_after 1235001430
// STATE CLOCK launchpad_claim_100_53_before 1235001435
// Launchpad Numerics CollectReward pattern=100 call=42/100
// - Gas Used: 3174523
// - Storage Diff: 12
// - CPU Cycles: 2895160
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_53_after 1235001435
// STATE CLOCK launchpad_claim_100_54_before 1235001440
// Launchpad Numerics CollectReward pattern=100 call=43/100
// - Gas Used: 3175016
// - Storage Diff: 12
// - CPU Cycles: 2895653
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_54_after 1235001440
// STATE CLOCK launchpad_claim_100_55_before 1235001445
// Launchpad Numerics CollectReward pattern=100 call=44/100
// - Gas Used: 3163587
// - Storage Diff: 12
// - CPU Cycles: 2884224
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_55_after 1235001445
// STATE CLOCK launchpad_claim_100_56_before 1235001450
// Launchpad Numerics CollectReward pattern=100 call=45/100
// - Gas Used: 3159805
// - Storage Diff: 12
// - CPU Cycles: 2880442
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_56_after 1235001450
// STATE CLOCK launchpad_claim_100_57_before 1235001455
// Launchpad Numerics CollectReward pattern=100 call=46/100
// - Gas Used: 3164573
// - Storage Diff: 12
// - CPU Cycles: 2885204
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_57_after 1235001455
// STATE CLOCK launchpad_claim_100_58_before 1235001460
// Launchpad Numerics CollectReward pattern=100 call=47/100
// - Gas Used: 3163593
// - Storage Diff: 12
// - CPU Cycles: 2884224
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_58_after 1235001460
// STATE CLOCK launchpad_claim_100_59_before 1235001465
// Launchpad Numerics CollectReward pattern=100 call=48/100
// - Gas Used: 3164086
// - Storage Diff: 12
// - CPU Cycles: 2884717
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_59_after 1235001465
// STATE CLOCK launchpad_claim_100_60_before 1235001470
// Launchpad Numerics CollectReward pattern=100 call=49/100
// - Gas Used: 3175022
// - Storage Diff: 12
// - CPU Cycles: 2895653
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_60_after 1235001470
// STATE CLOCK launchpad_claim_100_61_before 1235001475
// Launchpad Numerics CollectReward pattern=100 call=50/100
// - Gas Used: 3176002
// - Storage Diff: 12
// - CPU Cycles: 2896633
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_61_after 1235001475
// STATE CLOCK launchpad_claim_100_62_before 1235001480
// Launchpad Numerics CollectReward pattern=100 call=51/100
// - Gas Used: 3164573
// - Storage Diff: 12
// - CPU Cycles: 2885204
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_62_after 1235001480
// STATE CLOCK launchpad_claim_100_63_before 1235001485
// Launchpad Numerics CollectReward pattern=100 call=52/100
// - Gas Used: 3164086
// - Storage Diff: 12
// - CPU Cycles: 2884717
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_63_after 1235001485
// STATE CLOCK launchpad_claim_100_64_before 1235001490
// Launchpad Numerics CollectReward pattern=100 call=53/100
// - Gas Used: 3165553
// - Storage Diff: 12
// - CPU Cycles: 2886184
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_64_after 1235001490
// STATE CLOCK launchpad_claim_100_65_before 1235001495
// Launchpad Numerics CollectReward pattern=100 call=54/100
// - Gas Used: 3164086
// - Storage Diff: 12
// - CPU Cycles: 2884717
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_65_after 1235001495
// STATE CLOCK launchpad_claim_100_66_before 1235001500
// Launchpad Numerics CollectReward pattern=100 call=55/100
// - Gas Used: 3165553
// - Storage Diff: 12
// - CPU Cycles: 2886184
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_66_after 1235001500
// STATE CLOCK launchpad_claim_100_67_before 1235001505
// Launchpad Numerics CollectReward pattern=100 call=56/100
// - Gas Used: 3161771
// - Storage Diff: 12
// - CPU Cycles: 2882402
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_67_after 1235001505
// STATE CLOCK launchpad_claim_100_68_before 1235001510
// Launchpad Numerics CollectReward pattern=100 call=57/100
// - Gas Used: 3174525
// - Storage Diff: 12
// - CPU Cycles: 2895156
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_68_after 1235001510
// STATE CLOCK launchpad_claim_100_69_before 1235001515
// Launchpad Numerics CollectReward pattern=100 call=58/100
// - Gas Used: 3175505
// - Storage Diff: 12
// - CPU Cycles: 2896136
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_69_after 1235001515
// STATE CLOCK launchpad_claim_100_70_before 1235001520
// Launchpad Numerics CollectReward pattern=100 call=59/100
// - Gas Used: 3163589
// - Storage Diff: 12
// - CPU Cycles: 2884220
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_70_after 1235001520
// STATE CLOCK launchpad_claim_100_71_before 1235001525
// Launchpad Numerics CollectReward pattern=100 call=60/100
// - Gas Used: 3164082
// - Storage Diff: 12
// - CPU Cycles: 2884713
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_71_after 1235001525
// STATE CLOCK launchpad_claim_100_72_before 1235001530
// Launchpad Numerics CollectReward pattern=100 call=61/100
// - Gas Used: 3163593
// - Storage Diff: 12
// - CPU Cycles: 2884224
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_72_after 1235001530
// STATE CLOCK launchpad_claim_100_73_before 1235001535
// Launchpad Numerics CollectReward pattern=100 call=62/100
// - Gas Used: 3160791
// - Storage Diff: 12
// - CPU Cycles: 2881422
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_73_after 1235001535
// STATE CLOCK launchpad_claim_100_74_before 1235001540
// Launchpad Numerics CollectReward pattern=100 call=63/100
// - Gas Used: 3164573
// - Storage Diff: 12
// - CPU Cycles: 2885204
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_74_after 1235001540
// STATE CLOCK launchpad_claim_100_75_before 1235001545
// Launchpad Numerics CollectReward pattern=100 call=64/100
// - Gas Used: 3175509
// - Storage Diff: 12
// - CPU Cycles: 2896140
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_75_after 1235001545
// STATE CLOCK launchpad_claim_100_76_before 1235001550
// Launchpad Numerics CollectReward pattern=100 call=65/100
// - Gas Used: 3176489
// - Storage Diff: 12
// - CPU Cycles: 2897120
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_76_after 1235001550
// STATE CLOCK launchpad_claim_100_77_before 1235001555
// Launchpad Numerics CollectReward pattern=100 call=66/100
// - Gas Used: 3164086
// - Storage Diff: 12
// - CPU Cycles: 2884717
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_77_after 1235001555
// STATE CLOCK launchpad_claim_100_78_before 1235001560
// Launchpad Numerics CollectReward pattern=100 call=67/100
// - Gas Used: 3164086
// - Storage Diff: 12
// - CPU Cycles: 2884717
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_78_after 1235001560
// STATE CLOCK launchpad_claim_100_79_before 1235001565
// Launchpad Numerics CollectReward pattern=100 call=68/100
// - Gas Used: 3165553
// - Storage Diff: 12
// - CPU Cycles: 2886184
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_79_after 1235001565
// STATE CLOCK launchpad_claim_100_80_before 1235001570
// Launchpad Numerics CollectReward pattern=100 call=69/100
// - Gas Used: 3165549
// - Storage Diff: 12
// - CPU Cycles: 2886180
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_80_after 1235001570
// STATE CLOCK launchpad_claim_100_81_before 1235001575
// Launchpad Numerics CollectReward pattern=100 call=70/100
// - Gas Used: 3165553
// - Storage Diff: 12
// - CPU Cycles: 2886184
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_81_after 1235001575
// STATE CLOCK launchpad_claim_100_82_before 1235001580
// Launchpad Numerics CollectReward pattern=100 call=71/100
// - Gas Used: 3175022
// - Storage Diff: 12
// - CPU Cycles: 2895653
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_82_after 1235001580
// STATE CLOCK launchpad_claim_100_83_before 1235001585
// Launchpad Numerics CollectReward pattern=100 call=72/100
// - Gas Used: 3176002
// - Storage Diff: 12
// - CPU Cycles: 2896633
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_83_after 1235001585
// STATE CLOCK launchpad_claim_100_84_before 1235001590
// Launchpad Numerics CollectReward pattern=100 call=73/100
// - Gas Used: 3172707
// - Storage Diff: 12
// - CPU Cycles: 2893338
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_84_after 1235001590
// STATE CLOCK launchpad_claim_100_85_before 1235001595
// Launchpad Numerics CollectReward pattern=100 call=74/100
// - Gas Used: 3177469
// - Storage Diff: 12
// - CPU Cycles: 2898100
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_85_after 1235001595
// STATE CLOCK launchpad_claim_100_86_before 1235001600
// Launchpad Numerics CollectReward pattern=100 call=75/100
// - Gas Used: 3176002
// - Storage Diff: 12
// - CPU Cycles: 2896633
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_86_after 1235001600
// STATE CLOCK launchpad_claim_100_87_before 1235001605
// Launchpad Numerics CollectReward pattern=100 call=76/100
// - Gas Used: 3177469
// - Storage Diff: 12
// - CPU Cycles: 2898100
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_87_after 1235001605
// STATE CLOCK launchpad_claim_100_88_before 1235001610
// Launchpad Numerics CollectReward pattern=100 call=77/100
// - Gas Used: 3176982
// - Storage Diff: 12
// - CPU Cycles: 2897613
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_88_after 1235001610
// STATE CLOCK launchpad_claim_100_89_before 1235001615
// Launchpad Numerics CollectReward pattern=100 call=78/100
// - Gas Used: 3177962
// - Storage Diff: 12
// - CPU Cycles: 2898593
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_89_after 1235001615
// STATE CLOCK launchpad_claim_100_90_before 1235001620
// Launchpad Numerics CollectReward pattern=100 call=79/100
// - Gas Used: 3173683
// - Storage Diff: 12
// - CPU Cycles: 2894314
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_90_after 1235001620
// STATE CLOCK launchpad_claim_100_91_before 1235001625
// Launchpad Numerics CollectReward pattern=100 call=80/100
// - Gas Used: 3177469
// - Storage Diff: 12
// - CPU Cycles: 2898100
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_91_after 1235001625
// STATE CLOCK launchpad_claim_100_92_before 1235001630
// Launchpad Numerics CollectReward pattern=100 call=81/100
// - Gas Used: 3178449
// - Storage Diff: 12
// - CPU Cycles: 2899080
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_92_after 1235001630
// STATE CLOCK launchpad_claim_100_93_before 1235001635
// Launchpad Numerics CollectReward pattern=100 call=82/100
// - Gas Used: 3177469
// - Storage Diff: 12
// - CPU Cycles: 2898100
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_93_after 1235001635
// STATE CLOCK launchpad_claim_100_94_before 1235001640
// Launchpad Numerics CollectReward pattern=100 call=83/100
// - Gas Used: 3177962
// - Storage Diff: 12
// - CPU Cycles: 2898593
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_94_after 1235001640
// STATE CLOCK launchpad_claim_100_95_before 1235001645
// Launchpad Numerics CollectReward pattern=100 call=84/100
// - Gas Used: 3178449
// - Storage Diff: 12
// - CPU Cycles: 2899080
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_95_after 1235001645
// STATE CLOCK launchpad_claim_100_96_before 1235001650
// Launchpad Numerics CollectReward pattern=100 call=85/100
// - Gas Used: 3164573
// - Storage Diff: 12
// - CPU Cycles: 2885204
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_96_after 1235001650
// STATE CLOCK launchpad_claim_100_97_before 1235001655
// Launchpad Numerics CollectReward pattern=100 call=86/100
// - Gas Used: 3180607
// - Storage Diff: 18
// - CPU Cycles: 2886184
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_97_after 1235001655
// STATE CLOCK launchpad_claim_100_98_before 1235001660
// Launchpad Numerics CollectReward pattern=100 call=87/100
// - Gas Used: 3168691
// - Storage Diff: 18
// - CPU Cycles: 2874268
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_98_after 1235001660
// STATE CLOCK launchpad_claim_100_99_before 1235001665
// Launchpad Numerics CollectReward pattern=100 call=88/100
// - Gas Used: 3168691
// - Storage Diff: 18
// - CPU Cycles: 2874268
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_99_after 1235001665
// STATE CLOCK launchpad_claim_100_100_before 1235001670
// Launchpad Numerics CollectReward pattern=100 call=89/100
// - Gas Used: 3191602
// - Storage Diff: 18
// - CPU Cycles: 2893717
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_100_after 1235001670
// STATE CLOCK launchpad_claim_100_101_before 1235001675
// Launchpad Numerics CollectReward pattern=100 call=90/100
// - Gas Used: 3188311
// - Storage Diff: 18
// - CPU Cycles: 2890426
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_101_after 1235001675
// STATE CLOCK launchpad_claim_100_102_before 1235001680
// Launchpad Numerics CollectReward pattern=100 call=91/100
// - Gas Used: 3193073
// - Storage Diff: 18
// - CPU Cycles: 2895188
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_102_after 1235001680
// STATE CLOCK launchpad_claim_100_103_before 1235001685
// Launchpad Numerics CollectReward pattern=100 call=92/100
// - Gas Used: 3192093
// - Storage Diff: 18
// - CPU Cycles: 2894208
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_103_after 1235001685
// STATE CLOCK launchpad_claim_100_104_before 1235001690
// Launchpad Numerics CollectReward pattern=100 call=93/100
// - Gas Used: 3193073
// - Storage Diff: 18
// - CPU Cycles: 2895188
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_104_after 1235001690
// STATE CLOCK launchpad_claim_100_105_before 1235001695
// Launchpad Numerics CollectReward pattern=100 call=94/100
// - Gas Used: 3192586
// - Storage Diff: 18
// - CPU Cycles: 2894701
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_105_after 1235001695
// STATE CLOCK launchpad_claim_100_106_before 1235001700
// Launchpad Numerics CollectReward pattern=100 call=95/100
// - Gas Used: 3185006
// - Storage Diff: 12
// - CPU Cycles: 2905637
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_106_after 1235001700
// STATE CLOCK launchpad_claim_100_107_before 1235001705
// Launchpad Numerics CollectReward pattern=100 call=96/100
// - Gas Used: 3178329
// - Storage Diff: 12
// - CPU Cycles: 2898960
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_107_after 1235001705
// STATE CLOCK launchpad_claim_100_108_before 1235001710
// Launchpad Numerics CollectReward pattern=100 call=97/100
// - Gas Used: 3174553
// - Storage Diff: 12
// - CPU Cycles: 2895184
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_108_after 1235001710
// STATE CLOCK launchpad_claim_100_109_before 1235001715
// Launchpad Numerics CollectReward pattern=100 call=98/100
// - Gas Used: 3174066
// - Storage Diff: 12
// - CPU Cycles: 2894697
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_109_after 1235001715
// STATE CLOCK launchpad_claim_100_110_before 1235001720
// Launchpad Numerics CollectReward pattern=100 call=99/100
// - Gas Used: 3174553
// - Storage Diff: 12
// - CPU Cycles: 2895184
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_110_after 1235001720
// STATE CLOCK launchpad_claim_100_111_before 1235001725
// Launchpad Numerics CollectReward pattern=100 call=100/100
// - Gas Used: 3175046
// - Storage Diff: 12
// - CPU Cycles: 2895677
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_111_after 1235001725
// STATE launchpad-numerics phase=claimed-pattern-1 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=35987 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-pattern-10 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=644752419472195378092327733873980578 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=55 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=34111 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69254 record_created_offset=55 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-pattern-100 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1030928654824012160364300924622681117 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=555 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=33165 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69354 record_created_offset=555 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_withdraw_1_before 1237505495
// Launchpad Numerics CollectDepositGns call=1/256
// - Gas Used: 8092833
// - Storage Diff: -3321
// - CPU Cycles: 6966991
// - Realm gno.land/r/gnoswap/gns: 2055
// - Realm gno.land/r/gnoswap/launchpad: -5376
// STATE CLOCK launchpad_withdraw_1_after 1237505495
// STATE launchpad-numerics phase=withdrawn-stage-1 global_staked=255000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=1000000 tier_deposit_count=256 tier_withdraw_count=1 tier_collected=4666860 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=4666860 manager_active_deposit=255000000 manager_active_claimed=3687346 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=255 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_2_before 1237505500
// Launchpad Numerics CollectDepositGns call=2/256
// - Gas Used: 7681014
// - Storage Diff: -5372
// - CPU Cycles: 6688279
// - Realm gno.land/r/gnoswap/launchpad: -5372
// STATE CLOCK launchpad_withdraw_2_after 1237505500
// STATE CLOCK launchpad_withdraw_3_before 1237505505
// Launchpad Numerics CollectDepositGns call=3/256
// - Gas Used: 7509862
// - Storage Diff: -1897
// - CPU Cycles: 6542524
// - Realm gno.land/r/gnoswap/launchpad: -1897
// STATE CLOCK launchpad_withdraw_3_after 1237505505
// STATE CLOCK launchpad_withdraw_4_before 1237505510
// Launchpad Numerics CollectDepositGns call=4/256
// - Gas Used: 7656069
// - Storage Diff: -5334
// - CPU Cycles: 6665725
// - Realm gno.land/r/gnoswap/launchpad: -5334
// STATE CLOCK launchpad_withdraw_4_after 1237505510
// STATE CLOCK launchpad_withdraw_5_before 1237505515
// Launchpad Numerics CollectDepositGns call=5/256
// - Gas Used: 7582906
// - Storage Diff: -1902
// - CPU Cycles: 6594863
// - Realm gno.land/r/gnoswap/launchpad: -1902
// STATE CLOCK launchpad_withdraw_5_after 1237505515
// STATE CLOCK launchpad_withdraw_6_before 1237505520
// Launchpad Numerics CollectDepositGns call=6/256
// - Gas Used: 7714584
// - Storage Diff: -5381
// - CPU Cycles: 6705319
// - Realm gno.land/r/gnoswap/launchpad: -5381
// STATE CLOCK launchpad_withdraw_6_after 1237505520
// STATE CLOCK launchpad_withdraw_7_before 1237505525
// Launchpad Numerics CollectDepositGns call=7/256
// - Gas Used: 7709664
// - Storage Diff: -5369
// - CPU Cycles: 6703102
// - Realm gno.land/r/gnoswap/launchpad: -5369
// STATE CLOCK launchpad_withdraw_7_after 1237505525
// STATE CLOCK launchpad_withdraw_8_before 1237505530
// Launchpad Numerics CollectDepositGns call=8/256
// - Gas Used: 7582997
// - Storage Diff: -1902
// - CPU Cycles: 6594783
// - Realm gno.land/r/gnoswap/launchpad: -1902
// STATE CLOCK launchpad_withdraw_8_after 1237505530
// STATE CLOCK launchpad_withdraw_9_before 1237505535
// Launchpad Numerics CollectDepositGns call=9/256
// - Gas Used: 7508165
// - Storage Diff: -1897
// - CPU Cycles: 6539501
// - Realm gno.land/r/gnoswap/launchpad: -1902
// - Realm gno.land/r/onbloc/obl: 5
// STATE CLOCK launchpad_withdraw_9_after 1237505535
// STATE CLOCK launchpad_withdraw_10_before 1237505540
// Launchpad Numerics CollectDepositGns call=10/256
// - Gas Used: 7543513
// - Storage Diff: -1897
// - CPU Cycles: 6564764
// - Realm gno.land/r/gnoswap/launchpad: -1915
// - Realm gno.land/r/onbloc/obl: 18
// STATE CLOCK launchpad_withdraw_10_after 1237505540
// STATE CLOCK launchpad_withdraw_11_before 1237505545
// Launchpad Numerics CollectDepositGns call=11/256
// - Gas Used: 7513395
// - Storage Diff: -1916
// - CPU Cycles: 6548538
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_11_after 1237505545
// STATE CLOCK launchpad_withdraw_12_before 1237505550
// Launchpad Numerics CollectDepositGns call=12/256
// - Gas Used: 7602015
// - Storage Diff: -1904
// - CPU Cycles: 6613810
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_12_after 1237505550
// STATE CLOCK launchpad_withdraw_13_before 1237505555
// Launchpad Numerics CollectDepositGns call=13/256
// - Gas Used: 7727354
// - Storage Diff: -5372
// - CPU Cycles: 6714369
// - Realm gno.land/r/gnoswap/launchpad: -5372
// STATE CLOCK launchpad_withdraw_13_after 1237505555
// STATE CLOCK launchpad_withdraw_14_before 1237505560
// Launchpad Numerics CollectDepositGns call=14/256
// - Gas Used: 7609117
// - Storage Diff: -1904
// - CPU Cycles: 6613970
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_14_after 1237505560
// STATE CLOCK launchpad_withdraw_15_before 1237505565
// Launchpad Numerics CollectDepositGns call=15/256
// - Gas Used: 7558643
// - Storage Diff: -1903
// - CPU Cycles: 6570132
// - Realm gno.land/r/gnoswap/launchpad: -1903
// STATE CLOCK launchpad_withdraw_15_after 1237505565
// STATE CLOCK launchpad_withdraw_16_before 1237505570
// Launchpad Numerics CollectDepositGns call=16/256
// - Gas Used: 7532602
// - Storage Diff: -1916
// - CPU Cycles: 6561640
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_16_after 1237505570
// STATE CLOCK launchpad_withdraw_17_before 1237505575
// Launchpad Numerics CollectDepositGns call=17/256
// - Gas Used: 7771903
// - Storage Diff: -8734
// - CPU Cycles: 6772215
// - Realm gno.land/r/gnoswap/launchpad: -8734
// STATE CLOCK launchpad_withdraw_17_after 1237505575
// STATE CLOCK launchpad_withdraw_18_before 1237505580
// Launchpad Numerics CollectDepositGns call=18/256
// - Gas Used: 7611760
// - Storage Diff: -1904
// - CPU Cycles: 6624044
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_18_after 1237505580
// STATE CLOCK launchpad_withdraw_19_before 1237505585
// Launchpad Numerics CollectDepositGns call=19/256
// - Gas Used: 7631688
// - Storage Diff: -1904
// - CPU Cycles: 6633542
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_19_after 1237505585
// STATE CLOCK launchpad_withdraw_20_before 1237505590
// Launchpad Numerics CollectDepositGns call=20/256
// - Gas Used: 7525992
// - Storage Diff: -1916
// - CPU Cycles: 6559344
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_20_after 1237505590
// STATE CLOCK launchpad_withdraw_21_before 1237505595
// Launchpad Numerics CollectDepositGns call=21/256
// - Gas Used: 7602466
// - Storage Diff: -1904
// - CPU Cycles: 6614705
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_21_after 1237505595
// STATE CLOCK launchpad_withdraw_22_before 1237505600
// Launchpad Numerics CollectDepositGns call=22/256
// - Gas Used: 7561028
// - Storage Diff: -1903
// - CPU Cycles: 6579066
// - Realm gno.land/r/gnoswap/launchpad: -1903
// STATE CLOCK launchpad_withdraw_22_after 1237505600
// STATE CLOCK launchpad_withdraw_23_before 1237505605
// Launchpad Numerics CollectDepositGns call=23/256
// - Gas Used: 7534840
// - Storage Diff: -1916
// - CPU Cycles: 6570574
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_23_after 1237505605
// STATE CLOCK launchpad_withdraw_24_before 1237505610
// Launchpad Numerics CollectDepositGns call=24/256
// - Gas Used: 7647760
// - Storage Diff: -5202
// - CPU Cycles: 6663516
// - Realm gno.land/r/gnoswap/launchpad: -5202
// STATE CLOCK launchpad_withdraw_24_after 1237505610
// STATE CLOCK launchpad_withdraw_25_before 1237505615
// Launchpad Numerics CollectDepositGns call=25/256
// - Gas Used: 7734532
// - Storage Diff: -5125
// - CPU Cycles: 6719551
// - Realm gno.land/r/gnoswap/launchpad: -5125
// STATE CLOCK launchpad_withdraw_25_after 1237505615
// STATE CLOCK launchpad_withdraw_26_before 1237505620
// Launchpad Numerics CollectDepositGns call=26/256
// - Gas Used: 7505866
// - Storage Diff: -1916
// - CPU Cycles: 6540136
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_26_after 1237505620
// STATE CLOCK launchpad_withdraw_27_before 1237505625
// Launchpad Numerics CollectDepositGns call=27/256
// - Gas Used: 7504922
// - Storage Diff: -1916
// - CPU Cycles: 6540791
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_27_after 1237505625
// STATE CLOCK launchpad_withdraw_28_before 1237505630
// Launchpad Numerics CollectDepositGns call=28/256
// - Gas Used: 7512422
// - Storage Diff: -1916
// - CPU Cycles: 6549890
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_28_after 1237505630
// STATE CLOCK launchpad_withdraw_29_before 1237505635
// Launchpad Numerics CollectDepositGns call=29/256
// - Gas Used: 7510498
// - Storage Diff: -1916
// - CPU Cycles: 6549565
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_29_after 1237505635
// STATE CLOCK launchpad_withdraw_30_before 1237505640
// Launchpad Numerics CollectDepositGns call=30/256
// - Gas Used: 7500862
// - Storage Diff: -1916
// - CPU Cycles: 6541528
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_30_after 1237505640
// STATE CLOCK launchpad_withdraw_31_before 1237505645
// Launchpad Numerics CollectDepositGns call=31/256
// - Gas Used: 7535938
// - Storage Diff: -1915
// - CPU Cycles: 6556670
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_31_after 1237505645
// STATE CLOCK launchpad_withdraw_32_before 1237505650
// Launchpad Numerics CollectDepositGns call=32/256
// - Gas Used: 7534997
// - Storage Diff: -1915
// - CPU Cycles: 6557325
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_32_after 1237505650
// STATE launchpad-numerics phase=withdrawn-stage-32 global_staked=224000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=32000000 tier_deposit_count=256 tier_withdraw_count=32 tier_collected=33915241 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=33915241 manager_active_deposit=224000000 manager_active_claimed=2632955 manager_active_debt=235972506899103895716586901958147712416000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=224 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69275 record_created_offset=160 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_33_before 1237505655
// Launchpad Numerics CollectDepositGns call=33/256
// - Gas Used: 7524384
// - Storage Diff: -1915
// - CPU Cycles: 6548308
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_33_after 1237505655
// STATE CLOCK launchpad_withdraw_34_before 1237505660
// Launchpad Numerics CollectDepositGns call=34/256
// - Gas Used: 7522708
// - Storage Diff: -1915
// - CPU Cycles: 6548228
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_34_after 1237505660
// STATE CLOCK launchpad_withdraw_35_before 1237505665
// Launchpad Numerics CollectDepositGns call=35/256
// - Gas Used: 7521767
// - Storage Diff: -1915
// - CPU Cycles: 6548883
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_35_after 1237505665
// STATE CLOCK launchpad_withdraw_36_before 1237505670
// Launchpad Numerics CollectDepositGns call=36/256
// - Gas Used: 7519356
// - Storage Diff: -1915
// - CPU Cycles: 6548068
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_36_after 1237505670
// STATE CLOCK launchpad_withdraw_37_before 1237505675
// Launchpad Numerics CollectDepositGns call=37/256
// - Gas Used: 7611279
// - Storage Diff: -1914
// - CPU Cycles: 6625163
// - Realm gno.land/r/gnoswap/launchpad: -1914
// STATE CLOCK launchpad_withdraw_37_after 1237505675
// STATE CLOCK launchpad_withdraw_38_before 1237505680
// Launchpad Numerics CollectDepositGns call=38/256
// - Gas Used: 7599391
// - Storage Diff: -1915
// - CPU Cycles: 6614294
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_38_after 1237505680
// STATE CLOCK launchpad_withdraw_39_before 1237505685
// Launchpad Numerics CollectDepositGns call=39/256
// - Gas Used: 7621542
// - Storage Diff: -1915
// - CPU Cycles: 6619745
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_39_after 1237505685
// STATE CLOCK launchpad_withdraw_40_before 1237505690
// Launchpad Numerics CollectDepositGns call=40/256
// - Gas Used: 7611664
// - Storage Diff: -1915
// - CPU Cycles: 6611463
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_40_after 1237505690
// STATE CLOCK launchpad_withdraw_41_before 1237505695
// Launchpad Numerics CollectDepositGns call=41/256
// - Gas Used: 7609991
// - Storage Diff: -1915
// - CPU Cycles: 6611386
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_41_after 1237505695
// STATE CLOCK launchpad_withdraw_42_before 1237505700
// Launchpad Numerics CollectDepositGns call=42/256
// - Gas Used: 7609050
// - Storage Diff: -1915
// - CPU Cycles: 6612041
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_42_after 1237505700
// STATE CLOCK launchpad_withdraw_43_before 1237505705
// Launchpad Numerics CollectDepositGns call=43/256
// - Gas Used: 7606639
// - Storage Diff: -1915
// - CPU Cycles: 6611226
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_43_after 1237505705
// STATE CLOCK launchpad_withdraw_44_before 1237505710
// Launchpad Numerics CollectDepositGns call=44/256
// - Gas Used: 7605698
// - Storage Diff: -1915
// - CPU Cycles: 6611881
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_44_after 1237505710
// STATE CLOCK launchpad_withdraw_45_before 1237505715
// Launchpad Numerics CollectDepositGns call=45/256
// - Gas Used: 7604022
// - Storage Diff: -1915
// - CPU Cycles: 6611801
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_45_after 1237505715
// STATE CLOCK launchpad_withdraw_46_before 1237505720
// Launchpad Numerics CollectDepositGns call=46/256
// - Gas Used: 7721990
// - Storage Diff: -5384
// - CPU Cycles: 6713583
// - Realm gno.land/r/gnoswap/launchpad: -5384
// STATE CLOCK launchpad_withdraw_46_after 1237505720
// STATE CLOCK launchpad_withdraw_47_before 1237505725
// Launchpad Numerics CollectDepositGns call=47/256
// - Gas Used: 7504378
// - Storage Diff: -1915
// - CPU Cycles: 6538666
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_47_after 1237505725
// STATE CLOCK launchpad_withdraw_48_before 1237505730
// Launchpad Numerics CollectDepositGns call=48/256
// - Gas Used: 7493765
// - Storage Diff: -1915
// - CPU Cycles: 6529649
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_48_after 1237505730
// STATE CLOCK launchpad_withdraw_49_before 1237505735
// Launchpad Numerics CollectDepositGns call=49/256
// - Gas Used: 7493069
// - Storage Diff: -1915
// - CPU Cycles: 6530549
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_49_after 1237505735
// STATE CLOCK launchpad_withdraw_50_before 1237505740
// Launchpad Numerics CollectDepositGns call=50/256
// - Gas Used: 7490413
// - Storage Diff: -1915
// - CPU Cycles: 6529489
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_50_after 1237505740
// STATE CLOCK launchpad_withdraw_51_before 1237505745
// Launchpad Numerics CollectDepositGns call=51/256
// - Gas Used: 7490521
// - Storage Diff: -1926
// - CPU Cycles: 6531124
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_51_after 1237505745
// STATE CLOCK launchpad_withdraw_52_before 1237505750
// Launchpad Numerics CollectDepositGns call=52/256
// - Gas Used: 7604240
// - Storage Diff: -1925
// - CPU Cycles: 6617941
// - Realm gno.land/r/gnoswap/launchpad: -1925
// STATE CLOCK launchpad_withdraw_52_after 1237505750
// STATE CLOCK launchpad_withdraw_53_before 1237505755
// Launchpad Numerics CollectDepositGns call=53/256
// - Gas Used: 7599813
// - Storage Diff: -1926
// - CPU Cycles: 6614542
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_53_after 1237505755
// STATE CLOCK launchpad_withdraw_54_before 1237505760
// Launchpad Numerics CollectDepositGns call=54/256
// - Gas Used: 7612911
// - Storage Diff: -1926
// - CPU Cycles: 6612449
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_54_after 1237505760
// STATE CLOCK launchpad_withdraw_55_before 1237505765
// Launchpad Numerics CollectDepositGns call=55/256
// - Gas Used: 7602289
// - Storage Diff: -1926
// - CPU Cycles: 6603432
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_55_after 1237505765
// STATE CLOCK launchpad_withdraw_56_before 1237505770
// Launchpad Numerics CollectDepositGns call=56/256
// - Gas Used: 7600604
// - Storage Diff: -1926
// - CPU Cycles: 6603352
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_56_after 1237505770
// STATE CLOCK launchpad_withdraw_57_before 1237505775
// Launchpad Numerics CollectDepositGns call=57/256
// - Gas Used: 7599666
// - Storage Diff: -1927
// - CPU Cycles: 6604007
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_57_after 1237505775
// STATE CLOCK launchpad_withdraw_58_before 1237505780
// Launchpad Numerics CollectDepositGns call=58/256
// - Gas Used: 7597243
// - Storage Diff: -1927
// - CPU Cycles: 6603192
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_58_after 1237505780
// STATE CLOCK launchpad_withdraw_59_before 1237505785
// Launchpad Numerics CollectDepositGns call=59/256
// - Gas Used: 7596290
// - Storage Diff: -1927
// - CPU Cycles: 6603847
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_59_after 1237505785
// STATE CLOCK launchpad_withdraw_60_before 1237505790
// Launchpad Numerics CollectDepositGns call=60/256
// - Gas Used: 7722461
// - Storage Diff: -5400
// - CPU Cycles: 6714519
// - Realm gno.land/r/gnoswap/launchpad: -5400
// STATE CLOCK launchpad_withdraw_60_after 1237505790
// STATE CLOCK launchpad_withdraw_61_before 1237505795
// Launchpad Numerics CollectDepositGns call=61/256
// - Gas Used: 7506246
// - Storage Diff: -1927
// - CPU Cycles: 6540384
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_61_after 1237505795
// STATE CLOCK launchpad_withdraw_62_before 1237505800
// Launchpad Numerics CollectDepositGns call=62/256
// - Gas Used: 7495621
// - Storage Diff: -1927
// - CPU Cycles: 6531367
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_62_after 1237505800
// STATE CLOCK launchpad_withdraw_63_before 1237505805
// Launchpad Numerics CollectDepositGns call=63/256
// - Gas Used: 7494913
// - Storage Diff: -1927
// - CPU Cycles: 6532267
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_63_after 1237505805
// STATE CLOCK launchpad_withdraw_64_before 1237505810
// Launchpad Numerics CollectDepositGns call=64/256
// - Gas Used: 7492980
// - Storage Diff: -1927
// - CPU Cycles: 6531942
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_64_after 1237505810
// STATE CLOCK launchpad_withdraw_65_before 1237505815
// Launchpad Numerics CollectDepositGns call=65/256
// - Gas Used: 7491537
// - Storage Diff: -1927
// - CPU Cycles: 6532107
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_65_after 1237505815
// STATE CLOCK launchpad_withdraw_66_before 1237505820
// Launchpad Numerics CollectDepositGns call=66/256
// - Gas Used: 7604046
// - Storage Diff: -1926
// - CPU Cycles: 6617699
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_66_after 1237505820
// STATE CLOCK launchpad_withdraw_67_before 1237505825
// Launchpad Numerics CollectDepositGns call=67/256
// - Gas Used: 7592146
// - Storage Diff: -1927
// - CPU Cycles: 6606830
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_67_after 1237505825
// STATE CLOCK launchpad_withdraw_68_before 1237505830
// Launchpad Numerics CollectDepositGns call=68/256
// - Gas Used: 7719325
// - Storage Diff: -5407
// - CPU Cycles: 6712019
// - Realm gno.land/r/gnoswap/launchpad: -5407
// STATE CLOCK launchpad_withdraw_68_after 1237505830
// STATE CLOCK launchpad_withdraw_69_before 1237505835
// Launchpad Numerics CollectDepositGns call=69/256
// - Gas Used: 7504528
// - Storage Diff: -1927
// - CPU Cycles: 6538666
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_69_after 1237505835
// STATE CLOCK launchpad_withdraw_70_before 1237505840
// Launchpad Numerics CollectDepositGns call=70/256
// - Gas Used: 7493903
// - Storage Diff: -1927
// - CPU Cycles: 6529649
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_70_after 1237505840
// STATE CLOCK launchpad_withdraw_71_before 1237505845
// Launchpad Numerics CollectDepositGns call=71/256
// - Gas Used: 7493930
// - Storage Diff: -1927
// - CPU Cycles: 6531284
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_71_after 1237505845
// STATE CLOCK launchpad_withdraw_72_before 1237505850
// Launchpad Numerics CollectDepositGns call=72/256
// - Gas Used: 7490530
// - Storage Diff: -1927
// - CPU Cycles: 6529492
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_72_after 1237505850
// STATE CLOCK launchpad_withdraw_73_before 1237505855
// Launchpad Numerics CollectDepositGns call=73/256
// - Gas Used: 7490557
// - Storage Diff: -1927
// - CPU Cycles: 6531127
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_73_after 1237505855
// STATE CLOCK launchpad_withdraw_74_before 1237505860
// Launchpad Numerics CollectDepositGns call=74/256
// - Gas Used: 7604294
// - Storage Diff: -1926
// - CPU Cycles: 6617944
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_74_after 1237505860
// STATE CLOCK launchpad_withdraw_75_before 1237505865
// Launchpad Numerics CollectDepositGns call=75/256
// - Gas Used: 7600596
// - Storage Diff: -1927
// - CPU Cycles: 6615277
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_75_after 1237505865
// STATE CLOCK launchpad_withdraw_76_before 1237505870
// Launchpad Numerics CollectDepositGns call=76/256
// - Gas Used: 7613691
// - Storage Diff: -1927
// - CPU Cycles: 6613184
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_76_after 1237505870
// STATE CLOCK launchpad_withdraw_77_before 1237505875
// Launchpad Numerics CollectDepositGns call=77/256
// - Gas Used: 7603066
// - Storage Diff: -1927
// - CPU Cycles: 6604167
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_77_after 1237505875
// STATE CLOCK launchpad_withdraw_78_before 1237505880
// Launchpad Numerics CollectDepositGns call=78/256
// - Gas Used: 7601378
// - Storage Diff: -1927
// - CPU Cycles: 6604087
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_78_after 1237505880
// STATE CLOCK launchpad_withdraw_79_before 1237505885
// Launchpad Numerics CollectDepositGns call=79/256
// - Gas Used: 7600425
// - Storage Diff: -1927
// - CPU Cycles: 6604742
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_79_after 1237505885
// STATE CLOCK launchpad_withdraw_80_before 1237505890
// Launchpad Numerics CollectDepositGns call=80/256
// - Gas Used: 7598734
// - Storage Diff: -1927
// - CPU Cycles: 6604659
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_80_after 1237505890
// STATE CLOCK launchpad_withdraw_81_before 1237505895
// Launchpad Numerics CollectDepositGns call=81/256
// - Gas Used: 7597049
// - Storage Diff: -1927
// - CPU Cycles: 6604582
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_81_after 1237505895
// STATE CLOCK launchpad_withdraw_82_before 1237505900
// Launchpad Numerics CollectDepositGns call=82/256
// - Gas Used: 7719625
// - Storage Diff: -5407
// - CPU Cycles: 6712955
// - Realm gno.land/r/gnoswap/launchpad: -5407
// STATE CLOCK launchpad_withdraw_82_after 1237505900
// STATE CLOCK launchpad_withdraw_83_before 1237505905
// Launchpad Numerics CollectDepositGns call=83/256
// - Gas Used: 7506246
// - Storage Diff: -1927
// - CPU Cycles: 6540384
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_83_after 1237505905
// STATE CLOCK launchpad_withdraw_84_before 1237505910
// Launchpad Numerics CollectDepositGns call=84/256
// - Gas Used: 7504558
// - Storage Diff: -1927
// - CPU Cycles: 6540304
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_84_after 1237505910
// STATE CLOCK launchpad_withdraw_85_before 1237505915
// Launchpad Numerics CollectDepositGns call=85/256
// - Gas Used: 7504585
// - Storage Diff: -1927
// - CPU Cycles: 6541939
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_85_after 1237505915
// STATE CLOCK launchpad_withdraw_86_before 1237505920
// Launchpad Numerics CollectDepositGns call=86/256
// - Gas Used: 7501182
// - Storage Diff: -1927
// - CPU Cycles: 6540144
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_86_after 1237505920
// STATE CLOCK launchpad_withdraw_87_before 1237505925
// Launchpad Numerics CollectDepositGns call=87/256
// - Gas Used: 7501209
// - Storage Diff: -1927
// - CPU Cycles: 6541779
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_87_after 1237505925
// STATE CLOCK launchpad_withdraw_88_before 1237505930
// Launchpad Numerics CollectDepositGns call=88/256
// - Gas Used: 7613969
// - Storage Diff: -1926
// - CPU Cycles: 6627616
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_88_after 1237505930
// STATE CLOCK launchpad_withdraw_89_before 1237505935
// Launchpad Numerics CollectDepositGns call=89/256
// - Gas Used: 7602804
// - Storage Diff: -1927
// - CPU Cycles: 6617482
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_89_after 1237505935
// STATE CLOCK launchpad_withdraw_90_before 1237505940
// Launchpad Numerics CollectDepositGns call=90/256
// - Gas Used: 7719674
// - Storage Diff: -5407
// - CPU Cycles: 6713640
// - Realm gno.land/r/gnoswap/launchpad: -5407
// STATE CLOCK launchpad_withdraw_90_after 1237505940
// STATE CLOCK launchpad_withdraw_91_before 1237505945
// Launchpad Numerics CollectDepositGns call=91/256
// - Gas Used: 7506981
// - Storage Diff: -1927
// - CPU Cycles: 6541119
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_91_after 1237505945
// STATE CLOCK launchpad_withdraw_92_before 1237505950
// Launchpad Numerics CollectDepositGns call=92/256
// - Gas Used: 7506028
// - Storage Diff: -1927
// - CPU Cycles: 6541774
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_92_after 1237505950
// STATE CLOCK launchpad_withdraw_93_before 1237505955
// Launchpad Numerics CollectDepositGns call=93/256
// - Gas Used: 7504585
// - Storage Diff: -1927
// - CPU Cycles: 6541939
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_93_after 1237505955
// STATE CLOCK launchpad_withdraw_94_before 1237505960
// Launchpad Numerics CollectDepositGns call=94/256
// - Gas Used: 7502652
// - Storage Diff: -1927
// - CPU Cycles: 6541614
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_94_after 1237505960
// STATE CLOCK launchpad_withdraw_95_before 1237505965
// Launchpad Numerics CollectDepositGns call=95/256
// - Gas Used: 7501944
// - Storage Diff: -1927
// - CPU Cycles: 6542514
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_95_after 1237505965
// STATE CLOCK launchpad_withdraw_96_before 1237505970
// Launchpad Numerics CollectDepositGns call=96/256
// - Gas Used: 7585230
// - Storage Diff: -1926
// - CPU Cycles: 6606368
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_96_after 1237505970
// STATE CLOCK launchpad_withdraw_97_before 1237505975
// Launchpad Numerics CollectDepositGns call=97/256
// - Gas Used: 7611700
// - Storage Diff: -1921
// - CPU Cycles: 6596234
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_97_after 1237505975
// STATE CLOCK launchpad_withdraw_98_before 1237505980
// Launchpad Numerics CollectDepositGns call=98/256
// - Gas Used: 7708572
// - Storage Diff: -11830
// - CPU Cycles: 6692776
// - Realm gno.land/r/gnoswap/launchpad: -11830
// STATE CLOCK launchpad_withdraw_98_after 1237505980
// STATE CLOCK launchpad_withdraw_99_before 1237505985
// Launchpad Numerics CollectDepositGns call=99/256
// - Gas Used: 7434434
// - Storage Diff: -1921
// - CPU Cycles: 6463602
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_99_after 1237505985
// STATE CLOCK launchpad_withdraw_100_before 1237505990
// Launchpad Numerics CollectDepositGns call=100/256
// - Gas Used: 7504961
// - Storage Diff: -1921
// - CPU Cycles: 6493431
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_100_after 1237505990
// STATE CLOCK launchpad_withdraw_101_before 1237505995
// Launchpad Numerics CollectDepositGns call=101/256
// - Gas Used: 7502478
// - Storage Diff: -1921
// - CPU Cycles: 6493354
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_101_after 1237505995
// STATE CLOCK launchpad_withdraw_102_before 1237506000
// Launchpad Numerics CollectDepositGns call=102/256
// - Gas Used: 7500727
// - Storage Diff: -1921
// - CPU Cycles: 6494009
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_102_after 1237506000
// STATE CLOCK launchpad_withdraw_103_before 1237506005
// Launchpad Numerics CollectDepositGns call=103/256
// - Gas Used: 7497506
// - Storage Diff: -1921
// - CPU Cycles: 6493194
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_103_after 1237506005
// STATE CLOCK launchpad_withdraw_104_before 1237506010
// Launchpad Numerics CollectDepositGns call=104/256
// - Gas Used: 7627604
// - Storage Diff: -5401
// - CPU Cycles: 6584839
// - Realm gno.land/r/gnoswap/launchpad: -5401
// STATE CLOCK launchpad_withdraw_104_after 1237506010
// STATE CLOCK launchpad_withdraw_105_before 1237506015
// Launchpad Numerics CollectDepositGns call=105/256
// - Gas Used: 7513181
// - Storage Diff: -1921
// - CPU Cycles: 6494409
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_105_after 1237506015
// STATE CLOCK launchpad_withdraw_106_before 1237506020
// Launchpad Numerics CollectDepositGns call=106/256
// - Gas Used: 7467804
// - Storage Diff: -1928
// - CPU Cycles: 6502531
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_106_after 1237506020
// STATE CLOCK launchpad_withdraw_107_before 1237506025
// Launchpad Numerics CollectDepositGns call=107/256
// - Gas Used: 7466848
// - Storage Diff: -1928
// - CPU Cycles: 6503186
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_107_after 1237506025
// STATE CLOCK launchpad_withdraw_108_before 1237506030
// Launchpad Numerics CollectDepositGns call=108/256
// - Gas Used: 7456217
// - Storage Diff: -1928
// - CPU Cycles: 6494166
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_108_after 1237506030
// STATE CLOCK launchpad_withdraw_109_before 1237506035
// Launchpad Numerics CollectDepositGns call=109/256
// - Gas Used: 7454526
// - Storage Diff: -1928
// - CPU Cycles: 6494086
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_109_after 1237506035
// STATE CLOCK launchpad_withdraw_110_before 1237506040
// Launchpad Numerics CollectDepositGns call=110/256
// - Gas Used: 7452835
// - Storage Diff: -1928
// - CPU Cycles: 6494006
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_110_after 1237506040
// STATE CLOCK launchpad_withdraw_111_before 1237506045
// Launchpad Numerics CollectDepositGns call=111/256
// - Gas Used: 7451879
// - Storage Diff: -1928
// - CPU Cycles: 6494661
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_111_after 1237506045
// STATE CLOCK launchpad_withdraw_112_before 1237506050
// Launchpad Numerics CollectDepositGns call=112/256
// - Gas Used: 7566662
// - Storage Diff: -1916
// - CPU Cycles: 6573919
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_112_after 1237506050
// STATE CLOCK launchpad_withdraw_113_before 1237506055
// Launchpad Numerics CollectDepositGns call=113/256
// - Gas Used: 7572444
// - Storage Diff: -1916
// - CPU Cycles: 6581312
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_113_after 1237506055
// STATE CLOCK launchpad_withdraw_114_before 1237506060
// Launchpad Numerics CollectDepositGns call=114/256
// - Gas Used: 7571488
// - Storage Diff: -1916
// - CPU Cycles: 6581967
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_114_after 1237506060
// STATE CLOCK launchpad_withdraw_115_before 1237506065
// Launchpad Numerics CollectDepositGns call=115/256
// - Gas Used: 7560857
// - Storage Diff: -1916
// - CPU Cycles: 6572947
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_115_after 1237506065
// STATE CLOCK launchpad_withdraw_116_before 1237506070
// Launchpad Numerics CollectDepositGns call=116/256
// - Gas Used: 7559166
// - Storage Diff: -1916
// - CPU Cycles: 6572867
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_116_after 1237506070
// STATE CLOCK launchpad_withdraw_117_before 1237506075
// Launchpad Numerics CollectDepositGns call=117/256
// - Gas Used: 7558210
// - Storage Diff: -1916
// - CPU Cycles: 6573522
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_117_after 1237506075
// STATE CLOCK launchpad_withdraw_118_before 1237506080
// Launchpad Numerics CollectDepositGns call=118/256
// - Gas Used: 7578476
// - Storage Diff: -5396
// - CPU Cycles: 6583678
// - Realm gno.land/r/gnoswap/launchpad: -5396
// STATE CLOCK launchpad_withdraw_118_after 1237506080
// STATE CLOCK launchpad_withdraw_119_before 1237506085
// Launchpad Numerics CollectDepositGns call=119/256
// - Gas Used: 7460987
// - Storage Diff: -1916
// - CPU Cycles: 6494103
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_119_after 1237506085
// STATE CLOCK launchpad_withdraw_120_before 1237506090
// Launchpad Numerics CollectDepositGns call=120/256
// - Gas Used: 7467501
// - Storage Diff: -1916
// - CPU Cycles: 6502228
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_120_after 1237506090
// STATE CLOCK launchpad_withdraw_121_before 1237506095
// Launchpad Numerics CollectDepositGns call=121/256
// - Gas Used: 7466545
// - Storage Diff: -1916
// - CPU Cycles: 6502883
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_121_after 1237506095
// STATE CLOCK launchpad_withdraw_122_before 1237506100
// Launchpad Numerics CollectDepositGns call=122/256
// - Gas Used: 7455914
// - Storage Diff: -1916
// - CPU Cycles: 6493863
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_122_after 1237506100
// STATE CLOCK launchpad_withdraw_123_before 1237506105
// Launchpad Numerics CollectDepositGns call=123/256
// - Gas Used: 7454223
// - Storage Diff: -1916
// - CPU Cycles: 6493783
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_123_after 1237506105
// STATE CLOCK launchpad_withdraw_124_before 1237506110
// Launchpad Numerics CollectDepositGns call=124/256
// - Gas Used: 7453267
// - Storage Diff: -1916
// - CPU Cycles: 6494438
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_124_after 1237506110
// STATE CLOCK launchpad_withdraw_125_before 1237506115
// Launchpad Numerics CollectDepositGns call=125/256
// - Gas Used: 7450841
// - Storage Diff: -1916
// - CPU Cycles: 6493623
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_125_after 1237506115
// STATE CLOCK launchpad_withdraw_126_before 1237506120
// Launchpad Numerics CollectDepositGns call=126/256
// - Gas Used: 7578155
// - Storage Diff: -5397
// - CPU Cycles: 6585028
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_126_after 1237506120
// STATE CLOCK launchpad_withdraw_127_before 1237506125
// Launchpad Numerics CollectDepositGns call=127/256
// - Gas Used: 7461722
// - Storage Diff: -1916
// - CPU Cycles: 6494838
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_127_after 1237506125
// STATE CLOCK launchpad_withdraw_128_before 1237506130
// Launchpad Numerics CollectDepositGns call=128/256
// - Gas Used: 7466763
// - Storage Diff: -1916
// - CPU Cycles: 6501490
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_128_after 1237506130
// STATE launchpad-numerics phase=withdrawn-stage-128 global_staked=128000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=128000000 tier_deposit_count=256 tier_withdraw_count=128 tier_collected=125042846 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=125042846 manager_active_deposit=128000000 manager_active_claimed=0 manager_active_debt=143161052288871807480826382395675884485000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=128 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69371 record_created_offset=640 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_129_before 1237506135
// Launchpad Numerics CollectDepositGns call=129/256
// - Gas Used: 7465807
// - Storage Diff: -1916
// - CPU Cycles: 6502145
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_129_after 1237506135
// STATE CLOCK launchpad_withdraw_130_before 1237506140
// Launchpad Numerics CollectDepositGns call=130/256
// - Gas Used: 7455176
// - Storage Diff: -1916
// - CPU Cycles: 6493125
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_130_after 1237506140
// STATE CLOCK launchpad_withdraw_131_before 1237506145
// Launchpad Numerics CollectDepositGns call=131/256
// - Gas Used: 7454220
// - Storage Diff: -1916
// - CPU Cycles: 6493780
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_131_after 1237506145
// STATE CLOCK launchpad_withdraw_132_before 1237506150
// Launchpad Numerics CollectDepositGns call=132/256
// - Gas Used: 7451797
// - Storage Diff: -1916
// - CPU Cycles: 6492968
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_132_after 1237506150
// STATE CLOCK launchpad_withdraw_133_before 1237506155
// Launchpad Numerics CollectDepositGns call=133/256
// - Gas Used: 7450841
// - Storage Diff: -1916
// - CPU Cycles: 6493623
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_133_after 1237506155
// STATE CLOCK launchpad_withdraw_134_before 1237506160
// Launchpad Numerics CollectDepositGns call=134/256
// - Gas Used: 7575629
// - Storage Diff: -5385
// - CPU Cycles: 6584173
// - Realm gno.land/r/gnoswap/launchpad: -5385
// STATE CLOCK launchpad_withdraw_134_after 1237506160
// STATE CLOCK launchpad_withdraw_135_before 1237506165
// Launchpad Numerics CollectDepositGns call=135/256
// - Gas Used: 7469192
// - Storage Diff: -1916
// - CPU Cycles: 6502308
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_135_after 1237506165
// STATE CLOCK launchpad_withdraw_136_before 1237506170
// Launchpad Numerics CollectDepositGns call=136/256
// - Gas Used: 7468236
// - Storage Diff: -1916
// - CPU Cycles: 6502963
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_136_after 1237506170
// STATE CLOCK launchpad_withdraw_137_before 1237506175
// Launchpad Numerics CollectDepositGns call=137/256
// - Gas Used: 7457605
// - Storage Diff: -1916
// - CPU Cycles: 6493943
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_137_after 1237506175
// STATE CLOCK launchpad_withdraw_138_before 1237506180
// Launchpad Numerics CollectDepositGns call=138/256
// - Gas Used: 7455914
// - Storage Diff: -1916
// - CPU Cycles: 6493863
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_138_after 1237506180
// STATE CLOCK launchpad_withdraw_139_before 1237506185
// Launchpad Numerics CollectDepositGns call=139/256
// - Gas Used: 7454958
// - Storage Diff: -1916
// - CPU Cycles: 6494518
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_139_after 1237506185
// STATE CLOCK launchpad_withdraw_140_before 1237506190
// Launchpad Numerics CollectDepositGns call=140/256
// - Gas Used: 7453264
// - Storage Diff: -1916
// - CPU Cycles: 6494435
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_140_after 1237506190
// STATE CLOCK launchpad_withdraw_141_before 1237506195
// Launchpad Numerics CollectDepositGns call=141/256
// - Gas Used: 7451576
// - Storage Diff: -1916
// - CPU Cycles: 6494358
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_141_after 1237506195
// STATE CLOCK launchpad_withdraw_142_before 1237506200
// Launchpad Numerics CollectDepositGns call=142/256
// - Gas Used: 7581054
// - Storage Diff: -1916
// - CPU Cycles: 6582044
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_142_after 1237506200
// STATE CLOCK launchpad_withdraw_143_before 1237506205
// Launchpad Numerics CollectDepositGns call=143/256
// - Gas Used: 7580098
// - Storage Diff: -1916
// - CPU Cycles: 6582699
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_143_after 1237506205
// STATE CLOCK launchpad_withdraw_144_before 1237506210
// Launchpad Numerics CollectDepositGns call=144/256
// - Gas Used: 7569467
// - Storage Diff: -1916
// - CPU Cycles: 6573679
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_144_after 1237506210
// STATE CLOCK launchpad_withdraw_145_before 1237506215
// Launchpad Numerics CollectDepositGns call=145/256
// - Gas Used: 7567776
// - Storage Diff: -1916
// - CPU Cycles: 6573599
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_145_after 1237506215
// STATE CLOCK launchpad_withdraw_146_before 1237506220
// Launchpad Numerics CollectDepositGns call=146/256
// - Gas Used: 7566820
// - Storage Diff: -1916
// - CPU Cycles: 6574254
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_146_after 1237506220
// STATE CLOCK launchpad_withdraw_147_before 1237506225
// Launchpad Numerics CollectDepositGns call=147/256
// - Gas Used: 7573835
// - Storage Diff: -5397
// - CPU Cycles: 6584050
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_147_after 1237506225
// STATE CLOCK launchpad_withdraw_148_before 1237506230
// Launchpad Numerics CollectDepositGns call=148/256
// - Gas Used: 7461719
// - Storage Diff: -1916
// - CPU Cycles: 6494835
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_148_after 1237506230
// STATE CLOCK launchpad_withdraw_149_before 1237506235
// Launchpad Numerics CollectDepositGns call=149/256
// - Gas Used: 7460028
// - Storage Diff: -1916
// - CPU Cycles: 6494755
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_149_after 1237506235
// STATE CLOCK launchpad_withdraw_150_before 1237506240
// Launchpad Numerics CollectDepositGns call=150/256
// - Gas Used: 7467274
// - Storage Diff: -1916
// - CPU Cycles: 6503612
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_150_after 1237506240
// STATE CLOCK launchpad_withdraw_151_before 1237506245
// Launchpad Numerics CollectDepositGns call=151/256
// - Gas Used: 7465586
// - Storage Diff: -1916
// - CPU Cycles: 6503535
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_151_after 1237506245
// STATE CLOCK launchpad_withdraw_152_before 1237506250
// Launchpad Numerics CollectDepositGns call=152/256
// - Gas Used: 7464630
// - Storage Diff: -1916
// - CPU Cycles: 6504190
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_152_after 1237506250
// STATE CLOCK launchpad_withdraw_153_before 1237506255
// Launchpad Numerics CollectDepositGns call=153/256
// - Gas Used: 7462204
// - Storage Diff: -1916
// - CPU Cycles: 6503375
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_153_after 1237506255
// STATE CLOCK launchpad_withdraw_154_before 1237506260
// Launchpad Numerics CollectDepositGns call=154/256
// - Gas Used: 7461248
// - Storage Diff: -1916
// - CPU Cycles: 6504030
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_154_after 1237506260
// STATE CLOCK launchpad_withdraw_155_before 1237506265
// Launchpad Numerics CollectDepositGns call=155/256
// - Gas Used: 7574820
// - Storage Diff: -1880
// - CPU Cycles: 6584249
// - Realm gno.land/r/gnoswap/launchpad: -1880
// STATE CLOCK launchpad_withdraw_155_after 1237506265
// STATE CLOCK launchpad_withdraw_156_before 1237506270
// Launchpad Numerics CollectDepositGns call=156/256
// - Gas Used: 7573864
// - Storage Diff: -1916
// - CPU Cycles: 6584904
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_156_after 1237506270
// STATE CLOCK launchpad_withdraw_157_before 1237506275
// Launchpad Numerics CollectDepositGns call=157/256
// - Gas Used: 7560944
// - Storage Diff: -1916
// - CPU Cycles: 6573598
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_157_after 1237506275
// STATE CLOCK launchpad_withdraw_158_before 1237506280
// Launchpad Numerics CollectDepositGns call=158/256
// - Gas Used: 7556736
// - Storage Diff: -1916
// - CPU Cycles: 6571002
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_158_after 1237506280
// STATE CLOCK launchpad_withdraw_159_before 1237506285
// Launchpad Numerics CollectDepositGns call=159/256
// - Gas Used: 7555045
// - Storage Diff: -1916
// - CPU Cycles: 6570922
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_159_after 1237506285
// STATE CLOCK launchpad_withdraw_160_before 1237506290
// Launchpad Numerics CollectDepositGns call=160/256
// - Gas Used: 7569425
// - Storage Diff: -5243
// - CPU Cycles: 6581333
// - Realm gno.land/r/gnoswap/launchpad: -5243
// STATE CLOCK launchpad_withdraw_160_after 1237506290
// STATE CLOCK launchpad_withdraw_161_before 1237506295
// Launchpad Numerics CollectDepositGns call=161/256
// - Gas Used: 7459100
// - Storage Diff: -1916
// - CPU Cycles: 6492238
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_161_after 1237506295
// STATE CLOCK launchpad_withdraw_162_before 1237506300
// Launchpad Numerics CollectDepositGns call=162/256
// - Gas Used: 7457409
// - Storage Diff: -1916
// - CPU Cycles: 6492158
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_162_after 1237506300
// STATE CLOCK launchpad_withdraw_163_before 1237506305
// Launchpad Numerics CollectDepositGns call=163/256
// - Gas Used: 7452043
// - Storage Diff: -1916
// - CPU Cycles: 6488403
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_163_after 1237506305
// STATE CLOCK launchpad_withdraw_164_before 1237506310
// Launchpad Numerics CollectDepositGns call=164/256
// - Gas Used: 7565081
// - Storage Diff: -1910
// - CPU Cycles: 6489058
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_164_after 1237506310
// STATE CLOCK launchpad_withdraw_165_before 1237506315
// Launchpad Numerics CollectDepositGns call=165/256
// - Gas Used: 7563390
// - Storage Diff: -1910
// - CPU Cycles: 6488978
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_165_after 1237506315
// STATE CLOCK launchpad_withdraw_166_before 1237506320
// Launchpad Numerics CollectDepositGns call=166/256
// - Gas Used: 7562434
// - Storage Diff: -1910
// - CPU Cycles: 6489633
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_166_after 1237506320
// STATE CLOCK launchpad_withdraw_167_before 1237506325
// Launchpad Numerics CollectDepositGns call=167/256
// - Gas Used: 7560008
// - Storage Diff: -1910
// - CPU Cycles: 6488818
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_167_after 1237506325
// STATE CLOCK launchpad_withdraw_168_before 1237506330
// Launchpad Numerics CollectDepositGns call=168/256
// - Gas Used: 7680155
// - Storage Diff: -5391
// - CPU Cycles: 6579743
// - Realm gno.land/r/gnoswap/launchpad: -5391
// STATE CLOCK launchpad_withdraw_168_after 1237506330
// STATE CLOCK launchpad_withdraw_169_before 1237506335
// Launchpad Numerics CollectDepositGns call=169/256
// - Gas Used: 7558970
// - Storage Diff: -1910
// - CPU Cycles: 6478117
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_169_after 1237506335
// STATE CLOCK launchpad_withdraw_170_before 1237506340
// Launchpad Numerics CollectDepositGns call=170/256
// - Gas Used: 7567824
// - Storage Diff: -1909
// - CPU Cycles: 6486974
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_170_after 1237506340
// STATE CLOCK launchpad_withdraw_171_before 1237506345
// Launchpad Numerics CollectDepositGns call=171/256
// - Gas Used: 7557199
// - Storage Diff: -1909
// - CPU Cycles: 6477957
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_171_after 1237506345
// STATE CLOCK launchpad_withdraw_172_before 1237506350
// Launchpad Numerics CollectDepositGns call=172/256
// - Gas Used: 7555511
// - Storage Diff: -1909
// - CPU Cycles: 6477877
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_172_after 1237506350
// STATE CLOCK launchpad_withdraw_173_before 1237506355
// Launchpad Numerics CollectDepositGns call=173/256
// - Gas Used: 7554558
// - Storage Diff: -1909
// - CPU Cycles: 6478532
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_173_after 1237506355
// STATE CLOCK launchpad_withdraw_174_before 1237506360
// Launchpad Numerics CollectDepositGns call=174/256
// - Gas Used: 7552135
// - Storage Diff: -1909
// - CPU Cycles: 6477717
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_174_after 1237506360
// STATE CLOCK launchpad_withdraw_175_before 1237506365
// Launchpad Numerics CollectDepositGns call=175/256
// - Gas Used: 7551182
// - Storage Diff: -1909
// - CPU Cycles: 6478372
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_175_after 1237506365
// STATE CLOCK launchpad_withdraw_176_before 1237506370
// Launchpad Numerics CollectDepositGns call=176/256
// - Gas Used: 7668809
// - Storage Diff: -5390
// - CPU Cycles: 6568442
// - Realm gno.land/r/gnoswap/launchpad: -5390
// STATE CLOCK launchpad_withdraw_176_after 1237506370
// STATE CLOCK launchpad_withdraw_177_before 1237506375
// Launchpad Numerics CollectDepositGns call=177/256
// - Gas Used: 7453205
// - Storage Diff: -1916
// - CPU Cycles: 6486325
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_177_after 1237506375
// STATE CLOCK launchpad_withdraw_178_before 1237506380
// Launchpad Numerics CollectDepositGns call=178/256
// - Gas Used: 7452249
// - Storage Diff: -1916
// - CPU Cycles: 6486980
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_178_after 1237506380
// STATE CLOCK launchpad_withdraw_179_before 1237506385
// Launchpad Numerics CollectDepositGns call=179/256
// - Gas Used: 7441618
// - Storage Diff: -1916
// - CPU Cycles: 6477960
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_179_after 1237506385
// STATE CLOCK launchpad_withdraw_180_before 1237506390
// Launchpad Numerics CollectDepositGns call=180/256
// - Gas Used: 7440659
// - Storage Diff: -1916
// - CPU Cycles: 6478612
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_180_after 1237506390
// STATE CLOCK launchpad_withdraw_181_before 1237506395
// Launchpad Numerics CollectDepositGns call=181/256
// - Gas Used: 7438236
// - Storage Diff: -1916
// - CPU Cycles: 6477800
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_181_after 1237506395
// STATE CLOCK launchpad_withdraw_182_before 1237506400
// Launchpad Numerics CollectDepositGns call=182/256
// - Gas Used: 7437280
// - Storage Diff: -1916
// - CPU Cycles: 6478455
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_182_after 1237506400
// STATE CLOCK launchpad_withdraw_183_before 1237506405
// Launchpad Numerics CollectDepositGns call=183/256
// - Gas Used: 7435589
// - Storage Diff: -1916
// - CPU Cycles: 6478375
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_183_after 1237506405
// STATE CLOCK launchpad_withdraw_184_before 1237506410
// Launchpad Numerics CollectDepositGns call=184/256
// - Gas Used: 7556092
// - Storage Diff: -1916
// - CPU Cycles: 6566719
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_184_after 1237506410
// STATE CLOCK launchpad_withdraw_185_before 1237506415
// Launchpad Numerics CollectDepositGns call=185/256
// - Gas Used: 7555136
// - Storage Diff: -1916
// - CPU Cycles: 6567374
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_185_after 1237506415
// STATE CLOCK launchpad_withdraw_186_before 1237506420
// Launchpad Numerics CollectDepositGns call=186/256
// - Gas Used: 7544505
// - Storage Diff: -1916
// - CPU Cycles: 6558354
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_186_after 1237506420
// STATE CLOCK launchpad_withdraw_187_before 1237506425
// Launchpad Numerics CollectDepositGns call=187/256
// - Gas Used: 7542814
// - Storage Diff: -1916
// - CPU Cycles: 6558274
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_187_after 1237506425
// STATE CLOCK launchpad_withdraw_188_before 1237506430
// Launchpad Numerics CollectDepositGns call=188/256
// - Gas Used: 7552157
// - Storage Diff: -5397
// - CPU Cycles: 6569060
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_188_after 1237506430
// STATE CLOCK launchpad_withdraw_189_before 1237506435
// Launchpad Numerics CollectDepositGns call=189/256
// - Gas Used: 7445732
// - Storage Diff: -1916
// - CPU Cycles: 6478852
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_189_after 1237506435
// STATE CLOCK launchpad_withdraw_190_before 1237506440
// Launchpad Numerics CollectDepositGns call=190/256
// - Gas Used: 7444776
// - Storage Diff: -1916
// - CPU Cycles: 6479507
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_190_after 1237506440
// STATE CLOCK launchpad_withdraw_191_before 1237506445
// Launchpad Numerics CollectDepositGns call=191/256
// - Gas Used: 7449823
// - Storage Diff: -1916
// - CPU Cycles: 6486165
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_191_after 1237506445
// STATE CLOCK launchpad_withdraw_192_before 1237506450
// Launchpad Numerics CollectDepositGns call=192/256
// - Gas Used: 7448867
// - Storage Diff: -1916
// - CPU Cycles: 6486820
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_192_after 1237506450
// STATE CLOCK launchpad_withdraw_193_before 1237506455
// Launchpad Numerics CollectDepositGns call=193/256
// - Gas Used: 7438236
// - Storage Diff: -1916
// - CPU Cycles: 6477800
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_193_after 1237506455
// STATE CLOCK launchpad_withdraw_194_before 1237506460
// Launchpad Numerics CollectDepositGns call=194/256
// - Gas Used: 7436545
// - Storage Diff: -1916
// - CPU Cycles: 6477720
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_194_after 1237506460
// STATE CLOCK launchpad_withdraw_195_before 1237506465
// Launchpad Numerics CollectDepositGns call=195/256
// - Gas Used: 7435589
// - Storage Diff: -1916
// - CPU Cycles: 6478375
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_195_after 1237506465
// STATE CLOCK launchpad_withdraw_196_before 1237506470
// Launchpad Numerics CollectDepositGns call=196/256
// - Gas Used: 7548896
// - Storage Diff: -5397
// - CPU Cycles: 6567470
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_196_after 1237506470
// STATE CLOCK launchpad_withdraw_197_before 1237506475
// Launchpad Numerics CollectDepositGns call=197/256
// - Gas Used: 7445735
// - Storage Diff: -1916
// - CPU Cycles: 6478855
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_197_after 1237506475
// STATE CLOCK launchpad_withdraw_198_before 1237506480
// Launchpad Numerics CollectDepositGns call=198/256
// - Gas Used: 7444044
// - Storage Diff: -1916
// - CPU Cycles: 6478775
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_198_after 1237506480
// STATE CLOCK launchpad_withdraw_199_before 1237506485
// Launchpad Numerics CollectDepositGns call=199/256
// - Gas Used: 7450549
// - Storage Diff: -1916
// - CPU Cycles: 6486891
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_199_after 1237506485
// STATE CLOCK launchpad_withdraw_200_before 1237506490
// Launchpad Numerics CollectDepositGns call=200/256
// - Gas Used: 7440659
// - Storage Diff: -1916
// - CPU Cycles: 6478612
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_200_after 1237506490
// STATE CLOCK launchpad_withdraw_201_before 1237506495
// Launchpad Numerics CollectDepositGns call=201/256
// - Gas Used: 7439703
// - Storage Diff: -1916
// - CPU Cycles: 6479267
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_201_after 1237506495
// STATE CLOCK launchpad_withdraw_202_before 1237506500
// Launchpad Numerics CollectDepositGns call=202/256
// - Gas Used: 7437280
// - Storage Diff: -1916
// - CPU Cycles: 6478455
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_202_after 1237506500
// STATE CLOCK launchpad_withdraw_203_before 1237506505
// Launchpad Numerics CollectDepositGns call=203/256
// - Gas Used: 7436324
// - Storage Diff: -1916
// - CPU Cycles: 6479110
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_203_after 1237506505
// STATE CLOCK launchpad_withdraw_204_before 1237506510
// Launchpad Numerics CollectDepositGns call=204/256
// - Gas Used: 7548575
// - Storage Diff: -5385
// - CPU Cycles: 6568820
// - Realm gno.land/r/gnoswap/launchpad: -5385
// STATE CLOCK launchpad_withdraw_204_after 1237506510
// STATE CLOCK launchpad_withdraw_205_before 1237506515
// Launchpad Numerics CollectDepositGns call=205/256
// - Gas Used: 7433087
// - Storage Diff: -1916
// - CPU Cycles: 6466207
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_205_after 1237506515
// STATE CLOCK launchpad_withdraw_206_before 1237506520
// Launchpad Numerics CollectDepositGns call=206/256
// - Gas Used: 7432131
// - Storage Diff: -1916
// - CPU Cycles: 6466862
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_206_after 1237506520
// STATE CLOCK launchpad_withdraw_207_before 1237506525
// Launchpad Numerics CollectDepositGns call=207/256
// - Gas Used: 7421500
// - Storage Diff: -1916
// - CPU Cycles: 6457842
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_207_after 1237506525
// STATE CLOCK launchpad_withdraw_208_before 1237506530
// Launchpad Numerics CollectDepositGns call=208/256
// - Gas Used: 7419809
// - Storage Diff: -1916
// - CPU Cycles: 6457762
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_208_after 1237506530
// STATE CLOCK launchpad_withdraw_209_before 1237506535
// Launchpad Numerics CollectDepositGns call=209/256
// - Gas Used: 7418853
// - Storage Diff: -1916
// - CPU Cycles: 6458417
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_209_after 1237506535
// STATE CLOCK launchpad_withdraw_210_before 1237506540
// Launchpad Numerics CollectDepositGns call=210/256
// - Gas Used: 7417159
// - Storage Diff: -1916
// - CPU Cycles: 6458334
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_210_after 1237506540
// STATE CLOCK launchpad_withdraw_211_before 1237506545
// Launchpad Numerics CollectDepositGns call=211/256
// - Gas Used: 7415471
// - Storage Diff: -1916
// - CPU Cycles: 6458257
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_211_after 1237506545
// STATE CLOCK launchpad_withdraw_212_before 1237506550
// Launchpad Numerics CollectDepositGns call=212/256
// - Gas Used: 7545063
// - Storage Diff: -1916
// - CPU Cycles: 6554142
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_212_after 1237506550
// STATE CLOCK launchpad_withdraw_213_before 1237506555
// Launchpad Numerics CollectDepositGns call=213/256
// - Gas Used: 7544107
// - Storage Diff: -1916
// - CPU Cycles: 6554797
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_213_after 1237506555
// STATE CLOCK launchpad_withdraw_214_before 1237506560
// Launchpad Numerics CollectDepositGns call=214/256
// - Gas Used: 7533476
// - Storage Diff: -1916
// - CPU Cycles: 6545777
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_214_after 1237506560
// STATE CLOCK launchpad_withdraw_215_before 1237506565
// Launchpad Numerics CollectDepositGns call=215/256
// - Gas Used: 7531785
// - Storage Diff: -1916
// - CPU Cycles: 6545697
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_215_after 1237506565
// STATE CLOCK launchpad_withdraw_216_before 1237506570
// Launchpad Numerics CollectDepositGns call=216/256
// - Gas Used: 7530829
// - Storage Diff: -1916
// - CPU Cycles: 6546352
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_216_after 1237506570
// STATE CLOCK launchpad_withdraw_217_before 1237506575
// Launchpad Numerics CollectDepositGns call=217/256
// - Gas Used: 7533392
// - Storage Diff: -5397
// - CPU Cycles: 6555308
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_217_after 1237506575
// STATE CLOCK launchpad_withdraw_218_before 1237506580
// Launchpad Numerics CollectDepositGns call=218/256
// - Gas Used: 7433813
// - Storage Diff: -1916
// - CPU Cycles: 6466933
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_218_after 1237506580
// STATE CLOCK launchpad_withdraw_219_before 1237506585
// Launchpad Numerics CollectDepositGns call=219/256
// - Gas Used: 7432122
// - Storage Diff: -1916
// - CPU Cycles: 6466853
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_219_after 1237506585
// STATE CLOCK launchpad_withdraw_220_before 1237506590
// Launchpad Numerics CollectDepositGns call=220/256
// - Gas Used: 7439368
// - Storage Diff: -1916
// - CPU Cycles: 6475710
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_220_after 1237506590
// STATE CLOCK launchpad_withdraw_221_before 1237506595
// Launchpad Numerics CollectDepositGns call=221/256
// - Gas Used: 7437680
// - Storage Diff: -1916
// - CPU Cycles: 6475633
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_221_after 1237506595
// STATE CLOCK launchpad_withdraw_222_before 1237506600
// Launchpad Numerics CollectDepositGns call=222/256
// - Gas Used: 7436724
// - Storage Diff: -1916
// - CPU Cycles: 6476288
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_222_after 1237506600
// STATE CLOCK launchpad_withdraw_223_before 1237506605
// Launchpad Numerics CollectDepositGns call=223/256
// - Gas Used: 7434298
// - Storage Diff: -1916
// - CPU Cycles: 6475473
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_223_after 1237506605
// STATE CLOCK launchpad_withdraw_224_before 1237506610
// Launchpad Numerics CollectDepositGns call=224/256
// - Gas Used: 7433342
// - Storage Diff: -1916
// - CPU Cycles: 6476128
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_224_after 1237506610
// STATE CLOCK launchpad_withdraw_225_before 1237506615
// Launchpad Numerics CollectDepositGns call=225/256
// - Gas Used: 7548455
// - Storage Diff: -1880
// - CPU Cycles: 6556427
// - Realm gno.land/r/gnoswap/launchpad: -1880
// STATE CLOCK launchpad_withdraw_225_after 1237506615
// STATE CLOCK launchpad_withdraw_226_before 1237506620
// Launchpad Numerics CollectDepositGns call=226/256
// - Gas Used: 7547499
// - Storage Diff: -1916
// - CPU Cycles: 6557082
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_226_after 1237506620
// STATE CLOCK launchpad_withdraw_227_before 1237506625
// Launchpad Numerics CollectDepositGns call=227/256
// - Gas Used: 7544335
// - Storage Diff: -1916
// - CPU Cycles: 6555529
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_227_after 1237506625
// STATE CLOCK launchpad_withdraw_228_before 1237506630
// Launchpad Numerics CollectDepositGns call=228/256
// - Gas Used: 7543379
// - Storage Diff: -1916
// - CPU Cycles: 6556184
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_228_after 1237506630
// STATE CLOCK launchpad_withdraw_229_before 1237506635
// Launchpad Numerics CollectDepositGns call=229/256
// - Gas Used: 7541688
// - Storage Diff: -1916
// - CPU Cycles: 6556104
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_229_after 1237506635
// STATE CLOCK launchpad_withdraw_230_before 1237506640
// Launchpad Numerics CollectDepositGns call=230/256
// - Gas Used: 7539997
// - Storage Diff: -1916
// - CPU Cycles: 6556024
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_230_after 1237506640
// STATE CLOCK launchpad_withdraw_231_before 1237506645
// Launchpad Numerics CollectDepositGns call=231/256
// - Gas Used: 7542722
// - Storage Diff: -5243
// - CPU Cycles: 6566330
// - Realm gno.land/r/gnoswap/launchpad: -5243
// STATE CLOCK launchpad_withdraw_231_after 1237506645
// STATE CLOCK launchpad_withdraw_232_before 1237506650
// Launchpad Numerics CollectDepositGns call=232/256
// - Gas Used: 7432283
// - Storage Diff: -1916
// - CPU Cycles: 6465424
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_232_after 1237506650
// STATE CLOCK launchpad_withdraw_233_before 1237506655
// Launchpad Numerics CollectDepositGns call=233/256
// - Gas Used: 7410531
// - Storage Diff: -1911
// - CPU Cycles: 6445268
// - Realm gno.land/r/gnoswap/gov/xgns: 5
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_233_after 1237506655
// STATE CLOCK launchpad_withdraw_234_before 1237506660
// Launchpad Numerics CollectDepositGns call=234/256
// - Gas Used: 7523569
// - Storage Diff: -1910
// - CPU Cycles: 6445923
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_234_after 1237506660
// STATE CLOCK launchpad_withdraw_235_before 1237506665
// Launchpad Numerics CollectDepositGns call=235/256
// - Gas Used: 7521878
// - Storage Diff: -1910
// - CPU Cycles: 6445843
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_235_after 1237506665
// STATE CLOCK launchpad_withdraw_236_before 1237506670
// Launchpad Numerics CollectDepositGns call=236/256
// - Gas Used: 7520922
// - Storage Diff: -1910
// - CPU Cycles: 6446498
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_236_after 1237506670
// STATE CLOCK launchpad_withdraw_237_before 1237506675
// Launchpad Numerics CollectDepositGns call=237/256
// - Gas Used: 7518496
// - Storage Diff: -1910
// - CPU Cycles: 6445683
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_237_after 1237506675
// STATE CLOCK launchpad_withdraw_238_before 1237506680
// Launchpad Numerics CollectDepositGns call=238/256
// - Gas Used: 7517540
// - Storage Diff: -1910
// - CPU Cycles: 6446338
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_238_after 1237506680
// STATE CLOCK launchpad_withdraw_239_before 1237506685
// Launchpad Numerics CollectDepositGns call=239/256
// - Gas Used: 7626351
// - Storage Diff: -1910
// - CPU Cycles: 6526317
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_239_after 1237506685
// STATE CLOCK launchpad_withdraw_240_before 1237506690
// Launchpad Numerics CollectDepositGns call=240/256
// - Gas Used: 7643407
// - Storage Diff: -1909
// - CPU Cycles: 6543376
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_240_after 1237506690
// STATE CLOCK launchpad_withdraw_241_before 1237506695
// Launchpad Numerics CollectDepositGns call=241/256
// - Gas Used: 7624413
// - Storage Diff: -9082
// - CPU Cycles: 6544848
// - Realm gno.land/r/gnoswap/launchpad: -9082
// STATE CLOCK launchpad_withdraw_241_after 1237506695
// STATE CLOCK launchpad_withdraw_242_before 1237506700
// Launchpad Numerics CollectDepositGns call=242/256
// - Gas Used: 7459190
// - Storage Diff: -1909
// - CPU Cycles: 6385832
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_242_after 1237506700
// STATE CLOCK launchpad_withdraw_243_before 1237506705
// Launchpad Numerics CollectDepositGns call=243/256
// - Gas Used: 7458237
// - Storage Diff: -1909
// - CPU Cycles: 6386487
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_243_after 1237506705
// STATE CLOCK launchpad_withdraw_244_before 1237506710
// Launchpad Numerics CollectDepositGns call=244/256
// - Gas Used: 7455814
// - Storage Diff: -1909
// - CPU Cycles: 6385672
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_244_after 1237506710
// STATE CLOCK launchpad_withdraw_245_before 1237506715
// Launchpad Numerics CollectDepositGns call=245/256
// - Gas Used: 7454861
// - Storage Diff: -1909
// - CPU Cycles: 6386327
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_245_after 1237506715
// STATE CLOCK launchpad_withdraw_246_before 1237506720
// Launchpad Numerics CollectDepositGns call=246/256
// - Gas Used: 7453173
// - Storage Diff: -1909
// - CPU Cycles: 6386247
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_246_after 1237506720
// STATE CLOCK launchpad_withdraw_247_before 1237506725
// Launchpad Numerics CollectDepositGns call=247/256
// - Gas Used: 7341019
// - Storage Diff: -1916
// - CPU Cycles: 6391303
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_247_after 1237506725
// STATE CLOCK launchpad_withdraw_248_before 1237506730
// Launchpad Numerics CollectDepositGns call=248/256
// - Gas Used: 7339040
// - Storage Diff: -1916
// - CPU Cycles: 6390935
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_248_after 1237506730
// STATE CLOCK launchpad_withdraw_249_before 1237506735
// Launchpad Numerics CollectDepositGns call=249/256
// - Gas Used: 7328409
// - Storage Diff: -1916
// - CPU Cycles: 6381915
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_249_after 1237506735
// STATE CLOCK launchpad_withdraw_250_before 1237506740
// Launchpad Numerics CollectDepositGns call=250/256
// - Gas Used: 7315530
// - Storage Diff: -1916
// - CPU Cycles: 6370647
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_250_after 1237506740
// STATE CLOCK launchpad_withdraw_251_before 1237506745
// Launchpad Numerics CollectDepositGns call=251/256
// - Gas Used: 7313107
// - Storage Diff: -1916
// - CPU Cycles: 6369835
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_251_after 1237506745
// STATE CLOCK launchpad_withdraw_252_before 1237506750
// Launchpad Numerics CollectDepositGns call=252/256
// - Gas Used: 7312151
// - Storage Diff: -1916
// - CPU Cycles: 6370490
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_252_after 1237506750
// STATE CLOCK launchpad_withdraw_253_before 1237506755
// Launchpad Numerics CollectDepositGns call=253/256
// - Gas Used: 7310460
// - Storage Diff: -1916
// - CPU Cycles: 6370410
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_253_after 1237506755
// STATE CLOCK launchpad_withdraw_254_before 1237506760
// Launchpad Numerics CollectDepositGns call=254/256
// - Gas Used: 7295379
// - Storage Diff: -1916
// - CPU Cycles: 6356940
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_254_after 1237506760
// STATE CLOCK launchpad_withdraw_255_before 1237506765
// Launchpad Numerics CollectDepositGns call=255/256
// - Gas Used: 7294423
// - Storage Diff: -1916
// - CPU Cycles: 6357595
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_255_after 1237506765
// STATE CLOCK launchpad_withdraw_256_before 1237506770
// Launchpad Numerics CollectDepositGns call=256/256
// - Gas Used: 7273131
// - Storage Diff: -8448
// - CPU Cycles: 6243335
// - Realm gno.land/r/gnoswap/gns: -2055
// - Realm gno.land/r/gnoswap/gov/xgns: -1039
// - Realm gno.land/r/gnoswap/launchpad: -5354
// STATE CLOCK launchpad_withdraw_256_after 1237506770
// STATE launchpad-numerics phase=withdrawn-stage-256 global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=256000000 tier_deposit_count=256 tier_withdraw_count=256 tier_collected=249999871 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=249999871 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE launchpad-numerics phase=withdrawn-final-zero-active global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=256000000 tier_deposit_count=256 tier_withdraw_count=256 tier_collected=249999871 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=249999871 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_refund_before 1250465495
// Launchpad Numerics TransferLeftFromProjectByAdmin
// - Gas Used: 1397082
// - Storage Diff: 27
// - CPU Cycles: 1252349
// - Realm gno.land/r/gnoswap/launchpad: 21
// - Realm gno.land/r/onbloc/obl: 6
// STATE CLOCK launchpad_refund_after 1250465495
// STATE launchpad-numerics phase=refunded-final-zero-active global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=256000000 tier_deposit_count=256 tier_withdraw_count=256 tier_collected=250000000 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=249999871 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=0 record_amount=0 record_tier=0 record_created_height=-1 record_created_offset=-1 record_end_offset=-1 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
