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
// - Gas Used: 6764897
// - Storage Diff: 28412
// - CPU Cycles: 4949931
// - Realm gno.land/r/gnoswap/launchpad: 25959
// - Realm gno.land/r/gnoswap/launchpad/v1: 419
// - Realm gno.land/r/onbloc/obl: 2034
// STATE CLOCK launchpad_create_project_after 1234567890
// STATE launchpad-numerics phase=created global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=0 tier_total_withdraw=0 tier_deposit_count=0 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=0 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=-1234913490 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=0 record_amount=0 record_tier=0 record_created_height=-1 record_created_offset=-1 record_end_offset=-1 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=1/256_before 1234913495
// Launchpad Numerics DepositGns call=1/256
// - Gas Used: 6438341
// - Storage Diff: 27008
// - CPU Cycles: 4199160
// - Realm gno.land/r/gnoswap/gns: 2059
// - Realm gno.land/r/gnoswap/gov/staker: 14243
// - Realm gno.land/r/gnoswap/gov/xgns: 1043
// - Realm gno.land/r/gnoswap/launchpad: 9663
// STATE CLOCK launchpad_deposit_call=1/256_after 1234913495
// STATE launchpad-numerics phase=deposited-stage-1 global_staked=1000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=1000000 tier_total_withdraw=0 tier_deposit_count=1 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=0 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=1000000 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=-1234913490 manager_accumulated_distribute=0 manager_rewards=1 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=2/256_before 1234913500
// Launchpad Numerics DepositGns call=2/256
// - Gas Used: 6026452
// - Storage Diff: 3709
// - CPU Cycles: 5219420
// - Realm gno.land/r/gnoswap/gov/staker: 96
// - Realm gno.land/r/gnoswap/launchpad: 3613
// STATE CLOCK launchpad_deposit_call=2/256_after 1234913500
// STATE CLOCK launchpad_deposit_call=3/256_before 1234913505
// Launchpad Numerics DepositGns call=3/256
// - Gas Used: 6020744
// - Storage Diff: 3568
// - CPU Cycles: 5217826
// - Realm gno.land/r/gnoswap/gns: 3
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=3/256_after 1234913505
// STATE CLOCK launchpad_deposit_call=4/256_before 1234913510
// Launchpad Numerics DepositGns call=4/256
// - Gas Used: 6027164
// - Storage Diff: 3567
// - CPU Cycles: 5223298
// - Realm gno.land/r/gnoswap/gns: 2
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=4/256_after 1234913510
// STATE CLOCK launchpad_deposit_call=5/256_before 1234913515
// Launchpad Numerics DepositGns call=5/256
// - Gas Used: 6029080
// - Storage Diff: 3565
// - CPU Cycles: 5224272
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=5/256_after 1234913515
// STATE CLOCK launchpad_deposit_call=6/256_before 1234913520
// Launchpad Numerics DepositGns call=6/256
// - Gas Used: 6028561
// - Storage Diff: 3565
// - CPU Cycles: 5222811
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=6/256_after 1234913520
// STATE CLOCK launchpad_deposit_call=7/256_before 1234913525
// Launchpad Numerics DepositGns call=7/256
// - Gas Used: 6030964
// - Storage Diff: 3565
// - CPU Cycles: 5224272
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=7/256_after 1234913525
// STATE CLOCK launchpad_deposit_call=8/256_before 1234913530
// Launchpad Numerics DepositGns call=8/256
// - Gas Used: 6037378
// - Storage Diff: 3565
// - CPU Cycles: 5229744
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=8/256_after 1234913530
// STATE CLOCK launchpad_deposit_call=9/256_before 1234913535
// Launchpad Numerics DepositGns call=9/256
// - Gas Used: 6038807
// - Storage Diff: 3565
// - CPU Cycles: 5230231
// - Realm gno.land/r/gnoswap/launchpad: 3565
// STATE CLOCK launchpad_deposit_call=9/256_after 1234913535
// STATE CLOCK launchpad_deposit_call=10/256_before 1234913540
// Launchpad Numerics DepositGns call=10/256
// - Gas Used: 6070956
// - Storage Diff: 3664
// - CPU Cycles: 5242612
// - Realm gno.land/r/gnoswap/launchpad: 3664
// STATE CLOCK launchpad_deposit_call=10/256_after 1234913540
// STATE CLOCK launchpad_deposit_call=11/256_before 1234913545
// Launchpad Numerics DepositGns call=11/256
// - Gas Used: 6065950
// - Storage Diff: 3568
// - CPU Cycles: 5236658
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=11/256_after 1234913545
// STATE CLOCK launchpad_deposit_call=12/256_before 1234913550
// Launchpad Numerics DepositGns call=12/256
// - Gas Used: 6072854
// - Storage Diff: 3568
// - CPU Cycles: 5242614
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=12/256_after 1234913550
// STATE CLOCK launchpad_deposit_call=13/256_before 1234913555
// Launchpad Numerics DepositGns call=13/256
// - Gas Used: 6074289
// - Storage Diff: 3568
// - CPU Cycles: 5243101
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=13/256_after 1234913555
// STATE CLOCK launchpad_deposit_call=14/256_before 1234913560
// Launchpad Numerics DepositGns call=14/256
// - Gas Used: 6075242
// - Storage Diff: 3568
// - CPU Cycles: 5243106
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=14/256_after 1234913560
// STATE CLOCK launchpad_deposit_call=15/256_before 1234913565
// Launchpad Numerics DepositGns call=15/256
// - Gas Used: 6076190
// - Storage Diff: 3568
// - CPU Cycles: 5243106
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=15/256_after 1234913565
// STATE CLOCK launchpad_deposit_call=16/256_before 1234913570
// Launchpad Numerics DepositGns call=16/256
// - Gas Used: 6077630
// - Storage Diff: 3568
// - CPU Cycles: 5243598
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=16/256_after 1234913570
// STATE CLOCK launchpad_deposit_call=17/256_before 1234913575
// Launchpad Numerics DepositGns call=17/256
// - Gas Used: 6365977
// - Storage Diff: 16742
// - CPU Cycles: 5464655
// - Realm gno.land/r/gnoswap/launchpad: 16742
// STATE CLOCK launchpad_deposit_call=17/256_after 1234913575
// STATE CLOCK launchpad_deposit_call=18/256_before 1234913580
// Launchpad Numerics DepositGns call=18/256
// - Gas Used: 6126062
// - Storage Diff: 3664
// - CPU Cycles: 5279722
// - Realm gno.land/r/gnoswap/launchpad: 3664
// STATE CLOCK launchpad_deposit_call=18/256_after 1234913580
// STATE CLOCK launchpad_deposit_call=19/256_before 1234913585
// Launchpad Numerics DepositGns call=19/256
// - Gas Used: 6118246
// - Storage Diff: 3568
// - CPU Cycles: 5270958
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=19/256_after 1234913585
// STATE CLOCK launchpad_deposit_call=20/256_before 1234913590
// Launchpad Numerics DepositGns call=20/256
// - Gas Used: 6125936
// - Storage Diff: 3568
// - CPU Cycles: 5280052
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=20/256_after 1234913590
// STATE CLOCK launchpad_deposit_call=21/256_before 1234913595
// Launchpad Numerics DepositGns call=21/256
// - Gas Used: 6126884
// - Storage Diff: 3568
// - CPU Cycles: 5280052
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=21/256_after 1234913595
// STATE CLOCK launchpad_deposit_call=22/256_before 1234913600
// Launchpad Numerics DepositGns call=22/256
// - Gas Used: 6122363
// - Storage Diff: 3568
// - CPU Cycles: 5274583
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=22/256_after 1234913600
// STATE CLOCK launchpad_deposit_call=23/256_before 1234913605
// Launchpad Numerics DepositGns call=23/256
// - Gas Used: 6129759
// - Storage Diff: 3568
// - CPU Cycles: 5281031
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=23/256_after 1234913605
// STATE CLOCK launchpad_deposit_call=24/256_before 1234913610
// Launchpad Numerics DepositGns call=24/256
// - Gas Used: 6130212
// - Storage Diff: 3568
// - CPU Cycles: 5280536
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=24/256_after 1234913610
// STATE CLOCK launchpad_deposit_call=25/256_before 1234913615
// Launchpad Numerics DepositGns call=25/256
// - Gas Used: 6431904
// - Storage Diff: 10260
// - CPU Cycles: 5530388
// - Realm gno.land/r/gnoswap/launchpad: 10260
// STATE CLOCK launchpad_deposit_call=25/256_after 1234913615
// STATE CLOCK launchpad_deposit_call=26/256_before 1234913620
// Launchpad Numerics DepositGns call=26/256
// - Gas Used: 6118836
// - Storage Diff: 3616
// - CPU Cycles: 5273606
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=26/256_after 1234913620
// STATE CLOCK launchpad_deposit_call=27/256_before 1234913625
// Launchpad Numerics DepositGns call=27/256
// - Gas Used: 6126227
// - Storage Diff: 3568
// - CPU Cycles: 5280049
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=27/256_after 1234913625
// STATE CLOCK launchpad_deposit_call=28/256_before 1234913630
// Launchpad Numerics DepositGns call=28/256
// - Gas Used: 6128154
// - Storage Diff: 3568
// - CPU Cycles: 5281028
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=28/256_after 1234913630
// STATE CLOCK launchpad_deposit_call=29/256_before 1234913635
// Launchpad Numerics DepositGns call=29/256
// - Gas Used: 6124346
// - Storage Diff: 3568
// - CPU Cycles: 5276272
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=29/256_after 1234913635
// STATE CLOCK launchpad_deposit_call=30/256_before 1234913640
// Launchpad Numerics DepositGns call=30/256
// - Gas Used: 6126557
// - Storage Diff: 3568
// - CPU Cycles: 5279887
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=30/256_after 1234913640
// STATE CLOCK launchpad_deposit_call=31/256_before 1234913645
// Launchpad Numerics DepositGns call=31/256
// - Gas Used: 6127994
// - Storage Diff: 3568
// - CPU Cycles: 5280376
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=31/256_after 1234913645
// STATE CLOCK launchpad_deposit_call=32/256_before 1234913650
// Launchpad Numerics DepositGns call=32/256
// - Gas Used: 6125652
// - Storage Diff: 3568
// - CPU Cycles: 5277086
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=32/256_after 1234913650
// STATE launchpad-numerics phase=deposited-stage-32 global_staked=32000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=32000000 tier_total_withdraw=0 tier_deposit_count=32 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=824982105611041150227923453007644893 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=32000000 manager_active_claimed=0 manager_active_debt=21148156285094389901994559640816115053000000 manager_window=2592000 manager_cursor_offset=160 manager_accumulated_distribute=0 manager_rewards=32 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69275 record_created_offset=160 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=33/256_before 1234913655
// Launchpad Numerics DepositGns call=33/256
// - Gas Used: 6434608
// - Storage Diff: 10248
// - CPU Cycles: 5531694
// - Realm gno.land/r/gnoswap/launchpad: 10248
// STATE CLOCK launchpad_deposit_call=33/256_after 1234913655
// STATE CLOCK launchpad_deposit_call=34/256_before 1234913660
// Launchpad Numerics DepositGns call=34/256
// - Gas Used: 6124499
// - Storage Diff: 3616
// - CPU Cycles: 5280379
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=34/256_after 1234913660
// STATE CLOCK launchpad_deposit_call=35/256_before 1234913665
// Launchpad Numerics DepositGns call=35/256
// - Gas Used: 6131408
// - Storage Diff: 3568
// - CPU Cycles: 5286340
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=35/256_after 1234913665
// STATE CLOCK launchpad_deposit_call=36/256_before 1234913670
// Launchpad Numerics DepositGns call=36/256
// - Gas Used: 6126887
// - Storage Diff: 3568
// - CPU Cycles: 5280871
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=36/256_after 1234913670
// STATE CLOCK launchpad_deposit_call=37/256_before 1234913675
// Launchpad Numerics DepositGns call=37/256
// - Gas Used: 6120178
// - Storage Diff: 3568
// - CPU Cycles: 5273214
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=37/256_after 1234913675
// STATE CLOCK launchpad_deposit_call=38/256_before 1234913680
// Launchpad Numerics DepositGns call=38/256
// - Gas Used: 6130465
// - Storage Diff: 3568
// - CPU Cycles: 5282553
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=38/256_after 1234913680
// STATE CLOCK launchpad_deposit_call=39/256_before 1234913685
// Launchpad Numerics DepositGns call=39/256
// - Gas Used: 6134726
// - Storage Diff: 3574
// - CPU Cycles: 5285848
// - Realm gno.land/r/gnoswap/gov/xgns: 6
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=39/256_after 1234913685
// STATE CLOCK launchpad_deposit_call=40/256_before 1234913690
// Launchpad Numerics DepositGns call=40/256
// - Gas Used: 6134626
// - Storage Diff: 3568
// - CPU Cycles: 5287152
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=40/256_after 1234913690
// STATE CLOCK launchpad_deposit_call=41/256_before 1234913695
// Launchpad Numerics DepositGns call=41/256
// - Gas Used: 6438041
// - Storage Diff: 10248
// - CPU Cycles: 5533711
// - Realm gno.land/r/gnoswap/launchpad: 10248
// STATE CLOCK launchpad_deposit_call=41/256_after 1234913695
// STATE CLOCK launchpad_deposit_call=42/256_before 1234913700
// Launchpad Numerics DepositGns call=42/256
// - Gas Used: 6123246
// - Storage Diff: 3616
// - CPU Cycles: 5280224
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=42/256_after 1234913700
// STATE CLOCK launchpad_deposit_call=43/256_before 1234913705
// Launchpad Numerics DepositGns call=43/256
// - Gas Used: 6125168
// - Storage Diff: 3568
// - CPU Cycles: 5281198
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=43/256_after 1234913705
// STATE CLOCK launchpad_deposit_call=44/256_before 1234913710
// Launchpad Numerics DepositGns call=44/256
// - Gas Used: 6130606
// - Storage Diff: 3568
// - CPU Cycles: 5285688
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=44/256_after 1234913710
// STATE CLOCK launchpad_deposit_call=45/256_before 1234913715
// Launchpad Numerics DepositGns call=45/256
// - Gas Used: 6132528
// - Storage Diff: 3568
// - CPU Cycles: 5286662
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=45/256_after 1234913715
// STATE CLOCK launchpad_deposit_call=46/256_before 1234913720
// Launchpad Numerics DepositGns call=46/256
// - Gas Used: 6132994
// - Storage Diff: 3568
// - CPU Cycles: 5286180
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=46/256_after 1234913720
// STATE CLOCK launchpad_deposit_call=47/256_before 1234913725
// Launchpad Numerics DepositGns call=47/256
// - Gas Used: 6133942
// - Storage Diff: 3568
// - CPU Cycles: 5286180
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=47/256_after 1234913725
// STATE CLOCK launchpad_deposit_call=48/256_before 1234913730
// Launchpad Numerics DepositGns call=48/256
// - Gas Used: 6135864
// - Storage Diff: 3568
// - CPU Cycles: 5287154
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=48/256_after 1234913730
// STATE CLOCK launchpad_deposit_call=49/256_before 1234913735
// Launchpad Numerics DepositGns call=49/256
// - Gas Used: 6443215
// - Storage Diff: 10248
// - CPU Cycles: 5537493
// - Realm gno.land/r/gnoswap/launchpad: 10248
// STATE CLOCK launchpad_deposit_call=49/256_after 1234913735
// STATE CLOCK launchpad_deposit_call=50/256_before 1234913740
// Launchpad Numerics DepositGns call=50/256
// - Gas Used: 6127438
// - Storage Diff: 3616
// - CPU Cycles: 5285526
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=50/256_after 1234913740
// STATE CLOCK launchpad_deposit_call=51/256_before 1234913745
// Launchpad Numerics DepositGns call=51/256
// - Gas Used: 6128875
// - Storage Diff: 3568
// - CPU Cycles: 5286015
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=51/256_after 1234913745
// STATE CLOCK launchpad_deposit_call=52/256_before 1234913750
// Launchpad Numerics DepositGns call=52/256
// - Gas Used: 6130315
// - Storage Diff: 3568
// - CPU Cycles: 5286507
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=52/256_after 1234913750
// STATE CLOCK launchpad_deposit_call=53/256_before 1234913755
// Launchpad Numerics DepositGns call=53/256
// - Gas Used: 6130782
// - Storage Diff: 3569
// - CPU Cycles: 5286020
// - Realm gno.land/r/gnoswap/gov/xgns: 1
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=53/256_after 1234913755
// STATE CLOCK launchpad_deposit_call=54/256_before 1234913760
// Launchpad Numerics DepositGns call=54/256
// - Gas Used: 6132710
// - Storage Diff: 3570
// - CPU Cycles: 5286994
// - Realm gno.land/r/gnoswap/gov/xgns: 2
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=54/256_after 1234913760
// STATE CLOCK launchpad_deposit_call=55/256_before 1234913765
// Launchpad Numerics DepositGns call=55/256
// - Gas Used: 6133658
// - Storage Diff: 3568
// - CPU Cycles: 5286994
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=55/256_after 1234913765
// STATE CLOCK launchpad_deposit_call=56/256_before 1234913770
// Launchpad Numerics DepositGns call=56/256
// - Gas Used: 6134611
// - Storage Diff: 3568
// - CPU Cycles: 5286999
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=56/256_after 1234913770
// STATE CLOCK launchpad_deposit_call=57/256_before 1234913775
// Launchpad Numerics DepositGns call=57/256
// - Gas Used: 6443983
// - Storage Diff: 10248
// - CPU Cycles: 5536851
// - Realm gno.land/r/gnoswap/launchpad: 10248
// STATE CLOCK launchpad_deposit_call=57/256_after 1234913775
// STATE CLOCK launchpad_deposit_call=58/256_before 1234913780
// Launchpad Numerics DepositGns call=58/256
// - Gas Used: 6129668
// - Storage Diff: 3616
// - CPU Cycles: 5286502
// - Realm gno.land/r/gnoswap/launchpad: 3616
// STATE CLOCK launchpad_deposit_call=58/256_after 1234913780
// STATE CLOCK launchpad_deposit_call=59/256_before 1234913785
// Launchpad Numerics DepositGns call=59/256
// - Gas Used: 6130129
// - Storage Diff: 3568
// - CPU Cycles: 5286015
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=59/256_after 1234913785
// STATE CLOCK launchpad_deposit_call=60/256_before 1234913790
// Launchpad Numerics DepositGns call=60/256
// - Gas Used: 6122612
// - Storage Diff: 3568
// - CPU Cycles: 5279902
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=60/256_after 1234913790
// STATE CLOCK launchpad_deposit_call=61/256_before 1234913795
// Launchpad Numerics DepositGns call=61/256
// - Gas Used: 6124536
// - Storage Diff: 3568
// - CPU Cycles: 5280878
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=61/256_after 1234913795
// STATE CLOCK launchpad_deposit_call=62/256_before 1234913800
// Launchpad Numerics DepositGns call=62/256
// - Gas Used: 6128150
// - Storage Diff: 3568
// - CPU Cycles: 5283544
// - Realm gno.land/r/gnoswap/launchpad: 3568
// STATE CLOCK launchpad_deposit_call=62/256_after 1234913800
// STATE CLOCK launchpad_deposit_call=63/256_before 1234913805
// Launchpad Numerics DepositGns call=63/256
// - Gas Used: 6132926
// - Storage Diff: 3584
// - CPU Cycles: 5287324
// - Realm gno.land/r/gnoswap/launchpad: 3584
// STATE CLOCK launchpad_deposit_call=63/256_after 1234913805
// STATE CLOCK launchpad_deposit_call=64/256_before 1234913810
// Launchpad Numerics DepositGns call=64/256
// - Gas Used: 6133442
// - Storage Diff: 3591
// - CPU Cycles: 5286832
// - Realm gno.land/r/gnoswap/launchpad: 3591
// STATE CLOCK launchpad_deposit_call=64/256_after 1234913810
// STATE CLOCK launchpad_deposit_call=65/256_before 1234913815
// Launchpad Numerics DepositGns call=65/256
// - Gas Used: 6446424
// - Storage Diff: 10299
// - CPU Cycles: 5537660
// - Realm gno.land/r/gnoswap/launchpad: 10299
// STATE CLOCK launchpad_deposit_call=65/256_after 1234913815
// STATE CLOCK launchpad_deposit_call=66/256_before 1234913820
// Launchpad Numerics DepositGns call=66/256
// - Gas Used: 6135050
// - Storage Diff: 3637
// - CPU Cycles: 5292793
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=66/256_after 1234913820
// STATE CLOCK launchpad_deposit_call=67/256_before 1234913825
// Launchpad Numerics DepositGns call=67/256
// - Gas Used: 6136004
// - Storage Diff: 3589
// - CPU Cycles: 5292793
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=67/256_after 1234913825
// STATE CLOCK launchpad_deposit_call=68/256_before 1234913830
// Launchpad Numerics DepositGns call=68/256
// - Gas Used: 6131489
// - Storage Diff: 3589
// - CPU Cycles: 5287324
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=68/256_after 1234913830
// STATE CLOCK launchpad_deposit_call=69/256_before 1234913835
// Launchpad Numerics DepositGns call=69/256
// - Gas Used: 6131469
// - Storage Diff: 3589
// - CPU Cycles: 5286350
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=69/256_after 1234913835
// STATE CLOCK launchpad_deposit_call=70/256_before 1234913840
// Launchpad Numerics DepositGns call=70/256
// - Gas Used: 6135865
// - Storage Diff: 3589
// - CPU Cycles: 5292144
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=70/256_after 1234913840
// STATE CLOCK launchpad_deposit_call=71/256_before 1234913845
// Launchpad Numerics DepositGns call=71/256
// - Gas Used: 6136821
// - Storage Diff: 3589
// - CPU Cycles: 5292146
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=71/256_after 1234913845
// STATE CLOCK launchpad_deposit_call=72/256_before 1234913850
// Launchpad Numerics DepositGns call=72/256
// - Gas Used: 6138754
// - Storage Diff: 3589
// - CPU Cycles: 5293125
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=72/256_after 1234913850
// STATE CLOCK launchpad_deposit_call=73/256_before 1234913855
// Launchpad Numerics DepositGns call=73/256
// - Gas Used: 6454347
// - Storage Diff: 10291
// - CPU Cycles: 5543951
// - Realm gno.land/r/gnoswap/launchpad: 10291
// STATE CLOCK launchpad_deposit_call=73/256_after 1234913855
// STATE CLOCK launchpad_deposit_call=74/256_before 1234913860
// Launchpad Numerics DepositGns call=74/256
// - Gas Used: 6127848
// - Storage Diff: 3637
// - CPU Cycles: 5286677
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=74/256_after 1234913860
// STATE CLOCK launchpad_deposit_call=75/256_before 1234913865
// Launchpad Numerics DepositGns call=75/256
// - Gas Used: 6129289
// - Storage Diff: 3589
// - CPU Cycles: 5287164
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=75/256_after 1234913865
// STATE CLOCK launchpad_deposit_call=76/256_before 1234913870
// Launchpad Numerics DepositGns call=76/256
// - Gas Used: 6135712
// - Storage Diff: 3589
// - CPU Cycles: 5292633
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=76/256_after 1234913870
// STATE CLOCK launchpad_deposit_call=77/256_before 1234913875
// Launchpad Numerics DepositGns call=77/256
// - Gas Used: 6136666
// - Storage Diff: 3589
// - CPU Cycles: 5292633
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=77/256_after 1234913875
// STATE CLOCK launchpad_deposit_call=78/256_before 1234913880
// Launchpad Numerics DepositGns call=78/256
// - Gas Used: 6137133
// - Storage Diff: 3589
// - CPU Cycles: 5292146
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=78/256_after 1234913880
// STATE CLOCK launchpad_deposit_call=79/256_before 1234913885
// Launchpad Numerics DepositGns call=79/256
// - Gas Used: 6138574
// - Storage Diff: 3589
// - CPU Cycles: 5292633
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=79/256_after 1234913885
// STATE CLOCK launchpad_deposit_call=80/256_before 1234913890
// Launchpad Numerics DepositGns call=80/256
// - Gas Used: 6137506
// - Storage Diff: 3589
// - CPU Cycles: 5292963
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=80/256_after 1234913890
// STATE CLOCK launchpad_deposit_call=81/256_before 1234913895
// Launchpad Numerics DepositGns call=81/256
// - Gas Used: 6454710
// - Storage Diff: 10291
// - CPU Cycles: 5542817
// - Realm gno.land/r/gnoswap/launchpad: 10291
// STATE CLOCK launchpad_deposit_call=81/256_after 1234913895
// STATE CLOCK launchpad_deposit_call=82/256_before 1234913900
// Launchpad Numerics DepositGns call=82/256
// - Gas Used: 6126590
// - Storage Diff: 3637
// - CPU Cycles: 5286517
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=82/256_after 1234913900
// STATE CLOCK launchpad_deposit_call=83/256_before 1234913905
// Launchpad Numerics DepositGns call=83/256
// - Gas Used: 6123760
// - Storage Diff: 3589
// - CPU Cycles: 5282733
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=83/256_after 1234913905
// STATE CLOCK launchpad_deposit_call=84/256_before 1234913910
// Launchpad Numerics DepositGns call=84/256
// - Gas Used: 6134457
// - Storage Diff: 3589
// - CPU Cycles: 5292476
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=84/256_after 1234913910
// STATE CLOCK launchpad_deposit_call=85/256_before 1234913915
// Launchpad Numerics DepositGns call=85/256
// - Gas Used: 6132118
// - Storage Diff: 3589
// - CPU Cycles: 5289183
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=85/256_after 1234913915
// STATE CLOCK launchpad_deposit_call=86/256_before 1234913920
// Launchpad Numerics DepositGns call=86/256
// - Gas Used: 6136854
// - Storage Diff: 3589
// - CPU Cycles: 5292965
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=86/256_after 1234913920
// STATE CLOCK launchpad_deposit_call=87/256_before 1234913925
// Launchpad Numerics DepositGns call=87/256
// - Gas Used: 6136834
// - Storage Diff: 3589
// - CPU Cycles: 5291991
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=87/256_after 1234913925
// STATE CLOCK launchpad_deposit_call=88/256_before 1234913930
// Launchpad Numerics DepositGns call=88/256
// - Gas Used: 6138275
// - Storage Diff: 3589
// - CPU Cycles: 5292478
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=88/256_after 1234913930
// STATE CLOCK launchpad_deposit_call=89/256_before 1234913935
// Launchpad Numerics DepositGns call=89/256
// - Gas Used: 6457599
// - Storage Diff: 10291
// - CPU Cycles: 5544278
// - Realm gno.land/r/gnoswap/launchpad: 10291
// STATE CLOCK launchpad_deposit_call=89/256_after 1234913935
// STATE CLOCK launchpad_deposit_call=90/256_before 1234913940
// Launchpad Numerics DepositGns call=90/256
// - Gas Used: 6123770
// - Storage Diff: 3650
// - CPU Cycles: 5284756
// - Realm gno.land/r/gnoswap/gns: 13
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=90/256_after 1234913940
// STATE CLOCK launchpad_deposit_call=91/256_before 1234913945
// Launchpad Numerics DepositGns call=91/256
// - Gas Used: 6123795
// - Storage Diff: 3604
// - CPU Cycles: 5283782
// - Realm gno.land/r/gnoswap/gns: 15
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=91/256_after 1234913945
// STATE CLOCK launchpad_deposit_call=92/256_before 1234913950
// Launchpad Numerics DepositGns call=92/256
// - Gas Used: 6121454
// - Storage Diff: 3589
// - CPU Cycles: 5280487
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=92/256_after 1234913950
// STATE CLOCK launchpad_deposit_call=93/256_before 1234913955
// Launchpad Numerics DepositGns call=93/256
// - Gas Used: 6127746
// - Storage Diff: 3589
// - CPU Cycles: 5285825
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=93/256_after 1234913955
// STATE CLOCK launchpad_deposit_call=94/256_before 1234913960
// Launchpad Numerics DepositGns call=94/256
// - Gas Used: 6127726
// - Storage Diff: 3589
// - CPU Cycles: 5284851
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=94/256_after 1234913960
// STATE CLOCK launchpad_deposit_call=95/256_before 1234913965
// Launchpad Numerics DepositGns call=95/256
// - Gas Used: 6123831
// - Storage Diff: 3589
// - CPU Cycles: 5280002
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=95/256_after 1234913965
// STATE CLOCK launchpad_deposit_call=96/256_before 1234913970
// Launchpad Numerics DepositGns call=96/256
// - Gas Used: 6136082
// - Storage Diff: 3589
// - CPU Cycles: 5291299
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=96/256_after 1234913970
// STATE CLOCK launchpad_deposit_call=97/256_before 1234913975
// Launchpad Numerics DepositGns call=97/256
// - Gas Used: 6382332
// - Storage Diff: 10011
// - CPU Cycles: 5468339
// - Realm gno.land/r/gnoswap/launchpad: 10011
// STATE CLOCK launchpad_deposit_call=97/256_after 1234913975
// STATE CLOCK launchpad_deposit_call=98/256_before 1234913980
// Launchpad Numerics DepositGns call=98/256
// - Gas Used: 6106077
// - Storage Diff: 3637
// - CPU Cycles: 5272442
// - Realm gno.land/r/gnoswap/launchpad: 3637
// STATE CLOCK launchpad_deposit_call=98/256_after 1234913980
// STATE CLOCK launchpad_deposit_call=99/256_before 1234913985
// Launchpad Numerics DepositGns call=99/256
// - Gas Used: 6113479
// - Storage Diff: 3589
// - CPU Cycles: 5278890
// - Realm gno.land/r/gnoswap/launchpad: 3589
// STATE CLOCK launchpad_deposit_call=99/256_after 1234913985
// STATE CLOCK launchpad_deposit_call=100/256_before 1234913990
// Launchpad Numerics DepositGns call=100/256
// - Gas Used: 6177180
// - Storage Diff: 3574
// - CPU Cycles: 5321863
// - Realm gno.land/r/gnoswap/launchpad: 3574
// STATE CLOCK launchpad_deposit_call=100/256_after 1234913990
// STATE CLOCK launchpad_deposit_call=101/256_before 1234913995
// Launchpad Numerics DepositGns call=101/256
// - Gas Used: 6177048
// - Storage Diff: 3550
// - CPU Cycles: 5320891
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=101/256_after 1234913995
// STATE CLOCK launchpad_deposit_call=102/256_before 1234914000
// Launchpad Numerics DepositGns call=102/256
// - Gas Used: 6184825
// - Storage Diff: 3550
// - CPU Cycles: 5327828
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=102/256_after 1234914000
// STATE CLOCK launchpad_deposit_call=103/256_before 1234914005
// Launchpad Numerics DepositGns call=103/256
// - Gas Used: 6179707
// - Storage Diff: 3550
// - CPU Cycles: 5321870
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=103/256_after 1234914005
// STATE CLOCK launchpad_deposit_call=104/256_before 1234914010
// Launchpad Numerics DepositGns call=104/256
// - Gas Used: 6180547
// - Storage Diff: 3550
// - CPU Cycles: 5321870
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=104/256_after 1234914010
// STATE CLOCK launchpad_deposit_call=105/256_before 1234914015
// Launchpad Numerics DepositGns call=105/256
// - Gas Used: 6186853
// - Storage Diff: 3550
// - CPU Cycles: 5327336
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=105/256_after 1234914015
// STATE CLOCK launchpad_deposit_call=106/256_before 1234914020
// Launchpad Numerics DepositGns call=106/256
// - Gas Used: 6187206
// - Storage Diff: 3550
// - CPU Cycles: 5326849
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=106/256_after 1234914020
// STATE CLOCK launchpad_deposit_call=107/256_before 1234914025
// Launchpad Numerics DepositGns call=107/256
// - Gas Used: 6189512
// - Storage Diff: 3550
// - CPU Cycles: 5328315
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=107/256_after 1234914025
// STATE CLOCK launchpad_deposit_call=108/256_before 1234914030
// Launchpad Numerics DepositGns call=108/256
// - Gas Used: 6498524
// - Storage Diff: 10036
// - CPU Cycles: 5579221
// - Realm gno.land/r/gnoswap/launchpad: 10036
// STATE CLOCK launchpad_deposit_call=108/256_after 1234914030
// STATE CLOCK launchpad_deposit_call=109/256_before 1234914035
// Launchpad Numerics DepositGns call=109/256
// - Gas Used: 6178484
// - Storage Diff: 3640
// - CPU Cycles: 5322357
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=109/256_after 1234914035
// STATE CLOCK launchpad_deposit_call=110/256_before 1234914040
// Launchpad Numerics DepositGns call=110/256
// - Gas Used: 6173634
// - Storage Diff: 3592
// - CPU Cycles: 5318905
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=110/256_after 1234914040
// STATE CLOCK launchpad_deposit_call=111/256_before 1234914045
// Launchpad Numerics DepositGns call=111/256
// - Gas Used: 6180062
// - Storage Diff: 3592
// - CPU Cycles: 5324373
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=111/256_after 1234914045
// STATE CLOCK launchpad_deposit_call=112/256_before 1234914050
// Launchpad Numerics DepositGns call=112/256
// - Gas Used: 6184804
// - Storage Diff: 3592
// - CPU Cycles: 5328155
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=112/256_after 1234914050
// STATE CLOCK launchpad_deposit_call=113/256_before 1234914055
// Launchpad Numerics DepositGns call=113/256
// - Gas Used: 6186256
// - Storage Diff: 3592
// - CPU Cycles: 5328647
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=113/256_after 1234914055
// STATE CLOCK launchpad_deposit_call=114/256_before 1234914060
// Launchpad Numerics DepositGns call=114/256
// - Gas Used: 6185755
// - Storage Diff: 3592
// - CPU Cycles: 5327186
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=114/256_after 1234914060
// STATE CLOCK launchpad_deposit_call=115/256_before 1234914065
// Launchpad Numerics DepositGns call=115/256
// - Gas Used: 6188176
// - Storage Diff: 3592
// - CPU Cycles: 5328647
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=115/256_after 1234914065
// STATE CLOCK launchpad_deposit_call=116/256_before 1234914070
// Launchpad Numerics DepositGns call=116/256
// - Gas Used: 6522191
// - Storage Diff: 10296
// - CPU Cycles: 5581626
// - Realm gno.land/r/gnoswap/launchpad: 10296
// STATE CLOCK launchpad_deposit_call=116/256_after 1234914070
// STATE CLOCK launchpad_deposit_call=117/256_before 1234914075
// Launchpad Numerics DepositGns call=117/256
// - Gas Used: 6176738
// - Storage Diff: 3640
// - CPU Cycles: 5321715
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=117/256_after 1234914075
// STATE CLOCK launchpad_deposit_call=118/256_before 1234914080
// Launchpad Numerics DepositGns call=118/256
// - Gas Used: 6178185
// - Storage Diff: 3592
// - CPU Cycles: 5322202
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=118/256_after 1234914080
// STATE CLOCK launchpad_deposit_call=119/256_before 1234914085
// Launchpad Numerics DepositGns call=119/256
// - Gas Used: 6185098
// - Storage Diff: 3592
// - CPU Cycles: 5328155
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=119/256_after 1234914085
// STATE CLOCK launchpad_deposit_call=120/256_before 1234914090
// Launchpad Numerics DepositGns call=120/256
// - Gas Used: 6184030
// - Storage Diff: 3592
// - CPU Cycles: 5328485
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=120/256_after 1234914090
// STATE CLOCK launchpad_deposit_call=121/256_before 1234914095
// Launchpad Numerics DepositGns call=121/256
// - Gas Used: 6184505
// - Storage Diff: 3592
// - CPU Cycles: 5328000
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=121/256_after 1234914095
// STATE CLOCK launchpad_deposit_call=122/256_before 1234914100
// Launchpad Numerics DepositGns call=122/256
// - Gas Used: 6185463
// - Storage Diff: 3592
// - CPU Cycles: 5327998
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=122/256_after 1234914100
// STATE CLOCK launchpad_deposit_call=123/256_before 1234914105
// Launchpad Numerics DepositGns call=123/256
// - Gas Used: 6186915
// - Storage Diff: 3592
// - CPU Cycles: 5328490
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=123/256_after 1234914105
// STATE CLOCK launchpad_deposit_call=124/256_before 1234914110
// Launchpad Numerics DepositGns call=124/256
// - Gas Used: 6523464
// - Storage Diff: 10296
// - CPU Cycles: 5581471
// - Realm gno.land/r/gnoswap/launchpad: 10296
// STATE CLOCK launchpad_deposit_call=124/256_after 1234914110
// STATE CLOCK launchpad_deposit_call=125/256_before 1234914115
// Launchpad Numerics DepositGns call=125/256
// - Gas Used: 6182406
// - Storage Diff: 3640
// - CPU Cycles: 5328487
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=125/256_after 1234914115
// STATE CLOCK launchpad_deposit_call=126/256_before 1234914120
// Launchpad Numerics DepositGns call=126/256
// - Gas Used: 6180071
// - Storage Diff: 3592
// - CPU Cycles: 5325192
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=126/256_after 1234914120
// STATE CLOCK launchpad_deposit_call=127/256_before 1234914125
// Launchpad Numerics DepositGns call=127/256
// - Gas Used: 6181036
// - Storage Diff: 3592
// - CPU Cycles: 5325197
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=127/256_after 1234914125
// STATE CLOCK launchpad_deposit_call=128/256_before 1234914130
// Launchpad Numerics DepositGns call=128/256
// - Gas Used: 6185291
// - Storage Diff: 3592
// - CPU Cycles: 5328492
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=128/256_after 1234914130
// STATE launchpad-numerics phase=deposited-stage-128 global_staked=128000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=128000000 tier_total_withdraw=0 tier_deposit_count=128 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1054411681821579576241805020507828326 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=128000000 manager_active_claimed=0 manager_active_debt=113959610895326478137755079203287942984000000 manager_window=2592000 manager_cursor_offset=640 manager_accumulated_distribute=0 manager_rewards=128 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69371 record_created_offset=640 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=129/256_before 1234914135
// Launchpad Numerics DepositGns call=129/256
// - Gas Used: 6186251
// - Storage Diff: 3592
// - CPU Cycles: 5328492
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=129/256_after 1234914135
// STATE CLOCK launchpad_deposit_call=130/256_before 1234914140
// Launchpad Numerics DepositGns call=130/256
// - Gas Used: 6185183
// - Storage Diff: 3592
// - CPU Cycles: 5328822
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=130/256_after 1234914140
// STATE CLOCK launchpad_deposit_call=131/256_before 1234914145
// Launchpad Numerics DepositGns call=131/256
// - Gas Used: 6186140
// - Storage Diff: 3592
// - CPU Cycles: 5328819
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=131/256_after 1234914145
// STATE CLOCK launchpad_deposit_call=132/256_before 1234914150
// Launchpad Numerics DepositGns call=132/256
// - Gas Used: 6525219
// - Storage Diff: 10296
// - CPU Cycles: 5581798
// - Realm gno.land/r/gnoswap/launchpad: 10296
// STATE CLOCK launchpad_deposit_call=132/256_after 1234914150
// STATE CLOCK launchpad_deposit_call=133/256_before 1234914155
// Launchpad Numerics DepositGns call=133/256
// - Gas Used: 6181130
// - Storage Diff: 3640
// - CPU Cycles: 5328327
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=133/256_after 1234914155
// STATE CLOCK launchpad_deposit_call=134/256_before 1234914160
// Launchpad Numerics DepositGns call=134/256
// - Gas Used: 6181603
// - Storage Diff: 3592
// - CPU Cycles: 5327840
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=134/256_after 1234914160
// STATE CLOCK launchpad_deposit_call=135/256_before 1234914165
// Launchpad Numerics DepositGns call=135/256
// - Gas Used: 6177092
// - Storage Diff: 3592
// - CPU Cycles: 5322369
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=135/256_after 1234914165
// STATE CLOCK launchpad_deposit_call=136/256_before 1234914170
// Launchpad Numerics DepositGns call=136/256
// - Gas Used: 6177565
// - Storage Diff: 3592
// - CPU Cycles: 5321882
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=136/256_after 1234914170
// STATE CLOCK launchpad_deposit_call=137/256_before 1234914175
// Launchpad Numerics DepositGns call=137/256
// - Gas Used: 6184488
// - Storage Diff: 3592
// - CPU Cycles: 5327845
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=137/256_after 1234914175
// STATE CLOCK launchpad_deposit_call=138/256_before 1234914180
// Launchpad Numerics DepositGns call=138/256
// - Gas Used: 6185935
// - Storage Diff: 3592
// - CPU Cycles: 5328332
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=138/256_after 1234914180
// STATE CLOCK launchpad_deposit_call=139/256_before 1234914185
// Launchpad Numerics DepositGns call=139/256
// - Gas Used: 6185429
// - Storage Diff: 3592
// - CPU Cycles: 5326866
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=139/256_after 1234914185
// STATE CLOCK launchpad_deposit_call=140/256_before 1234914190
// Launchpad Numerics DepositGns call=140/256
// - Gas Used: 6921147
// - Storage Diff: 23858
// - CPU Cycles: 5918544
// - Realm gno.land/r/gnoswap/launchpad: 23858
// STATE CLOCK launchpad_deposit_call=140/256_after 1234914190
// STATE CLOCK launchpad_deposit_call=141/256_before 1234914195
// Launchpad Numerics DepositGns call=141/256
// - Gas Used: 6212042
// - Storage Diff: 3712
// - CPU Cycles: 5352841
// - Realm gno.land/r/gnoswap/launchpad: 3712
// STATE CLOCK launchpad_deposit_call=141/256_after 1234914195
// STATE CLOCK launchpad_deposit_call=142/256_before 1234914200
// Launchpad Numerics DepositGns call=142/256
// - Gas Used: 6209705
// - Storage Diff: 3592
// - CPU Cycles: 5349544
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=142/256_after 1234914200
// STATE CLOCK launchpad_deposit_call=143/256_before 1234914205
// Launchpad Numerics DepositGns call=143/256
// - Gas Used: 6220405
// - Storage Diff: 3592
// - CPU Cycles: 5359284
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=143/256_after 1234914205
// STATE CLOCK launchpad_deposit_call=144/256_before 1234914210
// Launchpad Numerics DepositGns call=144/256
// - Gas Used: 6221367
// - Storage Diff: 3592
// - CPU Cycles: 5359286
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=144/256_after 1234914210
// STATE CLOCK launchpad_deposit_call=145/256_before 1234914215
// Launchpad Numerics DepositGns call=145/256
// - Gas Used: 6222327
// - Storage Diff: 3592
// - CPU Cycles: 5359286
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=145/256_after 1234914215
// STATE CLOCK launchpad_deposit_call=146/256_before 1234914220
// Launchpad Numerics DepositGns call=146/256
// - Gas Used: 6222800
// - Storage Diff: 3592
// - CPU Cycles: 5358799
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=146/256_after 1234914220
// STATE CLOCK launchpad_deposit_call=147/256_before 1234914225
// Launchpad Numerics DepositGns call=147/256
// - Gas Used: 6224252
// - Storage Diff: 3592
// - CPU Cycles: 5359291
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=147/256_after 1234914225
// STATE CLOCK launchpad_deposit_call=148/256_before 1234914230
// Launchpad Numerics DepositGns call=148/256
// - Gas Used: 6546215
// - Storage Diff: 10270
// - CPU Cycles: 5611084
// - Realm gno.land/r/gnoswap/launchpad: 10270
// STATE CLOCK launchpad_deposit_call=148/256_after 1234914230
// STATE CLOCK launchpad_deposit_call=149/256_before 1234914235
// Launchpad Numerics DepositGns call=149/256
// - Gas Used: 6213783
// - Storage Diff: 3640
// - CPU Cycles: 5353328
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=149/256_after 1234914235
// STATE CLOCK launchpad_deposit_call=150/256_before 1234914240
// Launchpad Numerics DepositGns call=150/256
// - Gas Used: 6212223
// - Storage Diff: 3592
// - CPU Cycles: 5353166
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=150/256_after 1234914240
// STATE CLOCK launchpad_deposit_call=151/256_before 1234914245
// Launchpad Numerics DepositGns call=151/256
// - Gas Used: 6219146
// - Storage Diff: 3592
// - CPU Cycles: 5359129
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=151/256_after 1234914245
// STATE CLOCK launchpad_deposit_call=152/256_before 1234914250
// Launchpad Numerics DepositGns call=152/256
// - Gas Used: 6220108
// - Storage Diff: 3592
// - CPU Cycles: 5359131
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=152/256_after 1234914250
// STATE CLOCK launchpad_deposit_call=153/256_before 1234914255
// Launchpad Numerics DepositGns call=153/256
// - Gas Used: 6221068
// - Storage Diff: 3592
// - CPU Cycles: 5359131
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=153/256_after 1234914255
// STATE CLOCK launchpad_deposit_call=154/256_before 1234914260
// Launchpad Numerics DepositGns call=154/256
// - Gas Used: 6222515
// - Storage Diff: 3592
// - CPU Cycles: 5359618
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=154/256_after 1234914260
// STATE CLOCK launchpad_deposit_call=155/256_before 1234914265
// Launchpad Numerics DepositGns call=155/256
// - Gas Used: 6223475
// - Storage Diff: 3592
// - CPU Cycles: 5359618
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=155/256_after 1234914265
// STATE CLOCK launchpad_deposit_call=156/256_before 1234914270
// Launchpad Numerics DepositGns call=156/256
// - Gas Used: 6546868
// - Storage Diff: 10256
// - CPU Cycles: 5610435
// - Realm gno.land/r/gnoswap/launchpad: 10256
// STATE CLOCK launchpad_deposit_call=156/256_after 1234914270
// STATE CLOCK launchpad_deposit_call=157/256_before 1234914275
// Launchpad Numerics DepositGns call=157/256
// - Gas Used: 6212992
// - Storage Diff: 3640
// - CPU Cycles: 5353653
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=157/256_after 1234914275
// STATE CLOCK launchpad_deposit_call=158/256_before 1234914280
// Launchpad Numerics DepositGns call=158/256
// - Gas Used: 6213465
// - Storage Diff: 3592
// - CPU Cycles: 5353166
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=158/256_after 1234914280
// STATE CLOCK launchpad_deposit_call=159/256_before 1234914285
// Launchpad Numerics DepositGns call=159/256
// - Gas Used: 6221362
// - Storage Diff: 3592
// - CPU Cycles: 5360103
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=159/256_after 1234914285
// STATE CLOCK launchpad_deposit_call=160/256_before 1234914290
// Launchpad Numerics DepositGns call=160/256
// - Gas Used: 6211266
// - Storage Diff: 3592
// - CPU Cycles: 5351405
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=160/256_after 1234914290
// STATE CLOCK launchpad_deposit_call=161/256_before 1234914295
// Launchpad Numerics DepositGns call=161/256
// - Gas Used: 6211741
// - Storage Diff: 3592
// - CPU Cycles: 5350920
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=161/256_after 1234914295
// STATE CLOCK launchpad_deposit_call=162/256_before 1234914300
// Launchpad Numerics DepositGns call=162/256
// - Gas Used: 6212699
// - Storage Diff: 3592
// - CPU Cycles: 5350918
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=162/256_after 1234914300
// STATE CLOCK launchpad_deposit_call=163/256_before 1234914305
// Launchpad Numerics DepositGns call=163/256
// - Gas Used: 6220109
// - Storage Diff: 3592
// - CPU Cycles: 5357368
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=163/256_after 1234914305
// STATE CLOCK launchpad_deposit_call=164/256_before 1234914310
// Launchpad Numerics DepositGns call=164/256
// - Gas Used: 6474577
// - Storage Diff: 9978
// - CPU Cycles: 5537700
// - Realm gno.land/r/gnoswap/launchpad: 9978
// STATE CLOCK launchpad_deposit_call=164/256_after 1234914310
// STATE CLOCK launchpad_deposit_call=165/256_before 1234914315
// Launchpad Numerics DepositGns call=165/256
// - Gas Used: 6189062
// - Storage Diff: 3640
// - CPU Cycles: 5337535
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=165/256_after 1234914315
// STATE CLOCK launchpad_deposit_call=166/256_before 1234914320
// Launchpad Numerics DepositGns call=166/256
// - Gas Used: 6195985
// - Storage Diff: 3592
// - CPU Cycles: 5343498
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=166/256_after 1234914320
// STATE CLOCK launchpad_deposit_call=167/256_before 1234914325
// Launchpad Numerics DepositGns call=167/256
// - Gas Used: 6197919
// - Storage Diff: 3592
// - CPU Cycles: 5344472
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=167/256_after 1234914325
// STATE CLOCK launchpad_deposit_call=168/256_before 1234914330
// Launchpad Numerics DepositGns call=168/256
// - Gas Used: 6190735
// - Storage Diff: 3592
// - CPU Cycles: 5336328
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=168/256_after 1234914330
// STATE CLOCK launchpad_deposit_call=169/256_before 1234914335
// Launchpad Numerics DepositGns call=169/256
// - Gas Used: 6199839
// - Storage Diff: 3592
// - CPU Cycles: 5344472
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=169/256_after 1234914335
// STATE CLOCK launchpad_deposit_call=170/256_before 1234914340
// Launchpad Numerics DepositGns call=170/256
// - Gas Used: 6218827
// - Storage Diff: 3574
// - CPU Cycles: 5359590
// - Realm gno.land/r/gnoswap/launchpad: 3574
// STATE CLOCK launchpad_deposit_call=170/256_after 1234914340
// STATE CLOCK launchpad_deposit_call=171/256_before 1234914345
// Launchpad Numerics DepositGns call=171/256
// - Gas Used: 6213222
// - Storage Diff: 3550
// - CPU Cycles: 5353145
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=171/256_after 1234914345
// STATE CLOCK launchpad_deposit_call=172/256_before 1234914350
// Launchpad Numerics DepositGns call=172/256
// - Gas Used: 6216238
// - Storage Diff: 3550
// - CPU Cycles: 5355321
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=172/256_after 1234914350
// STATE CLOCK launchpad_deposit_call=173/256_before 1234914355
// Launchpad Numerics DepositGns call=173/256
// - Gas Used: 6221354
// - Storage Diff: 3550
// - CPU Cycles: 5359597
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=173/256_after 1234914355
// STATE CLOCK launchpad_deposit_call=174/256_before 1234914360
// Launchpad Numerics DepositGns call=174/256
// - Gas Used: 6223168
// - Storage Diff: 3550
// - CPU Cycles: 5360571
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=174/256_after 1234914360
// STATE CLOCK launchpad_deposit_call=175/256_before 1234914365
// Launchpad Numerics DepositGns call=175/256
// - Gas Used: 6217076
// - Storage Diff: 3550
// - CPU Cycles: 5353639
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=175/256_after 1234914365
// STATE CLOCK launchpad_deposit_call=176/256_before 1234914370
// Launchpad Numerics DepositGns call=176/256
// - Gas Used: 6225340
// - Storage Diff: 3550
// - CPU Cycles: 5361063
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=176/256_after 1234914370
// STATE CLOCK launchpad_deposit_call=177/256_before 1234914375
// Launchpad Numerics DepositGns call=177/256
// - Gas Used: 6224709
// - Storage Diff: 3550
// - CPU Cycles: 5359592
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=177/256_after 1234914375
// STATE CLOCK launchpad_deposit_call=178/256_before 1234914380
// Launchpad Numerics DepositGns call=178/256
// - Gas Used: 6525087
// - Storage Diff: 9986
// - CPU Cycles: 5608098
// - Realm gno.land/r/gnoswap/launchpad: 9986
// STATE CLOCK launchpad_deposit_call=178/256_after 1234914380
// STATE CLOCK launchpad_deposit_call=179/256_before 1234914385
// Launchpad Numerics DepositGns call=179/256
// - Gas Used: 6235985
// - Storage Diff: 3640
// - CPU Cycles: 5360080
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=179/256_after 1234914385
// STATE CLOCK launchpad_deposit_call=180/256_before 1234914390
// Launchpad Numerics DepositGns call=180/256
// - Gas Used: 6240388
// - Storage Diff: 3592
// - CPU Cycles: 5365881
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=180/256_after 1234914390
// STATE CLOCK launchpad_deposit_call=181/256_before 1234914395
// Launchpad Numerics DepositGns call=181/256
// - Gas Used: 6235881
// - Storage Diff: 3592
// - CPU Cycles: 5360414
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=181/256_after 1234914395
// STATE CLOCK launchpad_deposit_call=182/256_before 1234914400
// Launchpad Numerics DepositGns call=182/256
// - Gas Used: 6236839
// - Storage Diff: 3592
// - CPU Cycles: 5360412
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=182/256_after 1234914400
// STATE CLOCK launchpad_deposit_call=183/256_before 1234914405
// Launchpad Numerics DepositGns call=183/256
// - Gas Used: 6243752
// - Storage Diff: 3592
// - CPU Cycles: 5366365
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=183/256_after 1234914405
// STATE CLOCK launchpad_deposit_call=184/256_before 1234914410
// Launchpad Numerics DepositGns call=184/256
// - Gas Used: 6244225
// - Storage Diff: 3592
// - CPU Cycles: 5365878
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=184/256_after 1234914410
// STATE CLOCK launchpad_deposit_call=185/256_before 1234914415
// Launchpad Numerics DepositGns call=185/256
// - Gas Used: 6246166
// - Storage Diff: 3592
// - CPU Cycles: 5366859
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=185/256_after 1234914415
// STATE CLOCK launchpad_deposit_call=186/256_before 1234914420
// Launchpad Numerics DepositGns call=186/256
// - Gas Used: 6555557
// - Storage Diff: 10258
// - CPU Cycles: 5617438
// - Realm gno.land/r/gnoswap/launchpad: 10258
// STATE CLOCK launchpad_deposit_call=186/256_after 1234914420
// STATE CLOCK launchpad_deposit_call=187/256_before 1234914425
// Launchpad Numerics DepositGns call=187/256
// - Gas Used: 6234721
// - Storage Diff: 3640
// - CPU Cycles: 5359920
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=187/256_after 1234914425
// STATE CLOCK launchpad_deposit_call=188/256_before 1234914430
// Launchpad Numerics DepositGns call=188/256
// - Gas Used: 6241644
// - Storage Diff: 3592
// - CPU Cycles: 5365883
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=188/256_after 1234914430
// STATE CLOCK launchpad_deposit_call=189/256_before 1234914435
// Launchpad Numerics DepositGns call=189/256
// - Gas Used: 6237622
// - Storage Diff: 3592
// - CPU Cycles: 5360901
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=189/256_after 1234914435
// STATE CLOCK launchpad_deposit_call=190/256_before 1234914440
// Launchpad Numerics DepositGns call=190/256
// - Gas Used: 6240552
// - Storage Diff: 3592
// - CPU Cycles: 5365229
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=190/256_after 1234914440
// STATE CLOCK launchpad_deposit_call=191/256_before 1234914445
// Launchpad Numerics DepositGns call=191/256
// - Gas Used: 6242491
// - Storage Diff: 3592
// - CPU Cycles: 5366208
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=191/256_after 1234914445
// STATE CLOCK launchpad_deposit_call=192/256_before 1234914450
// Launchpad Numerics DepositGns call=192/256
// - Gas Used: 6243940
// - Storage Diff: 3592
// - CPU Cycles: 5366697
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=192/256_after 1234914450
// STATE CLOCK launchpad_deposit_call=193/256_before 1234914455
// Launchpad Numerics DepositGns call=193/256
// - Gas Used: 6243926
// - Storage Diff: 3592
// - CPU Cycles: 5365723
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=193/256_after 1234914455
// STATE CLOCK launchpad_deposit_call=194/256_before 1234914460
// Launchpad Numerics DepositGns call=194/256
// - Gas Used: 6556703
// - Storage Diff: 10258
// - CPU Cycles: 5617276
// - Realm gno.land/r/gnoswap/launchpad: 10258
// STATE CLOCK launchpad_deposit_call=194/256_after 1234914460
// STATE CLOCK launchpad_deposit_call=195/256_before 1234914465
// Launchpad Numerics DepositGns call=195/256
// - Gas Used: 6233462
// - Storage Diff: 3640
// - CPU Cycles: 5359765
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=195/256_after 1234914465
// STATE CLOCK launchpad_deposit_call=196/256_before 1234914470
// Launchpad Numerics DepositGns call=196/256
// - Gas Used: 6234909
// - Storage Diff: 3592
// - CPU Cycles: 5360252
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=196/256_after 1234914470
// STATE CLOCK launchpad_deposit_call=197/256_before 1234914475
// Launchpad Numerics DepositGns call=197/256
// - Gas Used: 6237553
// - Storage Diff: 3592
// - CPU Cycles: 5361936
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=197/256_after 1234914475
// STATE CLOCK launchpad_deposit_call=198/256_before 1234914480
// Launchpad Numerics DepositGns call=198/256
// - Gas Used: 6239000
// - Storage Diff: 3592
// - CPU Cycles: 5362423
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=198/256_after 1234914480
// STATE CLOCK launchpad_deposit_call=199/256_before 1234914485
// Launchpad Numerics DepositGns call=199/256
// - Gas Used: 6240939
// - Storage Diff: 3592
// - CPU Cycles: 5363402
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=199/256_after 1234914485
// STATE CLOCK launchpad_deposit_call=200/256_before 1234914490
// Launchpad Numerics DepositGns call=200/256
// - Gas Used: 6239672
// - Storage Diff: 3592
// - CPU Cycles: 5365891
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=200/256_after 1234914490
// STATE CLOCK launchpad_deposit_call=201/256_before 1234914495
// Launchpad Numerics DepositGns call=201/256
// - Gas Used: 6240633
// - Storage Diff: 3592
// - CPU Cycles: 5365892
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=201/256_after 1234914495
// STATE CLOCK launchpad_deposit_call=202/256_before 1234914500
// Launchpad Numerics DepositGns call=202/256
// - Gas Used: 6558180
// - Storage Diff: 10258
// - CPU Cycles: 5617445
// - Realm gno.land/r/gnoswap/launchpad: 10258
// STATE CLOCK launchpad_deposit_call=202/256_after 1234914500
// STATE CLOCK launchpad_deposit_call=203/256_before 1234914505
// Launchpad Numerics DepositGns call=203/256
// - Gas Used: 6235630
// - Storage Diff: 3640
// - CPU Cycles: 5365407
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=203/256_after 1234914505
// STATE CLOCK launchpad_deposit_call=204/256_before 1234914510
// Launchpad Numerics DepositGns call=204/256
// - Gas Used: 6237077
// - Storage Diff: 3592
// - CPU Cycles: 5365894
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=204/256_after 1234914510
// STATE CLOCK launchpad_deposit_call=205/256_before 1234914515
// Launchpad Numerics DepositGns call=205/256
// - Gas Used: 6231592
// - Storage Diff: 3592
// - CPU Cycles: 5359449
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=205/256_after 1234914515
// STATE CLOCK launchpad_deposit_call=206/256_before 1234914520
// Launchpad Numerics DepositGns call=206/256
// - Gas Used: 6233039
// - Storage Diff: 3592
// - CPU Cycles: 5359936
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=206/256_after 1234914520
// STATE CLOCK launchpad_deposit_call=207/256_before 1234914525
// Launchpad Numerics DepositGns call=207/256
// - Gas Used: 6240449
// - Storage Diff: 3592
// - CPU Cycles: 5366386
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=207/256_after 1234914525
// STATE CLOCK launchpad_deposit_call=208/256_before 1234914530
// Launchpad Numerics DepositGns call=208/256
// - Gas Used: 6241409
// - Storage Diff: 3592
// - CPU Cycles: 5366386
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=208/256_after 1234914530
// STATE CLOCK launchpad_deposit_call=209/256_before 1234914535
// Launchpad Numerics DepositGns call=209/256
// - Gas Used: 6241877
// - Storage Diff: 3592
// - CPU Cycles: 5365894
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=209/256_after 1234914535
// STATE CLOCK launchpad_deposit_call=210/256_before 1234914540
// Launchpad Numerics DepositGns call=210/256
// - Gas Used: 6559309
// - Storage Diff: 10258
// - CPU Cycles: 5617290
// - Realm gno.land/r/gnoswap/launchpad: 10258
// STATE CLOCK launchpad_deposit_call=210/256_after 1234914540
// STATE CLOCK launchpad_deposit_call=211/256_before 1234914545
// Launchpad Numerics DepositGns call=211/256
// - Gas Used: 6228913
// - Storage Diff: 3640
// - CPU Cycles: 5359776
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=211/256_after 1234914545
// STATE CLOCK launchpad_deposit_call=212/256_before 1234914550
// Launchpad Numerics DepositGns call=212/256
// - Gas Used: 6230379
// - Storage Diff: 3597
// - CPU Cycles: 5360261
// - Realm gno.land/r/gnoswap/gov/staker: 5
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=212/256_after 1234914550
// STATE CLOCK launchpad_deposit_call=213/256_before 1234914555
// Launchpad Numerics DepositGns call=213/256
// - Gas Used: 6237333
// - Storage Diff: 3597
// - CPU Cycles: 5366219
// - Realm gno.land/r/gnoswap/gov/staker: 5
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=213/256_after 1234914555
// STATE CLOCK launchpad_deposit_call=214/256_before 1234914560
// Launchpad Numerics DepositGns call=214/256
// - Gas Used: 6237321
// - Storage Diff: 3592
// - CPU Cycles: 5365247
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=214/256_after 1234914560
// STATE CLOCK launchpad_deposit_call=215/256_before 1234914565
// Launchpad Numerics DepositGns call=215/256
// - Gas Used: 6235473
// - Storage Diff: 3592
// - CPU Cycles: 5362439
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=215/256_after 1234914565
// STATE CLOCK launchpad_deposit_call=216/256_before 1234914570
// Launchpad Numerics DepositGns call=216/256
// - Gas Used: 6239728
// - Storage Diff: 3592
// - CPU Cycles: 5365734
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=216/256_after 1234914570
// STATE CLOCK launchpad_deposit_call=217/256_before 1234914575
// Launchpad Numerics DepositGns call=217/256
// - Gas Used: 6240693
// - Storage Diff: 3592
// - CPU Cycles: 5365739
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=217/256_after 1234914575
// STATE CLOCK launchpad_deposit_call=218/256_before 1234914580
// Launchpad Numerics DepositGns call=218/256
// - Gas Used: 6970739
// - Storage Diff: 17170
// - CPU Cycles: 5981423
// - Realm gno.land/r/gnoswap/launchpad: 17170
// STATE CLOCK launchpad_deposit_call=218/256_after 1234914580
// STATE CLOCK launchpad_deposit_call=219/256_before 1234914585
// Launchpad Numerics DepositGns call=219/256
// - Gas Used: 6221765
// - Storage Diff: 3688
// - CPU Cycles: 5360263
// - Realm gno.land/r/gnoswap/launchpad: 3688
// STATE CLOCK launchpad_deposit_call=219/256_after 1234914585
// STATE CLOCK launchpad_deposit_call=220/256_before 1234914590
// Launchpad Numerics DepositGns call=220/256
// - Gas Used: 6220205
// - Storage Diff: 3592
// - CPU Cycles: 5360101
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=220/256_after 1234914590
// STATE CLOCK launchpad_deposit_call=221/256_before 1234914595
// Launchpad Numerics DepositGns call=221/256
// - Gas Used: 6227128
// - Storage Diff: 3592
// - CPU Cycles: 5366064
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=221/256_after 1234914595
// STATE CLOCK launchpad_deposit_call=222/256_before 1234914600
// Launchpad Numerics DepositGns call=222/256
// - Gas Used: 6228090
// - Storage Diff: 3592
// - CPU Cycles: 5366066
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=222/256_after 1234914600
// STATE CLOCK launchpad_deposit_call=223/256_before 1234914605
// Launchpad Numerics DepositGns call=223/256
// - Gas Used: 6229537
// - Storage Diff: 3592
// - CPU Cycles: 5366553
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=223/256_after 1234914605
// STATE CLOCK launchpad_deposit_call=224/256_before 1234914610
// Launchpad Numerics DepositGns call=224/256
// - Gas Used: 6230010
// - Storage Diff: 3592
// - CPU Cycles: 5366066
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=224/256_after 1234914610
// STATE CLOCK launchpad_deposit_call=225/256_before 1234914615
// Launchpad Numerics DepositGns call=225/256
// - Gas Used: 6230970
// - Storage Diff: 3592
// - CPU Cycles: 5366066
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=225/256_after 1234914615
// STATE CLOCK launchpad_deposit_call=226/256_before 1234914620
// Launchpad Numerics DepositGns call=226/256
// - Gas Used: 6551514
// - Storage Diff: 10308
// - CPU Cycles: 5617130
// - Realm gno.land/r/gnoswap/launchpad: 10308
// STATE CLOCK launchpad_deposit_call=226/256_after 1234914620
// STATE CLOCK launchpad_deposit_call=227/256_before 1234914625
// Launchpad Numerics DepositGns call=227/256
// - Gas Used: 6220000
// - Storage Diff: 3640
// - CPU Cycles: 5359614
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=227/256_after 1234914625
// STATE CLOCK launchpad_deposit_call=228/256_before 1234914630
// Launchpad Numerics DepositGns call=228/256
// - Gas Used: 6220473
// - Storage Diff: 3592
// - CPU Cycles: 5359127
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=228/256_after 1234914630
// STATE CLOCK launchpad_deposit_call=229/256_before 1234914635
// Launchpad Numerics DepositGns call=229/256
// - Gas Used: 6228857
// - Storage Diff: 3592
// - CPU Cycles: 5366551
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=229/256_after 1234914635
// STATE CLOCK launchpad_deposit_call=230/256_before 1234914640
// Launchpad Numerics DepositGns call=230/256
// - Gas Used: 6217787
// - Storage Diff: 3592
// - CPU Cycles: 5356879
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=230/256_after 1234914640
// STATE CLOCK launchpad_deposit_call=231/256_before 1234914645
// Launchpad Numerics DepositGns call=231/256
// - Gas Used: 6215454
// - Storage Diff: 3592
// - CPU Cycles: 5353586
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=231/256_after 1234914645
// STATE CLOCK launchpad_deposit_call=232/256_before 1234914650
// Launchpad Numerics DepositGns call=232/256
// - Gas Used: 6220194
// - Storage Diff: 3592
// - CPU Cycles: 5357366
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=232/256_after 1234914650
// STATE CLOCK launchpad_deposit_call=233/256_before 1234914655
// Launchpad Numerics DepositGns call=233/256
// - Gas Used: 6228091
// - Storage Diff: 3592
// - CPU Cycles: 5364303
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=233/256_after 1234914655
// STATE CLOCK launchpad_deposit_call=234/256_before 1234914660
// Launchpad Numerics DepositGns call=234/256
// - Gas Used: 6479343
// - Storage Diff: 10018
// - CPU Cycles: 5544395
// - Realm gno.land/r/gnoswap/launchpad: 10018
// STATE CLOCK launchpad_deposit_call=234/256_after 1234914660
// STATE CLOCK launchpad_deposit_call=235/256_before 1234914665
// Launchpad Numerics DepositGns call=235/256
// - Gas Used: 6197044
// - Storage Diff: 3640
// - CPU Cycles: 5344470
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=235/256_after 1234914665
// STATE CLOCK launchpad_deposit_call=236/256_before 1234914670
// Launchpad Numerics DepositGns call=236/256
// - Gas Used: 6204454
// - Storage Diff: 3592
// - CPU Cycles: 5350920
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=236/256_after 1234914670
// STATE CLOCK launchpad_deposit_call=237/256_before 1234914675
// Launchpad Numerics DepositGns call=237/256
// - Gas Used: 6205901
// - Storage Diff: 3592
// - CPU Cycles: 5351407
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=237/256_after 1234914675
// STATE CLOCK launchpad_deposit_call=238/256_before 1234914680
// Launchpad Numerics DepositGns call=238/256
// - Gas Used: 6206861
// - Storage Diff: 3592
// - CPU Cycles: 5351407
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=238/256_after 1234914680
// STATE CLOCK launchpad_deposit_call=239/256_before 1234914685
// Launchpad Numerics DepositGns call=239/256
// - Gas Used: 6207334
// - Storage Diff: 3592
// - CPU Cycles: 5350920
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=239/256_after 1234914685
// STATE CLOCK launchpad_deposit_call=240/256_before 1234914690
// Launchpad Numerics DepositGns call=240/256
// - Gas Used: 6242684
// - Storage Diff: 3574
// - CPU Cycles: 5366530
// - Realm gno.land/r/gnoswap/launchpad: 3574
// STATE CLOCK launchpad_deposit_call=240/256_after 1234914690
// STATE CLOCK launchpad_deposit_call=241/256_before 1234914695
// Launchpad Numerics DepositGns call=241/256
// - Gas Used: 6238055
// - Storage Diff: 3550
// - CPU Cycles: 5361061
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=241/256_after 1234914695
// STATE CLOCK launchpad_deposit_call=242/256_before 1234914700
// Launchpad Numerics DepositGns call=242/256
// - Gas Used: 6243879
// - Storage Diff: 3550
// - CPU Cycles: 5366045
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=242/256_after 1234914700
// STATE CLOCK launchpad_deposit_call=243/256_before 1234914705
// Launchpad Numerics DepositGns call=243/256
// - Gas Used: 6245698
// - Storage Diff: 3550
// - CPU Cycles: 5367024
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=243/256_after 1234914705
// STATE CLOCK launchpad_deposit_call=244/256_before 1234914710
// Launchpad Numerics DepositGns call=244/256
// - Gas Used: 6246538
// - Storage Diff: 3550
// - CPU Cycles: 5367024
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=244/256_after 1234914710
// STATE CLOCK launchpad_deposit_call=245/256_before 1234914715
// Launchpad Numerics DepositGns call=245/256
// - Gas Used: 6241420
// - Storage Diff: 3550
// - CPU Cycles: 5361066
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=245/256_after 1234914715
// STATE CLOCK launchpad_deposit_call=246/256_before 1234914720
// Launchpad Numerics DepositGns call=246/256
// - Gas Used: 6249197
// - Storage Diff: 3550
// - CPU Cycles: 5368003
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=246/256_after 1234914720
// STATE CLOCK launchpad_deposit_call=247/256_before 1234914725
// Launchpad Numerics DepositGns call=247/256
// - Gas Used: 6248079
// - Storage Diff: 3550
// - CPU Cycles: 5366045
// - Realm gno.land/r/gnoswap/launchpad: 3550
// STATE CLOCK launchpad_deposit_call=247/256_after 1234914725
// STATE CLOCK launchpad_deposit_call=248/256_before 1234914730
// Launchpad Numerics DepositGns call=248/256
// - Gas Used: 6529978
// - Storage Diff: 10026
// - CPU Cycles: 5614798
// - Realm gno.land/r/gnoswap/launchpad: 10026
// STATE CLOCK launchpad_deposit_call=248/256_after 1234914730
// STATE CLOCK launchpad_deposit_call=249/256_before 1234914735
// Launchpad Numerics DepositGns call=249/256
// - Gas Used: 6237528
// - Storage Diff: 3640
// - CPU Cycles: 5360576
// - Realm gno.land/r/gnoswap/launchpad: 3640
// STATE CLOCK launchpad_deposit_call=249/256_after 1234914735
// STATE CLOCK launchpad_deposit_call=250/256_before 1234914740
// Launchpad Numerics DepositGns call=250/256
// - Gas Used: 6242905
// - Storage Diff: 3592
// - CPU Cycles: 5367351
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=250/256_after 1234914740
// STATE CLOCK launchpad_deposit_call=251/256_before 1234914745
// Launchpad Numerics DepositGns call=251/256
// - Gas Used: 6236935
// - Storage Diff: 3592
// - CPU Cycles: 5360421
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=251/256_after 1234914745
// STATE CLOCK launchpad_deposit_call=252/256_before 1234914750
// Launchpad Numerics DepositGns call=252/256
// - Gas Used: 6238380
// - Storage Diff: 3592
// - CPU Cycles: 5360906
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=252/256_after 1234914750
// STATE CLOCK launchpad_deposit_call=253/256_before 1234914755
// Launchpad Numerics DepositGns call=253/256
// - Gas Used: 6245295
// - Storage Diff: 3592
// - CPU Cycles: 5366861
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=253/256_after 1234914755
// STATE CLOCK launchpad_deposit_call=254/256_before 1234914760
// Launchpad Numerics DepositGns call=254/256
// - Gas Used: 6246255
// - Storage Diff: 3592
// - CPU Cycles: 5366861
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=254/256_after 1234914760
// STATE CLOCK launchpad_deposit_call=255/256_before 1234914765
// Launchpad Numerics DepositGns call=255/256
// - Gas Used: 6247707
// - Storage Diff: 3592
// - CPU Cycles: 5367353
// - Realm gno.land/r/gnoswap/launchpad: 3592
// STATE CLOCK launchpad_deposit_call=255/256_after 1234914765
// STATE CLOCK launchpad_deposit_call=256/256_before 1234914770
// Launchpad Numerics DepositGns call=256/256
// - Gas Used: 6535045
// - Storage Diff: 7162
// - CPU Cycles: 5608838
// - Realm gno.land/r/gnoswap/gns: -3136
// - Realm gno.land/r/gnoswap/launchpad: 10298
// STATE CLOCK launchpad_deposit_call=256/256_after 1234914770
// STATE launchpad-numerics phase=deposited-stage-256 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1168479812265116018988177298603093692 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=256000000 manager_active_claimed=0 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=1280 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_claim_1_1_before 1235001175
// Launchpad Numerics CollectReward pattern=1 call=1/1
// - Gas Used: 3240555
// - Storage Diff: 2046
// - CPU Cycles: 2935644
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2034
// STATE CLOCK launchpad_claim_1_1_after 1235001175
// STATE CLOCK launchpad_claim_10_2_before 1235001180
// Launchpad Numerics CollectReward pattern=10 call=1/10
// - Gas Used: 3228413
// - Storage Diff: 12
// - CPU Cycles: 2947951
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_2_after 1235001180
// STATE CLOCK launchpad_claim_10_3_before 1235001185
// Launchpad Numerics CollectReward pattern=10 call=2/10
// - Gas Used: 3207040
// - Storage Diff: 12
// - CPU Cycles: 2926578
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_3_after 1235001185
// STATE CLOCK launchpad_claim_10_4_before 1235001190
// Launchpad Numerics CollectReward pattern=10 call=3/10
// - Gas Used: 3215519
// - Storage Diff: 12
// - CPU Cycles: 2935063
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_4_after 1235001190
// STATE CLOCK launchpad_claim_10_5_before 1235001195
// Launchpad Numerics CollectReward pattern=10 call=4/10
// - Gas Used: 3189384
// - Storage Diff: 12
// - CPU Cycles: 2908928
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_5_after 1235001195
// STATE CLOCK launchpad_claim_10_6_before 1235001200
// Launchpad Numerics CollectReward pattern=10 call=5/10
// - Gas Used: 3193166
// - Storage Diff: 12
// - CPU Cycles: 2912710
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_6_after 1235001200
// STATE CLOCK launchpad_claim_10_7_before 1235001205
// Launchpad Numerics CollectReward pattern=10 call=6/10
// - Gas Used: 3192186
// - Storage Diff: 12
// - CPU Cycles: 2911730
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_7_after 1235001205
// STATE CLOCK launchpad_claim_10_8_before 1235001210
// Launchpad Numerics CollectReward pattern=10 call=7/10
// - Gas Used: 3192736
// - Storage Diff: 31
// - CPU Cycles: 2912223
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 19
// STATE CLOCK launchpad_claim_10_8_after 1235001210
// STATE CLOCK launchpad_claim_10_9_before 1235001215
// Launchpad Numerics CollectReward pattern=10 call=8/10
// - Gas Used: 3205159
// - Storage Diff: 20
// - CPU Cycles: 2924622
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 8
// STATE CLOCK launchpad_claim_10_9_after 1235001215
// STATE CLOCK launchpad_claim_10_10_before 1235001220
// Launchpad Numerics CollectReward pattern=10 call=9/10
// - Gas Used: 3213676
// - Storage Diff: 12
// - CPU Cycles: 2933139
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_10_after 1235001220
// STATE CLOCK launchpad_claim_10_11_before 1235001225
// Launchpad Numerics CollectReward pattern=10 call=10/10
// - Gas Used: 3200931
// - Storage Diff: 14
// - CPU Cycles: 2920379
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2
// STATE CLOCK launchpad_claim_10_11_after 1235001225
// STATE CLOCK launchpad_claim_100_12_before 1235001230
// Launchpad Numerics CollectReward pattern=100 call=1/100
// - Gas Used: 3204232
// - Storage Diff: 14
// - CPU Cycles: 2923674
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2
// STATE CLOCK launchpad_claim_100_12_after 1235001230
// STATE CLOCK launchpad_claim_100_13_before 1235001235
// Launchpad Numerics CollectReward pattern=100 call=2/100
// - Gas Used: 3203252
// - Storage Diff: 12
// - CPU Cycles: 2922694
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_13_after 1235001235
// STATE CLOCK launchpad_claim_100_14_before 1235001240
// Launchpad Numerics CollectReward pattern=100 call=3/100
// - Gas Used: 3204232
// - Storage Diff: 12
// - CPU Cycles: 2923674
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_14_after 1235001240
// STATE CLOCK launchpad_claim_100_15_before 1235001245
// Launchpad Numerics CollectReward pattern=100 call=4/100
// - Gas Used: 3215661
// - Storage Diff: 12
// - CPU Cycles: 2935103
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_15_after 1235001245
// STATE CLOCK launchpad_claim_100_16_before 1235001250
// Launchpad Numerics CollectReward pattern=100 call=5/100
// - Gas Used: 3218601
// - Storage Diff: 12
// - CPU Cycles: 2938043
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_16_after 1235001250
// STATE CLOCK launchpad_claim_100_17_before 1235001255
// Launchpad Numerics CollectReward pattern=100 call=6/100
// - Gas Used: 3227074
// - Storage Diff: 12
// - CPU Cycles: 2946522
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_17_after 1235001255
// STATE CLOCK launchpad_claim_100_18_before 1235001260
// Launchpad Numerics CollectReward pattern=100 call=7/100
// - Gas Used: 3216144
// - Storage Diff: 12
// - CPU Cycles: 2935586
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_18_after 1235001260
// STATE CLOCK launchpad_claim_100_19_before 1235001265
// Launchpad Numerics CollectReward pattern=100 call=8/100
// - Gas Used: 3217617
// - Storage Diff: 12
// - CPU Cycles: 2937059
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_19_after 1235001265
// STATE CLOCK launchpad_claim_100_20_before 1235001270
// Launchpad Numerics CollectReward pattern=100 call=9/100
// - Gas Used: 3217120
// - Storage Diff: 12
// - CPU Cycles: 2936562
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_20_after 1235001270
// STATE CLOCK launchpad_claim_100_21_before 1235001275
// Launchpad Numerics CollectReward pattern=100 call=10/100
// - Gas Used: 3204725
// - Storage Diff: 12
// - CPU Cycles: 2924167
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_21_after 1235001275
// STATE CLOCK launchpad_claim_100_22_before 1235001280
// Launchpad Numerics CollectReward pattern=100 call=11/100
// - Gas Used: 3224278
// - Storage Diff: 12
// - CPU Cycles: 2943720
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_22_after 1235001280
// STATE CLOCK launchpad_claim_100_23_before 1235001285
// Launchpad Numerics CollectReward pattern=100 call=12/100
// - Gas Used: 3231000
// - Storage Diff: 12
// - CPU Cycles: 2950442
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_23_after 1235001285
// STATE CLOCK launchpad_claim_100_24_before 1235001290
// Launchpad Numerics CollectReward pattern=100 call=13/100
// - Gas Used: 3228054
// - Storage Diff: 12
// - CPU Cycles: 2947502
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_24_after 1235001290
// STATE CLOCK launchpad_claim_100_25_before 1235001295
// Launchpad Numerics CollectReward pattern=100 call=14/100
// - Gas Used: 3217617
// - Storage Diff: 12
// - CPU Cycles: 2937059
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_25_after 1235001295
// STATE CLOCK launchpad_claim_100_26_before 1235001300
// Launchpad Numerics CollectReward pattern=100 call=15/100
// - Gas Used: 3206192
// - Storage Diff: 12
// - CPU Cycles: 2925634
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_26_after 1235001300
// STATE CLOCK launchpad_claim_100_27_before 1235001305
// Launchpad Numerics CollectReward pattern=100 call=16/100
// - Gas Used: 3206685
// - Storage Diff: 12
// - CPU Cycles: 2926127
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_27_after 1235001305
// STATE CLOCK launchpad_claim_100_28_before 1235001310
// Launchpad Numerics CollectReward pattern=100 call=17/100
// - Gas Used: 3214322
// - Storage Diff: 12
// - CPU Cycles: 2933764
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_28_after 1235001310
// STATE CLOCK launchpad_claim_100_29_before 1235001315
// Launchpad Numerics CollectReward pattern=100 call=18/100
// - Gas Used: 3219084
// - Storage Diff: 12
// - CPU Cycles: 2938526
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_29_after 1235001315
// STATE CLOCK launchpad_claim_100_30_before 1235001320
// Launchpad Numerics CollectReward pattern=100 call=19/100
// - Gas Used: 3207168
// - Storage Diff: 12
// - CPU Cycles: 2926610
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_30_after 1235001320
// STATE CLOCK launchpad_claim_100_31_before 1235001325
// Launchpad Numerics CollectReward pattern=100 call=20/100
// - Gas Used: 3213695
// - Storage Diff: 12
// - CPU Cycles: 2933143
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_31_after 1235001325
// STATE CLOCK launchpad_claim_100_32_before 1235001330
// Launchpad Numerics CollectReward pattern=100 call=21/100
// - Gas Used: 3215162
// - Storage Diff: 12
// - CPU Cycles: 2934610
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_32_after 1235001330
// STATE CLOCK launchpad_claim_100_33_before 1235001335
// Launchpad Numerics CollectReward pattern=100 call=22/100
// - Gas Used: 3202759
// - Storage Diff: 12
// - CPU Cycles: 2922207
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_33_after 1235001335
// STATE CLOCK launchpad_claim_100_34_before 1235001340
// Launchpad Numerics CollectReward pattern=100 call=23/100
// - Gas Used: 3203246
// - Storage Diff: 12
// - CPU Cycles: 2922694
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_34_after 1235001340
// STATE CLOCK launchpad_claim_100_35_before 1235001345
// Launchpad Numerics CollectReward pattern=100 call=24/100
// - Gas Used: 3204226
// - Storage Diff: 12
// - CPU Cycles: 2923674
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_35_after 1235001345
// STATE CLOCK launchpad_claim_100_36_before 1235001350
// Launchpad Numerics CollectReward pattern=100 call=25/100
// - Gas Used: 3203246
// - Storage Diff: 12
// - CPU Cycles: 2922694
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_36_after 1235001350
// STATE CLOCK launchpad_claim_100_37_before 1235001355
// Launchpad Numerics CollectReward pattern=100 call=26/100
// - Gas Used: 3203739
// - Storage Diff: 12
// - CPU Cycles: 2923187
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_37_after 1235001355
// STATE CLOCK launchpad_claim_100_38_before 1235001360
// Launchpad Numerics CollectReward pattern=100 call=27/100
// - Gas Used: 3203739
// - Storage Diff: 12
// - CPU Cycles: 2923187
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_38_after 1235001360
// STATE CLOCK launchpad_claim_100_39_before 1235001365
// Launchpad Numerics CollectReward pattern=100 call=28/100
// - Gas Used: 3211376
// - Storage Diff: 12
// - CPU Cycles: 2930824
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_39_after 1235001365
// STATE CLOCK launchpad_claim_100_40_before 1235001370
// Launchpad Numerics CollectReward pattern=100 call=29/100
// - Gas Used: 3204222
// - Storage Diff: 12
// - CPU Cycles: 2923670
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_40_after 1235001370
// STATE CLOCK launchpad_claim_100_41_before 1235001375
// Launchpad Numerics CollectReward pattern=100 call=30/100
// - Gas Used: 3204226
// - Storage Diff: 12
// - CPU Cycles: 2923674
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_41_after 1235001375
// STATE CLOCK launchpad_claim_100_42_before 1235001380
// Launchpad Numerics CollectReward pattern=100 call=31/100
// - Gas Used: 3204719
// - Storage Diff: 12
// - CPU Cycles: 2924167
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_42_after 1235001380
// STATE CLOCK launchpad_claim_100_43_before 1235001385
// Launchpad Numerics CollectReward pattern=100 call=32/100
// - Gas Used: 3204226
// - Storage Diff: 12
// - CPU Cycles: 2923674
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_43_after 1235001385
// STATE CLOCK launchpad_claim_100_44_before 1235001390
// Launchpad Numerics CollectReward pattern=100 call=33/100
// - Gas Used: 3204719
// - Storage Diff: 12
// - CPU Cycles: 2924167
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_44_after 1235001390
// STATE CLOCK launchpad_claim_100_45_before 1235001395
// Launchpad Numerics CollectReward pattern=100 call=34/100
// - Gas Used: 3200357
// - Storage Diff: 12
// - CPU Cycles: 2919805
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_45_after 1235001395
// STATE CLOCK launchpad_claim_100_46_before 1235001400
// Launchpad Numerics CollectReward pattern=100 call=35/100
// - Gas Used: 3203246
// - Storage Diff: 12
// - CPU Cycles: 2922694
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_46_after 1235001400
// STATE CLOCK launchpad_claim_100_47_before 1235001405
// Launchpad Numerics CollectReward pattern=100 call=36/100
// - Gas Used: 3204226
// - Storage Diff: 12
// - CPU Cycles: 2923674
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_47_after 1235001405
// STATE CLOCK launchpad_claim_100_48_before 1235001410
// Launchpad Numerics CollectReward pattern=100 call=37/100
// - Gas Used: 3191823
// - Storage Diff: 12
// - CPU Cycles: 2911271
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_48_after 1235001410
// STATE CLOCK launchpad_claim_100_49_before 1235001415
// Launchpad Numerics CollectReward pattern=100 call=38/100
// - Gas Used: 3192310
// - Storage Diff: 12
// - CPU Cycles: 2911758
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_49_after 1235001415
// STATE CLOCK launchpad_claim_100_50_before 1235001420
// Launchpad Numerics CollectReward pattern=100 call=39/100
// - Gas Used: 3191823
// - Storage Diff: 12
// - CPU Cycles: 2911271
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_50_after 1235001420
// STATE CLOCK launchpad_claim_100_51_before 1235001425
// Launchpad Numerics CollectReward pattern=100 call=40/100
// - Gas Used: 3193290
// - Storage Diff: 12
// - CPU Cycles: 2912738
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_51_after 1235001425
// STATE CLOCK launchpad_claim_100_52_before 1235001430
// Launchpad Numerics CollectReward pattern=100 call=41/100
// - Gas Used: 3193290
// - Storage Diff: 12
// - CPU Cycles: 2912738
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_52_after 1235001430
// STATE CLOCK launchpad_claim_100_53_before 1235001435
// Launchpad Numerics CollectReward pattern=100 call=42/100
// - Gas Used: 3203250
// - Storage Diff: 12
// - CPU Cycles: 2922698
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_53_after 1235001435
// STATE CLOCK launchpad_claim_100_54_before 1235001440
// Launchpad Numerics CollectReward pattern=100 call=43/100
// - Gas Used: 3203743
// - Storage Diff: 12
// - CPU Cycles: 2923191
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_54_after 1235001440
// STATE CLOCK launchpad_claim_100_55_before 1235001445
// Launchpad Numerics CollectReward pattern=100 call=44/100
// - Gas Used: 3192314
// - Storage Diff: 12
// - CPU Cycles: 2911762
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_55_after 1235001445
// STATE CLOCK launchpad_claim_100_56_before 1235001450
// Launchpad Numerics CollectReward pattern=100 call=45/100
// - Gas Used: 3188532
// - Storage Diff: 12
// - CPU Cycles: 2907980
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_56_after 1235001450
// STATE CLOCK launchpad_claim_100_57_before 1235001455
// Launchpad Numerics CollectReward pattern=100 call=46/100
// - Gas Used: 3193294
// - Storage Diff: 12
// - CPU Cycles: 2912742
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_57_after 1235001455
// STATE CLOCK launchpad_claim_100_58_before 1235001460
// Launchpad Numerics CollectReward pattern=100 call=47/100
// - Gas Used: 3192314
// - Storage Diff: 12
// - CPU Cycles: 2911762
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_58_after 1235001460
// STATE CLOCK launchpad_claim_100_59_before 1235001465
// Launchpad Numerics CollectReward pattern=100 call=48/100
// - Gas Used: 3192807
// - Storage Diff: 12
// - CPU Cycles: 2912255
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_59_after 1235001465
// STATE CLOCK launchpad_claim_100_60_before 1235001470
// Launchpad Numerics CollectReward pattern=100 call=49/100
// - Gas Used: 3203743
// - Storage Diff: 12
// - CPU Cycles: 2923191
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_60_after 1235001470
// STATE CLOCK launchpad_claim_100_61_before 1235001475
// Launchpad Numerics CollectReward pattern=100 call=50/100
// - Gas Used: 3204723
// - Storage Diff: 12
// - CPU Cycles: 2924171
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_61_after 1235001475
// STATE CLOCK launchpad_claim_100_62_before 1235001480
// Launchpad Numerics CollectReward pattern=100 call=51/100
// - Gas Used: 3193294
// - Storage Diff: 12
// - CPU Cycles: 2912742
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_62_after 1235001480
// STATE CLOCK launchpad_claim_100_63_before 1235001485
// Launchpad Numerics CollectReward pattern=100 call=52/100
// - Gas Used: 3192834
// - Storage Diff: 12
// - CPU Cycles: 2912255
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_63_after 1235001485
// STATE CLOCK launchpad_claim_100_64_before 1235001490
// Launchpad Numerics CollectReward pattern=100 call=53/100
// - Gas Used: 3194313
// - Storage Diff: 12
// - CPU Cycles: 2913722
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_64_after 1235001490
// STATE CLOCK launchpad_claim_100_65_before 1235001495
// Launchpad Numerics CollectReward pattern=100 call=54/100
// - Gas Used: 3192852
// - Storage Diff: 12
// - CPU Cycles: 2912255
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_65_after 1235001495
// STATE CLOCK launchpad_claim_100_66_before 1235001500
// Launchpad Numerics CollectReward pattern=100 call=55/100
// - Gas Used: 3194319
// - Storage Diff: 12
// - CPU Cycles: 2913722
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_66_after 1235001500
// STATE CLOCK launchpad_claim_100_67_before 1235001505
// Launchpad Numerics CollectReward pattern=100 call=56/100
// - Gas Used: 3190537
// - Storage Diff: 12
// - CPU Cycles: 2909940
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_67_after 1235001505
// STATE CLOCK launchpad_claim_100_68_before 1235001510
// Launchpad Numerics CollectReward pattern=100 call=57/100
// - Gas Used: 3203291
// - Storage Diff: 12
// - CPU Cycles: 2922694
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_68_after 1235001510
// STATE CLOCK launchpad_claim_100_69_before 1235001515
// Launchpad Numerics CollectReward pattern=100 call=58/100
// - Gas Used: 3204271
// - Storage Diff: 12
// - CPU Cycles: 2923674
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_69_after 1235001515
// STATE CLOCK launchpad_claim_100_70_before 1235001520
// Launchpad Numerics CollectReward pattern=100 call=59/100
// - Gas Used: 3192355
// - Storage Diff: 12
// - CPU Cycles: 2911758
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_70_after 1235001520
// STATE CLOCK launchpad_claim_100_71_before 1235001525
// Launchpad Numerics CollectReward pattern=100 call=60/100
// - Gas Used: 3192848
// - Storage Diff: 12
// - CPU Cycles: 2912251
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_71_after 1235001525
// STATE CLOCK launchpad_claim_100_72_before 1235001530
// Launchpad Numerics CollectReward pattern=100 call=61/100
// - Gas Used: 3192359
// - Storage Diff: 12
// - CPU Cycles: 2911762
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_72_after 1235001530
// STATE CLOCK launchpad_claim_100_73_before 1235001535
// Launchpad Numerics CollectReward pattern=100 call=62/100
// - Gas Used: 3189557
// - Storage Diff: 12
// - CPU Cycles: 2908960
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_73_after 1235001535
// STATE CLOCK launchpad_claim_100_74_before 1235001540
// Launchpad Numerics CollectReward pattern=100 call=63/100
// - Gas Used: 3193339
// - Storage Diff: 12
// - CPU Cycles: 2912742
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_74_after 1235001540
// STATE CLOCK launchpad_claim_100_75_before 1235001545
// Launchpad Numerics CollectReward pattern=100 call=64/100
// - Gas Used: 3204275
// - Storage Diff: 12
// - CPU Cycles: 2923678
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_75_after 1235001545
// STATE CLOCK launchpad_claim_100_76_before 1235001550
// Launchpad Numerics CollectReward pattern=100 call=65/100
// - Gas Used: 3205255
// - Storage Diff: 12
// - CPU Cycles: 2924658
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_76_after 1235001550
// STATE CLOCK launchpad_claim_100_77_before 1235001555
// Launchpad Numerics CollectReward pattern=100 call=66/100
// - Gas Used: 3192852
// - Storage Diff: 12
// - CPU Cycles: 2912255
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_77_after 1235001555
// STATE CLOCK launchpad_claim_100_78_before 1235001560
// Launchpad Numerics CollectReward pattern=100 call=67/100
// - Gas Used: 3192852
// - Storage Diff: 12
// - CPU Cycles: 2912255
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_78_after 1235001560
// STATE CLOCK launchpad_claim_100_79_before 1235001565
// Launchpad Numerics CollectReward pattern=100 call=68/100
// - Gas Used: 3194319
// - Storage Diff: 12
// - CPU Cycles: 2913722
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_79_after 1235001565
// STATE CLOCK launchpad_claim_100_80_before 1235001570
// Launchpad Numerics CollectReward pattern=100 call=69/100
// - Gas Used: 3194315
// - Storage Diff: 12
// - CPU Cycles: 2913718
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_80_after 1235001570
// STATE CLOCK launchpad_claim_100_81_before 1235001575
// Launchpad Numerics CollectReward pattern=100 call=70/100
// - Gas Used: 3194319
// - Storage Diff: 12
// - CPU Cycles: 2913722
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_81_after 1235001575
// STATE CLOCK launchpad_claim_100_82_before 1235001580
// Launchpad Numerics CollectReward pattern=100 call=71/100
// - Gas Used: 3203788
// - Storage Diff: 12
// - CPU Cycles: 2923191
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_82_after 1235001580
// STATE CLOCK launchpad_claim_100_83_before 1235001585
// Launchpad Numerics CollectReward pattern=100 call=72/100
// - Gas Used: 3204768
// - Storage Diff: 12
// - CPU Cycles: 2924171
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_83_after 1235001585
// STATE CLOCK launchpad_claim_100_84_before 1235001590
// Launchpad Numerics CollectReward pattern=100 call=73/100
// - Gas Used: 3201473
// - Storage Diff: 12
// - CPU Cycles: 2920876
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_84_after 1235001590
// STATE CLOCK launchpad_claim_100_85_before 1235001595
// Launchpad Numerics CollectReward pattern=100 call=74/100
// - Gas Used: 3206235
// - Storage Diff: 12
// - CPU Cycles: 2925638
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_85_after 1235001595
// STATE CLOCK launchpad_claim_100_86_before 1235001600
// Launchpad Numerics CollectReward pattern=100 call=75/100
// - Gas Used: 3204768
// - Storage Diff: 12
// - CPU Cycles: 2924171
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_86_after 1235001600
// STATE CLOCK launchpad_claim_100_87_before 1235001605
// Launchpad Numerics CollectReward pattern=100 call=76/100
// - Gas Used: 3206235
// - Storage Diff: 12
// - CPU Cycles: 2925638
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_87_after 1235001605
// STATE CLOCK launchpad_claim_100_88_before 1235001610
// Launchpad Numerics CollectReward pattern=100 call=77/100
// - Gas Used: 3205748
// - Storage Diff: 12
// - CPU Cycles: 2925151
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_88_after 1235001610
// STATE CLOCK launchpad_claim_100_89_before 1235001615
// Launchpad Numerics CollectReward pattern=100 call=78/100
// - Gas Used: 3206728
// - Storage Diff: 12
// - CPU Cycles: 2926131
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_89_after 1235001615
// STATE CLOCK launchpad_claim_100_90_before 1235001620
// Launchpad Numerics CollectReward pattern=100 call=79/100
// - Gas Used: 3202449
// - Storage Diff: 12
// - CPU Cycles: 2921852
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_90_after 1235001620
// STATE CLOCK launchpad_claim_100_91_before 1235001625
// Launchpad Numerics CollectReward pattern=100 call=80/100
// - Gas Used: 3206235
// - Storage Diff: 12
// - CPU Cycles: 2925638
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_91_after 1235001625
// STATE CLOCK launchpad_claim_100_92_before 1235001630
// Launchpad Numerics CollectReward pattern=100 call=81/100
// - Gas Used: 3207215
// - Storage Diff: 12
// - CPU Cycles: 2926618
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_92_after 1235001630
// STATE CLOCK launchpad_claim_100_93_before 1235001635
// Launchpad Numerics CollectReward pattern=100 call=82/100
// - Gas Used: 3206235
// - Storage Diff: 12
// - CPU Cycles: 2925638
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_93_after 1235001635
// STATE CLOCK launchpad_claim_100_94_before 1235001640
// Launchpad Numerics CollectReward pattern=100 call=83/100
// - Gas Used: 3206728
// - Storage Diff: 12
// - CPU Cycles: 2926131
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_94_after 1235001640
// STATE CLOCK launchpad_claim_100_95_before 1235001645
// Launchpad Numerics CollectReward pattern=100 call=84/100
// - Gas Used: 3207215
// - Storage Diff: 12
// - CPU Cycles: 2926618
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_95_after 1235001645
// STATE CLOCK launchpad_claim_100_96_before 1235001650
// Launchpad Numerics CollectReward pattern=100 call=85/100
// - Gas Used: 3193339
// - Storage Diff: 12
// - CPU Cycles: 2912742
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_96_after 1235001650
// STATE CLOCK launchpad_claim_100_97_before 1235001655
// Launchpad Numerics CollectReward pattern=100 call=86/100
// - Gas Used: 3209373
// - Storage Diff: 18
// - CPU Cycles: 2913722
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_97_after 1235001655
// STATE CLOCK launchpad_claim_100_98_before 1235001660
// Launchpad Numerics CollectReward pattern=100 call=87/100
// - Gas Used: 3197457
// - Storage Diff: 18
// - CPU Cycles: 2901806
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_98_after 1235001660
// STATE CLOCK launchpad_claim_100_99_before 1235001665
// Launchpad Numerics CollectReward pattern=100 call=88/100
// - Gas Used: 3197457
// - Storage Diff: 18
// - CPU Cycles: 2901806
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_99_after 1235001665
// STATE CLOCK launchpad_claim_100_100_before 1235001670
// Launchpad Numerics CollectReward pattern=100 call=89/100
// - Gas Used: 3220368
// - Storage Diff: 18
// - CPU Cycles: 2921255
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_100_after 1235001670
// STATE CLOCK launchpad_claim_100_101_before 1235001675
// Launchpad Numerics CollectReward pattern=100 call=90/100
// - Gas Used: 3217077
// - Storage Diff: 18
// - CPU Cycles: 2917964
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_101_after 1235001675
// STATE CLOCK launchpad_claim_100_102_before 1235001680
// Launchpad Numerics CollectReward pattern=100 call=91/100
// - Gas Used: 3221839
// - Storage Diff: 18
// - CPU Cycles: 2922726
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_102_after 1235001680
// STATE CLOCK launchpad_claim_100_103_before 1235001685
// Launchpad Numerics CollectReward pattern=100 call=92/100
// - Gas Used: 3220859
// - Storage Diff: 18
// - CPU Cycles: 2921746
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_103_after 1235001685
// STATE CLOCK launchpad_claim_100_104_before 1235001690
// Launchpad Numerics CollectReward pattern=100 call=93/100
// - Gas Used: 3221839
// - Storage Diff: 18
// - CPU Cycles: 2922726
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_104_after 1235001690
// STATE CLOCK launchpad_claim_100_105_before 1235001695
// Launchpad Numerics CollectReward pattern=100 call=94/100
// - Gas Used: 3221352
// - Storage Diff: 18
// - CPU Cycles: 2922239
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_105_after 1235001695
// STATE CLOCK launchpad_claim_100_106_before 1235001700
// Launchpad Numerics CollectReward pattern=100 call=95/100
// - Gas Used: 3213772
// - Storage Diff: 12
// - CPU Cycles: 2933175
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_106_after 1235001700
// STATE CLOCK launchpad_claim_100_107_before 1235001705
// Launchpad Numerics CollectReward pattern=100 call=96/100
// - Gas Used: 3207095
// - Storage Diff: 12
// - CPU Cycles: 2926498
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_107_after 1235001705
// STATE CLOCK launchpad_claim_100_108_before 1235001710
// Launchpad Numerics CollectReward pattern=100 call=97/100
// - Gas Used: 3203319
// - Storage Diff: 12
// - CPU Cycles: 2922722
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_108_after 1235001710
// STATE CLOCK launchpad_claim_100_109_before 1235001715
// Launchpad Numerics CollectReward pattern=100 call=98/100
// - Gas Used: 3202832
// - Storage Diff: 12
// - CPU Cycles: 2922235
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_109_after 1235001715
// STATE CLOCK launchpad_claim_100_110_before 1235001720
// Launchpad Numerics CollectReward pattern=100 call=99/100
// - Gas Used: 3203319
// - Storage Diff: 12
// - CPU Cycles: 2922722
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_110_after 1235001720
// STATE CLOCK launchpad_claim_100_111_before 1235001725
// Launchpad Numerics CollectReward pattern=100 call=100/100
// - Gas Used: 3203812
// - Storage Diff: 12
// - CPU Cycles: 2923215
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_111_after 1235001725
// STATE launchpad-numerics phase=claimed-pattern-1 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=35987 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-pattern-10 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=644752419472195378092327733873980578 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=55 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=34111 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69254 record_created_offset=55 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-pattern-100 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1030928654824012160364300924622681117 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=555 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=33165 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69354 record_created_offset=555 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_withdraw_1_before 1237505495
// Launchpad Numerics CollectDepositGns call=1/256
// - Gas Used: 8142787
// - Storage Diff: -3321
// - CPU Cycles: 7015215
// - Realm gno.land/r/gnoswap/gns: 2055
// - Realm gno.land/r/gnoswap/launchpad: -5376
// STATE CLOCK launchpad_withdraw_1_after 1237505495
// STATE launchpad-numerics phase=withdrawn-stage-1 global_staked=255000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=1000000 tier_deposit_count=256 tier_withdraw_count=1 tier_collected=4666860 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=4666860 manager_active_deposit=255000000 manager_active_claimed=3687346 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=255 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_2_before 1237505500
// Launchpad Numerics CollectDepositGns call=2/256
// - Gas Used: 7726286
// - Storage Diff: -5372
// - CPU Cycles: 6731352
// - Realm gno.land/r/gnoswap/launchpad: -5372
// STATE CLOCK launchpad_withdraw_2_after 1237505500
// STATE CLOCK launchpad_withdraw_3_before 1237505505
// Launchpad Numerics CollectDepositGns call=3/256
// - Gas Used: 7555134
// - Storage Diff: -1897
// - CPU Cycles: 6585597
// - Realm gno.land/r/gnoswap/launchpad: -1897
// STATE CLOCK launchpad_withdraw_3_after 1237505505
// STATE CLOCK launchpad_withdraw_4_before 1237505510
// Launchpad Numerics CollectDepositGns call=4/256
// - Gas Used: 7701332
// - Storage Diff: -5334
// - CPU Cycles: 6708798
// - Realm gno.land/r/gnoswap/launchpad: -5334
// STATE CLOCK launchpad_withdraw_4_after 1237505510
// STATE CLOCK launchpad_withdraw_5_before 1237505515
// Launchpad Numerics CollectDepositGns call=5/256
// - Gas Used: 7628148
// - Storage Diff: -1902
// - CPU Cycles: 6637936
// - Realm gno.land/r/gnoswap/launchpad: -1902
// STATE CLOCK launchpad_withdraw_5_after 1237505515
// STATE CLOCK launchpad_withdraw_6_before 1237505520
// Launchpad Numerics CollectDepositGns call=6/256
// - Gas Used: 7759766
// - Storage Diff: -5374
// - CPU Cycles: 6748392
// - Realm gno.land/r/gnoswap/launchpad: -5374
// STATE CLOCK launchpad_withdraw_6_after 1237505520
// STATE CLOCK launchpad_withdraw_7_before 1237505525
// Launchpad Numerics CollectDepositGns call=7/256
// - Gas Used: 7754924
// - Storage Diff: -5369
// - CPU Cycles: 6746175
// - Realm gno.land/r/gnoswap/launchpad: -5369
// STATE CLOCK launchpad_withdraw_7_after 1237505525
// STATE CLOCK launchpad_withdraw_8_before 1237505530
// Launchpad Numerics CollectDepositGns call=8/256
// - Gas Used: 7628257
// - Storage Diff: -1902
// - CPU Cycles: 6637856
// - Realm gno.land/r/gnoswap/launchpad: -1902
// STATE CLOCK launchpad_withdraw_8_after 1237505530
// STATE CLOCK launchpad_withdraw_9_before 1237505535
// Launchpad Numerics CollectDepositGns call=9/256
// - Gas Used: 7553437
// - Storage Diff: -1897
// - CPU Cycles: 6582574
// - Realm gno.land/r/gnoswap/launchpad: -1902
// - Realm gno.land/r/onbloc/obl: 5
// STATE CLOCK launchpad_withdraw_9_after 1237505535
// STATE CLOCK launchpad_withdraw_10_before 1237505540
// Launchpad Numerics CollectDepositGns call=10/256
// - Gas Used: 7588785
// - Storage Diff: -1897
// - CPU Cycles: 6607837
// - Realm gno.land/r/gnoswap/launchpad: -1915
// - Realm gno.land/r/onbloc/obl: 18
// STATE CLOCK launchpad_withdraw_10_after 1237505540
// STATE CLOCK launchpad_withdraw_11_before 1237505545
// Launchpad Numerics CollectDepositGns call=11/256
// - Gas Used: 7558667
// - Storage Diff: -1916
// - CPU Cycles: 6591611
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_11_after 1237505545
// STATE CLOCK launchpad_withdraw_12_before 1237505550
// Launchpad Numerics CollectDepositGns call=12/256
// - Gas Used: 7647287
// - Storage Diff: -1904
// - CPU Cycles: 6656883
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_12_after 1237505550
// STATE CLOCK launchpad_withdraw_13_before 1237505555
// Launchpad Numerics CollectDepositGns call=13/256
// - Gas Used: 7772626
// - Storage Diff: -5372
// - CPU Cycles: 6757442
// - Realm gno.land/r/gnoswap/launchpad: -5372
// STATE CLOCK launchpad_withdraw_13_after 1237505555
// STATE CLOCK launchpad_withdraw_14_before 1237505560
// Launchpad Numerics CollectDepositGns call=14/256
// - Gas Used: 7654389
// - Storage Diff: -1904
// - CPU Cycles: 6657043
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_14_after 1237505560
// STATE CLOCK launchpad_withdraw_15_before 1237505565
// Launchpad Numerics CollectDepositGns call=15/256
// - Gas Used: 7603915
// - Storage Diff: -1903
// - CPU Cycles: 6613205
// - Realm gno.land/r/gnoswap/launchpad: -1903
// STATE CLOCK launchpad_withdraw_15_after 1237505565
// STATE CLOCK launchpad_withdraw_16_before 1237505570
// Launchpad Numerics CollectDepositGns call=16/256
// - Gas Used: 7577874
// - Storage Diff: -1916
// - CPU Cycles: 6604713
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_16_after 1237505570
// STATE CLOCK launchpad_withdraw_17_before 1237505575
// Launchpad Numerics CollectDepositGns call=17/256
// - Gas Used: 7817175
// - Storage Diff: -8734
// - CPU Cycles: 6815288
// - Realm gno.land/r/gnoswap/launchpad: -8734
// STATE CLOCK launchpad_withdraw_17_after 1237505575
// STATE CLOCK launchpad_withdraw_18_before 1237505580
// Launchpad Numerics CollectDepositGns call=18/256
// - Gas Used: 7657032
// - Storage Diff: -1904
// - CPU Cycles: 6667117
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_18_after 1237505580
// STATE CLOCK launchpad_withdraw_19_before 1237505585
// Launchpad Numerics CollectDepositGns call=19/256
// - Gas Used: 7676960
// - Storage Diff: -1904
// - CPU Cycles: 6676615
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_19_after 1237505585
// STATE CLOCK launchpad_withdraw_20_before 1237505590
// Launchpad Numerics CollectDepositGns call=20/256
// - Gas Used: 7571264
// - Storage Diff: -1916
// - CPU Cycles: 6602417
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_20_after 1237505590
// STATE CLOCK launchpad_withdraw_21_before 1237505595
// Launchpad Numerics CollectDepositGns call=21/256
// - Gas Used: 7647738
// - Storage Diff: -1904
// - CPU Cycles: 6657778
// - Realm gno.land/r/gnoswap/launchpad: -1904
// STATE CLOCK launchpad_withdraw_21_after 1237505595
// STATE CLOCK launchpad_withdraw_22_before 1237505600
// Launchpad Numerics CollectDepositGns call=22/256
// - Gas Used: 7606300
// - Storage Diff: -1903
// - CPU Cycles: 6622139
// - Realm gno.land/r/gnoswap/launchpad: -1903
// STATE CLOCK launchpad_withdraw_22_after 1237505600
// STATE CLOCK launchpad_withdraw_23_before 1237505605
// Launchpad Numerics CollectDepositGns call=23/256
// - Gas Used: 7580112
// - Storage Diff: -1916
// - CPU Cycles: 6613647
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_23_after 1237505605
// STATE CLOCK launchpad_withdraw_24_before 1237505610
// Launchpad Numerics CollectDepositGns call=24/256
// - Gas Used: 7693032
// - Storage Diff: -5202
// - CPU Cycles: 6706589
// - Realm gno.land/r/gnoswap/launchpad: -5202
// STATE CLOCK launchpad_withdraw_24_after 1237505610
// STATE CLOCK launchpad_withdraw_25_before 1237505615
// Launchpad Numerics CollectDepositGns call=25/256
// - Gas Used: 7779804
// - Storage Diff: -5125
// - CPU Cycles: 6762624
// - Realm gno.land/r/gnoswap/launchpad: -5125
// STATE CLOCK launchpad_withdraw_25_after 1237505615
// STATE CLOCK launchpad_withdraw_26_before 1237505620
// Launchpad Numerics CollectDepositGns call=26/256
// - Gas Used: 7551138
// - Storage Diff: -1916
// - CPU Cycles: 6583209
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_26_after 1237505620
// STATE CLOCK launchpad_withdraw_27_before 1237505625
// Launchpad Numerics CollectDepositGns call=27/256
// - Gas Used: 7550194
// - Storage Diff: -1916
// - CPU Cycles: 6583864
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_27_after 1237505625
// STATE CLOCK launchpad_withdraw_28_before 1237505630
// Launchpad Numerics CollectDepositGns call=28/256
// - Gas Used: 7557694
// - Storage Diff: -1916
// - CPU Cycles: 6592963
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_28_after 1237505630
// STATE CLOCK launchpad_withdraw_29_before 1237505635
// Launchpad Numerics CollectDepositGns call=29/256
// - Gas Used: 7555770
// - Storage Diff: -1916
// - CPU Cycles: 6592638
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_29_after 1237505635
// STATE CLOCK launchpad_withdraw_30_before 1237505640
// Launchpad Numerics CollectDepositGns call=30/256
// - Gas Used: 7546134
// - Storage Diff: -1916
// - CPU Cycles: 6584601
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_30_after 1237505640
// STATE CLOCK launchpad_withdraw_31_before 1237505645
// Launchpad Numerics CollectDepositGns call=31/256
// - Gas Used: 7581210
// - Storage Diff: -1915
// - CPU Cycles: 6599743
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_31_after 1237505645
// STATE CLOCK launchpad_withdraw_32_before 1237505650
// Launchpad Numerics CollectDepositGns call=32/256
// - Gas Used: 7580269
// - Storage Diff: -1915
// - CPU Cycles: 6600398
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_32_after 1237505650
// STATE launchpad-numerics phase=withdrawn-stage-32 global_staked=224000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=32000000 tier_deposit_count=256 tier_withdraw_count=32 tier_collected=33915241 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=33915241 manager_active_deposit=224000000 manager_active_claimed=2632955 manager_active_debt=235972506899103895716586901958147712416000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=224 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69275 record_created_offset=160 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_33_before 1237505655
// Launchpad Numerics CollectDepositGns call=33/256
// - Gas Used: 7569656
// - Storage Diff: -1915
// - CPU Cycles: 6591381
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_33_after 1237505655
// STATE CLOCK launchpad_withdraw_34_before 1237505660
// Launchpad Numerics CollectDepositGns call=34/256
// - Gas Used: 7567980
// - Storage Diff: -1915
// - CPU Cycles: 6591301
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_34_after 1237505660
// STATE CLOCK launchpad_withdraw_35_before 1237505665
// Launchpad Numerics CollectDepositGns call=35/256
// - Gas Used: 7567039
// - Storage Diff: -1915
// - CPU Cycles: 6591956
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_35_after 1237505665
// STATE CLOCK launchpad_withdraw_36_before 1237505670
// Launchpad Numerics CollectDepositGns call=36/256
// - Gas Used: 7564628
// - Storage Diff: -1915
// - CPU Cycles: 6591141
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_36_after 1237505670
// STATE CLOCK launchpad_withdraw_37_before 1237505675
// Launchpad Numerics CollectDepositGns call=37/256
// - Gas Used: 7656551
// - Storage Diff: -1914
// - CPU Cycles: 6668236
// - Realm gno.land/r/gnoswap/launchpad: -1914
// STATE CLOCK launchpad_withdraw_37_after 1237505675
// STATE CLOCK launchpad_withdraw_38_before 1237505680
// Launchpad Numerics CollectDepositGns call=38/256
// - Gas Used: 7644663
// - Storage Diff: -1915
// - CPU Cycles: 6657367
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_38_after 1237505680
// STATE CLOCK launchpad_withdraw_39_before 1237505685
// Launchpad Numerics CollectDepositGns call=39/256
// - Gas Used: 7666712
// - Storage Diff: -1915
// - CPU Cycles: 6662818
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_39_after 1237505685
// STATE CLOCK launchpad_withdraw_40_before 1237505690
// Launchpad Numerics CollectDepositGns call=40/256
// - Gas Used: 7656834
// - Storage Diff: -1915
// - CPU Cycles: 6654536
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_40_after 1237505690
// STATE CLOCK launchpad_withdraw_41_before 1237505695
// Launchpad Numerics CollectDepositGns call=41/256
// - Gas Used: 7655161
// - Storage Diff: -1915
// - CPU Cycles: 6654459
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_41_after 1237505695
// STATE CLOCK launchpad_withdraw_42_before 1237505700
// Launchpad Numerics CollectDepositGns call=42/256
// - Gas Used: 7654220
// - Storage Diff: -1915
// - CPU Cycles: 6655114
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_42_after 1237505700
// STATE CLOCK launchpad_withdraw_43_before 1237505705
// Launchpad Numerics CollectDepositGns call=43/256
// - Gas Used: 7651809
// - Storage Diff: -1915
// - CPU Cycles: 6654299
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_43_after 1237505705
// STATE CLOCK launchpad_withdraw_44_before 1237505710
// Launchpad Numerics CollectDepositGns call=44/256
// - Gas Used: 7650868
// - Storage Diff: -1915
// - CPU Cycles: 6654954
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_44_after 1237505710
// STATE CLOCK launchpad_withdraw_45_before 1237505715
// Launchpad Numerics CollectDepositGns call=45/256
// - Gas Used: 7649192
// - Storage Diff: -1915
// - CPU Cycles: 6654874
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_45_after 1237505715
// STATE CLOCK launchpad_withdraw_46_before 1237505720
// Launchpad Numerics CollectDepositGns call=46/256
// - Gas Used: 7767253
// - Storage Diff: -5384
// - CPU Cycles: 6756656
// - Realm gno.land/r/gnoswap/launchpad: -5384
// STATE CLOCK launchpad_withdraw_46_after 1237505720
// STATE CLOCK launchpad_withdraw_47_before 1237505725
// Launchpad Numerics CollectDepositGns call=47/256
// - Gas Used: 7549641
// - Storage Diff: -1915
// - CPU Cycles: 6581739
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_47_after 1237505725
// STATE CLOCK launchpad_withdraw_48_before 1237505730
// Launchpad Numerics CollectDepositGns call=48/256
// - Gas Used: 7539028
// - Storage Diff: -1915
// - CPU Cycles: 6572722
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_48_after 1237505730
// STATE CLOCK launchpad_withdraw_49_before 1237505735
// Launchpad Numerics CollectDepositGns call=49/256
// - Gas Used: 7538332
// - Storage Diff: -1915
// - CPU Cycles: 6573622
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_49_after 1237505735
// STATE CLOCK launchpad_withdraw_50_before 1237505740
// Launchpad Numerics CollectDepositGns call=50/256
// - Gas Used: 7535676
// - Storage Diff: -1915
// - CPU Cycles: 6572562
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_50_after 1237505740
// STATE CLOCK launchpad_withdraw_51_before 1237505745
// Launchpad Numerics CollectDepositGns call=51/256
// - Gas Used: 7535715
// - Storage Diff: -1915
// - CPU Cycles: 6574197
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_51_after 1237505745
// STATE CLOCK launchpad_withdraw_52_before 1237505750
// Launchpad Numerics CollectDepositGns call=52/256
// - Gas Used: 7649332
// - Storage Diff: -1914
// - CPU Cycles: 6661014
// - Realm gno.land/r/gnoswap/launchpad: -1914
// STATE CLOCK launchpad_withdraw_52_after 1237505750
// STATE CLOCK launchpad_withdraw_53_before 1237505755
// Launchpad Numerics CollectDepositGns call=53/256
// - Gas Used: 7644914
// - Storage Diff: -1915
// - CPU Cycles: 6657615
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_53_after 1237505755
// STATE CLOCK launchpad_withdraw_54_before 1237505760
// Launchpad Numerics CollectDepositGns call=54/256
// - Gas Used: 7657973
// - Storage Diff: -1915
// - CPU Cycles: 6655522
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_54_after 1237505760
// STATE CLOCK launchpad_withdraw_55_before 1237505765
// Launchpad Numerics CollectDepositGns call=55/256
// - Gas Used: 7647360
// - Storage Diff: -1915
// - CPU Cycles: 6646505
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_55_after 1237505765
// STATE CLOCK launchpad_withdraw_56_before 1237505770
// Launchpad Numerics CollectDepositGns call=56/256
// - Gas Used: 7645684
// - Storage Diff: -1915
// - CPU Cycles: 6646425
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_56_after 1237505770
// STATE CLOCK launchpad_withdraw_57_before 1237505775
// Launchpad Numerics CollectDepositGns call=57/256
// - Gas Used: 7644743
// - Storage Diff: -1915
// - CPU Cycles: 6647080
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_57_after 1237505775
// STATE CLOCK launchpad_withdraw_58_before 1237505780
// Launchpad Numerics CollectDepositGns call=58/256
// - Gas Used: 7642332
// - Storage Diff: -1915
// - CPU Cycles: 6646265
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_58_after 1237505780
// STATE CLOCK launchpad_withdraw_59_before 1237505785
// Launchpad Numerics CollectDepositGns call=59/256
// - Gas Used: 7641391
// - Storage Diff: -1915
// - CPU Cycles: 6646920
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_59_after 1237505785
// STATE CLOCK launchpad_withdraw_60_before 1237505790
// Launchpad Numerics CollectDepositGns call=60/256
// - Gas Used: 7767586
// - Storage Diff: -5384
// - CPU Cycles: 6757592
// - Realm gno.land/r/gnoswap/launchpad: -5384
// STATE CLOCK launchpad_withdraw_60_after 1237505790
// STATE CLOCK launchpad_withdraw_61_before 1237505795
// Launchpad Numerics CollectDepositGns call=61/256
// - Gas Used: 7551383
// - Storage Diff: -1915
// - CPU Cycles: 6583457
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_61_after 1237505795
// STATE CLOCK launchpad_withdraw_62_before 1237505800
// Launchpad Numerics CollectDepositGns call=62/256
// - Gas Used: 7540770
// - Storage Diff: -1915
// - CPU Cycles: 6574440
// - Realm gno.land/r/gnoswap/launchpad: -1915
// STATE CLOCK launchpad_withdraw_62_after 1237505800
// STATE CLOCK launchpad_withdraw_63_before 1237505805
// Launchpad Numerics CollectDepositGns call=63/256
// - Gas Used: 7540098
// - Storage Diff: -1923
// - CPU Cycles: 6575340
// - Realm gno.land/r/gnoswap/launchpad: -1923
// STATE CLOCK launchpad_withdraw_63_after 1237505805
// STATE CLOCK launchpad_withdraw_64_before 1237505810
// Launchpad Numerics CollectDepositGns call=64/256
// - Gas Used: 7538237
// - Storage Diff: -1926
// - CPU Cycles: 6575015
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_64_after 1237505810
// STATE CLOCK launchpad_withdraw_65_before 1237505815
// Launchpad Numerics CollectDepositGns call=65/256
// - Gas Used: 7536809
// - Storage Diff: -1927
// - CPU Cycles: 6575180
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_65_after 1237505815
// STATE CLOCK launchpad_withdraw_66_before 1237505820
// Launchpad Numerics CollectDepositGns call=66/256
// - Gas Used: 7649318
// - Storage Diff: -1926
// - CPU Cycles: 6660772
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_66_after 1237505820
// STATE CLOCK launchpad_withdraw_67_before 1237505825
// Launchpad Numerics CollectDepositGns call=67/256
// - Gas Used: 7637418
// - Storage Diff: -1927
// - CPU Cycles: 6649903
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_67_after 1237505825
// STATE CLOCK launchpad_withdraw_68_before 1237505830
// Launchpad Numerics CollectDepositGns call=68/256
// - Gas Used: 7764597
// - Storage Diff: -5407
// - CPU Cycles: 6755092
// - Realm gno.land/r/gnoswap/launchpad: -5407
// STATE CLOCK launchpad_withdraw_68_after 1237505830
// STATE CLOCK launchpad_withdraw_69_before 1237505835
// Launchpad Numerics CollectDepositGns call=69/256
// - Gas Used: 7549800
// - Storage Diff: -1927
// - CPU Cycles: 6581739
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_69_after 1237505835
// STATE CLOCK launchpad_withdraw_70_before 1237505840
// Launchpad Numerics CollectDepositGns call=70/256
// - Gas Used: 7539175
// - Storage Diff: -1927
// - CPU Cycles: 6572722
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_70_after 1237505840
// STATE CLOCK launchpad_withdraw_71_before 1237505845
// Launchpad Numerics CollectDepositGns call=71/256
// - Gas Used: 7539202
// - Storage Diff: -1927
// - CPU Cycles: 6574357
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_71_after 1237505845
// STATE CLOCK launchpad_withdraw_72_before 1237505850
// Launchpad Numerics CollectDepositGns call=72/256
// - Gas Used: 7535802
// - Storage Diff: -1927
// - CPU Cycles: 6572565
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_72_after 1237505850
// STATE CLOCK launchpad_withdraw_73_before 1237505855
// Launchpad Numerics CollectDepositGns call=73/256
// - Gas Used: 7535829
// - Storage Diff: -1927
// - CPU Cycles: 6574200
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_73_after 1237505855
// STATE CLOCK launchpad_withdraw_74_before 1237505860
// Launchpad Numerics CollectDepositGns call=74/256
// - Gas Used: 7649566
// - Storage Diff: -1926
// - CPU Cycles: 6661017
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_74_after 1237505860
// STATE CLOCK launchpad_withdraw_75_before 1237505865
// Launchpad Numerics CollectDepositGns call=75/256
// - Gas Used: 7645868
// - Storage Diff: -1927
// - CPU Cycles: 6658350
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_75_after 1237505865
// STATE CLOCK launchpad_withdraw_76_before 1237505870
// Launchpad Numerics CollectDepositGns call=76/256
// - Gas Used: 7658963
// - Storage Diff: -1927
// - CPU Cycles: 6656257
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_76_after 1237505870
// STATE CLOCK launchpad_withdraw_77_before 1237505875
// Launchpad Numerics CollectDepositGns call=77/256
// - Gas Used: 7648338
// - Storage Diff: -1927
// - CPU Cycles: 6647240
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_77_after 1237505875
// STATE CLOCK launchpad_withdraw_78_before 1237505880
// Launchpad Numerics CollectDepositGns call=78/256
// - Gas Used: 7646650
// - Storage Diff: -1927
// - CPU Cycles: 6647160
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_78_after 1237505880
// STATE CLOCK launchpad_withdraw_79_before 1237505885
// Launchpad Numerics CollectDepositGns call=79/256
// - Gas Used: 7645697
// - Storage Diff: -1927
// - CPU Cycles: 6647815
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_79_after 1237505885
// STATE CLOCK launchpad_withdraw_80_before 1237505890
// Launchpad Numerics CollectDepositGns call=80/256
// - Gas Used: 7644006
// - Storage Diff: -1927
// - CPU Cycles: 6647732
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_80_after 1237505890
// STATE CLOCK launchpad_withdraw_81_before 1237505895
// Launchpad Numerics CollectDepositGns call=81/256
// - Gas Used: 7642321
// - Storage Diff: -1927
// - CPU Cycles: 6647655
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_81_after 1237505895
// STATE CLOCK launchpad_withdraw_82_before 1237505900
// Launchpad Numerics CollectDepositGns call=82/256
// - Gas Used: 7764897
// - Storage Diff: -5407
// - CPU Cycles: 6756028
// - Realm gno.land/r/gnoswap/launchpad: -5407
// STATE CLOCK launchpad_withdraw_82_after 1237505900
// STATE CLOCK launchpad_withdraw_83_before 1237505905
// Launchpad Numerics CollectDepositGns call=83/256
// - Gas Used: 7551518
// - Storage Diff: -1927
// - CPU Cycles: 6583457
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_83_after 1237505905
// STATE CLOCK launchpad_withdraw_84_before 1237505910
// Launchpad Numerics CollectDepositGns call=84/256
// - Gas Used: 7549830
// - Storage Diff: -1927
// - CPU Cycles: 6583377
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_84_after 1237505910
// STATE CLOCK launchpad_withdraw_85_before 1237505915
// Launchpad Numerics CollectDepositGns call=85/256
// - Gas Used: 7549857
// - Storage Diff: -1927
// - CPU Cycles: 6585012
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_85_after 1237505915
// STATE CLOCK launchpad_withdraw_86_before 1237505920
// Launchpad Numerics CollectDepositGns call=86/256
// - Gas Used: 7546454
// - Storage Diff: -1927
// - CPU Cycles: 6583217
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_86_after 1237505920
// STATE CLOCK launchpad_withdraw_87_before 1237505925
// Launchpad Numerics CollectDepositGns call=87/256
// - Gas Used: 7546481
// - Storage Diff: -1927
// - CPU Cycles: 6584852
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_87_after 1237505925
// STATE CLOCK launchpad_withdraw_88_before 1237505930
// Launchpad Numerics CollectDepositGns call=88/256
// - Gas Used: 7659241
// - Storage Diff: -1926
// - CPU Cycles: 6670689
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_88_after 1237505930
// STATE CLOCK launchpad_withdraw_89_before 1237505935
// Launchpad Numerics CollectDepositGns call=89/256
// - Gas Used: 7648076
// - Storage Diff: -1927
// - CPU Cycles: 6660555
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_89_after 1237505935
// STATE CLOCK launchpad_withdraw_90_before 1237505940
// Launchpad Numerics CollectDepositGns call=90/256
// - Gas Used: 7764946
// - Storage Diff: -5407
// - CPU Cycles: 6756713
// - Realm gno.land/r/gnoswap/launchpad: -5407
// STATE CLOCK launchpad_withdraw_90_after 1237505940
// STATE CLOCK launchpad_withdraw_91_before 1237505945
// Launchpad Numerics CollectDepositGns call=91/256
// - Gas Used: 7552253
// - Storage Diff: -1927
// - CPU Cycles: 6584192
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_91_after 1237505945
// STATE CLOCK launchpad_withdraw_92_before 1237505950
// Launchpad Numerics CollectDepositGns call=92/256
// - Gas Used: 7551300
// - Storage Diff: -1927
// - CPU Cycles: 6584847
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_92_after 1237505950
// STATE CLOCK launchpad_withdraw_93_before 1237505955
// Launchpad Numerics CollectDepositGns call=93/256
// - Gas Used: 7549857
// - Storage Diff: -1927
// - CPU Cycles: 6585012
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_93_after 1237505955
// STATE CLOCK launchpad_withdraw_94_before 1237505960
// Launchpad Numerics CollectDepositGns call=94/256
// - Gas Used: 7547924
// - Storage Diff: -1927
// - CPU Cycles: 6584687
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_94_after 1237505960
// STATE CLOCK launchpad_withdraw_95_before 1237505965
// Launchpad Numerics CollectDepositGns call=95/256
// - Gas Used: 7547216
// - Storage Diff: -1927
// - CPU Cycles: 6585587
// - Realm gno.land/r/gnoswap/launchpad: -1927
// STATE CLOCK launchpad_withdraw_95_after 1237505965
// STATE CLOCK launchpad_withdraw_96_before 1237505970
// Launchpad Numerics CollectDepositGns call=96/256
// - Gas Used: 7630502
// - Storage Diff: -1926
// - CPU Cycles: 6649441
// - Realm gno.land/r/gnoswap/launchpad: -1926
// STATE CLOCK launchpad_withdraw_96_after 1237505970
// STATE CLOCK launchpad_withdraw_97_before 1237505975
// Launchpad Numerics CollectDepositGns call=97/256
// - Gas Used: 7656972
// - Storage Diff: -1921
// - CPU Cycles: 6639307
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_97_after 1237505975
// STATE CLOCK launchpad_withdraw_98_before 1237505980
// Launchpad Numerics CollectDepositGns call=98/256
// - Gas Used: 7753844
// - Storage Diff: -11830
// - CPU Cycles: 6735849
// - Realm gno.land/r/gnoswap/launchpad: -11830
// STATE CLOCK launchpad_withdraw_98_after 1237505980
// STATE CLOCK launchpad_withdraw_99_before 1237505985
// Launchpad Numerics CollectDepositGns call=99/256
// - Gas Used: 7479706
// - Storage Diff: -1921
// - CPU Cycles: 6506675
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_99_after 1237505985
// STATE CLOCK launchpad_withdraw_100_before 1237505990
// Launchpad Numerics CollectDepositGns call=100/256
// - Gas Used: 7550233
// - Storage Diff: -1921
// - CPU Cycles: 6536504
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_100_after 1237505990
// STATE CLOCK launchpad_withdraw_101_before 1237505995
// Launchpad Numerics CollectDepositGns call=101/256
// - Gas Used: 7547750
// - Storage Diff: -1921
// - CPU Cycles: 6536427
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_101_after 1237505995
// STATE CLOCK launchpad_withdraw_102_before 1237506000
// Launchpad Numerics CollectDepositGns call=102/256
// - Gas Used: 7545999
// - Storage Diff: -1921
// - CPU Cycles: 6537082
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_102_after 1237506000
// STATE CLOCK launchpad_withdraw_103_before 1237506005
// Launchpad Numerics CollectDepositGns call=103/256
// - Gas Used: 7542778
// - Storage Diff: -1921
// - CPU Cycles: 6536267
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_103_after 1237506005
// STATE CLOCK launchpad_withdraw_104_before 1237506010
// Launchpad Numerics CollectDepositGns call=104/256
// - Gas Used: 7672876
// - Storage Diff: -5401
// - CPU Cycles: 6627912
// - Realm gno.land/r/gnoswap/launchpad: -5401
// STATE CLOCK launchpad_withdraw_104_after 1237506010
// STATE CLOCK launchpad_withdraw_105_before 1237506015
// Launchpad Numerics CollectDepositGns call=105/256
// - Gas Used: 7558453
// - Storage Diff: -1921
// - CPU Cycles: 6537482
// - Realm gno.land/r/gnoswap/launchpad: -1921
// STATE CLOCK launchpad_withdraw_105_after 1237506015
// STATE CLOCK launchpad_withdraw_106_before 1237506020
// Launchpad Numerics CollectDepositGns call=106/256
// - Gas Used: 7513076
// - Storage Diff: -1928
// - CPU Cycles: 6545604
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_106_after 1237506020
// STATE CLOCK launchpad_withdraw_107_before 1237506025
// Launchpad Numerics CollectDepositGns call=107/256
// - Gas Used: 7512120
// - Storage Diff: -1928
// - CPU Cycles: 6546259
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_107_after 1237506025
// STATE CLOCK launchpad_withdraw_108_before 1237506030
// Launchpad Numerics CollectDepositGns call=108/256
// - Gas Used: 7501489
// - Storage Diff: -1928
// - CPU Cycles: 6537239
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_108_after 1237506030
// STATE CLOCK launchpad_withdraw_109_before 1237506035
// Launchpad Numerics CollectDepositGns call=109/256
// - Gas Used: 7499798
// - Storage Diff: -1928
// - CPU Cycles: 6537159
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_109_after 1237506035
// STATE CLOCK launchpad_withdraw_110_before 1237506040
// Launchpad Numerics CollectDepositGns call=110/256
// - Gas Used: 7498107
// - Storage Diff: -1928
// - CPU Cycles: 6537079
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_110_after 1237506040
// STATE CLOCK launchpad_withdraw_111_before 1237506045
// Launchpad Numerics CollectDepositGns call=111/256
// - Gas Used: 7497151
// - Storage Diff: -1928
// - CPU Cycles: 6537734
// - Realm gno.land/r/gnoswap/launchpad: -1928
// STATE CLOCK launchpad_withdraw_111_after 1237506045
// STATE CLOCK launchpad_withdraw_112_before 1237506050
// Launchpad Numerics CollectDepositGns call=112/256
// - Gas Used: 7611934
// - Storage Diff: -1916
// - CPU Cycles: 6616992
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_112_after 1237506050
// STATE CLOCK launchpad_withdraw_113_before 1237506055
// Launchpad Numerics CollectDepositGns call=113/256
// - Gas Used: 7617716
// - Storage Diff: -1916
// - CPU Cycles: 6624385
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_113_after 1237506055
// STATE CLOCK launchpad_withdraw_114_before 1237506060
// Launchpad Numerics CollectDepositGns call=114/256
// - Gas Used: 7616760
// - Storage Diff: -1916
// - CPU Cycles: 6625040
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_114_after 1237506060
// STATE CLOCK launchpad_withdraw_115_before 1237506065
// Launchpad Numerics CollectDepositGns call=115/256
// - Gas Used: 7606129
// - Storage Diff: -1916
// - CPU Cycles: 6616020
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_115_after 1237506065
// STATE CLOCK launchpad_withdraw_116_before 1237506070
// Launchpad Numerics CollectDepositGns call=116/256
// - Gas Used: 7604438
// - Storage Diff: -1916
// - CPU Cycles: 6615940
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_116_after 1237506070
// STATE CLOCK launchpad_withdraw_117_before 1237506075
// Launchpad Numerics CollectDepositGns call=117/256
// - Gas Used: 7603482
// - Storage Diff: -1916
// - CPU Cycles: 6616595
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_117_after 1237506075
// STATE CLOCK launchpad_withdraw_118_before 1237506080
// Launchpad Numerics CollectDepositGns call=118/256
// - Gas Used: 7623748
// - Storage Diff: -5396
// - CPU Cycles: 6626751
// - Realm gno.land/r/gnoswap/launchpad: -5396
// STATE CLOCK launchpad_withdraw_118_after 1237506080
// STATE CLOCK launchpad_withdraw_119_before 1237506085
// Launchpad Numerics CollectDepositGns call=119/256
// - Gas Used: 7506259
// - Storage Diff: -1916
// - CPU Cycles: 6537176
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_119_after 1237506085
// STATE CLOCK launchpad_withdraw_120_before 1237506090
// Launchpad Numerics CollectDepositGns call=120/256
// - Gas Used: 7512773
// - Storage Diff: -1916
// - CPU Cycles: 6545301
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_120_after 1237506090
// STATE CLOCK launchpad_withdraw_121_before 1237506095
// Launchpad Numerics CollectDepositGns call=121/256
// - Gas Used: 7511817
// - Storage Diff: -1916
// - CPU Cycles: 6545956
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_121_after 1237506095
// STATE CLOCK launchpad_withdraw_122_before 1237506100
// Launchpad Numerics CollectDepositGns call=122/256
// - Gas Used: 7501186
// - Storage Diff: -1916
// - CPU Cycles: 6536936
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_122_after 1237506100
// STATE CLOCK launchpad_withdraw_123_before 1237506105
// Launchpad Numerics CollectDepositGns call=123/256
// - Gas Used: 7499495
// - Storage Diff: -1916
// - CPU Cycles: 6536856
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_123_after 1237506105
// STATE CLOCK launchpad_withdraw_124_before 1237506110
// Launchpad Numerics CollectDepositGns call=124/256
// - Gas Used: 7498539
// - Storage Diff: -1916
// - CPU Cycles: 6537511
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_124_after 1237506110
// STATE CLOCK launchpad_withdraw_125_before 1237506115
// Launchpad Numerics CollectDepositGns call=125/256
// - Gas Used: 7496113
// - Storage Diff: -1916
// - CPU Cycles: 6536696
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_125_after 1237506115
// STATE CLOCK launchpad_withdraw_126_before 1237506120
// Launchpad Numerics CollectDepositGns call=126/256
// - Gas Used: 7623427
// - Storage Diff: -5397
// - CPU Cycles: 6628101
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_126_after 1237506120
// STATE CLOCK launchpad_withdraw_127_before 1237506125
// Launchpad Numerics CollectDepositGns call=127/256
// - Gas Used: 7506994
// - Storage Diff: -1916
// - CPU Cycles: 6537911
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_127_after 1237506125
// STATE CLOCK launchpad_withdraw_128_before 1237506130
// Launchpad Numerics CollectDepositGns call=128/256
// - Gas Used: 7512035
// - Storage Diff: -1916
// - CPU Cycles: 6544563
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_128_after 1237506130
// STATE launchpad-numerics phase=withdrawn-stage-128 global_staked=128000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=128000000 tier_deposit_count=256 tier_withdraw_count=128 tier_collected=125042846 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=125042846 manager_active_deposit=128000000 manager_active_claimed=0 manager_active_debt=143161052288871807480826382395675884485000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=128 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69371 record_created_offset=640 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_129_before 1237506135
// Launchpad Numerics CollectDepositGns call=129/256
// - Gas Used: 7511079
// - Storage Diff: -1916
// - CPU Cycles: 6545218
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_129_after 1237506135
// STATE CLOCK launchpad_withdraw_130_before 1237506140
// Launchpad Numerics CollectDepositGns call=130/256
// - Gas Used: 7500448
// - Storage Diff: -1916
// - CPU Cycles: 6536198
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_130_after 1237506140
// STATE CLOCK launchpad_withdraw_131_before 1237506145
// Launchpad Numerics CollectDepositGns call=131/256
// - Gas Used: 7499492
// - Storage Diff: -1916
// - CPU Cycles: 6536853
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_131_after 1237506145
// STATE CLOCK launchpad_withdraw_132_before 1237506150
// Launchpad Numerics CollectDepositGns call=132/256
// - Gas Used: 7497069
// - Storage Diff: -1916
// - CPU Cycles: 6536041
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_132_after 1237506150
// STATE CLOCK launchpad_withdraw_133_before 1237506155
// Launchpad Numerics CollectDepositGns call=133/256
// - Gas Used: 7496113
// - Storage Diff: -1916
// - CPU Cycles: 6536696
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_133_after 1237506155
// STATE CLOCK launchpad_withdraw_134_before 1237506160
// Launchpad Numerics CollectDepositGns call=134/256
// - Gas Used: 7620901
// - Storage Diff: -5385
// - CPU Cycles: 6627246
// - Realm gno.land/r/gnoswap/launchpad: -5385
// STATE CLOCK launchpad_withdraw_134_after 1237506160
// STATE CLOCK launchpad_withdraw_135_before 1237506165
// Launchpad Numerics CollectDepositGns call=135/256
// - Gas Used: 7514464
// - Storage Diff: -1916
// - CPU Cycles: 6545381
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_135_after 1237506165
// STATE CLOCK launchpad_withdraw_136_before 1237506170
// Launchpad Numerics CollectDepositGns call=136/256
// - Gas Used: 7513508
// - Storage Diff: -1916
// - CPU Cycles: 6546036
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_136_after 1237506170
// STATE CLOCK launchpad_withdraw_137_before 1237506175
// Launchpad Numerics CollectDepositGns call=137/256
// - Gas Used: 7502877
// - Storage Diff: -1916
// - CPU Cycles: 6537016
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_137_after 1237506175
// STATE CLOCK launchpad_withdraw_138_before 1237506180
// Launchpad Numerics CollectDepositGns call=138/256
// - Gas Used: 7501186
// - Storage Diff: -1916
// - CPU Cycles: 6536936
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_138_after 1237506180
// STATE CLOCK launchpad_withdraw_139_before 1237506185
// Launchpad Numerics CollectDepositGns call=139/256
// - Gas Used: 7500230
// - Storage Diff: -1916
// - CPU Cycles: 6537591
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_139_after 1237506185
// STATE CLOCK launchpad_withdraw_140_before 1237506190
// Launchpad Numerics CollectDepositGns call=140/256
// - Gas Used: 7498536
// - Storage Diff: -1916
// - CPU Cycles: 6537508
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_140_after 1237506190
// STATE CLOCK launchpad_withdraw_141_before 1237506195
// Launchpad Numerics CollectDepositGns call=141/256
// - Gas Used: 7496848
// - Storage Diff: -1916
// - CPU Cycles: 6537431
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_141_after 1237506195
// STATE CLOCK launchpad_withdraw_142_before 1237506200
// Launchpad Numerics CollectDepositGns call=142/256
// - Gas Used: 7626326
// - Storage Diff: -1916
// - CPU Cycles: 6625117
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_142_after 1237506200
// STATE CLOCK launchpad_withdraw_143_before 1237506205
// Launchpad Numerics CollectDepositGns call=143/256
// - Gas Used: 7625370
// - Storage Diff: -1916
// - CPU Cycles: 6625772
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_143_after 1237506205
// STATE CLOCK launchpad_withdraw_144_before 1237506210
// Launchpad Numerics CollectDepositGns call=144/256
// - Gas Used: 7614739
// - Storage Diff: -1916
// - CPU Cycles: 6616752
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_144_after 1237506210
// STATE CLOCK launchpad_withdraw_145_before 1237506215
// Launchpad Numerics CollectDepositGns call=145/256
// - Gas Used: 7613048
// - Storage Diff: -1916
// - CPU Cycles: 6616672
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_145_after 1237506215
// STATE CLOCK launchpad_withdraw_146_before 1237506220
// Launchpad Numerics CollectDepositGns call=146/256
// - Gas Used: 7612092
// - Storage Diff: -1916
// - CPU Cycles: 6617327
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_146_after 1237506220
// STATE CLOCK launchpad_withdraw_147_before 1237506225
// Launchpad Numerics CollectDepositGns call=147/256
// - Gas Used: 7619107
// - Storage Diff: -5397
// - CPU Cycles: 6627123
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_147_after 1237506225
// STATE CLOCK launchpad_withdraw_148_before 1237506230
// Launchpad Numerics CollectDepositGns call=148/256
// - Gas Used: 7506991
// - Storage Diff: -1916
// - CPU Cycles: 6537908
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_148_after 1237506230
// STATE CLOCK launchpad_withdraw_149_before 1237506235
// Launchpad Numerics CollectDepositGns call=149/256
// - Gas Used: 7505300
// - Storage Diff: -1916
// - CPU Cycles: 6537828
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_149_after 1237506235
// STATE CLOCK launchpad_withdraw_150_before 1237506240
// Launchpad Numerics CollectDepositGns call=150/256
// - Gas Used: 7512546
// - Storage Diff: -1916
// - CPU Cycles: 6546685
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_150_after 1237506240
// STATE CLOCK launchpad_withdraw_151_before 1237506245
// Launchpad Numerics CollectDepositGns call=151/256
// - Gas Used: 7510858
// - Storage Diff: -1916
// - CPU Cycles: 6546608
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_151_after 1237506245
// STATE CLOCK launchpad_withdraw_152_before 1237506250
// Launchpad Numerics CollectDepositGns call=152/256
// - Gas Used: 7509902
// - Storage Diff: -1916
// - CPU Cycles: 6547263
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_152_after 1237506250
// STATE CLOCK launchpad_withdraw_153_before 1237506255
// Launchpad Numerics CollectDepositGns call=153/256
// - Gas Used: 7507476
// - Storage Diff: -1916
// - CPU Cycles: 6546448
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_153_after 1237506255
// STATE CLOCK launchpad_withdraw_154_before 1237506260
// Launchpad Numerics CollectDepositGns call=154/256
// - Gas Used: 7506520
// - Storage Diff: -1916
// - CPU Cycles: 6547103
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_154_after 1237506260
// STATE CLOCK launchpad_withdraw_155_before 1237506265
// Launchpad Numerics CollectDepositGns call=155/256
// - Gas Used: 7620092
// - Storage Diff: -1880
// - CPU Cycles: 6627322
// - Realm gno.land/r/gnoswap/launchpad: -1880
// STATE CLOCK launchpad_withdraw_155_after 1237506265
// STATE CLOCK launchpad_withdraw_156_before 1237506270
// Launchpad Numerics CollectDepositGns call=156/256
// - Gas Used: 7619136
// - Storage Diff: -1916
// - CPU Cycles: 6627977
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_156_after 1237506270
// STATE CLOCK launchpad_withdraw_157_before 1237506275
// Launchpad Numerics CollectDepositGns call=157/256
// - Gas Used: 7606216
// - Storage Diff: -1916
// - CPU Cycles: 6616671
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_157_after 1237506275
// STATE CLOCK launchpad_withdraw_158_before 1237506280
// Launchpad Numerics CollectDepositGns call=158/256
// - Gas Used: 7602008
// - Storage Diff: -1916
// - CPU Cycles: 6614075
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_158_after 1237506280
// STATE CLOCK launchpad_withdraw_159_before 1237506285
// Launchpad Numerics CollectDepositGns call=159/256
// - Gas Used: 7600317
// - Storage Diff: -1916
// - CPU Cycles: 6613995
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_159_after 1237506285
// STATE CLOCK launchpad_withdraw_160_before 1237506290
// Launchpad Numerics CollectDepositGns call=160/256
// - Gas Used: 7614697
// - Storage Diff: -5243
// - CPU Cycles: 6624406
// - Realm gno.land/r/gnoswap/launchpad: -5243
// STATE CLOCK launchpad_withdraw_160_after 1237506290
// STATE CLOCK launchpad_withdraw_161_before 1237506295
// Launchpad Numerics CollectDepositGns call=161/256
// - Gas Used: 7504372
// - Storage Diff: -1916
// - CPU Cycles: 6535311
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_161_after 1237506295
// STATE CLOCK launchpad_withdraw_162_before 1237506300
// Launchpad Numerics CollectDepositGns call=162/256
// - Gas Used: 7502681
// - Storage Diff: -1916
// - CPU Cycles: 6535231
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_162_after 1237506300
// STATE CLOCK launchpad_withdraw_163_before 1237506305
// Launchpad Numerics CollectDepositGns call=163/256
// - Gas Used: 7497315
// - Storage Diff: -1916
// - CPU Cycles: 6531476
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_163_after 1237506305
// STATE CLOCK launchpad_withdraw_164_before 1237506310
// Launchpad Numerics CollectDepositGns call=164/256
// - Gas Used: 7610353
// - Storage Diff: -1910
// - CPU Cycles: 6532131
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_164_after 1237506310
// STATE CLOCK launchpad_withdraw_165_before 1237506315
// Launchpad Numerics CollectDepositGns call=165/256
// - Gas Used: 7608662
// - Storage Diff: -1910
// - CPU Cycles: 6532051
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_165_after 1237506315
// STATE CLOCK launchpad_withdraw_166_before 1237506320
// Launchpad Numerics CollectDepositGns call=166/256
// - Gas Used: 7607706
// - Storage Diff: -1910
// - CPU Cycles: 6532706
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_166_after 1237506320
// STATE CLOCK launchpad_withdraw_167_before 1237506325
// Launchpad Numerics CollectDepositGns call=167/256
// - Gas Used: 7605280
// - Storage Diff: -1910
// - CPU Cycles: 6531891
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_167_after 1237506325
// STATE CLOCK launchpad_withdraw_168_before 1237506330
// Launchpad Numerics CollectDepositGns call=168/256
// - Gas Used: 7725427
// - Storage Diff: -5391
// - CPU Cycles: 6622816
// - Realm gno.land/r/gnoswap/launchpad: -5391
// STATE CLOCK launchpad_withdraw_168_after 1237506330
// STATE CLOCK launchpad_withdraw_169_before 1237506335
// Launchpad Numerics CollectDepositGns call=169/256
// - Gas Used: 7604242
// - Storage Diff: -1910
// - CPU Cycles: 6521190
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_169_after 1237506335
// STATE CLOCK launchpad_withdraw_170_before 1237506340
// Launchpad Numerics CollectDepositGns call=170/256
// - Gas Used: 7613096
// - Storage Diff: -1909
// - CPU Cycles: 6530047
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_170_after 1237506340
// STATE CLOCK launchpad_withdraw_171_before 1237506345
// Launchpad Numerics CollectDepositGns call=171/256
// - Gas Used: 7602471
// - Storage Diff: -1909
// - CPU Cycles: 6521030
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_171_after 1237506345
// STATE CLOCK launchpad_withdraw_172_before 1237506350
// Launchpad Numerics CollectDepositGns call=172/256
// - Gas Used: 7600783
// - Storage Diff: -1909
// - CPU Cycles: 6520950
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_172_after 1237506350
// STATE CLOCK launchpad_withdraw_173_before 1237506355
// Launchpad Numerics CollectDepositGns call=173/256
// - Gas Used: 7599830
// - Storage Diff: -1909
// - CPU Cycles: 6521605
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_173_after 1237506355
// STATE CLOCK launchpad_withdraw_174_before 1237506360
// Launchpad Numerics CollectDepositGns call=174/256
// - Gas Used: 7597407
// - Storage Diff: -1909
// - CPU Cycles: 6520790
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_174_after 1237506360
// STATE CLOCK launchpad_withdraw_175_before 1237506365
// Launchpad Numerics CollectDepositGns call=175/256
// - Gas Used: 7596454
// - Storage Diff: -1909
// - CPU Cycles: 6521445
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_175_after 1237506365
// STATE CLOCK launchpad_withdraw_176_before 1237506370
// Launchpad Numerics CollectDepositGns call=176/256
// - Gas Used: 7714081
// - Storage Diff: -5390
// - CPU Cycles: 6611515
// - Realm gno.land/r/gnoswap/launchpad: -5390
// STATE CLOCK launchpad_withdraw_176_after 1237506370
// STATE CLOCK launchpad_withdraw_177_before 1237506375
// Launchpad Numerics CollectDepositGns call=177/256
// - Gas Used: 7498477
// - Storage Diff: -1916
// - CPU Cycles: 6529398
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_177_after 1237506375
// STATE CLOCK launchpad_withdraw_178_before 1237506380
// Launchpad Numerics CollectDepositGns call=178/256
// - Gas Used: 7497521
// - Storage Diff: -1916
// - CPU Cycles: 6530053
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_178_after 1237506380
// STATE CLOCK launchpad_withdraw_179_before 1237506385
// Launchpad Numerics CollectDepositGns call=179/256
// - Gas Used: 7486890
// - Storage Diff: -1916
// - CPU Cycles: 6521033
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_179_after 1237506385
// STATE CLOCK launchpad_withdraw_180_before 1237506390
// Launchpad Numerics CollectDepositGns call=180/256
// - Gas Used: 7485931
// - Storage Diff: -1916
// - CPU Cycles: 6521685
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_180_after 1237506390
// STATE CLOCK launchpad_withdraw_181_before 1237506395
// Launchpad Numerics CollectDepositGns call=181/256
// - Gas Used: 7483508
// - Storage Diff: -1916
// - CPU Cycles: 6520873
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_181_after 1237506395
// STATE CLOCK launchpad_withdraw_182_before 1237506400
// Launchpad Numerics CollectDepositGns call=182/256
// - Gas Used: 7482552
// - Storage Diff: -1916
// - CPU Cycles: 6521528
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_182_after 1237506400
// STATE CLOCK launchpad_withdraw_183_before 1237506405
// Launchpad Numerics CollectDepositGns call=183/256
// - Gas Used: 7480861
// - Storage Diff: -1916
// - CPU Cycles: 6521448
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_183_after 1237506405
// STATE CLOCK launchpad_withdraw_184_before 1237506410
// Launchpad Numerics CollectDepositGns call=184/256
// - Gas Used: 7601364
// - Storage Diff: -1916
// - CPU Cycles: 6609792
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_184_after 1237506410
// STATE CLOCK launchpad_withdraw_185_before 1237506415
// Launchpad Numerics CollectDepositGns call=185/256
// - Gas Used: 7600408
// - Storage Diff: -1916
// - CPU Cycles: 6610447
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_185_after 1237506415
// STATE CLOCK launchpad_withdraw_186_before 1237506420
// Launchpad Numerics CollectDepositGns call=186/256
// - Gas Used: 7589777
// - Storage Diff: -1916
// - CPU Cycles: 6601427
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_186_after 1237506420
// STATE CLOCK launchpad_withdraw_187_before 1237506425
// Launchpad Numerics CollectDepositGns call=187/256
// - Gas Used: 7588086
// - Storage Diff: -1916
// - CPU Cycles: 6601347
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_187_after 1237506425
// STATE CLOCK launchpad_withdraw_188_before 1237506430
// Launchpad Numerics CollectDepositGns call=188/256
// - Gas Used: 7597429
// - Storage Diff: -5397
// - CPU Cycles: 6612133
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_188_after 1237506430
// STATE CLOCK launchpad_withdraw_189_before 1237506435
// Launchpad Numerics CollectDepositGns call=189/256
// - Gas Used: 7491004
// - Storage Diff: -1916
// - CPU Cycles: 6521925
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_189_after 1237506435
// STATE CLOCK launchpad_withdraw_190_before 1237506440
// Launchpad Numerics CollectDepositGns call=190/256
// - Gas Used: 7490048
// - Storage Diff: -1916
// - CPU Cycles: 6522580
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_190_after 1237506440
// STATE CLOCK launchpad_withdraw_191_before 1237506445
// Launchpad Numerics CollectDepositGns call=191/256
// - Gas Used: 7495095
// - Storage Diff: -1916
// - CPU Cycles: 6529238
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_191_after 1237506445
// STATE CLOCK launchpad_withdraw_192_before 1237506450
// Launchpad Numerics CollectDepositGns call=192/256
// - Gas Used: 7494139
// - Storage Diff: -1916
// - CPU Cycles: 6529893
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_192_after 1237506450
// STATE CLOCK launchpad_withdraw_193_before 1237506455
// Launchpad Numerics CollectDepositGns call=193/256
// - Gas Used: 7483508
// - Storage Diff: -1916
// - CPU Cycles: 6520873
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_193_after 1237506455
// STATE CLOCK launchpad_withdraw_194_before 1237506460
// Launchpad Numerics CollectDepositGns call=194/256
// - Gas Used: 7481817
// - Storage Diff: -1916
// - CPU Cycles: 6520793
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_194_after 1237506460
// STATE CLOCK launchpad_withdraw_195_before 1237506465
// Launchpad Numerics CollectDepositGns call=195/256
// - Gas Used: 7480861
// - Storage Diff: -1916
// - CPU Cycles: 6521448
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_195_after 1237506465
// STATE CLOCK launchpad_withdraw_196_before 1237506470
// Launchpad Numerics CollectDepositGns call=196/256
// - Gas Used: 7594168
// - Storage Diff: -5397
// - CPU Cycles: 6610543
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_196_after 1237506470
// STATE CLOCK launchpad_withdraw_197_before 1237506475
// Launchpad Numerics CollectDepositGns call=197/256
// - Gas Used: 7491007
// - Storage Diff: -1916
// - CPU Cycles: 6521928
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_197_after 1237506475
// STATE CLOCK launchpad_withdraw_198_before 1237506480
// Launchpad Numerics CollectDepositGns call=198/256
// - Gas Used: 7489316
// - Storage Diff: -1916
// - CPU Cycles: 6521848
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_198_after 1237506480
// STATE CLOCK launchpad_withdraw_199_before 1237506485
// Launchpad Numerics CollectDepositGns call=199/256
// - Gas Used: 7495821
// - Storage Diff: -1916
// - CPU Cycles: 6529964
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_199_after 1237506485
// STATE CLOCK launchpad_withdraw_200_before 1237506490
// Launchpad Numerics CollectDepositGns call=200/256
// - Gas Used: 7485931
// - Storage Diff: -1916
// - CPU Cycles: 6521685
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_200_after 1237506490
// STATE CLOCK launchpad_withdraw_201_before 1237506495
// Launchpad Numerics CollectDepositGns call=201/256
// - Gas Used: 7484975
// - Storage Diff: -1916
// - CPU Cycles: 6522340
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_201_after 1237506495
// STATE CLOCK launchpad_withdraw_202_before 1237506500
// Launchpad Numerics CollectDepositGns call=202/256
// - Gas Used: 7482552
// - Storage Diff: -1916
// - CPU Cycles: 6521528
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_202_after 1237506500
// STATE CLOCK launchpad_withdraw_203_before 1237506505
// Launchpad Numerics CollectDepositGns call=203/256
// - Gas Used: 7481596
// - Storage Diff: -1916
// - CPU Cycles: 6522183
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_203_after 1237506505
// STATE CLOCK launchpad_withdraw_204_before 1237506510
// Launchpad Numerics CollectDepositGns call=204/256
// - Gas Used: 7593847
// - Storage Diff: -5385
// - CPU Cycles: 6611893
// - Realm gno.land/r/gnoswap/launchpad: -5385
// STATE CLOCK launchpad_withdraw_204_after 1237506510
// STATE CLOCK launchpad_withdraw_205_before 1237506515
// Launchpad Numerics CollectDepositGns call=205/256
// - Gas Used: 7478359
// - Storage Diff: -1916
// - CPU Cycles: 6509280
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_205_after 1237506515
// STATE CLOCK launchpad_withdraw_206_before 1237506520
// Launchpad Numerics CollectDepositGns call=206/256
// - Gas Used: 7477403
// - Storage Diff: -1916
// - CPU Cycles: 6509935
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_206_after 1237506520
// STATE CLOCK launchpad_withdraw_207_before 1237506525
// Launchpad Numerics CollectDepositGns call=207/256
// - Gas Used: 7466772
// - Storage Diff: -1916
// - CPU Cycles: 6500915
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_207_after 1237506525
// STATE CLOCK launchpad_withdraw_208_before 1237506530
// Launchpad Numerics CollectDepositGns call=208/256
// - Gas Used: 7465081
// - Storage Diff: -1916
// - CPU Cycles: 6500835
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_208_after 1237506530
// STATE CLOCK launchpad_withdraw_209_before 1237506535
// Launchpad Numerics CollectDepositGns call=209/256
// - Gas Used: 7464125
// - Storage Diff: -1916
// - CPU Cycles: 6501490
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_209_after 1237506535
// STATE CLOCK launchpad_withdraw_210_before 1237506540
// Launchpad Numerics CollectDepositGns call=210/256
// - Gas Used: 7462431
// - Storage Diff: -1916
// - CPU Cycles: 6501407
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_210_after 1237506540
// STATE CLOCK launchpad_withdraw_211_before 1237506545
// Launchpad Numerics CollectDepositGns call=211/256
// - Gas Used: 7460743
// - Storage Diff: -1916
// - CPU Cycles: 6501330
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_211_after 1237506545
// STATE CLOCK launchpad_withdraw_212_before 1237506550
// Launchpad Numerics CollectDepositGns call=212/256
// - Gas Used: 7590335
// - Storage Diff: -1916
// - CPU Cycles: 6597215
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_212_after 1237506550
// STATE CLOCK launchpad_withdraw_213_before 1237506555
// Launchpad Numerics CollectDepositGns call=213/256
// - Gas Used: 7589379
// - Storage Diff: -1916
// - CPU Cycles: 6597870
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_213_after 1237506555
// STATE CLOCK launchpad_withdraw_214_before 1237506560
// Launchpad Numerics CollectDepositGns call=214/256
// - Gas Used: 7578748
// - Storage Diff: -1916
// - CPU Cycles: 6588850
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_214_after 1237506560
// STATE CLOCK launchpad_withdraw_215_before 1237506565
// Launchpad Numerics CollectDepositGns call=215/256
// - Gas Used: 7577057
// - Storage Diff: -1916
// - CPU Cycles: 6588770
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_215_after 1237506565
// STATE CLOCK launchpad_withdraw_216_before 1237506570
// Launchpad Numerics CollectDepositGns call=216/256
// - Gas Used: 7576101
// - Storage Diff: -1916
// - CPU Cycles: 6589425
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_216_after 1237506570
// STATE CLOCK launchpad_withdraw_217_before 1237506575
// Launchpad Numerics CollectDepositGns call=217/256
// - Gas Used: 7578664
// - Storage Diff: -5397
// - CPU Cycles: 6598381
// - Realm gno.land/r/gnoswap/launchpad: -5397
// STATE CLOCK launchpad_withdraw_217_after 1237506575
// STATE CLOCK launchpad_withdraw_218_before 1237506580
// Launchpad Numerics CollectDepositGns call=218/256
// - Gas Used: 7479085
// - Storage Diff: -1916
// - CPU Cycles: 6510006
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_218_after 1237506580
// STATE CLOCK launchpad_withdraw_219_before 1237506585
// Launchpad Numerics CollectDepositGns call=219/256
// - Gas Used: 7477394
// - Storage Diff: -1916
// - CPU Cycles: 6509926
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_219_after 1237506585
// STATE CLOCK launchpad_withdraw_220_before 1237506590
// Launchpad Numerics CollectDepositGns call=220/256
// - Gas Used: 7484640
// - Storage Diff: -1916
// - CPU Cycles: 6518783
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_220_after 1237506590
// STATE CLOCK launchpad_withdraw_221_before 1237506595
// Launchpad Numerics CollectDepositGns call=221/256
// - Gas Used: 7482952
// - Storage Diff: -1916
// - CPU Cycles: 6518706
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_221_after 1237506595
// STATE CLOCK launchpad_withdraw_222_before 1237506600
// Launchpad Numerics CollectDepositGns call=222/256
// - Gas Used: 7481996
// - Storage Diff: -1916
// - CPU Cycles: 6519361
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_222_after 1237506600
// STATE CLOCK launchpad_withdraw_223_before 1237506605
// Launchpad Numerics CollectDepositGns call=223/256
// - Gas Used: 7479570
// - Storage Diff: -1916
// - CPU Cycles: 6518546
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_223_after 1237506605
// STATE CLOCK launchpad_withdraw_224_before 1237506610
// Launchpad Numerics CollectDepositGns call=224/256
// - Gas Used: 7478614
// - Storage Diff: -1916
// - CPU Cycles: 6519201
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_224_after 1237506610
// STATE CLOCK launchpad_withdraw_225_before 1237506615
// Launchpad Numerics CollectDepositGns call=225/256
// - Gas Used: 7593727
// - Storage Diff: -1880
// - CPU Cycles: 6599500
// - Realm gno.land/r/gnoswap/launchpad: -1880
// STATE CLOCK launchpad_withdraw_225_after 1237506615
// STATE CLOCK launchpad_withdraw_226_before 1237506620
// Launchpad Numerics CollectDepositGns call=226/256
// - Gas Used: 7592771
// - Storage Diff: -1916
// - CPU Cycles: 6600155
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_226_after 1237506620
// STATE CLOCK launchpad_withdraw_227_before 1237506625
// Launchpad Numerics CollectDepositGns call=227/256
// - Gas Used: 7589607
// - Storage Diff: -1916
// - CPU Cycles: 6598602
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_227_after 1237506625
// STATE CLOCK launchpad_withdraw_228_before 1237506630
// Launchpad Numerics CollectDepositGns call=228/256
// - Gas Used: 7588651
// - Storage Diff: -1916
// - CPU Cycles: 6599257
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_228_after 1237506630
// STATE CLOCK launchpad_withdraw_229_before 1237506635
// Launchpad Numerics CollectDepositGns call=229/256
// - Gas Used: 7586960
// - Storage Diff: -1916
// - CPU Cycles: 6599177
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_229_after 1237506635
// STATE CLOCK launchpad_withdraw_230_before 1237506640
// Launchpad Numerics CollectDepositGns call=230/256
// - Gas Used: 7585269
// - Storage Diff: -1916
// - CPU Cycles: 6599097
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_230_after 1237506640
// STATE CLOCK launchpad_withdraw_231_before 1237506645
// Launchpad Numerics CollectDepositGns call=231/256
// - Gas Used: 7587994
// - Storage Diff: -5243
// - CPU Cycles: 6609403
// - Realm gno.land/r/gnoswap/launchpad: -5243
// STATE CLOCK launchpad_withdraw_231_after 1237506645
// STATE CLOCK launchpad_withdraw_232_before 1237506650
// Launchpad Numerics CollectDepositGns call=232/256
// - Gas Used: 7477555
// - Storage Diff: -1916
// - CPU Cycles: 6508497
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_232_after 1237506650
// STATE CLOCK launchpad_withdraw_233_before 1237506655
// Launchpad Numerics CollectDepositGns call=233/256
// - Gas Used: 7455803
// - Storage Diff: -1911
// - CPU Cycles: 6488341
// - Realm gno.land/r/gnoswap/gov/xgns: 5
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_233_after 1237506655
// STATE CLOCK launchpad_withdraw_234_before 1237506660
// Launchpad Numerics CollectDepositGns call=234/256
// - Gas Used: 7568841
// - Storage Diff: -1910
// - CPU Cycles: 6488996
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_234_after 1237506660
// STATE CLOCK launchpad_withdraw_235_before 1237506665
// Launchpad Numerics CollectDepositGns call=235/256
// - Gas Used: 7567150
// - Storage Diff: -1910
// - CPU Cycles: 6488916
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_235_after 1237506665
// STATE CLOCK launchpad_withdraw_236_before 1237506670
// Launchpad Numerics CollectDepositGns call=236/256
// - Gas Used: 7566194
// - Storage Diff: -1910
// - CPU Cycles: 6489571
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_236_after 1237506670
// STATE CLOCK launchpad_withdraw_237_before 1237506675
// Launchpad Numerics CollectDepositGns call=237/256
// - Gas Used: 7563768
// - Storage Diff: -1910
// - CPU Cycles: 6488756
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_237_after 1237506675
// STATE CLOCK launchpad_withdraw_238_before 1237506680
// Launchpad Numerics CollectDepositGns call=238/256
// - Gas Used: 7562812
// - Storage Diff: -1910
// - CPU Cycles: 6489411
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_238_after 1237506680
// STATE CLOCK launchpad_withdraw_239_before 1237506685
// Launchpad Numerics CollectDepositGns call=239/256
// - Gas Used: 7671623
// - Storage Diff: -1910
// - CPU Cycles: 6569390
// - Realm gno.land/r/gnoswap/launchpad: -1910
// STATE CLOCK launchpad_withdraw_239_after 1237506685
// STATE CLOCK launchpad_withdraw_240_before 1237506690
// Launchpad Numerics CollectDepositGns call=240/256
// - Gas Used: 7688679
// - Storage Diff: -1909
// - CPU Cycles: 6586449
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_240_after 1237506690
// STATE CLOCK launchpad_withdraw_241_before 1237506695
// Launchpad Numerics CollectDepositGns call=241/256
// - Gas Used: 7669685
// - Storage Diff: -9082
// - CPU Cycles: 6587921
// - Realm gno.land/r/gnoswap/launchpad: -9082
// STATE CLOCK launchpad_withdraw_241_after 1237506695
// STATE CLOCK launchpad_withdraw_242_before 1237506700
// Launchpad Numerics CollectDepositGns call=242/256
// - Gas Used: 7504462
// - Storage Diff: -1909
// - CPU Cycles: 6428905
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_242_after 1237506700
// STATE CLOCK launchpad_withdraw_243_before 1237506705
// Launchpad Numerics CollectDepositGns call=243/256
// - Gas Used: 7503509
// - Storage Diff: -1909
// - CPU Cycles: 6429560
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_243_after 1237506705
// STATE CLOCK launchpad_withdraw_244_before 1237506710
// Launchpad Numerics CollectDepositGns call=244/256
// - Gas Used: 7501086
// - Storage Diff: -1909
// - CPU Cycles: 6428745
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_244_after 1237506710
// STATE CLOCK launchpad_withdraw_245_before 1237506715
// Launchpad Numerics CollectDepositGns call=245/256
// - Gas Used: 7500133
// - Storage Diff: -1909
// - CPU Cycles: 6429400
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_245_after 1237506715
// STATE CLOCK launchpad_withdraw_246_before 1237506720
// Launchpad Numerics CollectDepositGns call=246/256
// - Gas Used: 7498445
// - Storage Diff: -1909
// - CPU Cycles: 6429320
// - Realm gno.land/r/gnoswap/launchpad: -1909
// STATE CLOCK launchpad_withdraw_246_after 1237506720
// STATE CLOCK launchpad_withdraw_247_before 1237506725
// Launchpad Numerics CollectDepositGns call=247/256
// - Gas Used: 7386291
// - Storage Diff: -1916
// - CPU Cycles: 6434376
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_247_after 1237506725
// STATE CLOCK launchpad_withdraw_248_before 1237506730
// Launchpad Numerics CollectDepositGns call=248/256
// - Gas Used: 7384312
// - Storage Diff: -1916
// - CPU Cycles: 6434008
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_248_after 1237506730
// STATE CLOCK launchpad_withdraw_249_before 1237506735
// Launchpad Numerics CollectDepositGns call=249/256
// - Gas Used: 7373681
// - Storage Diff: -1916
// - CPU Cycles: 6424988
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_249_after 1237506735
// STATE CLOCK launchpad_withdraw_250_before 1237506740
// Launchpad Numerics CollectDepositGns call=250/256
// - Gas Used: 7360802
// - Storage Diff: -1916
// - CPU Cycles: 6413720
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_250_after 1237506740
// STATE CLOCK launchpad_withdraw_251_before 1237506745
// Launchpad Numerics CollectDepositGns call=251/256
// - Gas Used: 7358379
// - Storage Diff: -1916
// - CPU Cycles: 6412908
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_251_after 1237506745
// STATE CLOCK launchpad_withdraw_252_before 1237506750
// Launchpad Numerics CollectDepositGns call=252/256
// - Gas Used: 7357423
// - Storage Diff: -1916
// - CPU Cycles: 6413563
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_252_after 1237506750
// STATE CLOCK launchpad_withdraw_253_before 1237506755
// Launchpad Numerics CollectDepositGns call=253/256
// - Gas Used: 7355732
// - Storage Diff: -1916
// - CPU Cycles: 6413483
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_253_after 1237506755
// STATE CLOCK launchpad_withdraw_254_before 1237506760
// Launchpad Numerics CollectDepositGns call=254/256
// - Gas Used: 7340651
// - Storage Diff: -1916
// - CPU Cycles: 6400013
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_254_after 1237506760
// STATE CLOCK launchpad_withdraw_255_before 1237506765
// Launchpad Numerics CollectDepositGns call=255/256
// - Gas Used: 7339695
// - Storage Diff: -1916
// - CPU Cycles: 6400668
// - Realm gno.land/r/gnoswap/launchpad: -1916
// STATE CLOCK launchpad_withdraw_255_after 1237506765
// STATE CLOCK launchpad_withdraw_256_before 1237506770
// Launchpad Numerics CollectDepositGns call=256/256
// - Gas Used: 7318403
// - Storage Diff: -8448
// - CPU Cycles: 6286408
// - Realm gno.land/r/gnoswap/gns: -2055
// - Realm gno.land/r/gnoswap/gov/xgns: -1039
// - Realm gno.land/r/gnoswap/launchpad: -5354
// STATE CLOCK launchpad_withdraw_256_after 1237506770
// STATE launchpad-numerics phase=withdrawn-stage-256 global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=256000000 tier_deposit_count=256 tier_withdraw_count=256 tier_collected=249999871 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=249999871 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE launchpad-numerics phase=withdrawn-final-zero-active global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=256000000 tier_deposit_count=256 tier_withdraw_count=256 tier_collected=249999871 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=249999871 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_refund_before 1250465495
// Launchpad Numerics TransferLeftFromProjectByAdmin
// - Gas Used: 1325502
// - Storage Diff: 21
// - CPU Cycles: 1187076
// - Realm gno.land/r/gnoswap/launchpad: 15
// - Realm gno.land/r/onbloc/obl: 6
// STATE CLOCK launchpad_refund_after 1250465495
// STATE launchpad-numerics phase=refunded-final-zero-active global_staked=0 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=256000000 tier_deposit_count=256 tier_withdraw_count=256 tier_collected=250000000 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=249999871 manager_active_deposit=0 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=0 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=0 record_amount=0 record_tier=0 record_created_height=-1 record_created_offset=-1 record_end_offset=-1 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
