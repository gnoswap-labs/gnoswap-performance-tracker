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
// - Gas Used: 6391412
// - Storage Diff: 27369
// - CPU Cycles: 4155046
// - Realm gno.land/r/gnoswap/gns: 2059
// - Realm gno.land/r/gnoswap/gov/staker: 14243
// - Realm gno.land/r/gnoswap/gov/xgns: 1043
// - Realm gno.land/r/gnoswap/launchpad: 10024
// STATE CLOCK launchpad_deposit_call=1/256_after 1234913495
// STATE launchpad-numerics phase=deposited-stage-1 global_staked=1000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=1000000 tier_total_withdraw=0 tier_deposit_count=1 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=0 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=1000000 manager_active_claimed=0 manager_active_debt=0 manager_window=2592000 manager_cursor_offset=-1234913490 manager_accumulated_distribute=0 manager_rewards=1 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=2/256_before 1234913500
// Launchpad Numerics DepositGns call=2/256
// - Gas Used: 5973016
// - Storage Diff: 4070
// - CPU Cycles: 5168454
// - Realm gno.land/r/gnoswap/gov/staker: 96
// - Realm gno.land/r/gnoswap/launchpad: 3974
// STATE CLOCK launchpad_deposit_call=2/256_after 1234913500
// STATE CLOCK launchpad_deposit_call=3/256_before 1234913505
// Launchpad Numerics DepositGns call=3/256
// - Gas Used: 5967308
// - Storage Diff: 3929
// - CPU Cycles: 5166860
// - Realm gno.land/r/gnoswap/gns: 3
// - Realm gno.land/r/gnoswap/launchpad: 3926
// STATE CLOCK launchpad_deposit_call=3/256_after 1234913505
// STATE CLOCK launchpad_deposit_call=4/256_before 1234913510
// Launchpad Numerics DepositGns call=4/256
// - Gas Used: 5973728
// - Storage Diff: 3928
// - CPU Cycles: 5172332
// - Realm gno.land/r/gnoswap/gns: 2
// - Realm gno.land/r/gnoswap/launchpad: 3926
// STATE CLOCK launchpad_deposit_call=4/256_after 1234913510
// STATE CLOCK launchpad_deposit_call=5/256_before 1234913515
// Launchpad Numerics DepositGns call=5/256
// - Gas Used: 5975644
// - Storage Diff: 3926
// - CPU Cycles: 5173306
// - Realm gno.land/r/gnoswap/launchpad: 3926
// STATE CLOCK launchpad_deposit_call=5/256_after 1234913515
// STATE CLOCK launchpad_deposit_call=6/256_before 1234913520
// Launchpad Numerics DepositGns call=6/256
// - Gas Used: 5975125
// - Storage Diff: 3926
// - CPU Cycles: 5171845
// - Realm gno.land/r/gnoswap/launchpad: 3926
// STATE CLOCK launchpad_deposit_call=6/256_after 1234913520
// STATE CLOCK launchpad_deposit_call=7/256_before 1234913525
// Launchpad Numerics DepositGns call=7/256
// - Gas Used: 5977528
// - Storage Diff: 3926
// - CPU Cycles: 5173306
// - Realm gno.land/r/gnoswap/launchpad: 3926
// STATE CLOCK launchpad_deposit_call=7/256_after 1234913525
// STATE CLOCK launchpad_deposit_call=8/256_before 1234913530
// Launchpad Numerics DepositGns call=8/256
// - Gas Used: 5983942
// - Storage Diff: 3926
// - CPU Cycles: 5178778
// - Realm gno.land/r/gnoswap/launchpad: 3926
// STATE CLOCK launchpad_deposit_call=8/256_after 1234913530
// STATE CLOCK launchpad_deposit_call=9/256_before 1234913535
// Launchpad Numerics DepositGns call=9/256
// - Gas Used: 5985371
// - Storage Diff: 3926
// - CPU Cycles: 5179265
// - Realm gno.land/r/gnoswap/launchpad: 3926
// STATE CLOCK launchpad_deposit_call=9/256_after 1234913535
// STATE CLOCK launchpad_deposit_call=10/256_before 1234913540
// Launchpad Numerics DepositGns call=10/256
// - Gas Used: 6017520
// - Storage Diff: 4025
// - CPU Cycles: 5191646
// - Realm gno.land/r/gnoswap/launchpad: 4025
// STATE CLOCK launchpad_deposit_call=10/256_after 1234913540
// STATE CLOCK launchpad_deposit_call=11/256_before 1234913545
// Launchpad Numerics DepositGns call=11/256
// - Gas Used: 6012514
// - Storage Diff: 3929
// - CPU Cycles: 5185692
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=11/256_after 1234913545
// STATE CLOCK launchpad_deposit_call=12/256_before 1234913550
// Launchpad Numerics DepositGns call=12/256
// - Gas Used: 6019418
// - Storage Diff: 3929
// - CPU Cycles: 5191648
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=12/256_after 1234913550
// STATE CLOCK launchpad_deposit_call=13/256_before 1234913555
// Launchpad Numerics DepositGns call=13/256
// - Gas Used: 6020853
// - Storage Diff: 3929
// - CPU Cycles: 5192135
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=13/256_after 1234913555
// STATE CLOCK launchpad_deposit_call=14/256_before 1234913560
// Launchpad Numerics DepositGns call=14/256
// - Gas Used: 6021806
// - Storage Diff: 3929
// - CPU Cycles: 5192140
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=14/256_after 1234913560
// STATE CLOCK launchpad_deposit_call=15/256_before 1234913565
// Launchpad Numerics DepositGns call=15/256
// - Gas Used: 6022754
// - Storage Diff: 3929
// - CPU Cycles: 5192140
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=15/256_after 1234913565
// STATE CLOCK launchpad_deposit_call=16/256_before 1234913570
// Launchpad Numerics DepositGns call=16/256
// - Gas Used: 6024194
// - Storage Diff: 3929
// - CPU Cycles: 5192632
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=16/256_after 1234913570
// STATE CLOCK launchpad_deposit_call=17/256_before 1234913575
// Launchpad Numerics DepositGns call=17/256
// - Gas Used: 6312541
// - Storage Diff: 17103
// - CPU Cycles: 5413689
// - Realm gno.land/r/gnoswap/launchpad: 17103
// STATE CLOCK launchpad_deposit_call=17/256_after 1234913575
// STATE CLOCK launchpad_deposit_call=18/256_before 1234913580
// Launchpad Numerics DepositGns call=18/256
// - Gas Used: 6072626
// - Storage Diff: 4025
// - CPU Cycles: 5228756
// - Realm gno.land/r/gnoswap/launchpad: 4025
// STATE CLOCK launchpad_deposit_call=18/256_after 1234913580
// STATE CLOCK launchpad_deposit_call=19/256_before 1234913585
// Launchpad Numerics DepositGns call=19/256
// - Gas Used: 6064810
// - Storage Diff: 3929
// - CPU Cycles: 5219992
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=19/256_after 1234913585
// STATE CLOCK launchpad_deposit_call=20/256_before 1234913590
// Launchpad Numerics DepositGns call=20/256
// - Gas Used: 6072500
// - Storage Diff: 3929
// - CPU Cycles: 5229086
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=20/256_after 1234913590
// STATE CLOCK launchpad_deposit_call=21/256_before 1234913595
// Launchpad Numerics DepositGns call=21/256
// - Gas Used: 6073448
// - Storage Diff: 3929
// - CPU Cycles: 5229086
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=21/256_after 1234913595
// STATE CLOCK launchpad_deposit_call=22/256_before 1234913600
// Launchpad Numerics DepositGns call=22/256
// - Gas Used: 6068927
// - Storage Diff: 3929
// - CPU Cycles: 5223617
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=22/256_after 1234913600
// STATE CLOCK launchpad_deposit_call=23/256_before 1234913605
// Launchpad Numerics DepositGns call=23/256
// - Gas Used: 6076323
// - Storage Diff: 3929
// - CPU Cycles: 5230065
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=23/256_after 1234913605
// STATE CLOCK launchpad_deposit_call=24/256_before 1234913610
// Launchpad Numerics DepositGns call=24/256
// - Gas Used: 6076776
// - Storage Diff: 3929
// - CPU Cycles: 5229570
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=24/256_after 1234913610
// STATE CLOCK launchpad_deposit_call=25/256_before 1234913615
// Launchpad Numerics DepositGns call=25/256
// - Gas Used: 6378468
// - Storage Diff: 10621
// - CPU Cycles: 5479422
// - Realm gno.land/r/gnoswap/launchpad: 10621
// STATE CLOCK launchpad_deposit_call=25/256_after 1234913615
// STATE CLOCK launchpad_deposit_call=26/256_before 1234913620
// Launchpad Numerics DepositGns call=26/256
// - Gas Used: 6065400
// - Storage Diff: 3977
// - CPU Cycles: 5222640
// - Realm gno.land/r/gnoswap/launchpad: 3977
// STATE CLOCK launchpad_deposit_call=26/256_after 1234913620
// STATE CLOCK launchpad_deposit_call=27/256_before 1234913625
// Launchpad Numerics DepositGns call=27/256
// - Gas Used: 6072791
// - Storage Diff: 3929
// - CPU Cycles: 5229083
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=27/256_after 1234913625
// STATE CLOCK launchpad_deposit_call=28/256_before 1234913630
// Launchpad Numerics DepositGns call=28/256
// - Gas Used: 6074718
// - Storage Diff: 3929
// - CPU Cycles: 5230062
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=28/256_after 1234913630
// STATE CLOCK launchpad_deposit_call=29/256_before 1234913635
// Launchpad Numerics DepositGns call=29/256
// - Gas Used: 6070910
// - Storage Diff: 3929
// - CPU Cycles: 5225306
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=29/256_after 1234913635
// STATE CLOCK launchpad_deposit_call=30/256_before 1234913640
// Launchpad Numerics DepositGns call=30/256
// - Gas Used: 6073121
// - Storage Diff: 3929
// - CPU Cycles: 5228921
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=30/256_after 1234913640
// STATE CLOCK launchpad_deposit_call=31/256_before 1234913645
// Launchpad Numerics DepositGns call=31/256
// - Gas Used: 6074558
// - Storage Diff: 3929
// - CPU Cycles: 5229410
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=31/256_after 1234913645
// STATE CLOCK launchpad_deposit_call=32/256_before 1234913650
// Launchpad Numerics DepositGns call=32/256
// - Gas Used: 6072216
// - Storage Diff: 3929
// - CPU Cycles: 5226120
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=32/256_after 1234913650
// STATE launchpad-numerics phase=deposited-stage-32 global_staked=32000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=32000000 tier_total_withdraw=0 tier_deposit_count=32 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=824982105611041150227923453007644893 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=32000000 manager_active_claimed=0 manager_active_debt=21148156285094389901994559640816115053000000 manager_window=2592000 manager_cursor_offset=160 manager_accumulated_distribute=0 manager_rewards=32 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69275 record_created_offset=160 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=33/256_before 1234913655
// Launchpad Numerics DepositGns call=33/256
// - Gas Used: 6381172
// - Storage Diff: 10609
// - CPU Cycles: 5480728
// - Realm gno.land/r/gnoswap/launchpad: 10609
// STATE CLOCK launchpad_deposit_call=33/256_after 1234913655
// STATE CLOCK launchpad_deposit_call=34/256_before 1234913660
// Launchpad Numerics DepositGns call=34/256
// - Gas Used: 6071063
// - Storage Diff: 3977
// - CPU Cycles: 5229413
// - Realm gno.land/r/gnoswap/launchpad: 3977
// STATE CLOCK launchpad_deposit_call=34/256_after 1234913660
// STATE CLOCK launchpad_deposit_call=35/256_before 1234913665
// Launchpad Numerics DepositGns call=35/256
// - Gas Used: 6077972
// - Storage Diff: 3929
// - CPU Cycles: 5235374
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=35/256_after 1234913665
// STATE CLOCK launchpad_deposit_call=36/256_before 1234913670
// Launchpad Numerics DepositGns call=36/256
// - Gas Used: 6073451
// - Storage Diff: 3929
// - CPU Cycles: 5229905
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=36/256_after 1234913670
// STATE CLOCK launchpad_deposit_call=37/256_before 1234913675
// Launchpad Numerics DepositGns call=37/256
// - Gas Used: 6066742
// - Storage Diff: 3929
// - CPU Cycles: 5222248
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=37/256_after 1234913675
// STATE CLOCK launchpad_deposit_call=38/256_before 1234913680
// Launchpad Numerics DepositGns call=38/256
// - Gas Used: 6077029
// - Storage Diff: 3929
// - CPU Cycles: 5231587
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=38/256_after 1234913680
// STATE CLOCK launchpad_deposit_call=39/256_before 1234913685
// Launchpad Numerics DepositGns call=39/256
// - Gas Used: 6081290
// - Storage Diff: 3935
// - CPU Cycles: 5234882
// - Realm gno.land/r/gnoswap/gov/xgns: 6
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=39/256_after 1234913685
// STATE CLOCK launchpad_deposit_call=40/256_before 1234913690
// Launchpad Numerics DepositGns call=40/256
// - Gas Used: 6081190
// - Storage Diff: 3929
// - CPU Cycles: 5236186
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=40/256_after 1234913690
// STATE CLOCK launchpad_deposit_call=41/256_before 1234913695
// Launchpad Numerics DepositGns call=41/256
// - Gas Used: 6384605
// - Storage Diff: 10609
// - CPU Cycles: 5482745
// - Realm gno.land/r/gnoswap/launchpad: 10609
// STATE CLOCK launchpad_deposit_call=41/256_after 1234913695
// STATE CLOCK launchpad_deposit_call=42/256_before 1234913700
// Launchpad Numerics DepositGns call=42/256
// - Gas Used: 6069810
// - Storage Diff: 3977
// - CPU Cycles: 5229258
// - Realm gno.land/r/gnoswap/launchpad: 3977
// STATE CLOCK launchpad_deposit_call=42/256_after 1234913700
// STATE CLOCK launchpad_deposit_call=43/256_before 1234913705
// Launchpad Numerics DepositGns call=43/256
// - Gas Used: 6071732
// - Storage Diff: 3929
// - CPU Cycles: 5230232
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=43/256_after 1234913705
// STATE CLOCK launchpad_deposit_call=44/256_before 1234913710
// Launchpad Numerics DepositGns call=44/256
// - Gas Used: 6077170
// - Storage Diff: 3929
// - CPU Cycles: 5234722
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=44/256_after 1234913710
// STATE CLOCK launchpad_deposit_call=45/256_before 1234913715
// Launchpad Numerics DepositGns call=45/256
// - Gas Used: 6079092
// - Storage Diff: 3929
// - CPU Cycles: 5235696
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=45/256_after 1234913715
// STATE CLOCK launchpad_deposit_call=46/256_before 1234913720
// Launchpad Numerics DepositGns call=46/256
// - Gas Used: 6079558
// - Storage Diff: 3929
// - CPU Cycles: 5235214
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=46/256_after 1234913720
// STATE CLOCK launchpad_deposit_call=47/256_before 1234913725
// Launchpad Numerics DepositGns call=47/256
// - Gas Used: 6080506
// - Storage Diff: 3929
// - CPU Cycles: 5235214
// - Realm gno.land/r/gnoswap/launchpad: 3929
// STATE CLOCK launchpad_deposit_call=47/256_after 1234913725
// STATE CLOCK launchpad_deposit_call=48/256_before 1234913730
// Launchpad Numerics DepositGns call=48/256
// - Gas Used: 6082467
// - Storage Diff: 3942
// - CPU Cycles: 5236188
// - Realm gno.land/r/gnoswap/launchpad: 3942
// STATE CLOCK launchpad_deposit_call=48/256_after 1234913730
// STATE CLOCK launchpad_deposit_call=49/256_before 1234913735
// Launchpad Numerics DepositGns call=49/256
// - Gas Used: 6390019
// - Storage Diff: 10673
// - CPU Cycles: 5486527
// - Realm gno.land/r/gnoswap/launchpad: 10673
// STATE CLOCK launchpad_deposit_call=49/256_after 1234913735
// STATE CLOCK launchpad_deposit_call=50/256_before 1234913740
// Launchpad Numerics DepositGns call=50/256
// - Gas Used: 6074233
// - Storage Diff: 4001
// - CPU Cycles: 5234560
// - Realm gno.land/r/gnoswap/launchpad: 4001
// STATE CLOCK launchpad_deposit_call=50/256_after 1234913740
// STATE CLOCK launchpad_deposit_call=51/256_before 1234913745
// Launchpad Numerics DepositGns call=51/256
// - Gas Used: 6075676
// - Storage Diff: 3953
// - CPU Cycles: 5235049
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=51/256_after 1234913745
// STATE CLOCK launchpad_deposit_call=52/256_before 1234913750
// Launchpad Numerics DepositGns call=52/256
// - Gas Used: 6077122
// - Storage Diff: 3953
// - CPU Cycles: 5235541
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=52/256_after 1234913750
// STATE CLOCK launchpad_deposit_call=53/256_before 1234913755
// Launchpad Numerics DepositGns call=53/256
// - Gas Used: 6077595
// - Storage Diff: 3954
// - CPU Cycles: 5235054
// - Realm gno.land/r/gnoswap/gov/xgns: 1
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=53/256_after 1234913755
// STATE CLOCK launchpad_deposit_call=54/256_before 1234913760
// Launchpad Numerics DepositGns call=54/256
// - Gas Used: 6079529
// - Storage Diff: 3955
// - CPU Cycles: 5236028
// - Realm gno.land/r/gnoswap/gov/xgns: 2
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=54/256_after 1234913760
// STATE CLOCK launchpad_deposit_call=55/256_before 1234913765
// Launchpad Numerics DepositGns call=55/256
// - Gas Used: 6080483
// - Storage Diff: 3953
// - CPU Cycles: 5236028
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=55/256_after 1234913765
// STATE CLOCK launchpad_deposit_call=56/256_before 1234913770
// Launchpad Numerics DepositGns call=56/256
// - Gas Used: 6081442
// - Storage Diff: 3953
// - CPU Cycles: 5236033
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=56/256_after 1234913770
// STATE CLOCK launchpad_deposit_call=57/256_before 1234913775
// Launchpad Numerics DepositGns call=57/256
// - Gas Used: 6391030
// - Storage Diff: 10655
// - CPU Cycles: 5485885
// - Realm gno.land/r/gnoswap/launchpad: 10655
// STATE CLOCK launchpad_deposit_call=57/256_after 1234913775
// STATE CLOCK launchpad_deposit_call=58/256_before 1234913780
// Launchpad Numerics DepositGns call=58/256
// - Gas Used: 6076493
// - Storage Diff: 4001
// - CPU Cycles: 5235536
// - Realm gno.land/r/gnoswap/launchpad: 4001
// STATE CLOCK launchpad_deposit_call=58/256_after 1234913780
// STATE CLOCK launchpad_deposit_call=59/256_before 1234913785
// Launchpad Numerics DepositGns call=59/256
// - Gas Used: 6076960
// - Storage Diff: 3953
// - CPU Cycles: 5235049
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=59/256_after 1234913785
// STATE CLOCK launchpad_deposit_call=60/256_before 1234913790
// Launchpad Numerics DepositGns call=60/256
// - Gas Used: 6069449
// - Storage Diff: 3953
// - CPU Cycles: 5228936
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=60/256_after 1234913790
// STATE CLOCK launchpad_deposit_call=61/256_before 1234913795
// Launchpad Numerics DepositGns call=61/256
// - Gas Used: 6071379
// - Storage Diff: 3953
// - CPU Cycles: 5229912
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=61/256_after 1234913795
// STATE CLOCK launchpad_deposit_call=62/256_before 1234913800
// Launchpad Numerics DepositGns call=62/256
// - Gas Used: 6074999
// - Storage Diff: 3953
// - CPU Cycles: 5232578
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=62/256_after 1234913800
// STATE CLOCK launchpad_deposit_call=63/256_before 1234913805
// Launchpad Numerics DepositGns call=63/256
// - Gas Used: 6079733
// - Storage Diff: 3953
// - CPU Cycles: 5236358
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=63/256_after 1234913805
// STATE CLOCK launchpad_deposit_call=64/256_before 1234913810
// Launchpad Numerics DepositGns call=64/256
// - Gas Used: 6080195
// - Storage Diff: 3953
// - CPU Cycles: 5235866
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=64/256_after 1234913810
// STATE CLOCK launchpad_deposit_call=65/256_before 1234913815
// Launchpad Numerics DepositGns call=65/256
// - Gas Used: 6393339
// - Storage Diff: 10655
// - CPU Cycles: 5486694
// - Realm gno.land/r/gnoswap/launchpad: 10655
// STATE CLOCK launchpad_deposit_call=65/256_after 1234913815
// STATE CLOCK launchpad_deposit_call=66/256_before 1234913820
// Launchpad Numerics DepositGns call=66/256
// - Gas Used: 6081686
// - Storage Diff: 4001
// - CPU Cycles: 5241827
// - Realm gno.land/r/gnoswap/launchpad: 4001
// STATE CLOCK launchpad_deposit_call=66/256_after 1234913820
// STATE CLOCK launchpad_deposit_call=67/256_before 1234913825
// Launchpad Numerics DepositGns call=67/256
// - Gas Used: 6082640
// - Storage Diff: 3953
// - CPU Cycles: 5241827
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=67/256_after 1234913825
// STATE CLOCK launchpad_deposit_call=68/256_before 1234913830
// Launchpad Numerics DepositGns call=68/256
// - Gas Used: 6078125
// - Storage Diff: 3953
// - CPU Cycles: 5236358
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=68/256_after 1234913830
// STATE CLOCK launchpad_deposit_call=69/256_before 1234913835
// Launchpad Numerics DepositGns call=69/256
// - Gas Used: 6078105
// - Storage Diff: 3953
// - CPU Cycles: 5235384
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=69/256_after 1234913835
// STATE CLOCK launchpad_deposit_call=70/256_before 1234913840
// Launchpad Numerics DepositGns call=70/256
// - Gas Used: 6082501
// - Storage Diff: 3953
// - CPU Cycles: 5241178
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=70/256_after 1234913840
// STATE CLOCK launchpad_deposit_call=71/256_before 1234913845
// Launchpad Numerics DepositGns call=71/256
// - Gas Used: 6083457
// - Storage Diff: 3953
// - CPU Cycles: 5241180
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=71/256_after 1234913845
// STATE CLOCK launchpad_deposit_call=72/256_before 1234913850
// Launchpad Numerics DepositGns call=72/256
// - Gas Used: 6085390
// - Storage Diff: 3953
// - CPU Cycles: 5242159
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=72/256_after 1234913850
// STATE CLOCK launchpad_deposit_call=73/256_before 1234913855
// Launchpad Numerics DepositGns call=73/256
// - Gas Used: 6401058
// - Storage Diff: 10655
// - CPU Cycles: 5492985
// - Realm gno.land/r/gnoswap/launchpad: 10655
// STATE CLOCK launchpad_deposit_call=73/256_after 1234913855
// STATE CLOCK launchpad_deposit_call=74/256_before 1234913860
// Launchpad Numerics DepositGns call=74/256
// - Gas Used: 6074460
// - Storage Diff: 4001
// - CPU Cycles: 5235711
// - Realm gno.land/r/gnoswap/launchpad: 4001
// STATE CLOCK launchpad_deposit_call=74/256_after 1234913860
// STATE CLOCK launchpad_deposit_call=75/256_before 1234913865
// Launchpad Numerics DepositGns call=75/256
// - Gas Used: 6075901
// - Storage Diff: 3953
// - CPU Cycles: 5236198
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=75/256_after 1234913865
// STATE CLOCK launchpad_deposit_call=76/256_before 1234913870
// Launchpad Numerics DepositGns call=76/256
// - Gas Used: 6082324
// - Storage Diff: 3953
// - CPU Cycles: 5241667
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=76/256_after 1234913870
// STATE CLOCK launchpad_deposit_call=77/256_before 1234913875
// Launchpad Numerics DepositGns call=77/256
// - Gas Used: 6083278
// - Storage Diff: 3953
// - CPU Cycles: 5241667
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=77/256_after 1234913875
// STATE CLOCK launchpad_deposit_call=78/256_before 1234913880
// Launchpad Numerics DepositGns call=78/256
// - Gas Used: 6083745
// - Storage Diff: 3953
// - CPU Cycles: 5241180
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=78/256_after 1234913880
// STATE CLOCK launchpad_deposit_call=79/256_before 1234913885
// Launchpad Numerics DepositGns call=79/256
// - Gas Used: 6085186
// - Storage Diff: 3953
// - CPU Cycles: 5241667
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=79/256_after 1234913885
// STATE CLOCK launchpad_deposit_call=80/256_before 1234913890
// Launchpad Numerics DepositGns call=80/256
// - Gas Used: 6084118
// - Storage Diff: 3953
// - CPU Cycles: 5241997
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=80/256_after 1234913890
// STATE CLOCK launchpad_deposit_call=81/256_before 1234913895
// Launchpad Numerics DepositGns call=81/256
// - Gas Used: 6401322
// - Storage Diff: 10655
// - CPU Cycles: 5491851
// - Realm gno.land/r/gnoswap/launchpad: 10655
// STATE CLOCK launchpad_deposit_call=81/256_after 1234913895
// STATE CLOCK launchpad_deposit_call=82/256_before 1234913900
// Launchpad Numerics DepositGns call=82/256
// - Gas Used: 6073202
// - Storage Diff: 4001
// - CPU Cycles: 5235551
// - Realm gno.land/r/gnoswap/launchpad: 4001
// STATE CLOCK launchpad_deposit_call=82/256_after 1234913900
// STATE CLOCK launchpad_deposit_call=83/256_before 1234913905
// Launchpad Numerics DepositGns call=83/256
// - Gas Used: 6070372
// - Storage Diff: 3953
// - CPU Cycles: 5231767
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=83/256_after 1234913905
// STATE CLOCK launchpad_deposit_call=84/256_before 1234913910
// Launchpad Numerics DepositGns call=84/256
// - Gas Used: 6081069
// - Storage Diff: 3953
// - CPU Cycles: 5241510
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=84/256_after 1234913910
// STATE CLOCK launchpad_deposit_call=85/256_before 1234913915
// Launchpad Numerics DepositGns call=85/256
// - Gas Used: 6078730
// - Storage Diff: 3953
// - CPU Cycles: 5238217
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=85/256_after 1234913915
// STATE CLOCK launchpad_deposit_call=86/256_before 1234913920
// Launchpad Numerics DepositGns call=86/256
// - Gas Used: 6083466
// - Storage Diff: 3953
// - CPU Cycles: 5241999
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=86/256_after 1234913920
// STATE CLOCK launchpad_deposit_call=87/256_before 1234913925
// Launchpad Numerics DepositGns call=87/256
// - Gas Used: 6083446
// - Storage Diff: 3953
// - CPU Cycles: 5241025
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=87/256_after 1234913925
// STATE CLOCK launchpad_deposit_call=88/256_before 1234913930
// Launchpad Numerics DepositGns call=88/256
// - Gas Used: 6084887
// - Storage Diff: 3953
// - CPU Cycles: 5241512
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=88/256_after 1234913930
// STATE CLOCK launchpad_deposit_call=89/256_before 1234913935
// Launchpad Numerics DepositGns call=89/256
// - Gas Used: 6404211
// - Storage Diff: 10655
// - CPU Cycles: 5493312
// - Realm gno.land/r/gnoswap/launchpad: 10655
// STATE CLOCK launchpad_deposit_call=89/256_after 1234913935
// STATE CLOCK launchpad_deposit_call=90/256_before 1234913940
// Launchpad Numerics DepositGns call=90/256
// - Gas Used: 6070382
// - Storage Diff: 4014
// - CPU Cycles: 5233790
// - Realm gno.land/r/gnoswap/gns: 13
// - Realm gno.land/r/gnoswap/launchpad: 4001
// STATE CLOCK launchpad_deposit_call=90/256_after 1234913940
// STATE CLOCK launchpad_deposit_call=91/256_before 1234913945
// Launchpad Numerics DepositGns call=91/256
// - Gas Used: 6070407
// - Storage Diff: 3968
// - CPU Cycles: 5232816
// - Realm gno.land/r/gnoswap/gns: 15
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=91/256_after 1234913945
// STATE CLOCK launchpad_deposit_call=92/256_before 1234913950
// Launchpad Numerics DepositGns call=92/256
// - Gas Used: 6068066
// - Storage Diff: 3953
// - CPU Cycles: 5229521
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=92/256_after 1234913950
// STATE CLOCK launchpad_deposit_call=93/256_before 1234913955
// Launchpad Numerics DepositGns call=93/256
// - Gas Used: 6074358
// - Storage Diff: 3953
// - CPU Cycles: 5234859
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=93/256_after 1234913955
// STATE CLOCK launchpad_deposit_call=94/256_before 1234913960
// Launchpad Numerics DepositGns call=94/256
// - Gas Used: 6074338
// - Storage Diff: 3953
// - CPU Cycles: 5233885
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=94/256_after 1234913960
// STATE CLOCK launchpad_deposit_call=95/256_before 1234913965
// Launchpad Numerics DepositGns call=95/256
// - Gas Used: 6070443
// - Storage Diff: 3953
// - CPU Cycles: 5229036
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=95/256_after 1234913965
// STATE CLOCK launchpad_deposit_call=96/256_before 1234913970
// Launchpad Numerics DepositGns call=96/256
// - Gas Used: 6082694
// - Storage Diff: 3953
// - CPU Cycles: 5240333
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=96/256_after 1234913970
// STATE CLOCK launchpad_deposit_call=97/256_before 1234913975
// Launchpad Numerics DepositGns call=97/256
// - Gas Used: 6328944
// - Storage Diff: 10375
// - CPU Cycles: 5417373
// - Realm gno.land/r/gnoswap/launchpad: 10375
// STATE CLOCK launchpad_deposit_call=97/256_after 1234913975
// STATE CLOCK launchpad_deposit_call=98/256_before 1234913980
// Launchpad Numerics DepositGns call=98/256
// - Gas Used: 6052689
// - Storage Diff: 4001
// - CPU Cycles: 5221476
// - Realm gno.land/r/gnoswap/launchpad: 4001
// STATE CLOCK launchpad_deposit_call=98/256_after 1234913980
// STATE CLOCK launchpad_deposit_call=99/256_before 1234913985
// Launchpad Numerics DepositGns call=99/256
// - Gas Used: 6060091
// - Storage Diff: 3953
// - CPU Cycles: 5227924
// - Realm gno.land/r/gnoswap/launchpad: 3953
// STATE CLOCK launchpad_deposit_call=99/256_after 1234913985
// STATE CLOCK launchpad_deposit_call=100/256_before 1234913990
// Launchpad Numerics DepositGns call=100/256
// - Gas Used: 6123792
// - Storage Diff: 3938
// - CPU Cycles: 5270897
// - Realm gno.land/r/gnoswap/launchpad: 3938
// STATE CLOCK launchpad_deposit_call=100/256_after 1234913990
// STATE CLOCK launchpad_deposit_call=101/256_before 1234913995
// Launchpad Numerics DepositGns call=101/256
// - Gas Used: 6123660
// - Storage Diff: 3914
// - CPU Cycles: 5269925
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=101/256_after 1234913995
// STATE CLOCK launchpad_deposit_call=102/256_before 1234914000
// Launchpad Numerics DepositGns call=102/256
// - Gas Used: 6131437
// - Storage Diff: 3914
// - CPU Cycles: 5276862
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=102/256_after 1234914000
// STATE CLOCK launchpad_deposit_call=103/256_before 1234914005
// Launchpad Numerics DepositGns call=103/256
// - Gas Used: 6126319
// - Storage Diff: 3914
// - CPU Cycles: 5270904
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=103/256_after 1234914005
// STATE CLOCK launchpad_deposit_call=104/256_before 1234914010
// Launchpad Numerics DepositGns call=104/256
// - Gas Used: 6127159
// - Storage Diff: 3914
// - CPU Cycles: 5270904
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=104/256_after 1234914010
// STATE CLOCK launchpad_deposit_call=105/256_before 1234914015
// Launchpad Numerics DepositGns call=105/256
// - Gas Used: 6133465
// - Storage Diff: 3914
// - CPU Cycles: 5276370
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=105/256_after 1234914015
// STATE CLOCK launchpad_deposit_call=106/256_before 1234914020
// Launchpad Numerics DepositGns call=106/256
// - Gas Used: 6133818
// - Storage Diff: 3914
// - CPU Cycles: 5275883
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=106/256_after 1234914020
// STATE CLOCK launchpad_deposit_call=107/256_before 1234914025
// Launchpad Numerics DepositGns call=107/256
// - Gas Used: 6136124
// - Storage Diff: 3914
// - CPU Cycles: 5277349
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=107/256_after 1234914025
// STATE CLOCK launchpad_deposit_call=108/256_before 1234914030
// Launchpad Numerics DepositGns call=108/256
// - Gas Used: 6445160
// - Storage Diff: 10400
// - CPU Cycles: 5528255
// - Realm gno.land/r/gnoswap/launchpad: 10400
// STATE CLOCK launchpad_deposit_call=108/256_after 1234914030
// STATE CLOCK launchpad_deposit_call=109/256_before 1234914035
// Launchpad Numerics DepositGns call=109/256
// - Gas Used: 6125096
// - Storage Diff: 4004
// - CPU Cycles: 5271391
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=109/256_after 1234914035
// STATE CLOCK launchpad_deposit_call=110/256_before 1234914040
// Launchpad Numerics DepositGns call=110/256
// - Gas Used: 6120246
// - Storage Diff: 3956
// - CPU Cycles: 5267939
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=110/256_after 1234914040
// STATE CLOCK launchpad_deposit_call=111/256_before 1234914045
// Launchpad Numerics DepositGns call=111/256
// - Gas Used: 6126674
// - Storage Diff: 3956
// - CPU Cycles: 5273407
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=111/256_after 1234914045
// STATE CLOCK launchpad_deposit_call=112/256_before 1234914050
// Launchpad Numerics DepositGns call=112/256
// - Gas Used: 6131416
// - Storage Diff: 3956
// - CPU Cycles: 5277189
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=112/256_after 1234914050
// STATE CLOCK launchpad_deposit_call=113/256_before 1234914055
// Launchpad Numerics DepositGns call=113/256
// - Gas Used: 6132868
// - Storage Diff: 3956
// - CPU Cycles: 5277681
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=113/256_after 1234914055
// STATE CLOCK launchpad_deposit_call=114/256_before 1234914060
// Launchpad Numerics DepositGns call=114/256
// - Gas Used: 6132367
// - Storage Diff: 3956
// - CPU Cycles: 5276220
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=114/256_after 1234914060
// STATE CLOCK launchpad_deposit_call=115/256_before 1234914065
// Launchpad Numerics DepositGns call=115/256
// - Gas Used: 6134788
// - Storage Diff: 3956
// - CPU Cycles: 5277681
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=115/256_after 1234914065
// STATE CLOCK launchpad_deposit_call=116/256_before 1234914070
// Launchpad Numerics DepositGns call=116/256
// - Gas Used: 6468827
// - Storage Diff: 10660
// - CPU Cycles: 5530660
// - Realm gno.land/r/gnoswap/launchpad: 10660
// STATE CLOCK launchpad_deposit_call=116/256_after 1234914070
// STATE CLOCK launchpad_deposit_call=117/256_before 1234914075
// Launchpad Numerics DepositGns call=117/256
// - Gas Used: 6123350
// - Storage Diff: 4004
// - CPU Cycles: 5270749
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=117/256_after 1234914075
// STATE CLOCK launchpad_deposit_call=118/256_before 1234914080
// Launchpad Numerics DepositGns call=118/256
// - Gas Used: 6124797
// - Storage Diff: 3956
// - CPU Cycles: 5271236
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=118/256_after 1234914080
// STATE CLOCK launchpad_deposit_call=119/256_before 1234914085
// Launchpad Numerics DepositGns call=119/256
// - Gas Used: 6131710
// - Storage Diff: 3956
// - CPU Cycles: 5277189
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=119/256_after 1234914085
// STATE CLOCK launchpad_deposit_call=120/256_before 1234914090
// Launchpad Numerics DepositGns call=120/256
// - Gas Used: 6130642
// - Storage Diff: 3956
// - CPU Cycles: 5277519
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=120/256_after 1234914090
// STATE CLOCK launchpad_deposit_call=121/256_before 1234914095
// Launchpad Numerics DepositGns call=121/256
// - Gas Used: 6131117
// - Storage Diff: 3956
// - CPU Cycles: 5277034
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=121/256_after 1234914095
// STATE CLOCK launchpad_deposit_call=122/256_before 1234914100
// Launchpad Numerics DepositGns call=122/256
// - Gas Used: 6132075
// - Storage Diff: 3956
// - CPU Cycles: 5277032
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=122/256_after 1234914100
// STATE CLOCK launchpad_deposit_call=123/256_before 1234914105
// Launchpad Numerics DepositGns call=123/256
// - Gas Used: 6133527
// - Storage Diff: 3956
// - CPU Cycles: 5277524
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=123/256_after 1234914105
// STATE CLOCK launchpad_deposit_call=124/256_before 1234914110
// Launchpad Numerics DepositGns call=124/256
// - Gas Used: 6470100
// - Storage Diff: 10660
// - CPU Cycles: 5530505
// - Realm gno.land/r/gnoswap/launchpad: 10660
// STATE CLOCK launchpad_deposit_call=124/256_after 1234914110
// STATE CLOCK launchpad_deposit_call=125/256_before 1234914115
// Launchpad Numerics DepositGns call=125/256
// - Gas Used: 6129018
// - Storage Diff: 4004
// - CPU Cycles: 5277521
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=125/256_after 1234914115
// STATE CLOCK launchpad_deposit_call=126/256_before 1234914120
// Launchpad Numerics DepositGns call=126/256
// - Gas Used: 6126683
// - Storage Diff: 3956
// - CPU Cycles: 5274226
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=126/256_after 1234914120
// STATE CLOCK launchpad_deposit_call=127/256_before 1234914125
// Launchpad Numerics DepositGns call=127/256
// - Gas Used: 6127648
// - Storage Diff: 3956
// - CPU Cycles: 5274231
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=127/256_after 1234914125
// STATE CLOCK launchpad_deposit_call=128/256_before 1234914130
// Launchpad Numerics DepositGns call=128/256
// - Gas Used: 6131903
// - Storage Diff: 3956
// - CPU Cycles: 5277526
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=128/256_after 1234914130
// STATE launchpad-numerics phase=deposited-stage-128 global_staked=128000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=128000000 tier_total_withdraw=0 tier_deposit_count=128 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1054411681821579576241805020507828326 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=128000000 manager_active_claimed=0 manager_active_debt=113959610895326478137755079203287942984000000 manager_window=2592000 manager_cursor_offset=640 manager_accumulated_distribute=0 manager_rewards=128 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69371 record_created_offset=640 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_deposit_call=129/256_before 1234914135
// Launchpad Numerics DepositGns call=129/256
// - Gas Used: 6132863
// - Storage Diff: 3956
// - CPU Cycles: 5277526
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=129/256_after 1234914135
// STATE CLOCK launchpad_deposit_call=130/256_before 1234914140
// Launchpad Numerics DepositGns call=130/256
// - Gas Used: 6131795
// - Storage Diff: 3956
// - CPU Cycles: 5277856
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=130/256_after 1234914140
// STATE CLOCK launchpad_deposit_call=131/256_before 1234914145
// Launchpad Numerics DepositGns call=131/256
// - Gas Used: 6132752
// - Storage Diff: 3956
// - CPU Cycles: 5277853
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=131/256_after 1234914145
// STATE CLOCK launchpad_deposit_call=132/256_before 1234914150
// Launchpad Numerics DepositGns call=132/256
// - Gas Used: 6471855
// - Storage Diff: 10660
// - CPU Cycles: 5530832
// - Realm gno.land/r/gnoswap/launchpad: 10660
// STATE CLOCK launchpad_deposit_call=132/256_after 1234914150
// STATE CLOCK launchpad_deposit_call=133/256_before 1234914155
// Launchpad Numerics DepositGns call=133/256
// - Gas Used: 6127742
// - Storage Diff: 4004
// - CPU Cycles: 5277361
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=133/256_after 1234914155
// STATE CLOCK launchpad_deposit_call=134/256_before 1234914160
// Launchpad Numerics DepositGns call=134/256
// - Gas Used: 6128215
// - Storage Diff: 3956
// - CPU Cycles: 5276874
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=134/256_after 1234914160
// STATE CLOCK launchpad_deposit_call=135/256_before 1234914165
// Launchpad Numerics DepositGns call=135/256
// - Gas Used: 6123704
// - Storage Diff: 3956
// - CPU Cycles: 5271403
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=135/256_after 1234914165
// STATE CLOCK launchpad_deposit_call=136/256_before 1234914170
// Launchpad Numerics DepositGns call=136/256
// - Gas Used: 6124177
// - Storage Diff: 3956
// - CPU Cycles: 5270916
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=136/256_after 1234914170
// STATE CLOCK launchpad_deposit_call=137/256_before 1234914175
// Launchpad Numerics DepositGns call=137/256
// - Gas Used: 6131100
// - Storage Diff: 3956
// - CPU Cycles: 5276879
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=137/256_after 1234914175
// STATE CLOCK launchpad_deposit_call=138/256_before 1234914180
// Launchpad Numerics DepositGns call=138/256
// - Gas Used: 6132547
// - Storage Diff: 3956
// - CPU Cycles: 5277366
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=138/256_after 1234914180
// STATE CLOCK launchpad_deposit_call=139/256_before 1234914185
// Launchpad Numerics DepositGns call=139/256
// - Gas Used: 6132041
// - Storage Diff: 3956
// - CPU Cycles: 5275900
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=139/256_after 1234914185
// STATE CLOCK launchpad_deposit_call=140/256_before 1234914190
// Launchpad Numerics DepositGns call=140/256
// - Gas Used: 6867783
// - Storage Diff: 24222
// - CPU Cycles: 5867578
// - Realm gno.land/r/gnoswap/launchpad: 24222
// STATE CLOCK launchpad_deposit_call=140/256_after 1234914190
// STATE CLOCK launchpad_deposit_call=141/256_before 1234914195
// Launchpad Numerics DepositGns call=141/256
// - Gas Used: 6158642
// - Storage Diff: 4076
// - CPU Cycles: 5301875
// - Realm gno.land/r/gnoswap/launchpad: 4076
// STATE CLOCK launchpad_deposit_call=141/256_after 1234914195
// STATE CLOCK launchpad_deposit_call=142/256_before 1234914200
// Launchpad Numerics DepositGns call=142/256
// - Gas Used: 6156305
// - Storage Diff: 3956
// - CPU Cycles: 5298578
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=142/256_after 1234914200
// STATE CLOCK launchpad_deposit_call=143/256_before 1234914205
// Launchpad Numerics DepositGns call=143/256
// - Gas Used: 6167005
// - Storage Diff: 3956
// - CPU Cycles: 5308318
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=143/256_after 1234914205
// STATE CLOCK launchpad_deposit_call=144/256_before 1234914210
// Launchpad Numerics DepositGns call=144/256
// - Gas Used: 6167967
// - Storage Diff: 3956
// - CPU Cycles: 5308320
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=144/256_after 1234914210
// STATE CLOCK launchpad_deposit_call=145/256_before 1234914215
// Launchpad Numerics DepositGns call=145/256
// - Gas Used: 6168927
// - Storage Diff: 3956
// - CPU Cycles: 5308320
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=145/256_after 1234914215
// STATE CLOCK launchpad_deposit_call=146/256_before 1234914220
// Launchpad Numerics DepositGns call=146/256
// - Gas Used: 6169400
// - Storage Diff: 3956
// - CPU Cycles: 5307833
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=146/256_after 1234914220
// STATE CLOCK launchpad_deposit_call=147/256_before 1234914225
// Launchpad Numerics DepositGns call=147/256
// - Gas Used: 6170852
// - Storage Diff: 3956
// - CPU Cycles: 5308325
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=147/256_after 1234914225
// STATE CLOCK launchpad_deposit_call=148/256_before 1234914230
// Launchpad Numerics DepositGns call=148/256
// - Gas Used: 6492815
// - Storage Diff: 10634
// - CPU Cycles: 5560118
// - Realm gno.land/r/gnoswap/launchpad: 10634
// STATE CLOCK launchpad_deposit_call=148/256_after 1234914230
// STATE CLOCK launchpad_deposit_call=149/256_before 1234914235
// Launchpad Numerics DepositGns call=149/256
// - Gas Used: 6160383
// - Storage Diff: 4004
// - CPU Cycles: 5302362
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=149/256_after 1234914235
// STATE CLOCK launchpad_deposit_call=150/256_before 1234914240
// Launchpad Numerics DepositGns call=150/256
// - Gas Used: 6158823
// - Storage Diff: 3956
// - CPU Cycles: 5302200
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=150/256_after 1234914240
// STATE CLOCK launchpad_deposit_call=151/256_before 1234914245
// Launchpad Numerics DepositGns call=151/256
// - Gas Used: 6165746
// - Storage Diff: 3956
// - CPU Cycles: 5308163
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=151/256_after 1234914245
// STATE CLOCK launchpad_deposit_call=152/256_before 1234914250
// Launchpad Numerics DepositGns call=152/256
// - Gas Used: 6166708
// - Storage Diff: 3956
// - CPU Cycles: 5308165
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=152/256_after 1234914250
// STATE CLOCK launchpad_deposit_call=153/256_before 1234914255
// Launchpad Numerics DepositGns call=153/256
// - Gas Used: 6167668
// - Storage Diff: 3956
// - CPU Cycles: 5308165
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=153/256_after 1234914255
// STATE CLOCK launchpad_deposit_call=154/256_before 1234914260
// Launchpad Numerics DepositGns call=154/256
// - Gas Used: 6169115
// - Storage Diff: 3956
// - CPU Cycles: 5308652
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=154/256_after 1234914260
// STATE CLOCK launchpad_deposit_call=155/256_before 1234914265
// Launchpad Numerics DepositGns call=155/256
// - Gas Used: 6170075
// - Storage Diff: 3956
// - CPU Cycles: 5308652
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=155/256_after 1234914265
// STATE CLOCK launchpad_deposit_call=156/256_before 1234914270
// Launchpad Numerics DepositGns call=156/256
// - Gas Used: 6493468
// - Storage Diff: 10620
// - CPU Cycles: 5559469
// - Realm gno.land/r/gnoswap/launchpad: 10620
// STATE CLOCK launchpad_deposit_call=156/256_after 1234914270
// STATE CLOCK launchpad_deposit_call=157/256_before 1234914275
// Launchpad Numerics DepositGns call=157/256
// - Gas Used: 6159592
// - Storage Diff: 4004
// - CPU Cycles: 5302687
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=157/256_after 1234914275
// STATE CLOCK launchpad_deposit_call=158/256_before 1234914280
// Launchpad Numerics DepositGns call=158/256
// - Gas Used: 6160065
// - Storage Diff: 3956
// - CPU Cycles: 5302200
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=158/256_after 1234914280
// STATE CLOCK launchpad_deposit_call=159/256_before 1234914285
// Launchpad Numerics DepositGns call=159/256
// - Gas Used: 6167962
// - Storage Diff: 3956
// - CPU Cycles: 5309137
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=159/256_after 1234914285
// STATE CLOCK launchpad_deposit_call=160/256_before 1234914290
// Launchpad Numerics DepositGns call=160/256
// - Gas Used: 6157866
// - Storage Diff: 3956
// - CPU Cycles: 5300439
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=160/256_after 1234914290
// STATE CLOCK launchpad_deposit_call=161/256_before 1234914295
// Launchpad Numerics DepositGns call=161/256
// - Gas Used: 6158341
// - Storage Diff: 3956
// - CPU Cycles: 5299954
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=161/256_after 1234914295
// STATE CLOCK launchpad_deposit_call=162/256_before 1234914300
// Launchpad Numerics DepositGns call=162/256
// - Gas Used: 6159299
// - Storage Diff: 3956
// - CPU Cycles: 5299952
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=162/256_after 1234914300
// STATE CLOCK launchpad_deposit_call=163/256_before 1234914305
// Launchpad Numerics DepositGns call=163/256
// - Gas Used: 6166709
// - Storage Diff: 3956
// - CPU Cycles: 5306402
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=163/256_after 1234914305
// STATE CLOCK launchpad_deposit_call=164/256_before 1234914310
// Launchpad Numerics DepositGns call=164/256
// - Gas Used: 6421177
// - Storage Diff: 10342
// - CPU Cycles: 5486734
// - Realm gno.land/r/gnoswap/launchpad: 10342
// STATE CLOCK launchpad_deposit_call=164/256_after 1234914310
// STATE CLOCK launchpad_deposit_call=165/256_before 1234914315
// Launchpad Numerics DepositGns call=165/256
// - Gas Used: 6135662
// - Storage Diff: 4004
// - CPU Cycles: 5286569
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=165/256_after 1234914315
// STATE CLOCK launchpad_deposit_call=166/256_before 1234914320
// Launchpad Numerics DepositGns call=166/256
// - Gas Used: 6142585
// - Storage Diff: 3956
// - CPU Cycles: 5292532
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=166/256_after 1234914320
// STATE CLOCK launchpad_deposit_call=167/256_before 1234914325
// Launchpad Numerics DepositGns call=167/256
// - Gas Used: 6144519
// - Storage Diff: 3956
// - CPU Cycles: 5293506
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=167/256_after 1234914325
// STATE CLOCK launchpad_deposit_call=168/256_before 1234914330
// Launchpad Numerics DepositGns call=168/256
// - Gas Used: 6137335
// - Storage Diff: 3956
// - CPU Cycles: 5285362
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=168/256_after 1234914330
// STATE CLOCK launchpad_deposit_call=169/256_before 1234914335
// Launchpad Numerics DepositGns call=169/256
// - Gas Used: 6146439
// - Storage Diff: 3956
// - CPU Cycles: 5293506
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=169/256_after 1234914335
// STATE CLOCK launchpad_deposit_call=170/256_before 1234914340
// Launchpad Numerics DepositGns call=170/256
// - Gas Used: 6165427
// - Storage Diff: 3938
// - CPU Cycles: 5308624
// - Realm gno.land/r/gnoswap/launchpad: 3938
// STATE CLOCK launchpad_deposit_call=170/256_after 1234914340
// STATE CLOCK launchpad_deposit_call=171/256_before 1234914345
// Launchpad Numerics DepositGns call=171/256
// - Gas Used: 6159822
// - Storage Diff: 3914
// - CPU Cycles: 5302179
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=171/256_after 1234914345
// STATE CLOCK launchpad_deposit_call=172/256_before 1234914350
// Launchpad Numerics DepositGns call=172/256
// - Gas Used: 6162838
// - Storage Diff: 3914
// - CPU Cycles: 5304355
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=172/256_after 1234914350
// STATE CLOCK launchpad_deposit_call=173/256_before 1234914355
// Launchpad Numerics DepositGns call=173/256
// - Gas Used: 6167954
// - Storage Diff: 3914
// - CPU Cycles: 5308631
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=173/256_after 1234914355
// STATE CLOCK launchpad_deposit_call=174/256_before 1234914360
// Launchpad Numerics DepositGns call=174/256
// - Gas Used: 6169768
// - Storage Diff: 3914
// - CPU Cycles: 5309605
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=174/256_after 1234914360
// STATE CLOCK launchpad_deposit_call=175/256_before 1234914365
// Launchpad Numerics DepositGns call=175/256
// - Gas Used: 6163676
// - Storage Diff: 3914
// - CPU Cycles: 5302673
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=175/256_after 1234914365
// STATE CLOCK launchpad_deposit_call=176/256_before 1234914370
// Launchpad Numerics DepositGns call=176/256
// - Gas Used: 6171940
// - Storage Diff: 3914
// - CPU Cycles: 5310097
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=176/256_after 1234914370
// STATE CLOCK launchpad_deposit_call=177/256_before 1234914375
// Launchpad Numerics DepositGns call=177/256
// - Gas Used: 6171309
// - Storage Diff: 3914
// - CPU Cycles: 5308626
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=177/256_after 1234914375
// STATE CLOCK launchpad_deposit_call=178/256_before 1234914380
// Launchpad Numerics DepositGns call=178/256
// - Gas Used: 6471687
// - Storage Diff: 10350
// - CPU Cycles: 5557132
// - Realm gno.land/r/gnoswap/launchpad: 10350
// STATE CLOCK launchpad_deposit_call=178/256_after 1234914380
// STATE CLOCK launchpad_deposit_call=179/256_before 1234914385
// Launchpad Numerics DepositGns call=179/256
// - Gas Used: 6182585
// - Storage Diff: 4004
// - CPU Cycles: 5309114
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=179/256_after 1234914385
// STATE CLOCK launchpad_deposit_call=180/256_before 1234914390
// Launchpad Numerics DepositGns call=180/256
// - Gas Used: 6186988
// - Storage Diff: 3956
// - CPU Cycles: 5314915
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=180/256_after 1234914390
// STATE CLOCK launchpad_deposit_call=181/256_before 1234914395
// Launchpad Numerics DepositGns call=181/256
// - Gas Used: 6182481
// - Storage Diff: 3956
// - CPU Cycles: 5309448
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=181/256_after 1234914395
// STATE CLOCK launchpad_deposit_call=182/256_before 1234914400
// Launchpad Numerics DepositGns call=182/256
// - Gas Used: 6183439
// - Storage Diff: 3956
// - CPU Cycles: 5309446
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=182/256_after 1234914400
// STATE CLOCK launchpad_deposit_call=183/256_before 1234914405
// Launchpad Numerics DepositGns call=183/256
// - Gas Used: 6190352
// - Storage Diff: 3956
// - CPU Cycles: 5315399
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=183/256_after 1234914405
// STATE CLOCK launchpad_deposit_call=184/256_before 1234914410
// Launchpad Numerics DepositGns call=184/256
// - Gas Used: 6190825
// - Storage Diff: 3956
// - CPU Cycles: 5314912
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=184/256_after 1234914410
// STATE CLOCK launchpad_deposit_call=185/256_before 1234914415
// Launchpad Numerics DepositGns call=185/256
// - Gas Used: 6192766
// - Storage Diff: 3956
// - CPU Cycles: 5315893
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=185/256_after 1234914415
// STATE CLOCK launchpad_deposit_call=186/256_before 1234914420
// Launchpad Numerics DepositGns call=186/256
// - Gas Used: 6502157
// - Storage Diff: 10622
// - CPU Cycles: 5566472
// - Realm gno.land/r/gnoswap/launchpad: 10622
// STATE CLOCK launchpad_deposit_call=186/256_after 1234914420
// STATE CLOCK launchpad_deposit_call=187/256_before 1234914425
// Launchpad Numerics DepositGns call=187/256
// - Gas Used: 6181321
// - Storage Diff: 4004
// - CPU Cycles: 5308954
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=187/256_after 1234914425
// STATE CLOCK launchpad_deposit_call=188/256_before 1234914430
// Launchpad Numerics DepositGns call=188/256
// - Gas Used: 6188244
// - Storage Diff: 3956
// - CPU Cycles: 5314917
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=188/256_after 1234914430
// STATE CLOCK launchpad_deposit_call=189/256_before 1234914435
// Launchpad Numerics DepositGns call=189/256
// - Gas Used: 6184222
// - Storage Diff: 3956
// - CPU Cycles: 5309935
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=189/256_after 1234914435
// STATE CLOCK launchpad_deposit_call=190/256_before 1234914440
// Launchpad Numerics DepositGns call=190/256
// - Gas Used: 6187152
// - Storage Diff: 3956
// - CPU Cycles: 5314263
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=190/256_after 1234914440
// STATE CLOCK launchpad_deposit_call=191/256_before 1234914445
// Launchpad Numerics DepositGns call=191/256
// - Gas Used: 6189091
// - Storage Diff: 3956
// - CPU Cycles: 5315242
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=191/256_after 1234914445
// STATE CLOCK launchpad_deposit_call=192/256_before 1234914450
// Launchpad Numerics DepositGns call=192/256
// - Gas Used: 6190540
// - Storage Diff: 3956
// - CPU Cycles: 5315731
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=192/256_after 1234914450
// STATE CLOCK launchpad_deposit_call=193/256_before 1234914455
// Launchpad Numerics DepositGns call=193/256
// - Gas Used: 6190526
// - Storage Diff: 3956
// - CPU Cycles: 5314757
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=193/256_after 1234914455
// STATE CLOCK launchpad_deposit_call=194/256_before 1234914460
// Launchpad Numerics DepositGns call=194/256
// - Gas Used: 6503303
// - Storage Diff: 10622
// - CPU Cycles: 5566310
// - Realm gno.land/r/gnoswap/launchpad: 10622
// STATE CLOCK launchpad_deposit_call=194/256_after 1234914460
// STATE CLOCK launchpad_deposit_call=195/256_before 1234914465
// Launchpad Numerics DepositGns call=195/256
// - Gas Used: 6180062
// - Storage Diff: 4004
// - CPU Cycles: 5308799
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=195/256_after 1234914465
// STATE CLOCK launchpad_deposit_call=196/256_before 1234914470
// Launchpad Numerics DepositGns call=196/256
// - Gas Used: 6181509
// - Storage Diff: 3956
// - CPU Cycles: 5309286
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=196/256_after 1234914470
// STATE CLOCK launchpad_deposit_call=197/256_before 1234914475
// Launchpad Numerics DepositGns call=197/256
// - Gas Used: 6184153
// - Storage Diff: 3956
// - CPU Cycles: 5310970
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=197/256_after 1234914475
// STATE CLOCK launchpad_deposit_call=198/256_before 1234914480
// Launchpad Numerics DepositGns call=198/256
// - Gas Used: 6185600
// - Storage Diff: 3956
// - CPU Cycles: 5311457
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=198/256_after 1234914480
// STATE CLOCK launchpad_deposit_call=199/256_before 1234914485
// Launchpad Numerics DepositGns call=199/256
// - Gas Used: 6187539
// - Storage Diff: 3956
// - CPU Cycles: 5312436
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=199/256_after 1234914485
// STATE CLOCK launchpad_deposit_call=200/256_before 1234914490
// Launchpad Numerics DepositGns call=200/256
// - Gas Used: 6186272
// - Storage Diff: 3956
// - CPU Cycles: 5314925
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=200/256_after 1234914490
// STATE CLOCK launchpad_deposit_call=201/256_before 1234914495
// Launchpad Numerics DepositGns call=201/256
// - Gas Used: 6187233
// - Storage Diff: 3956
// - CPU Cycles: 5314926
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=201/256_after 1234914495
// STATE CLOCK launchpad_deposit_call=202/256_before 1234914500
// Launchpad Numerics DepositGns call=202/256
// - Gas Used: 6504780
// - Storage Diff: 10622
// - CPU Cycles: 5566479
// - Realm gno.land/r/gnoswap/launchpad: 10622
// STATE CLOCK launchpad_deposit_call=202/256_after 1234914500
// STATE CLOCK launchpad_deposit_call=203/256_before 1234914505
// Launchpad Numerics DepositGns call=203/256
// - Gas Used: 6182230
// - Storage Diff: 4004
// - CPU Cycles: 5314441
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=203/256_after 1234914505
// STATE CLOCK launchpad_deposit_call=204/256_before 1234914510
// Launchpad Numerics DepositGns call=204/256
// - Gas Used: 6183677
// - Storage Diff: 3956
// - CPU Cycles: 5314928
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=204/256_after 1234914510
// STATE CLOCK launchpad_deposit_call=205/256_before 1234914515
// Launchpad Numerics DepositGns call=205/256
// - Gas Used: 6178192
// - Storage Diff: 3956
// - CPU Cycles: 5308483
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=205/256_after 1234914515
// STATE CLOCK launchpad_deposit_call=206/256_before 1234914520
// Launchpad Numerics DepositGns call=206/256
// - Gas Used: 6179639
// - Storage Diff: 3956
// - CPU Cycles: 5308970
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=206/256_after 1234914520
// STATE CLOCK launchpad_deposit_call=207/256_before 1234914525
// Launchpad Numerics DepositGns call=207/256
// - Gas Used: 6187049
// - Storage Diff: 3956
// - CPU Cycles: 5315420
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=207/256_after 1234914525
// STATE CLOCK launchpad_deposit_call=208/256_before 1234914530
// Launchpad Numerics DepositGns call=208/256
// - Gas Used: 6188009
// - Storage Diff: 3956
// - CPU Cycles: 5315420
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=208/256_after 1234914530
// STATE CLOCK launchpad_deposit_call=209/256_before 1234914535
// Launchpad Numerics DepositGns call=209/256
// - Gas Used: 6188477
// - Storage Diff: 3956
// - CPU Cycles: 5314928
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=209/256_after 1234914535
// STATE CLOCK launchpad_deposit_call=210/256_before 1234914540
// Launchpad Numerics DepositGns call=210/256
// - Gas Used: 6505909
// - Storage Diff: 10622
// - CPU Cycles: 5566324
// - Realm gno.land/r/gnoswap/launchpad: 10622
// STATE CLOCK launchpad_deposit_call=210/256_after 1234914540
// STATE CLOCK launchpad_deposit_call=211/256_before 1234914545
// Launchpad Numerics DepositGns call=211/256
// - Gas Used: 6175513
// - Storage Diff: 4004
// - CPU Cycles: 5308810
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=211/256_after 1234914545
// STATE CLOCK launchpad_deposit_call=212/256_before 1234914550
// Launchpad Numerics DepositGns call=212/256
// - Gas Used: 6176979
// - Storage Diff: 3961
// - CPU Cycles: 5309295
// - Realm gno.land/r/gnoswap/gov/staker: 5
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=212/256_after 1234914550
// STATE CLOCK launchpad_deposit_call=213/256_before 1234914555
// Launchpad Numerics DepositGns call=213/256
// - Gas Used: 6183933
// - Storage Diff: 3961
// - CPU Cycles: 5315253
// - Realm gno.land/r/gnoswap/gov/staker: 5
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=213/256_after 1234914555
// STATE CLOCK launchpad_deposit_call=214/256_before 1234914560
// Launchpad Numerics DepositGns call=214/256
// - Gas Used: 6183921
// - Storage Diff: 3956
// - CPU Cycles: 5314281
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=214/256_after 1234914560
// STATE CLOCK launchpad_deposit_call=215/256_before 1234914565
// Launchpad Numerics DepositGns call=215/256
// - Gas Used: 6182073
// - Storage Diff: 3956
// - CPU Cycles: 5311473
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=215/256_after 1234914565
// STATE CLOCK launchpad_deposit_call=216/256_before 1234914570
// Launchpad Numerics DepositGns call=216/256
// - Gas Used: 6186328
// - Storage Diff: 3956
// - CPU Cycles: 5314768
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=216/256_after 1234914570
// STATE CLOCK launchpad_deposit_call=217/256_before 1234914575
// Launchpad Numerics DepositGns call=217/256
// - Gas Used: 6187293
// - Storage Diff: 3956
// - CPU Cycles: 5314773
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=217/256_after 1234914575
// STATE CLOCK launchpad_deposit_call=218/256_before 1234914580
// Launchpad Numerics DepositGns call=218/256
// - Gas Used: 6917339
// - Storage Diff: 17534
// - CPU Cycles: 5930457
// - Realm gno.land/r/gnoswap/launchpad: 17534
// STATE CLOCK launchpad_deposit_call=218/256_after 1234914580
// STATE CLOCK launchpad_deposit_call=219/256_before 1234914585
// Launchpad Numerics DepositGns call=219/256
// - Gas Used: 6168365
// - Storage Diff: 4052
// - CPU Cycles: 5309297
// - Realm gno.land/r/gnoswap/launchpad: 4052
// STATE CLOCK launchpad_deposit_call=219/256_after 1234914585
// STATE CLOCK launchpad_deposit_call=220/256_before 1234914590
// Launchpad Numerics DepositGns call=220/256
// - Gas Used: 6166805
// - Storage Diff: 3956
// - CPU Cycles: 5309135
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=220/256_after 1234914590
// STATE CLOCK launchpad_deposit_call=221/256_before 1234914595
// Launchpad Numerics DepositGns call=221/256
// - Gas Used: 6173728
// - Storage Diff: 3956
// - CPU Cycles: 5315098
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=221/256_after 1234914595
// STATE CLOCK launchpad_deposit_call=222/256_before 1234914600
// Launchpad Numerics DepositGns call=222/256
// - Gas Used: 6174690
// - Storage Diff: 3956
// - CPU Cycles: 5315100
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=222/256_after 1234914600
// STATE CLOCK launchpad_deposit_call=223/256_before 1234914605
// Launchpad Numerics DepositGns call=223/256
// - Gas Used: 6176137
// - Storage Diff: 3956
// - CPU Cycles: 5315587
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=223/256_after 1234914605
// STATE CLOCK launchpad_deposit_call=224/256_before 1234914610
// Launchpad Numerics DepositGns call=224/256
// - Gas Used: 6176610
// - Storage Diff: 3956
// - CPU Cycles: 5315100
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=224/256_after 1234914610
// STATE CLOCK launchpad_deposit_call=225/256_before 1234914615
// Launchpad Numerics DepositGns call=225/256
// - Gas Used: 6177570
// - Storage Diff: 3956
// - CPU Cycles: 5315100
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=225/256_after 1234914615
// STATE CLOCK launchpad_deposit_call=226/256_before 1234914620
// Launchpad Numerics DepositGns call=226/256
// - Gas Used: 6498114
// - Storage Diff: 10672
// - CPU Cycles: 5566164
// - Realm gno.land/r/gnoswap/launchpad: 10672
// STATE CLOCK launchpad_deposit_call=226/256_after 1234914620
// STATE CLOCK launchpad_deposit_call=227/256_before 1234914625
// Launchpad Numerics DepositGns call=227/256
// - Gas Used: 6166600
// - Storage Diff: 4004
// - CPU Cycles: 5308648
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=227/256_after 1234914625
// STATE CLOCK launchpad_deposit_call=228/256_before 1234914630
// Launchpad Numerics DepositGns call=228/256
// - Gas Used: 6167073
// - Storage Diff: 3956
// - CPU Cycles: 5308161
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=228/256_after 1234914630
// STATE CLOCK launchpad_deposit_call=229/256_before 1234914635
// Launchpad Numerics DepositGns call=229/256
// - Gas Used: 6175457
// - Storage Diff: 3956
// - CPU Cycles: 5315585
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=229/256_after 1234914635
// STATE CLOCK launchpad_deposit_call=230/256_before 1234914640
// Launchpad Numerics DepositGns call=230/256
// - Gas Used: 6164387
// - Storage Diff: 3956
// - CPU Cycles: 5305913
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=230/256_after 1234914640
// STATE CLOCK launchpad_deposit_call=231/256_before 1234914645
// Launchpad Numerics DepositGns call=231/256
// - Gas Used: 6162054
// - Storage Diff: 3956
// - CPU Cycles: 5302620
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=231/256_after 1234914645
// STATE CLOCK launchpad_deposit_call=232/256_before 1234914650
// Launchpad Numerics DepositGns call=232/256
// - Gas Used: 6166794
// - Storage Diff: 3956
// - CPU Cycles: 5306400
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=232/256_after 1234914650
// STATE CLOCK launchpad_deposit_call=233/256_before 1234914655
// Launchpad Numerics DepositGns call=233/256
// - Gas Used: 6174691
// - Storage Diff: 3956
// - CPU Cycles: 5313337
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=233/256_after 1234914655
// STATE CLOCK launchpad_deposit_call=234/256_before 1234914660
// Launchpad Numerics DepositGns call=234/256
// - Gas Used: 6425943
// - Storage Diff: 10382
// - CPU Cycles: 5493429
// - Realm gno.land/r/gnoswap/launchpad: 10382
// STATE CLOCK launchpad_deposit_call=234/256_after 1234914660
// STATE CLOCK launchpad_deposit_call=235/256_before 1234914665
// Launchpad Numerics DepositGns call=235/256
// - Gas Used: 6143644
// - Storage Diff: 4004
// - CPU Cycles: 5293504
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=235/256_after 1234914665
// STATE CLOCK launchpad_deposit_call=236/256_before 1234914670
// Launchpad Numerics DepositGns call=236/256
// - Gas Used: 6151054
// - Storage Diff: 3956
// - CPU Cycles: 5299954
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=236/256_after 1234914670
// STATE CLOCK launchpad_deposit_call=237/256_before 1234914675
// Launchpad Numerics DepositGns call=237/256
// - Gas Used: 6152501
// - Storage Diff: 3956
// - CPU Cycles: 5300441
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=237/256_after 1234914675
// STATE CLOCK launchpad_deposit_call=238/256_before 1234914680
// Launchpad Numerics DepositGns call=238/256
// - Gas Used: 6153461
// - Storage Diff: 3956
// - CPU Cycles: 5300441
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=238/256_after 1234914680
// STATE CLOCK launchpad_deposit_call=239/256_before 1234914685
// Launchpad Numerics DepositGns call=239/256
// - Gas Used: 6153934
// - Storage Diff: 3956
// - CPU Cycles: 5299954
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=239/256_after 1234914685
// STATE CLOCK launchpad_deposit_call=240/256_before 1234914690
// Launchpad Numerics DepositGns call=240/256
// - Gas Used: 6189284
// - Storage Diff: 3938
// - CPU Cycles: 5315564
// - Realm gno.land/r/gnoswap/launchpad: 3938
// STATE CLOCK launchpad_deposit_call=240/256_after 1234914690
// STATE CLOCK launchpad_deposit_call=241/256_before 1234914695
// Launchpad Numerics DepositGns call=241/256
// - Gas Used: 6184655
// - Storage Diff: 3914
// - CPU Cycles: 5310095
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=241/256_after 1234914695
// STATE CLOCK launchpad_deposit_call=242/256_before 1234914700
// Launchpad Numerics DepositGns call=242/256
// - Gas Used: 6190479
// - Storage Diff: 3914
// - CPU Cycles: 5315079
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=242/256_after 1234914700
// STATE CLOCK launchpad_deposit_call=243/256_before 1234914705
// Launchpad Numerics DepositGns call=243/256
// - Gas Used: 6192298
// - Storage Diff: 3914
// - CPU Cycles: 5316058
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=243/256_after 1234914705
// STATE CLOCK launchpad_deposit_call=244/256_before 1234914710
// Launchpad Numerics DepositGns call=244/256
// - Gas Used: 6193138
// - Storage Diff: 3914
// - CPU Cycles: 5316058
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=244/256_after 1234914710
// STATE CLOCK launchpad_deposit_call=245/256_before 1234914715
// Launchpad Numerics DepositGns call=245/256
// - Gas Used: 6188020
// - Storage Diff: 3914
// - CPU Cycles: 5310100
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=245/256_after 1234914715
// STATE CLOCK launchpad_deposit_call=246/256_before 1234914720
// Launchpad Numerics DepositGns call=246/256
// - Gas Used: 6195797
// - Storage Diff: 3914
// - CPU Cycles: 5317037
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=246/256_after 1234914720
// STATE CLOCK launchpad_deposit_call=247/256_before 1234914725
// Launchpad Numerics DepositGns call=247/256
// - Gas Used: 6194679
// - Storage Diff: 3914
// - CPU Cycles: 5315079
// - Realm gno.land/r/gnoswap/launchpad: 3914
// STATE CLOCK launchpad_deposit_call=247/256_after 1234914725
// STATE CLOCK launchpad_deposit_call=248/256_before 1234914730
// Launchpad Numerics DepositGns call=248/256
// - Gas Used: 6476578
// - Storage Diff: 10390
// - CPU Cycles: 5563832
// - Realm gno.land/r/gnoswap/launchpad: 10390
// STATE CLOCK launchpad_deposit_call=248/256_after 1234914730
// STATE CLOCK launchpad_deposit_call=249/256_before 1234914735
// Launchpad Numerics DepositGns call=249/256
// - Gas Used: 6184128
// - Storage Diff: 4004
// - CPU Cycles: 5309610
// - Realm gno.land/r/gnoswap/launchpad: 4004
// STATE CLOCK launchpad_deposit_call=249/256_after 1234914735
// STATE CLOCK launchpad_deposit_call=250/256_before 1234914740
// Launchpad Numerics DepositGns call=250/256
// - Gas Used: 6189505
// - Storage Diff: 3956
// - CPU Cycles: 5316385
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=250/256_after 1234914740
// STATE CLOCK launchpad_deposit_call=251/256_before 1234914745
// Launchpad Numerics DepositGns call=251/256
// - Gas Used: 6183535
// - Storage Diff: 3956
// - CPU Cycles: 5309455
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=251/256_after 1234914745
// STATE CLOCK launchpad_deposit_call=252/256_before 1234914750
// Launchpad Numerics DepositGns call=252/256
// - Gas Used: 6184980
// - Storage Diff: 3956
// - CPU Cycles: 5309940
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=252/256_after 1234914750
// STATE CLOCK launchpad_deposit_call=253/256_before 1234914755
// Launchpad Numerics DepositGns call=253/256
// - Gas Used: 6191895
// - Storage Diff: 3956
// - CPU Cycles: 5315895
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=253/256_after 1234914755
// STATE CLOCK launchpad_deposit_call=254/256_before 1234914760
// Launchpad Numerics DepositGns call=254/256
// - Gas Used: 6192855
// - Storage Diff: 3956
// - CPU Cycles: 5315895
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=254/256_after 1234914760
// STATE CLOCK launchpad_deposit_call=255/256_before 1234914765
// Launchpad Numerics DepositGns call=255/256
// - Gas Used: 6194307
// - Storage Diff: 3956
// - CPU Cycles: 5316387
// - Realm gno.land/r/gnoswap/launchpad: 3956
// STATE CLOCK launchpad_deposit_call=255/256_after 1234914765
// STATE CLOCK launchpad_deposit_call=256/256_before 1234914770
// Launchpad Numerics DepositGns call=256/256
// - Gas Used: 6481645
// - Storage Diff: 7526
// - CPU Cycles: 5557872
// - Realm gno.land/r/gnoswap/gns: -3136
// - Realm gno.land/r/gnoswap/launchpad: 10662
// STATE CLOCK launchpad_deposit_call=256/256_after 1234914770
// STATE launchpad-numerics phase=deposited-stage-256 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=0 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=1168479812265116018988177298603093692 manager_total_distribute=250000000 manager_total_claimed=0 manager_active_deposit=256000000 manager_active_claimed=0 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=1280 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=0 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69499 record_created_offset=1280 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_claim_1_1_before 1235001175
// Launchpad Numerics CollectReward pattern=1 call=1/1
// - Gas Used: 3205677
// - Storage Diff: 2046
// - CPU Cycles: 2902572
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2034
// STATE CLOCK launchpad_claim_1_1_after 1235001175
// STATE CLOCK launchpad_claim_10_2_before 1235001180
// Launchpad Numerics CollectReward pattern=10 call=1/10
// - Gas Used: 3193535
// - Storage Diff: 12
// - CPU Cycles: 2914879
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_2_after 1235001180
// STATE CLOCK launchpad_claim_10_3_before 1235001185
// Launchpad Numerics CollectReward pattern=10 call=2/10
// - Gas Used: 3172162
// - Storage Diff: 12
// - CPU Cycles: 2893506
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_3_after 1235001185
// STATE CLOCK launchpad_claim_10_4_before 1235001190
// Launchpad Numerics CollectReward pattern=10 call=3/10
// - Gas Used: 3180641
// - Storage Diff: 12
// - CPU Cycles: 2901991
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_4_after 1235001190
// STATE CLOCK launchpad_claim_10_5_before 1235001195
// Launchpad Numerics CollectReward pattern=10 call=4/10
// - Gas Used: 3154506
// - Storage Diff: 12
// - CPU Cycles: 2875856
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_5_after 1235001195
// STATE CLOCK launchpad_claim_10_6_before 1235001200
// Launchpad Numerics CollectReward pattern=10 call=5/10
// - Gas Used: 3158288
// - Storage Diff: 12
// - CPU Cycles: 2879638
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_6_after 1235001200
// STATE CLOCK launchpad_claim_10_7_before 1235001205
// Launchpad Numerics CollectReward pattern=10 call=6/10
// - Gas Used: 3157308
// - Storage Diff: 12
// - CPU Cycles: 2878658
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_7_after 1235001205
// STATE CLOCK launchpad_claim_10_8_before 1235001210
// Launchpad Numerics CollectReward pattern=10 call=7/10
// - Gas Used: 3157858
// - Storage Diff: 31
// - CPU Cycles: 2879151
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 19
// STATE CLOCK launchpad_claim_10_8_after 1235001210
// STATE CLOCK launchpad_claim_10_9_before 1235001215
// Launchpad Numerics CollectReward pattern=10 call=8/10
// - Gas Used: 3170281
// - Storage Diff: 20
// - CPU Cycles: 2891550
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 8
// STATE CLOCK launchpad_claim_10_9_after 1235001215
// STATE CLOCK launchpad_claim_10_10_before 1235001220
// Launchpad Numerics CollectReward pattern=10 call=9/10
// - Gas Used: 3178798
// - Storage Diff: 12
// - CPU Cycles: 2900067
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_10_10_after 1235001220
// STATE CLOCK launchpad_claim_10_11_before 1235001225
// Launchpad Numerics CollectReward pattern=10 call=10/10
// - Gas Used: 3166053
// - Storage Diff: 14
// - CPU Cycles: 2887307
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2
// STATE CLOCK launchpad_claim_10_11_after 1235001225
// STATE CLOCK launchpad_claim_100_12_before 1235001230
// Launchpad Numerics CollectReward pattern=100 call=1/100
// - Gas Used: 3169354
// - Storage Diff: 14
// - CPU Cycles: 2890602
// - Realm gno.land/r/gnoswap/launchpad: 12
// - Realm gno.land/r/onbloc/obl: 2
// STATE CLOCK launchpad_claim_100_12_after 1235001230
// STATE CLOCK launchpad_claim_100_13_before 1235001235
// Launchpad Numerics CollectReward pattern=100 call=2/100
// - Gas Used: 3168374
// - Storage Diff: 12
// - CPU Cycles: 2889622
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_13_after 1235001235
// STATE CLOCK launchpad_claim_100_14_before 1235001240
// Launchpad Numerics CollectReward pattern=100 call=3/100
// - Gas Used: 3169354
// - Storage Diff: 12
// - CPU Cycles: 2890602
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_14_after 1235001240
// STATE CLOCK launchpad_claim_100_15_before 1235001245
// Launchpad Numerics CollectReward pattern=100 call=4/100
// - Gas Used: 3180783
// - Storage Diff: 12
// - CPU Cycles: 2902031
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_15_after 1235001245
// STATE CLOCK launchpad_claim_100_16_before 1235001250
// Launchpad Numerics CollectReward pattern=100 call=5/100
// - Gas Used: 3183723
// - Storage Diff: 12
// - CPU Cycles: 2904971
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_16_after 1235001250
// STATE CLOCK launchpad_claim_100_17_before 1235001255
// Launchpad Numerics CollectReward pattern=100 call=6/100
// - Gas Used: 3192196
// - Storage Diff: 12
// - CPU Cycles: 2913450
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_17_after 1235001255
// STATE CLOCK launchpad_claim_100_18_before 1235001260
// Launchpad Numerics CollectReward pattern=100 call=7/100
// - Gas Used: 3181266
// - Storage Diff: 12
// - CPU Cycles: 2902514
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_18_after 1235001260
// STATE CLOCK launchpad_claim_100_19_before 1235001265
// Launchpad Numerics CollectReward pattern=100 call=8/100
// - Gas Used: 3182739
// - Storage Diff: 12
// - CPU Cycles: 2903987
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_19_after 1235001265
// STATE CLOCK launchpad_claim_100_20_before 1235001270
// Launchpad Numerics CollectReward pattern=100 call=9/100
// - Gas Used: 3182242
// - Storage Diff: 12
// - CPU Cycles: 2903490
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_20_after 1235001270
// STATE CLOCK launchpad_claim_100_21_before 1235001275
// Launchpad Numerics CollectReward pattern=100 call=10/100
// - Gas Used: 3169847
// - Storage Diff: 12
// - CPU Cycles: 2891095
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_21_after 1235001275
// STATE CLOCK launchpad_claim_100_22_before 1235001280
// Launchpad Numerics CollectReward pattern=100 call=11/100
// - Gas Used: 3189400
// - Storage Diff: 12
// - CPU Cycles: 2910648
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_22_after 1235001280
// STATE CLOCK launchpad_claim_100_23_before 1235001285
// Launchpad Numerics CollectReward pattern=100 call=12/100
// - Gas Used: 3196122
// - Storage Diff: 12
// - CPU Cycles: 2917370
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_23_after 1235001285
// STATE CLOCK launchpad_claim_100_24_before 1235001290
// Launchpad Numerics CollectReward pattern=100 call=13/100
// - Gas Used: 3193176
// - Storage Diff: 12
// - CPU Cycles: 2914430
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_24_after 1235001290
// STATE CLOCK launchpad_claim_100_25_before 1235001295
// Launchpad Numerics CollectReward pattern=100 call=14/100
// - Gas Used: 3182739
// - Storage Diff: 12
// - CPU Cycles: 2903987
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_25_after 1235001295
// STATE CLOCK launchpad_claim_100_26_before 1235001300
// Launchpad Numerics CollectReward pattern=100 call=15/100
// - Gas Used: 3171314
// - Storage Diff: 12
// - CPU Cycles: 2892562
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_26_after 1235001300
// STATE CLOCK launchpad_claim_100_27_before 1235001305
// Launchpad Numerics CollectReward pattern=100 call=16/100
// - Gas Used: 3171807
// - Storage Diff: 12
// - CPU Cycles: 2893055
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_27_after 1235001305
// STATE CLOCK launchpad_claim_100_28_before 1235001310
// Launchpad Numerics CollectReward pattern=100 call=17/100
// - Gas Used: 3179444
// - Storage Diff: 12
// - CPU Cycles: 2900692
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_28_after 1235001310
// STATE CLOCK launchpad_claim_100_29_before 1235001315
// Launchpad Numerics CollectReward pattern=100 call=18/100
// - Gas Used: 3184206
// - Storage Diff: 12
// - CPU Cycles: 2905454
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_29_after 1235001315
// STATE CLOCK launchpad_claim_100_30_before 1235001320
// Launchpad Numerics CollectReward pattern=100 call=19/100
// - Gas Used: 3172290
// - Storage Diff: 12
// - CPU Cycles: 2893538
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_30_after 1235001320
// STATE CLOCK launchpad_claim_100_31_before 1235001325
// Launchpad Numerics CollectReward pattern=100 call=20/100
// - Gas Used: 3178817
// - Storage Diff: 12
// - CPU Cycles: 2900071
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_31_after 1235001325
// STATE CLOCK launchpad_claim_100_32_before 1235001330
// Launchpad Numerics CollectReward pattern=100 call=21/100
// - Gas Used: 3180284
// - Storage Diff: 12
// - CPU Cycles: 2901538
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_32_after 1235001330
// STATE CLOCK launchpad_claim_100_33_before 1235001335
// Launchpad Numerics CollectReward pattern=100 call=22/100
// - Gas Used: 3167881
// - Storage Diff: 12
// - CPU Cycles: 2889135
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_33_after 1235001335
// STATE CLOCK launchpad_claim_100_34_before 1235001340
// Launchpad Numerics CollectReward pattern=100 call=23/100
// - Gas Used: 3168368
// - Storage Diff: 12
// - CPU Cycles: 2889622
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_34_after 1235001340
// STATE CLOCK launchpad_claim_100_35_before 1235001345
// Launchpad Numerics CollectReward pattern=100 call=24/100
// - Gas Used: 3169348
// - Storage Diff: 12
// - CPU Cycles: 2890602
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_35_after 1235001345
// STATE CLOCK launchpad_claim_100_36_before 1235001350
// Launchpad Numerics CollectReward pattern=100 call=25/100
// - Gas Used: 3168368
// - Storage Diff: 12
// - CPU Cycles: 2889622
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_36_after 1235001350
// STATE CLOCK launchpad_claim_100_37_before 1235001355
// Launchpad Numerics CollectReward pattern=100 call=26/100
// - Gas Used: 3168861
// - Storage Diff: 12
// - CPU Cycles: 2890115
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_37_after 1235001355
// STATE CLOCK launchpad_claim_100_38_before 1235001360
// Launchpad Numerics CollectReward pattern=100 call=27/100
// - Gas Used: 3168861
// - Storage Diff: 12
// - CPU Cycles: 2890115
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_38_after 1235001360
// STATE CLOCK launchpad_claim_100_39_before 1235001365
// Launchpad Numerics CollectReward pattern=100 call=28/100
// - Gas Used: 3176498
// - Storage Diff: 12
// - CPU Cycles: 2897752
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_39_after 1235001365
// STATE CLOCK launchpad_claim_100_40_before 1235001370
// Launchpad Numerics CollectReward pattern=100 call=29/100
// - Gas Used: 3169344
// - Storage Diff: 12
// - CPU Cycles: 2890598
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_40_after 1235001370
// STATE CLOCK launchpad_claim_100_41_before 1235001375
// Launchpad Numerics CollectReward pattern=100 call=30/100
// - Gas Used: 3169348
// - Storage Diff: 12
// - CPU Cycles: 2890602
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_41_after 1235001375
// STATE CLOCK launchpad_claim_100_42_before 1235001380
// Launchpad Numerics CollectReward pattern=100 call=31/100
// - Gas Used: 3169841
// - Storage Diff: 12
// - CPU Cycles: 2891095
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_42_after 1235001380
// STATE CLOCK launchpad_claim_100_43_before 1235001385
// Launchpad Numerics CollectReward pattern=100 call=32/100
// - Gas Used: 3169348
// - Storage Diff: 12
// - CPU Cycles: 2890602
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_43_after 1235001385
// STATE CLOCK launchpad_claim_100_44_before 1235001390
// Launchpad Numerics CollectReward pattern=100 call=33/100
// - Gas Used: 3169841
// - Storage Diff: 12
// - CPU Cycles: 2891095
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_44_after 1235001390
// STATE CLOCK launchpad_claim_100_45_before 1235001395
// Launchpad Numerics CollectReward pattern=100 call=34/100
// - Gas Used: 3165479
// - Storage Diff: 12
// - CPU Cycles: 2886733
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_45_after 1235001395
// STATE CLOCK launchpad_claim_100_46_before 1235001400
// Launchpad Numerics CollectReward pattern=100 call=35/100
// - Gas Used: 3168368
// - Storage Diff: 12
// - CPU Cycles: 2889622
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_46_after 1235001400
// STATE CLOCK launchpad_claim_100_47_before 1235001405
// Launchpad Numerics CollectReward pattern=100 call=36/100
// - Gas Used: 3169348
// - Storage Diff: 12
// - CPU Cycles: 2890602
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_47_after 1235001405
// STATE CLOCK launchpad_claim_100_48_before 1235001410
// Launchpad Numerics CollectReward pattern=100 call=37/100
// - Gas Used: 3156945
// - Storage Diff: 12
// - CPU Cycles: 2878199
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_48_after 1235001410
// STATE CLOCK launchpad_claim_100_49_before 1235001415
// Launchpad Numerics CollectReward pattern=100 call=38/100
// - Gas Used: 3157477
// - Storage Diff: 12
// - CPU Cycles: 2878686
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_49_after 1235001415
// STATE CLOCK launchpad_claim_100_50_before 1235001420
// Launchpad Numerics CollectReward pattern=100 call=39/100
// - Gas Used: 3156990
// - Storage Diff: 12
// - CPU Cycles: 2878199
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_50_after 1235001420
// STATE CLOCK launchpad_claim_100_51_before 1235001425
// Launchpad Numerics CollectReward pattern=100 call=40/100
// - Gas Used: 3158457
// - Storage Diff: 12
// - CPU Cycles: 2879666
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_51_after 1235001425
// STATE CLOCK launchpad_claim_100_52_before 1235001430
// Launchpad Numerics CollectReward pattern=100 call=41/100
// - Gas Used: 3158457
// - Storage Diff: 12
// - CPU Cycles: 2879666
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_52_after 1235001430
// STATE CLOCK launchpad_claim_100_53_before 1235001435
// Launchpad Numerics CollectReward pattern=100 call=42/100
// - Gas Used: 3168417
// - Storage Diff: 12
// - CPU Cycles: 2889626
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_53_after 1235001435
// STATE CLOCK launchpad_claim_100_54_before 1235001440
// Launchpad Numerics CollectReward pattern=100 call=43/100
// - Gas Used: 3168910
// - Storage Diff: 12
// - CPU Cycles: 2890119
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_54_after 1235001440
// STATE CLOCK launchpad_claim_100_55_before 1235001445
// Launchpad Numerics CollectReward pattern=100 call=44/100
// - Gas Used: 3157481
// - Storage Diff: 12
// - CPU Cycles: 2878690
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_55_after 1235001445
// STATE CLOCK launchpad_claim_100_56_before 1235001450
// Launchpad Numerics CollectReward pattern=100 call=45/100
// - Gas Used: 3153699
// - Storage Diff: 12
// - CPU Cycles: 2874908
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_56_after 1235001450
// STATE CLOCK launchpad_claim_100_57_before 1235001455
// Launchpad Numerics CollectReward pattern=100 call=46/100
// - Gas Used: 3158461
// - Storage Diff: 12
// - CPU Cycles: 2879670
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_57_after 1235001455
// STATE CLOCK launchpad_claim_100_58_before 1235001460
// Launchpad Numerics CollectReward pattern=100 call=47/100
// - Gas Used: 3157481
// - Storage Diff: 12
// - CPU Cycles: 2878690
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_58_after 1235001460
// STATE CLOCK launchpad_claim_100_59_before 1235001465
// Launchpad Numerics CollectReward pattern=100 call=48/100
// - Gas Used: 3157974
// - Storage Diff: 12
// - CPU Cycles: 2879183
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_59_after 1235001465
// STATE CLOCK launchpad_claim_100_60_before 1235001470
// Launchpad Numerics CollectReward pattern=100 call=49/100
// - Gas Used: 3168910
// - Storage Diff: 12
// - CPU Cycles: 2890119
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_60_after 1235001470
// STATE CLOCK launchpad_claim_100_61_before 1235001475
// Launchpad Numerics CollectReward pattern=100 call=50/100
// - Gas Used: 3169890
// - Storage Diff: 12
// - CPU Cycles: 2891099
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_61_after 1235001475
// STATE CLOCK launchpad_claim_100_62_before 1235001480
// Launchpad Numerics CollectReward pattern=100 call=51/100
// - Gas Used: 3158461
// - Storage Diff: 12
// - CPU Cycles: 2879670
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_62_after 1235001480
// STATE CLOCK launchpad_claim_100_63_before 1235001485
// Launchpad Numerics CollectReward pattern=100 call=52/100
// - Gas Used: 3157974
// - Storage Diff: 12
// - CPU Cycles: 2879183
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_63_after 1235001485
// STATE CLOCK launchpad_claim_100_64_before 1235001490
// Launchpad Numerics CollectReward pattern=100 call=53/100
// - Gas Used: 3159441
// - Storage Diff: 12
// - CPU Cycles: 2880650
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_64_after 1235001490
// STATE CLOCK launchpad_claim_100_65_before 1235001495
// Launchpad Numerics CollectReward pattern=100 call=54/100
// - Gas Used: 3157974
// - Storage Diff: 12
// - CPU Cycles: 2879183
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_65_after 1235001495
// STATE CLOCK launchpad_claim_100_66_before 1235001500
// Launchpad Numerics CollectReward pattern=100 call=55/100
// - Gas Used: 3159441
// - Storage Diff: 12
// - CPU Cycles: 2880650
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_66_after 1235001500
// STATE CLOCK launchpad_claim_100_67_before 1235001505
// Launchpad Numerics CollectReward pattern=100 call=56/100
// - Gas Used: 3155659
// - Storage Diff: 12
// - CPU Cycles: 2876868
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_67_after 1235001505
// STATE CLOCK launchpad_claim_100_68_before 1235001510
// Launchpad Numerics CollectReward pattern=100 call=57/100
// - Gas Used: 3168413
// - Storage Diff: 12
// - CPU Cycles: 2889622
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_68_after 1235001510
// STATE CLOCK launchpad_claim_100_69_before 1235001515
// Launchpad Numerics CollectReward pattern=100 call=58/100
// - Gas Used: 3169393
// - Storage Diff: 12
// - CPU Cycles: 2890602
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_69_after 1235001515
// STATE CLOCK launchpad_claim_100_70_before 1235001520
// Launchpad Numerics CollectReward pattern=100 call=59/100
// - Gas Used: 3157477
// - Storage Diff: 12
// - CPU Cycles: 2878686
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_70_after 1235001520
// STATE CLOCK launchpad_claim_100_71_before 1235001525
// Launchpad Numerics CollectReward pattern=100 call=60/100
// - Gas Used: 3157970
// - Storage Diff: 12
// - CPU Cycles: 2879179
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_71_after 1235001525
// STATE CLOCK launchpad_claim_100_72_before 1235001530
// Launchpad Numerics CollectReward pattern=100 call=61/100
// - Gas Used: 3157481
// - Storage Diff: 12
// - CPU Cycles: 2878690
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_72_after 1235001530
// STATE CLOCK launchpad_claim_100_73_before 1235001535
// Launchpad Numerics CollectReward pattern=100 call=62/100
// - Gas Used: 3154679
// - Storage Diff: 12
// - CPU Cycles: 2875888
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_73_after 1235001535
// STATE CLOCK launchpad_claim_100_74_before 1235001540
// Launchpad Numerics CollectReward pattern=100 call=63/100
// - Gas Used: 3158461
// - Storage Diff: 12
// - CPU Cycles: 2879670
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_74_after 1235001540
// STATE CLOCK launchpad_claim_100_75_before 1235001545
// Launchpad Numerics CollectReward pattern=100 call=64/100
// - Gas Used: 3169397
// - Storage Diff: 12
// - CPU Cycles: 2890606
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_75_after 1235001545
// STATE CLOCK launchpad_claim_100_76_before 1235001550
// Launchpad Numerics CollectReward pattern=100 call=65/100
// - Gas Used: 3170377
// - Storage Diff: 12
// - CPU Cycles: 2891586
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_76_after 1235001550
// STATE CLOCK launchpad_claim_100_77_before 1235001555
// Launchpad Numerics CollectReward pattern=100 call=66/100
// - Gas Used: 3157974
// - Storage Diff: 12
// - CPU Cycles: 2879183
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_77_after 1235001555
// STATE CLOCK launchpad_claim_100_78_before 1235001560
// Launchpad Numerics CollectReward pattern=100 call=67/100
// - Gas Used: 3157974
// - Storage Diff: 12
// - CPU Cycles: 2879183
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_78_after 1235001560
// STATE CLOCK launchpad_claim_100_79_before 1235001565
// Launchpad Numerics CollectReward pattern=100 call=68/100
// - Gas Used: 3159441
// - Storage Diff: 12
// - CPU Cycles: 2880650
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_79_after 1235001565
// STATE CLOCK launchpad_claim_100_80_before 1235001570
// Launchpad Numerics CollectReward pattern=100 call=69/100
// - Gas Used: 3159437
// - Storage Diff: 12
// - CPU Cycles: 2880646
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_80_after 1235001570
// STATE CLOCK launchpad_claim_100_81_before 1235001575
// Launchpad Numerics CollectReward pattern=100 call=70/100
// - Gas Used: 3159441
// - Storage Diff: 12
// - CPU Cycles: 2880650
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_81_after 1235001575
// STATE CLOCK launchpad_claim_100_82_before 1235001580
// Launchpad Numerics CollectReward pattern=100 call=71/100
// - Gas Used: 3168910
// - Storage Diff: 12
// - CPU Cycles: 2890119
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_82_after 1235001580
// STATE CLOCK launchpad_claim_100_83_before 1235001585
// Launchpad Numerics CollectReward pattern=100 call=72/100
// - Gas Used: 3169890
// - Storage Diff: 12
// - CPU Cycles: 2891099
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_83_after 1235001585
// STATE CLOCK launchpad_claim_100_84_before 1235001590
// Launchpad Numerics CollectReward pattern=100 call=73/100
// - Gas Used: 3166595
// - Storage Diff: 12
// - CPU Cycles: 2887804
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_84_after 1235001590
// STATE CLOCK launchpad_claim_100_85_before 1235001595
// Launchpad Numerics CollectReward pattern=100 call=74/100
// - Gas Used: 3171357
// - Storage Diff: 12
// - CPU Cycles: 2892566
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_85_after 1235001595
// STATE CLOCK launchpad_claim_100_86_before 1235001600
// Launchpad Numerics CollectReward pattern=100 call=75/100
// - Gas Used: 3169890
// - Storage Diff: 12
// - CPU Cycles: 2891099
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_86_after 1235001600
// STATE CLOCK launchpad_claim_100_87_before 1235001605
// Launchpad Numerics CollectReward pattern=100 call=76/100
// - Gas Used: 3171357
// - Storage Diff: 12
// - CPU Cycles: 2892566
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_87_after 1235001605
// STATE CLOCK launchpad_claim_100_88_before 1235001610
// Launchpad Numerics CollectReward pattern=100 call=77/100
// - Gas Used: 3170870
// - Storage Diff: 12
// - CPU Cycles: 2892079
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_88_after 1235001610
// STATE CLOCK launchpad_claim_100_89_before 1235001615
// Launchpad Numerics CollectReward pattern=100 call=78/100
// - Gas Used: 3171850
// - Storage Diff: 12
// - CPU Cycles: 2893059
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_89_after 1235001615
// STATE CLOCK launchpad_claim_100_90_before 1235001620
// Launchpad Numerics CollectReward pattern=100 call=79/100
// - Gas Used: 3167571
// - Storage Diff: 12
// - CPU Cycles: 2888780
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_90_after 1235001620
// STATE CLOCK launchpad_claim_100_91_before 1235001625
// Launchpad Numerics CollectReward pattern=100 call=80/100
// - Gas Used: 3171357
// - Storage Diff: 12
// - CPU Cycles: 2892566
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_91_after 1235001625
// STATE CLOCK launchpad_claim_100_92_before 1235001630
// Launchpad Numerics CollectReward pattern=100 call=81/100
// - Gas Used: 3172337
// - Storage Diff: 12
// - CPU Cycles: 2893546
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_92_after 1235001630
// STATE CLOCK launchpad_claim_100_93_before 1235001635
// Launchpad Numerics CollectReward pattern=100 call=82/100
// - Gas Used: 3171357
// - Storage Diff: 12
// - CPU Cycles: 2892566
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_93_after 1235001635
// STATE CLOCK launchpad_claim_100_94_before 1235001640
// Launchpad Numerics CollectReward pattern=100 call=83/100
// - Gas Used: 3171850
// - Storage Diff: 12
// - CPU Cycles: 2893059
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_94_after 1235001640
// STATE CLOCK launchpad_claim_100_95_before 1235001645
// Launchpad Numerics CollectReward pattern=100 call=84/100
// - Gas Used: 3172337
// - Storage Diff: 12
// - CPU Cycles: 2893546
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_95_after 1235001645
// STATE CLOCK launchpad_claim_100_96_before 1235001650
// Launchpad Numerics CollectReward pattern=100 call=85/100
// - Gas Used: 3158461
// - Storage Diff: 12
// - CPU Cycles: 2879670
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_96_after 1235001650
// STATE CLOCK launchpad_claim_100_97_before 1235001655
// Launchpad Numerics CollectReward pattern=100 call=86/100
// - Gas Used: 3174495
// - Storage Diff: 18
// - CPU Cycles: 2880650
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_97_after 1235001655
// STATE CLOCK launchpad_claim_100_98_before 1235001660
// Launchpad Numerics CollectReward pattern=100 call=87/100
// - Gas Used: 3162579
// - Storage Diff: 18
// - CPU Cycles: 2868734
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_98_after 1235001660
// STATE CLOCK launchpad_claim_100_99_before 1235001665
// Launchpad Numerics CollectReward pattern=100 call=88/100
// - Gas Used: 3162579
// - Storage Diff: 18
// - CPU Cycles: 2868734
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_99_after 1235001665
// STATE CLOCK launchpad_claim_100_100_before 1235001670
// Launchpad Numerics CollectReward pattern=100 call=89/100
// - Gas Used: 3185490
// - Storage Diff: 18
// - CPU Cycles: 2888183
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_100_after 1235001670
// STATE CLOCK launchpad_claim_100_101_before 1235001675
// Launchpad Numerics CollectReward pattern=100 call=90/100
// - Gas Used: 3182199
// - Storage Diff: 18
// - CPU Cycles: 2884892
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_101_after 1235001675
// STATE CLOCK launchpad_claim_100_102_before 1235001680
// Launchpad Numerics CollectReward pattern=100 call=91/100
// - Gas Used: 3186961
// - Storage Diff: 18
// - CPU Cycles: 2889654
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_102_after 1235001680
// STATE CLOCK launchpad_claim_100_103_before 1235001685
// Launchpad Numerics CollectReward pattern=100 call=92/100
// - Gas Used: 3185981
// - Storage Diff: 18
// - CPU Cycles: 2888674
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_103_after 1235001685
// STATE CLOCK launchpad_claim_100_104_before 1235001690
// Launchpad Numerics CollectReward pattern=100 call=93/100
// - Gas Used: 3186961
// - Storage Diff: 18
// - CPU Cycles: 2889654
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_104_after 1235001690
// STATE CLOCK launchpad_claim_100_105_before 1235001695
// Launchpad Numerics CollectReward pattern=100 call=94/100
// - Gas Used: 3186474
// - Storage Diff: 18
// - CPU Cycles: 2889167
// - Realm gno.land/r/gnoswap/launchpad: 18
// STATE CLOCK launchpad_claim_100_105_after 1235001695
// STATE CLOCK launchpad_claim_100_106_before 1235001700
// Launchpad Numerics CollectReward pattern=100 call=95/100
// - Gas Used: 3178894
// - Storage Diff: 12
// - CPU Cycles: 2900103
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_106_after 1235001700
// STATE CLOCK launchpad_claim_100_107_before 1235001705
// Launchpad Numerics CollectReward pattern=100 call=96/100
// - Gas Used: 3172217
// - Storage Diff: 12
// - CPU Cycles: 2893426
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_107_after 1235001705
// STATE CLOCK launchpad_claim_100_108_before 1235001710
// Launchpad Numerics CollectReward pattern=100 call=97/100
// - Gas Used: 3168441
// - Storage Diff: 12
// - CPU Cycles: 2889650
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_108_after 1235001710
// STATE CLOCK launchpad_claim_100_109_before 1235001715
// Launchpad Numerics CollectReward pattern=100 call=98/100
// - Gas Used: 3167954
// - Storage Diff: 12
// - CPU Cycles: 2889163
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_109_after 1235001715
// STATE CLOCK launchpad_claim_100_110_before 1235001720
// Launchpad Numerics CollectReward pattern=100 call=99/100
// - Gas Used: 3168441
// - Storage Diff: 12
// - CPU Cycles: 2889650
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_110_after 1235001720
// STATE CLOCK launchpad_claim_100_111_before 1235001725
// Launchpad Numerics CollectReward pattern=100 call=100/100
// - Gas Used: 3168934
// - Storage Diff: 12
// - CPU Cycles: 2890143
// - Realm gno.land/r/gnoswap/launchpad: 12
// STATE CLOCK launchpad_claim_100_111_after 1235001725
// STATE launchpad-numerics phase=claimed-pattern-1 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=0 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=0 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=0 reward_claimed=35987 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-pattern-10 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=644752419472195378092327733873980578 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=55 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=34111 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69254 record_created_offset=55 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE launchpad-numerics phase=claimed-pattern-100 global_staked=256000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=0 tier_deposit_count=256 tier_withdraw_count=0 tier_collected=3723333 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=12316533474830447782910876269154536737 manager_total_distribute=250000000 manager_total_claimed=3723333 manager_active_deposit=256000000 manager_active_claimed=3723333 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=88235 manager_accumulated_distribute=0 manager_rewards=256 reward_present=1 reward_debt=1030928654824012160364300924622681117 reward_claimable_offset=86400 reward_deposit_amount=1000000 reward_start_offset=555 reward_end_offset=2592000 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=33165 record_present=1 record_amount=1000000 record_tier=30 record_created_height=69354 record_created_offset=555 record_end_offset=2592000 record_withdrawn=0 record_withdrawn_offset=-1 record_withdrawn_height_offset=-1
// STATE CLOCK launchpad_withdraw_1_before 1237505495
// Launchpad Numerics CollectDepositGns call=1/256
// - Gas Used: 8079071
// - Storage Diff: -3682
// - CPU Cycles: 6954605
// - Realm gno.land/r/gnoswap/gns: 2055
// - Realm gno.land/r/gnoswap/launchpad: -5737
// STATE CLOCK launchpad_withdraw_1_after 1237505495
// STATE launchpad-numerics phase=withdrawn-stage-1 global_staked=255000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=1000000 tier_deposit_count=256 tier_withdraw_count=1 tier_collected=4666860 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=4666860 manager_active_deposit=255000000 manager_active_claimed=3687346 manager_active_debt=257120663184198285618581461598963827469000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=255 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69244 record_created_offset=5 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_2_before 1237505500
// Launchpad Numerics CollectDepositGns call=2/256
// - Gas Used: 7667252
// - Storage Diff: -5733
// - CPU Cycles: 6675893
// - Realm gno.land/r/gnoswap/launchpad: -5733
// STATE CLOCK launchpad_withdraw_2_after 1237505500
// STATE CLOCK launchpad_withdraw_3_before 1237505505
// Launchpad Numerics CollectDepositGns call=3/256
// - Gas Used: 7496100
// - Storage Diff: -2258
// - CPU Cycles: 6530138
// - Realm gno.land/r/gnoswap/launchpad: -2258
// STATE CLOCK launchpad_withdraw_3_after 1237505505
// STATE CLOCK launchpad_withdraw_4_before 1237505510
// Launchpad Numerics CollectDepositGns call=4/256
// - Gas Used: 7642316
// - Storage Diff: -5699
// - CPU Cycles: 6653339
// - Realm gno.land/r/gnoswap/launchpad: -5699
// STATE CLOCK launchpad_withdraw_4_after 1237505510
// STATE CLOCK launchpad_withdraw_5_before 1237505515
// Launchpad Numerics CollectDepositGns call=5/256
// - Gas Used: 7569192
// - Storage Diff: -2263
// - CPU Cycles: 6582477
// - Realm gno.land/r/gnoswap/launchpad: -2263
// STATE CLOCK launchpad_withdraw_5_after 1237505515
// STATE CLOCK launchpad_withdraw_6_before 1237505520
// Launchpad Numerics CollectDepositGns call=6/256
// - Gas Used: 7700861
// - Storage Diff: -5742
// - CPU Cycles: 6692933
// - Realm gno.land/r/gnoswap/launchpad: -5742
// STATE CLOCK launchpad_withdraw_6_after 1237505520
// STATE CLOCK launchpad_withdraw_7_before 1237505525
// Launchpad Numerics CollectDepositGns call=7/256
// - Gas Used: 7695911
// - Storage Diff: -5730
// - CPU Cycles: 6690716
// - Realm gno.land/r/gnoswap/launchpad: -5730
// STATE CLOCK launchpad_withdraw_7_after 1237505525
// STATE CLOCK launchpad_withdraw_8_before 1237505530
// Launchpad Numerics CollectDepositGns call=8/256
// - Gas Used: 7569235
// - Storage Diff: -2263
// - CPU Cycles: 6582397
// - Realm gno.land/r/gnoswap/launchpad: -2263
// STATE CLOCK launchpad_withdraw_8_after 1237505530
// STATE CLOCK launchpad_withdraw_9_before 1237505535
// Launchpad Numerics CollectDepositGns call=9/256
// - Gas Used: 7494403
// - Storage Diff: -2258
// - CPU Cycles: 6527115
// - Realm gno.land/r/gnoswap/launchpad: -2263
// - Realm gno.land/r/onbloc/obl: 5
// STATE CLOCK launchpad_withdraw_9_after 1237505535
// STATE CLOCK launchpad_withdraw_10_before 1237505540
// Launchpad Numerics CollectDepositGns call=10/256
// - Gas Used: 7529751
// - Storage Diff: -2258
// - CPU Cycles: 6552378
// - Realm gno.land/r/gnoswap/launchpad: -2276
// - Realm gno.land/r/onbloc/obl: 18
// STATE CLOCK launchpad_withdraw_10_after 1237505540
// STATE CLOCK launchpad_withdraw_11_before 1237505545
// Launchpad Numerics CollectDepositGns call=11/256
// - Gas Used: 7499633
// - Storage Diff: -2277
// - CPU Cycles: 6536152
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_11_after 1237505545
// STATE CLOCK launchpad_withdraw_12_before 1237505550
// Launchpad Numerics CollectDepositGns call=12/256
// - Gas Used: 7588253
// - Storage Diff: -2265
// - CPU Cycles: 6601424
// - Realm gno.land/r/gnoswap/launchpad: -2265
// STATE CLOCK launchpad_withdraw_12_after 1237505550
// STATE CLOCK launchpad_withdraw_13_before 1237505555
// Launchpad Numerics CollectDepositGns call=13/256
// - Gas Used: 7713592
// - Storage Diff: -5733
// - CPU Cycles: 6701983
// - Realm gno.land/r/gnoswap/launchpad: -5733
// STATE CLOCK launchpad_withdraw_13_after 1237505555
// STATE CLOCK launchpad_withdraw_14_before 1237505560
// Launchpad Numerics CollectDepositGns call=14/256
// - Gas Used: 7595355
// - Storage Diff: -2265
// - CPU Cycles: 6601584
// - Realm gno.land/r/gnoswap/launchpad: -2265
// STATE CLOCK launchpad_withdraw_14_after 1237505560
// STATE CLOCK launchpad_withdraw_15_before 1237505565
// Launchpad Numerics CollectDepositGns call=15/256
// - Gas Used: 7544881
// - Storage Diff: -2264
// - CPU Cycles: 6557746
// - Realm gno.land/r/gnoswap/launchpad: -2264
// STATE CLOCK launchpad_withdraw_15_after 1237505565
// STATE CLOCK launchpad_withdraw_16_before 1237505570
// Launchpad Numerics CollectDepositGns call=16/256
// - Gas Used: 7518840
// - Storage Diff: -2277
// - CPU Cycles: 6549254
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_16_after 1237505570
// STATE CLOCK launchpad_withdraw_17_before 1237505575
// Launchpad Numerics CollectDepositGns call=17/256
// - Gas Used: 7758141
// - Storage Diff: -9095
// - CPU Cycles: 6759829
// - Realm gno.land/r/gnoswap/launchpad: -9095
// STATE CLOCK launchpad_withdraw_17_after 1237505575
// STATE CLOCK launchpad_withdraw_18_before 1237505580
// Launchpad Numerics CollectDepositGns call=18/256
// - Gas Used: 7597998
// - Storage Diff: -2265
// - CPU Cycles: 6611658
// - Realm gno.land/r/gnoswap/launchpad: -2265
// STATE CLOCK launchpad_withdraw_18_after 1237505580
// STATE CLOCK launchpad_withdraw_19_before 1237505585
// Launchpad Numerics CollectDepositGns call=19/256
// - Gas Used: 7617926
// - Storage Diff: -2265
// - CPU Cycles: 6621156
// - Realm gno.land/r/gnoswap/launchpad: -2265
// STATE CLOCK launchpad_withdraw_19_after 1237505585
// STATE CLOCK launchpad_withdraw_20_before 1237505590
// Launchpad Numerics CollectDepositGns call=20/256
// - Gas Used: 7512230
// - Storage Diff: -2277
// - CPU Cycles: 6546958
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_20_after 1237505590
// STATE CLOCK launchpad_withdraw_21_before 1237505595
// Launchpad Numerics CollectDepositGns call=21/256
// - Gas Used: 7588704
// - Storage Diff: -2265
// - CPU Cycles: 6602319
// - Realm gno.land/r/gnoswap/launchpad: -2265
// STATE CLOCK launchpad_withdraw_21_after 1237505595
// STATE CLOCK launchpad_withdraw_22_before 1237505600
// Launchpad Numerics CollectDepositGns call=22/256
// - Gas Used: 7547266
// - Storage Diff: -2264
// - CPU Cycles: 6566680
// - Realm gno.land/r/gnoswap/launchpad: -2264
// STATE CLOCK launchpad_withdraw_22_after 1237505600
// STATE CLOCK launchpad_withdraw_23_before 1237505605
// Launchpad Numerics CollectDepositGns call=23/256
// - Gas Used: 7521078
// - Storage Diff: -2277
// - CPU Cycles: 6558188
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_23_after 1237505605
// STATE CLOCK launchpad_withdraw_24_before 1237505610
// Launchpad Numerics CollectDepositGns call=24/256
// - Gas Used: 7633998
// - Storage Diff: -5563
// - CPU Cycles: 6651130
// - Realm gno.land/r/gnoswap/launchpad: -5563
// STATE CLOCK launchpad_withdraw_24_after 1237505610
// STATE CLOCK launchpad_withdraw_25_before 1237505615
// Launchpad Numerics CollectDepositGns call=25/256
// - Gas Used: 7720779
// - Storage Diff: -5486
// - CPU Cycles: 6707165
// - Realm gno.land/r/gnoswap/launchpad: -5486
// STATE CLOCK launchpad_withdraw_25_after 1237505615
// STATE CLOCK launchpad_withdraw_26_before 1237505620
// Launchpad Numerics CollectDepositGns call=26/256
// - Gas Used: 7492104
// - Storage Diff: -2277
// - CPU Cycles: 6527750
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_26_after 1237505620
// STATE CLOCK launchpad_withdraw_27_before 1237505625
// Launchpad Numerics CollectDepositGns call=27/256
// - Gas Used: 7491160
// - Storage Diff: -2277
// - CPU Cycles: 6528405
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_27_after 1237505625
// STATE CLOCK launchpad_withdraw_28_before 1237505630
// Launchpad Numerics CollectDepositGns call=28/256
// - Gas Used: 7498660
// - Storage Diff: -2277
// - CPU Cycles: 6537504
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_28_after 1237505630
// STATE CLOCK launchpad_withdraw_29_before 1237505635
// Launchpad Numerics CollectDepositGns call=29/256
// - Gas Used: 7496736
// - Storage Diff: -2277
// - CPU Cycles: 6537179
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_29_after 1237505635
// STATE CLOCK launchpad_withdraw_30_before 1237505640
// Launchpad Numerics CollectDepositGns call=30/256
// - Gas Used: 7487100
// - Storage Diff: -2277
// - CPU Cycles: 6529142
// - Realm gno.land/r/gnoswap/launchpad: -2277
// STATE CLOCK launchpad_withdraw_30_after 1237505640
// STATE CLOCK launchpad_withdraw_31_before 1237505645
// Launchpad Numerics CollectDepositGns call=31/256
// - Gas Used: 7522176
// - Storage Diff: -2276
// - CPU Cycles: 6544284
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_31_after 1237505645
// STATE CLOCK launchpad_withdraw_32_before 1237505650
// Launchpad Numerics CollectDepositGns call=32/256
// - Gas Used: 7521235
// - Storage Diff: -2276
// - CPU Cycles: 6544939
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_32_after 1237505650
// STATE launchpad-numerics phase=withdrawn-stage-32 global_staked=224000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=32000000 tier_deposit_count=256 tier_withdraw_count=32 tier_collected=33915241 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=33915241 manager_active_deposit=224000000 manager_active_claimed=2632955 manager_active_debt=235972506899103895716586901958147712416000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=224 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69275 record_created_offset=160 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_33_before 1237505655
// Launchpad Numerics CollectDepositGns call=33/256
// - Gas Used: 7510622
// - Storage Diff: -2276
// - CPU Cycles: 6535922
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_33_after 1237505655
// STATE CLOCK launchpad_withdraw_34_before 1237505660
// Launchpad Numerics CollectDepositGns call=34/256
// - Gas Used: 7508946
// - Storage Diff: -2276
// - CPU Cycles: 6535842
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_34_after 1237505660
// STATE CLOCK launchpad_withdraw_35_before 1237505665
// Launchpad Numerics CollectDepositGns call=35/256
// - Gas Used: 7508005
// - Storage Diff: -2276
// - CPU Cycles: 6536497
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_35_after 1237505665
// STATE CLOCK launchpad_withdraw_36_before 1237505670
// Launchpad Numerics CollectDepositGns call=36/256
// - Gas Used: 7505594
// - Storage Diff: -2276
// - CPU Cycles: 6535682
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_36_after 1237505670
// STATE CLOCK launchpad_withdraw_37_before 1237505675
// Launchpad Numerics CollectDepositGns call=37/256
// - Gas Used: 7597517
// - Storage Diff: -2275
// - CPU Cycles: 6612777
// - Realm gno.land/r/gnoswap/launchpad: -2275
// STATE CLOCK launchpad_withdraw_37_after 1237505675
// STATE CLOCK launchpad_withdraw_38_before 1237505680
// Launchpad Numerics CollectDepositGns call=38/256
// - Gas Used: 7585629
// - Storage Diff: -2276
// - CPU Cycles: 6601908
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_38_after 1237505680
// STATE CLOCK launchpad_withdraw_39_before 1237505685
// Launchpad Numerics CollectDepositGns call=39/256
// - Gas Used: 7607840
// - Storage Diff: -2276
// - CPU Cycles: 6607359
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_39_after 1237505685
// STATE CLOCK launchpad_withdraw_40_before 1237505690
// Launchpad Numerics CollectDepositGns call=40/256
// - Gas Used: 7597962
// - Storage Diff: -2276
// - CPU Cycles: 6599077
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_40_after 1237505690
// STATE CLOCK launchpad_withdraw_41_before 1237505695
// Launchpad Numerics CollectDepositGns call=41/256
// - Gas Used: 7596289
// - Storage Diff: -2276
// - CPU Cycles: 6599000
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_41_after 1237505695
// STATE CLOCK launchpad_withdraw_42_before 1237505700
// Launchpad Numerics CollectDepositGns call=42/256
// - Gas Used: 7595348
// - Storage Diff: -2276
// - CPU Cycles: 6599655
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_42_after 1237505700
// STATE CLOCK launchpad_withdraw_43_before 1237505705
// Launchpad Numerics CollectDepositGns call=43/256
// - Gas Used: 7592937
// - Storage Diff: -2276
// - CPU Cycles: 6598840
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_43_after 1237505705
// STATE CLOCK launchpad_withdraw_44_before 1237505710
// Launchpad Numerics CollectDepositGns call=44/256
// - Gas Used: 7591996
// - Storage Diff: -2276
// - CPU Cycles: 6599495
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_44_after 1237505710
// STATE CLOCK launchpad_withdraw_45_before 1237505715
// Launchpad Numerics CollectDepositGns call=45/256
// - Gas Used: 7590320
// - Storage Diff: -2276
// - CPU Cycles: 6599415
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_45_after 1237505715
// STATE CLOCK launchpad_withdraw_46_before 1237505720
// Launchpad Numerics CollectDepositGns call=46/256
// - Gas Used: 7708264
// - Storage Diff: -5745
// - CPU Cycles: 6701197
// - Realm gno.land/r/gnoswap/launchpad: -5745
// STATE CLOCK launchpad_withdraw_46_after 1237505720
// STATE CLOCK launchpad_withdraw_47_before 1237505725
// Launchpad Numerics CollectDepositGns call=47/256
// - Gas Used: 7490643
// - Storage Diff: -2276
// - CPU Cycles: 6526280
// - Realm gno.land/r/gnoswap/launchpad: -2276
// STATE CLOCK launchpad_withdraw_47_after 1237505725
// STATE CLOCK launchpad_withdraw_48_before 1237505730
// Launchpad Numerics CollectDepositGns call=48/256
// - Gas Used: 7480030
// - Storage Diff: -2278
// - CPU Cycles: 6517263
// - Realm gno.land/r/gnoswap/launchpad: -2278
// STATE CLOCK launchpad_withdraw_48_after 1237505730
// STATE CLOCK launchpad_withdraw_49_before 1237505735
// Launchpad Numerics CollectDepositGns call=49/256
// - Gas Used: 7479433
// - Storage Diff: -2291
// - CPU Cycles: 6518163
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_49_after 1237505735
// STATE CLOCK launchpad_withdraw_50_before 1237505740
// Launchpad Numerics CollectDepositGns call=50/256
// - Gas Used: 7476765
// - Storage Diff: -2291
// - CPU Cycles: 6517103
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_50_after 1237505740
// STATE CLOCK launchpad_withdraw_51_before 1237505745
// Launchpad Numerics CollectDepositGns call=51/256
// - Gas Used: 7476792
// - Storage Diff: -2291
// - CPU Cycles: 6518738
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_51_after 1237505745
// STATE CLOCK launchpad_withdraw_52_before 1237505750
// Launchpad Numerics CollectDepositGns call=52/256
// - Gas Used: 7590523
// - Storage Diff: -2290
// - CPU Cycles: 6605555
// - Realm gno.land/r/gnoswap/launchpad: -2290
// STATE CLOCK launchpad_withdraw_52_after 1237505750
// STATE CLOCK launchpad_withdraw_53_before 1237505755
// Launchpad Numerics CollectDepositGns call=53/256
// - Gas Used: 7586093
// - Storage Diff: -2291
// - CPU Cycles: 6602156
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_53_after 1237505755
// STATE CLOCK launchpad_withdraw_54_before 1237505760
// Launchpad Numerics CollectDepositGns call=54/256
// - Gas Used: 7599188
// - Storage Diff: -2291
// - CPU Cycles: 6600063
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_54_after 1237505760
// STATE CLOCK launchpad_withdraw_55_before 1237505765
// Launchpad Numerics CollectDepositGns call=55/256
// - Gas Used: 7588563
// - Storage Diff: -2291
// - CPU Cycles: 6591046
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_55_after 1237505765
// STATE CLOCK launchpad_withdraw_56_before 1237505770
// Launchpad Numerics CollectDepositGns call=56/256
// - Gas Used: 7586875
// - Storage Diff: -2291
// - CPU Cycles: 6590966
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_56_after 1237505770
// STATE CLOCK launchpad_withdraw_57_before 1237505775
// Launchpad Numerics CollectDepositGns call=57/256
// - Gas Used: 7585922
// - Storage Diff: -2291
// - CPU Cycles: 6591621
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_57_after 1237505775
// STATE CLOCK launchpad_withdraw_58_before 1237505780
// Launchpad Numerics CollectDepositGns call=58/256
// - Gas Used: 7583499
// - Storage Diff: -2291
// - CPU Cycles: 6590806
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_58_after 1237505780
// STATE CLOCK launchpad_withdraw_59_before 1237505785
// Launchpad Numerics CollectDepositGns call=59/256
// - Gas Used: 7582546
// - Storage Diff: -2291
// - CPU Cycles: 6591461
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_59_after 1237505785
// STATE CLOCK launchpad_withdraw_60_before 1237505790
// Launchpad Numerics CollectDepositGns call=60/256
// - Gas Used: 7708699
// - Storage Diff: -5771
// - CPU Cycles: 6702133
// - Realm gno.land/r/gnoswap/launchpad: -5771
// STATE CLOCK launchpad_withdraw_60_after 1237505790
// STATE CLOCK launchpad_withdraw_61_before 1237505795
// Launchpad Numerics CollectDepositGns call=61/256
// - Gas Used: 7492484
// - Storage Diff: -2291
// - CPU Cycles: 6527998
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_61_after 1237505795
// STATE CLOCK launchpad_withdraw_62_before 1237505800
// Launchpad Numerics CollectDepositGns call=62/256
// - Gas Used: 7481859
// - Storage Diff: -2291
// - CPU Cycles: 6518981
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_62_after 1237505800
// STATE CLOCK launchpad_withdraw_63_before 1237505805
// Launchpad Numerics CollectDepositGns call=63/256
// - Gas Used: 7481151
// - Storage Diff: -2291
// - CPU Cycles: 6519881
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_63_after 1237505805
// STATE CLOCK launchpad_withdraw_64_before 1237505810
// Launchpad Numerics CollectDepositGns call=64/256
// - Gas Used: 7479218
// - Storage Diff: -2291
// - CPU Cycles: 6519556
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_64_after 1237505810
// STATE CLOCK launchpad_withdraw_65_before 1237505815
// Launchpad Numerics CollectDepositGns call=65/256
// - Gas Used: 7477775
// - Storage Diff: -2291
// - CPU Cycles: 6519721
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_65_after 1237505815
// STATE CLOCK launchpad_withdraw_66_before 1237505820
// Launchpad Numerics CollectDepositGns call=66/256
// - Gas Used: 7590284
// - Storage Diff: -2290
// - CPU Cycles: 6605313
// - Realm gno.land/r/gnoswap/launchpad: -2290
// STATE CLOCK launchpad_withdraw_66_after 1237505820
// STATE CLOCK launchpad_withdraw_67_before 1237505825
// Launchpad Numerics CollectDepositGns call=67/256
// - Gas Used: 7578384
// - Storage Diff: -2291
// - CPU Cycles: 6594444
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_67_after 1237505825
// STATE CLOCK launchpad_withdraw_68_before 1237505830
// Launchpad Numerics CollectDepositGns call=68/256
// - Gas Used: 7705563
// - Storage Diff: -5771
// - CPU Cycles: 6699633
// - Realm gno.land/r/gnoswap/launchpad: -5771
// STATE CLOCK launchpad_withdraw_68_after 1237505830
// STATE CLOCK launchpad_withdraw_69_before 1237505835
// Launchpad Numerics CollectDepositGns call=69/256
// - Gas Used: 7490766
// - Storage Diff: -2291
// - CPU Cycles: 6526280
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_69_after 1237505835
// STATE CLOCK launchpad_withdraw_70_before 1237505840
// Launchpad Numerics CollectDepositGns call=70/256
// - Gas Used: 7480141
// - Storage Diff: -2291
// - CPU Cycles: 6517263
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_70_after 1237505840
// STATE CLOCK launchpad_withdraw_71_before 1237505845
// Launchpad Numerics CollectDepositGns call=71/256
// - Gas Used: 7480168
// - Storage Diff: -2291
// - CPU Cycles: 6518898
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_71_after 1237505845
// STATE CLOCK launchpad_withdraw_72_before 1237505850
// Launchpad Numerics CollectDepositGns call=72/256
// - Gas Used: 7476768
// - Storage Diff: -2291
// - CPU Cycles: 6517106
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_72_after 1237505850
// STATE CLOCK launchpad_withdraw_73_before 1237505855
// Launchpad Numerics CollectDepositGns call=73/256
// - Gas Used: 7476795
// - Storage Diff: -2291
// - CPU Cycles: 6518741
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_73_after 1237505855
// STATE CLOCK launchpad_withdraw_74_before 1237505860
// Launchpad Numerics CollectDepositGns call=74/256
// - Gas Used: 7590532
// - Storage Diff: -2290
// - CPU Cycles: 6605558
// - Realm gno.land/r/gnoswap/launchpad: -2290
// STATE CLOCK launchpad_withdraw_74_after 1237505860
// STATE CLOCK launchpad_withdraw_75_before 1237505865
// Launchpad Numerics CollectDepositGns call=75/256
// - Gas Used: 7586834
// - Storage Diff: -2291
// - CPU Cycles: 6602891
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_75_after 1237505865
// STATE CLOCK launchpad_withdraw_76_before 1237505870
// Launchpad Numerics CollectDepositGns call=76/256
// - Gas Used: 7599929
// - Storage Diff: -2291
// - CPU Cycles: 6600798
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_76_after 1237505870
// STATE CLOCK launchpad_withdraw_77_before 1237505875
// Launchpad Numerics CollectDepositGns call=77/256
// - Gas Used: 7589304
// - Storage Diff: -2291
// - CPU Cycles: 6591781
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_77_after 1237505875
// STATE CLOCK launchpad_withdraw_78_before 1237505880
// Launchpad Numerics CollectDepositGns call=78/256
// - Gas Used: 7587616
// - Storage Diff: -2291
// - CPU Cycles: 6591701
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_78_after 1237505880
// STATE CLOCK launchpad_withdraw_79_before 1237505885
// Launchpad Numerics CollectDepositGns call=79/256
// - Gas Used: 7586663
// - Storage Diff: -2291
// - CPU Cycles: 6592356
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_79_after 1237505885
// STATE CLOCK launchpad_withdraw_80_before 1237505890
// Launchpad Numerics CollectDepositGns call=80/256
// - Gas Used: 7584972
// - Storage Diff: -2291
// - CPU Cycles: 6592273
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_80_after 1237505890
// STATE CLOCK launchpad_withdraw_81_before 1237505895
// Launchpad Numerics CollectDepositGns call=81/256
// - Gas Used: 7583287
// - Storage Diff: -2291
// - CPU Cycles: 6592196
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_81_after 1237505895
// STATE CLOCK launchpad_withdraw_82_before 1237505900
// Launchpad Numerics CollectDepositGns call=82/256
// - Gas Used: 7705863
// - Storage Diff: -5771
// - CPU Cycles: 6700569
// - Realm gno.land/r/gnoswap/launchpad: -5771
// STATE CLOCK launchpad_withdraw_82_after 1237505900
// STATE CLOCK launchpad_withdraw_83_before 1237505905
// Launchpad Numerics CollectDepositGns call=83/256
// - Gas Used: 7492484
// - Storage Diff: -2291
// - CPU Cycles: 6527998
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_83_after 1237505905
// STATE CLOCK launchpad_withdraw_84_before 1237505910
// Launchpad Numerics CollectDepositGns call=84/256
// - Gas Used: 7490796
// - Storage Diff: -2291
// - CPU Cycles: 6527918
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_84_after 1237505910
// STATE CLOCK launchpad_withdraw_85_before 1237505915
// Launchpad Numerics CollectDepositGns call=85/256
// - Gas Used: 7490823
// - Storage Diff: -2291
// - CPU Cycles: 6529553
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_85_after 1237505915
// STATE CLOCK launchpad_withdraw_86_before 1237505920
// Launchpad Numerics CollectDepositGns call=86/256
// - Gas Used: 7487420
// - Storage Diff: -2291
// - CPU Cycles: 6527758
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_86_after 1237505920
// STATE CLOCK launchpad_withdraw_87_before 1237505925
// Launchpad Numerics CollectDepositGns call=87/256
// - Gas Used: 7487447
// - Storage Diff: -2291
// - CPU Cycles: 6529393
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_87_after 1237505925
// STATE CLOCK launchpad_withdraw_88_before 1237505930
// Launchpad Numerics CollectDepositGns call=88/256
// - Gas Used: 7600207
// - Storage Diff: -2290
// - CPU Cycles: 6615230
// - Realm gno.land/r/gnoswap/launchpad: -2290
// STATE CLOCK launchpad_withdraw_88_after 1237505930
// STATE CLOCK launchpad_withdraw_89_before 1237505935
// Launchpad Numerics CollectDepositGns call=89/256
// - Gas Used: 7589042
// - Storage Diff: -2291
// - CPU Cycles: 6605096
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_89_after 1237505935
// STATE CLOCK launchpad_withdraw_90_before 1237505940
// Launchpad Numerics CollectDepositGns call=90/256
// - Gas Used: 7705912
// - Storage Diff: -5771
// - CPU Cycles: 6701254
// - Realm gno.land/r/gnoswap/launchpad: -5771
// STATE CLOCK launchpad_withdraw_90_after 1237505940
// STATE CLOCK launchpad_withdraw_91_before 1237505945
// Launchpad Numerics CollectDepositGns call=91/256
// - Gas Used: 7493219
// - Storage Diff: -2291
// - CPU Cycles: 6528733
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_91_after 1237505945
// STATE CLOCK launchpad_withdraw_92_before 1237505950
// Launchpad Numerics CollectDepositGns call=92/256
// - Gas Used: 7492266
// - Storage Diff: -2291
// - CPU Cycles: 6529388
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_92_after 1237505950
// STATE CLOCK launchpad_withdraw_93_before 1237505955
// Launchpad Numerics CollectDepositGns call=93/256
// - Gas Used: 7490823
// - Storage Diff: -2291
// - CPU Cycles: 6529553
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_93_after 1237505955
// STATE CLOCK launchpad_withdraw_94_before 1237505960
// Launchpad Numerics CollectDepositGns call=94/256
// - Gas Used: 7488890
// - Storage Diff: -2291
// - CPU Cycles: 6529228
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_94_after 1237505960
// STATE CLOCK launchpad_withdraw_95_before 1237505965
// Launchpad Numerics CollectDepositGns call=95/256
// - Gas Used: 7488182
// - Storage Diff: -2291
// - CPU Cycles: 6530128
// - Realm gno.land/r/gnoswap/launchpad: -2291
// STATE CLOCK launchpad_withdraw_95_after 1237505965
// STATE CLOCK launchpad_withdraw_96_before 1237505970
// Launchpad Numerics CollectDepositGns call=96/256
// - Gas Used: 7571468
// - Storage Diff: -2290
// - CPU Cycles: 6593982
// - Realm gno.land/r/gnoswap/launchpad: -2290
// STATE CLOCK launchpad_withdraw_96_after 1237505970
// STATE CLOCK launchpad_withdraw_97_before 1237505975
// Launchpad Numerics CollectDepositGns call=97/256
// - Gas Used: 7597938
// - Storage Diff: -2285
// - CPU Cycles: 6583848
// - Realm gno.land/r/gnoswap/launchpad: -2285
// STATE CLOCK launchpad_withdraw_97_after 1237505975
// STATE CLOCK launchpad_withdraw_98_before 1237505980
// Launchpad Numerics CollectDepositGns call=98/256
// - Gas Used: 7694810
// - Storage Diff: -12194
// - CPU Cycles: 6680390
// - Realm gno.land/r/gnoswap/launchpad: -12194
// STATE CLOCK launchpad_withdraw_98_after 1237505980
// STATE CLOCK launchpad_withdraw_99_before 1237505985
// Launchpad Numerics CollectDepositGns call=99/256
// - Gas Used: 7420672
// - Storage Diff: -2285
// - CPU Cycles: 6451216
// - Realm gno.land/r/gnoswap/launchpad: -2285
// STATE CLOCK launchpad_withdraw_99_after 1237505985
// STATE CLOCK launchpad_withdraw_100_before 1237505990
// Launchpad Numerics CollectDepositGns call=100/256
// - Gas Used: 7491199
// - Storage Diff: -2285
// - CPU Cycles: 6481045
// - Realm gno.land/r/gnoswap/launchpad: -2285
// STATE CLOCK launchpad_withdraw_100_after 1237505990
// STATE CLOCK launchpad_withdraw_101_before 1237505995
// Launchpad Numerics CollectDepositGns call=101/256
// - Gas Used: 7488716
// - Storage Diff: -2285
// - CPU Cycles: 6480968
// - Realm gno.land/r/gnoswap/launchpad: -2285
// STATE CLOCK launchpad_withdraw_101_after 1237505995
// STATE CLOCK launchpad_withdraw_102_before 1237506000
// Launchpad Numerics CollectDepositGns call=102/256
// - Gas Used: 7486965
// - Storage Diff: -2285
// - CPU Cycles: 6481623
// - Realm gno.land/r/gnoswap/launchpad: -2285
// STATE CLOCK launchpad_withdraw_102_after 1237506000
// STATE CLOCK launchpad_withdraw_103_before 1237506005
// Launchpad Numerics CollectDepositGns call=103/256
// - Gas Used: 7483744
// - Storage Diff: -2285
// - CPU Cycles: 6480808
// - Realm gno.land/r/gnoswap/launchpad: -2285
// STATE CLOCK launchpad_withdraw_103_after 1237506005
// STATE CLOCK launchpad_withdraw_104_before 1237506010
// Launchpad Numerics CollectDepositGns call=104/256
// - Gas Used: 7613842
// - Storage Diff: -5765
// - CPU Cycles: 6572453
// - Realm gno.land/r/gnoswap/launchpad: -5765
// STATE CLOCK launchpad_withdraw_104_after 1237506010
// STATE CLOCK launchpad_withdraw_105_before 1237506015
// Launchpad Numerics CollectDepositGns call=105/256
// - Gas Used: 7499419
// - Storage Diff: -2285
// - CPU Cycles: 6482023
// - Realm gno.land/r/gnoswap/launchpad: -2285
// STATE CLOCK launchpad_withdraw_105_after 1237506015
// STATE CLOCK launchpad_withdraw_106_before 1237506020
// Launchpad Numerics CollectDepositGns call=106/256
// - Gas Used: 7454042
// - Storage Diff: -2292
// - CPU Cycles: 6490145
// - Realm gno.land/r/gnoswap/launchpad: -2292
// STATE CLOCK launchpad_withdraw_106_after 1237506020
// STATE CLOCK launchpad_withdraw_107_before 1237506025
// Launchpad Numerics CollectDepositGns call=107/256
// - Gas Used: 7453086
// - Storage Diff: -2292
// - CPU Cycles: 6490800
// - Realm gno.land/r/gnoswap/launchpad: -2292
// STATE CLOCK launchpad_withdraw_107_after 1237506025
// STATE CLOCK launchpad_withdraw_108_before 1237506030
// Launchpad Numerics CollectDepositGns call=108/256
// - Gas Used: 7442455
// - Storage Diff: -2292
// - CPU Cycles: 6481780
// - Realm gno.land/r/gnoswap/launchpad: -2292
// STATE CLOCK launchpad_withdraw_108_after 1237506030
// STATE CLOCK launchpad_withdraw_109_before 1237506035
// Launchpad Numerics CollectDepositGns call=109/256
// - Gas Used: 7440764
// - Storage Diff: -2292
// - CPU Cycles: 6481700
// - Realm gno.land/r/gnoswap/launchpad: -2292
// STATE CLOCK launchpad_withdraw_109_after 1237506035
// STATE CLOCK launchpad_withdraw_110_before 1237506040
// Launchpad Numerics CollectDepositGns call=110/256
// - Gas Used: 7439073
// - Storage Diff: -2292
// - CPU Cycles: 6481620
// - Realm gno.land/r/gnoswap/launchpad: -2292
// STATE CLOCK launchpad_withdraw_110_after 1237506040
// STATE CLOCK launchpad_withdraw_111_before 1237506045
// Launchpad Numerics CollectDepositGns call=111/256
// - Gas Used: 7438117
// - Storage Diff: -2292
// - CPU Cycles: 6482275
// - Realm gno.land/r/gnoswap/launchpad: -2292
// STATE CLOCK launchpad_withdraw_111_after 1237506045
// STATE CLOCK launchpad_withdraw_112_before 1237506050
// Launchpad Numerics CollectDepositGns call=112/256
// - Gas Used: 7552900
// - Storage Diff: -2280
// - CPU Cycles: 6561533
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_112_after 1237506050
// STATE CLOCK launchpad_withdraw_113_before 1237506055
// Launchpad Numerics CollectDepositGns call=113/256
// - Gas Used: 7558682
// - Storage Diff: -2280
// - CPU Cycles: 6568926
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_113_after 1237506055
// STATE CLOCK launchpad_withdraw_114_before 1237506060
// Launchpad Numerics CollectDepositGns call=114/256
// - Gas Used: 7557726
// - Storage Diff: -2280
// - CPU Cycles: 6569581
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_114_after 1237506060
// STATE CLOCK launchpad_withdraw_115_before 1237506065
// Launchpad Numerics CollectDepositGns call=115/256
// - Gas Used: 7547095
// - Storage Diff: -2280
// - CPU Cycles: 6560561
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_115_after 1237506065
// STATE CLOCK launchpad_withdraw_116_before 1237506070
// Launchpad Numerics CollectDepositGns call=116/256
// - Gas Used: 7545404
// - Storage Diff: -2280
// - CPU Cycles: 6560481
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_116_after 1237506070
// STATE CLOCK launchpad_withdraw_117_before 1237506075
// Launchpad Numerics CollectDepositGns call=117/256
// - Gas Used: 7544448
// - Storage Diff: -2280
// - CPU Cycles: 6561136
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_117_after 1237506075
// STATE CLOCK launchpad_withdraw_118_before 1237506080
// Launchpad Numerics CollectDepositGns call=118/256
// - Gas Used: 7564714
// - Storage Diff: -5760
// - CPU Cycles: 6571292
// - Realm gno.land/r/gnoswap/launchpad: -5760
// STATE CLOCK launchpad_withdraw_118_after 1237506080
// STATE CLOCK launchpad_withdraw_119_before 1237506085
// Launchpad Numerics CollectDepositGns call=119/256
// - Gas Used: 7447225
// - Storage Diff: -2280
// - CPU Cycles: 6481717
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_119_after 1237506085
// STATE CLOCK launchpad_withdraw_120_before 1237506090
// Launchpad Numerics CollectDepositGns call=120/256
// - Gas Used: 7453739
// - Storage Diff: -2280
// - CPU Cycles: 6489842
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_120_after 1237506090
// STATE CLOCK launchpad_withdraw_121_before 1237506095
// Launchpad Numerics CollectDepositGns call=121/256
// - Gas Used: 7452783
// - Storage Diff: -2280
// - CPU Cycles: 6490497
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_121_after 1237506095
// STATE CLOCK launchpad_withdraw_122_before 1237506100
// Launchpad Numerics CollectDepositGns call=122/256
// - Gas Used: 7442152
// - Storage Diff: -2280
// - CPU Cycles: 6481477
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_122_after 1237506100
// STATE CLOCK launchpad_withdraw_123_before 1237506105
// Launchpad Numerics CollectDepositGns call=123/256
// - Gas Used: 7440461
// - Storage Diff: -2280
// - CPU Cycles: 6481397
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_123_after 1237506105
// STATE CLOCK launchpad_withdraw_124_before 1237506110
// Launchpad Numerics CollectDepositGns call=124/256
// - Gas Used: 7439505
// - Storage Diff: -2280
// - CPU Cycles: 6482052
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_124_after 1237506110
// STATE CLOCK launchpad_withdraw_125_before 1237506115
// Launchpad Numerics CollectDepositGns call=125/256
// - Gas Used: 7437079
// - Storage Diff: -2280
// - CPU Cycles: 6481237
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_125_after 1237506115
// STATE CLOCK launchpad_withdraw_126_before 1237506120
// Launchpad Numerics CollectDepositGns call=126/256
// - Gas Used: 7564393
// - Storage Diff: -5761
// - CPU Cycles: 6572642
// - Realm gno.land/r/gnoswap/launchpad: -5761
// STATE CLOCK launchpad_withdraw_126_after 1237506120
// STATE CLOCK launchpad_withdraw_127_before 1237506125
// Launchpad Numerics CollectDepositGns call=127/256
// - Gas Used: 7447960
// - Storage Diff: -2280
// - CPU Cycles: 6482452
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_127_after 1237506125
// STATE CLOCK launchpad_withdraw_128_before 1237506130
// Launchpad Numerics CollectDepositGns call=128/256
// - Gas Used: 7453001
// - Storage Diff: -2280
// - CPU Cycles: 6489104
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_128_after 1237506130
// STATE launchpad-numerics phase=withdrawn-stage-128 global_staked=128000000 tier_rate=32820444340368293158118692846428261135802 tier_total_distribute=250000000 tier_total_deposit=256000000 tier_total_withdraw=128000000 tier_deposit_count=256 tier_withdraw_count=128 tier_collected=125042846 tier_window=2592000 tier_at_start=1 tier_at_end=0 tier_ended_at_end=0 tier_ended_after_end=1 manager_rate=32820444340368293158118692846428261135802 manager_accumulator=333311376536792242779149348904457096278 manager_total_distribute=250000000 manager_total_claimed=125042846 manager_active_deposit=128000000 manager_active_claimed=0 manager_active_debt=143161052288871807480826382395675884485000000 manager_window=2592000 manager_cursor_offset=2592000 manager_accumulated_distribute=0 manager_rewards=128 reward_present=0 reward_debt=- reward_claimable_offset=-1 reward_deposit_amount=0 reward_start_offset=0 reward_end_offset=0 reward_accumulated_amount=0 reward_cursor_offset=-1 reward_claimed=0 record_present=1 record_amount=0 record_tier=30 record_created_height=69371 record_created_offset=640 record_end_offset=2592000 record_withdrawn=1 record_withdrawn_offset=2592000 record_withdrawn_height_offset=518400
// STATE CLOCK launchpad_withdraw_129_before 1237506135
// Launchpad Numerics CollectDepositGns call=129/256
// - Gas Used: 7452045
// - Storage Diff: -2280
// - CPU Cycles: 6489759
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_129_after 1237506135
// STATE CLOCK launchpad_withdraw_130_before 1237506140
// Launchpad Numerics CollectDepositGns call=130/256
// - Gas Used: 7441414
// - Storage Diff: -2280
// - CPU Cycles: 6480739
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_130_after 1237506140
// STATE CLOCK launchpad_withdraw_131_before 1237506145
// Launchpad Numerics CollectDepositGns call=131/256
// - Gas Used: 7440458
// - Storage Diff: -2280
// - CPU Cycles: 6481394
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_131_after 1237506145
// STATE CLOCK launchpad_withdraw_132_before 1237506150
// Launchpad Numerics CollectDepositGns call=132/256
// - Gas Used: 7438035
// - Storage Diff: -2280
// - CPU Cycles: 6480582
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_132_after 1237506150
// STATE CLOCK launchpad_withdraw_133_before 1237506155
// Launchpad Numerics CollectDepositGns call=133/256
// - Gas Used: 7437079
// - Storage Diff: -2280
// - CPU Cycles: 6481237
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_133_after 1237506155
// STATE CLOCK launchpad_withdraw_134_before 1237506160
// Launchpad Numerics CollectDepositGns call=134/256
// - Gas Used: 7561867
// - Storage Diff: -5749
// - CPU Cycles: 6571787
// - Realm gno.land/r/gnoswap/launchpad: -5749
// STATE CLOCK launchpad_withdraw_134_after 1237506160
// STATE CLOCK launchpad_withdraw_135_before 1237506165
// Launchpad Numerics CollectDepositGns call=135/256
// - Gas Used: 7455430
// - Storage Diff: -2280
// - CPU Cycles: 6489922
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_135_after 1237506165
// STATE CLOCK launchpad_withdraw_136_before 1237506170
// Launchpad Numerics CollectDepositGns call=136/256
// - Gas Used: 7454474
// - Storage Diff: -2280
// - CPU Cycles: 6490577
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_136_after 1237506170
// STATE CLOCK launchpad_withdraw_137_before 1237506175
// Launchpad Numerics CollectDepositGns call=137/256
// - Gas Used: 7443843
// - Storage Diff: -2280
// - CPU Cycles: 6481557
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_137_after 1237506175
// STATE CLOCK launchpad_withdraw_138_before 1237506180
// Launchpad Numerics CollectDepositGns call=138/256
// - Gas Used: 7442152
// - Storage Diff: -2280
// - CPU Cycles: 6481477
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_138_after 1237506180
// STATE CLOCK launchpad_withdraw_139_before 1237506185
// Launchpad Numerics CollectDepositGns call=139/256
// - Gas Used: 7441196
// - Storage Diff: -2280
// - CPU Cycles: 6482132
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_139_after 1237506185
// STATE CLOCK launchpad_withdraw_140_before 1237506190
// Launchpad Numerics CollectDepositGns call=140/256
// - Gas Used: 7439502
// - Storage Diff: -2280
// - CPU Cycles: 6482049
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_140_after 1237506190
// STATE CLOCK launchpad_withdraw_141_before 1237506195
// Launchpad Numerics CollectDepositGns call=141/256
// - Gas Used: 7437814
// - Storage Diff: -2280
// - CPU Cycles: 6481972
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_141_after 1237506195
// STATE CLOCK launchpad_withdraw_142_before 1237506200
// Launchpad Numerics CollectDepositGns call=142/256
// - Gas Used: 7567292
// - Storage Diff: -2280
// - CPU Cycles: 6569658
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_142_after 1237506200
// STATE CLOCK launchpad_withdraw_143_before 1237506205
// Launchpad Numerics CollectDepositGns call=143/256
// - Gas Used: 7566336
// - Storage Diff: -2280
// - CPU Cycles: 6570313
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_143_after 1237506205
// STATE CLOCK launchpad_withdraw_144_before 1237506210
// Launchpad Numerics CollectDepositGns call=144/256
// - Gas Used: 7555705
// - Storage Diff: -2280
// - CPU Cycles: 6561293
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_144_after 1237506210
// STATE CLOCK launchpad_withdraw_145_before 1237506215
// Launchpad Numerics CollectDepositGns call=145/256
// - Gas Used: 7554014
// - Storage Diff: -2280
// - CPU Cycles: 6561213
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_145_after 1237506215
// STATE CLOCK launchpad_withdraw_146_before 1237506220
// Launchpad Numerics CollectDepositGns call=146/256
// - Gas Used: 7553058
// - Storage Diff: -2280
// - CPU Cycles: 6561868
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_146_after 1237506220
// STATE CLOCK launchpad_withdraw_147_before 1237506225
// Launchpad Numerics CollectDepositGns call=147/256
// - Gas Used: 7560073
// - Storage Diff: -5761
// - CPU Cycles: 6571664
// - Realm gno.land/r/gnoswap/launchpad: -5761
// STATE CLOCK launchpad_withdraw_147_after 1237506225
// STATE CLOCK launchpad_withdraw_148_before 1237506230
// Launchpad Numerics CollectDepositGns call=148/256
// - Gas Used: 7447957
// - Storage Diff: -2280
// - CPU Cycles: 6482449
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_148_after 1237506230
// STATE CLOCK launchpad_withdraw_149_before 1237506235
// Launchpad Numerics CollectDepositGns call=149/256
// - Gas Used: 7446266
// - Storage Diff: -2280
// - CPU Cycles: 6482369
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_149_after 1237506235
// STATE CLOCK launchpad_withdraw_150_before 1237506240
// Launchpad Numerics CollectDepositGns call=150/256
// - Gas Used: 7453512
// - Storage Diff: -2280
// - CPU Cycles: 6491226
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_150_after 1237506240
// STATE CLOCK launchpad_withdraw_151_before 1237506245
// Launchpad Numerics CollectDepositGns call=151/256
// - Gas Used: 7451824
// - Storage Diff: -2280
// - CPU Cycles: 6491149
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_151_after 1237506245
// STATE CLOCK launchpad_withdraw_152_before 1237506250
// Launchpad Numerics CollectDepositGns call=152/256
// - Gas Used: 7450868
// - Storage Diff: -2280
// - CPU Cycles: 6491804
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_152_after 1237506250
// STATE CLOCK launchpad_withdraw_153_before 1237506255
// Launchpad Numerics CollectDepositGns call=153/256
// - Gas Used: 7448442
// - Storage Diff: -2280
// - CPU Cycles: 6490989
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_153_after 1237506255
// STATE CLOCK launchpad_withdraw_154_before 1237506260
// Launchpad Numerics CollectDepositGns call=154/256
// - Gas Used: 7447486
// - Storage Diff: -2280
// - CPU Cycles: 6491644
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_154_after 1237506260
// STATE CLOCK launchpad_withdraw_155_before 1237506265
// Launchpad Numerics CollectDepositGns call=155/256
// - Gas Used: 7561058
// - Storage Diff: -2244
// - CPU Cycles: 6571863
// - Realm gno.land/r/gnoswap/launchpad: -2244
// STATE CLOCK launchpad_withdraw_155_after 1237506265
// STATE CLOCK launchpad_withdraw_156_before 1237506270
// Launchpad Numerics CollectDepositGns call=156/256
// - Gas Used: 7560102
// - Storage Diff: -2280
// - CPU Cycles: 6572518
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_156_after 1237506270
// STATE CLOCK launchpad_withdraw_157_before 1237506275
// Launchpad Numerics CollectDepositGns call=157/256
// - Gas Used: 7547182
// - Storage Diff: -2280
// - CPU Cycles: 6561212
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_157_after 1237506275
// STATE CLOCK launchpad_withdraw_158_before 1237506280
// Launchpad Numerics CollectDepositGns call=158/256
// - Gas Used: 7542974
// - Storage Diff: -2280
// - CPU Cycles: 6558616
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_158_after 1237506280
// STATE CLOCK launchpad_withdraw_159_before 1237506285
// Launchpad Numerics CollectDepositGns call=159/256
// - Gas Used: 7541283
// - Storage Diff: -2280
// - CPU Cycles: 6558536
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_159_after 1237506285
// STATE CLOCK launchpad_withdraw_160_before 1237506290
// Launchpad Numerics CollectDepositGns call=160/256
// - Gas Used: 7555663
// - Storage Diff: -5607
// - CPU Cycles: 6568947
// - Realm gno.land/r/gnoswap/launchpad: -5607
// STATE CLOCK launchpad_withdraw_160_after 1237506290
// STATE CLOCK launchpad_withdraw_161_before 1237506295
// Launchpad Numerics CollectDepositGns call=161/256
// - Gas Used: 7445338
// - Storage Diff: -2280
// - CPU Cycles: 6479852
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_161_after 1237506295
// STATE CLOCK launchpad_withdraw_162_before 1237506300
// Launchpad Numerics CollectDepositGns call=162/256
// - Gas Used: 7443647
// - Storage Diff: -2280
// - CPU Cycles: 6479772
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_162_after 1237506300
// STATE CLOCK launchpad_withdraw_163_before 1237506305
// Launchpad Numerics CollectDepositGns call=163/256
// - Gas Used: 7438281
// - Storage Diff: -2280
// - CPU Cycles: 6476017
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_163_after 1237506305
// STATE CLOCK launchpad_withdraw_164_before 1237506310
// Launchpad Numerics CollectDepositGns call=164/256
// - Gas Used: 7551319
// - Storage Diff: -2274
// - CPU Cycles: 6476672
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_164_after 1237506310
// STATE CLOCK launchpad_withdraw_165_before 1237506315
// Launchpad Numerics CollectDepositGns call=165/256
// - Gas Used: 7549628
// - Storage Diff: -2274
// - CPU Cycles: 6476592
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_165_after 1237506315
// STATE CLOCK launchpad_withdraw_166_before 1237506320
// Launchpad Numerics CollectDepositGns call=166/256
// - Gas Used: 7548672
// - Storage Diff: -2274
// - CPU Cycles: 6477247
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_166_after 1237506320
// STATE CLOCK launchpad_withdraw_167_before 1237506325
// Launchpad Numerics CollectDepositGns call=167/256
// - Gas Used: 7546246
// - Storage Diff: -2274
// - CPU Cycles: 6476432
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_167_after 1237506325
// STATE CLOCK launchpad_withdraw_168_before 1237506330
// Launchpad Numerics CollectDepositGns call=168/256
// - Gas Used: 7666393
// - Storage Diff: -5755
// - CPU Cycles: 6567357
// - Realm gno.land/r/gnoswap/launchpad: -5755
// STATE CLOCK launchpad_withdraw_168_after 1237506330
// STATE CLOCK launchpad_withdraw_169_before 1237506335
// Launchpad Numerics CollectDepositGns call=169/256
// - Gas Used: 7545208
// - Storage Diff: -2274
// - CPU Cycles: 6465731
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_169_after 1237506335
// STATE CLOCK launchpad_withdraw_170_before 1237506340
// Launchpad Numerics CollectDepositGns call=170/256
// - Gas Used: 7554062
// - Storage Diff: -2273
// - CPU Cycles: 6474588
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_170_after 1237506340
// STATE CLOCK launchpad_withdraw_171_before 1237506345
// Launchpad Numerics CollectDepositGns call=171/256
// - Gas Used: 7543437
// - Storage Diff: -2273
// - CPU Cycles: 6465571
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_171_after 1237506345
// STATE CLOCK launchpad_withdraw_172_before 1237506350
// Launchpad Numerics CollectDepositGns call=172/256
// - Gas Used: 7541749
// - Storage Diff: -2273
// - CPU Cycles: 6465491
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_172_after 1237506350
// STATE CLOCK launchpad_withdraw_173_before 1237506355
// Launchpad Numerics CollectDepositGns call=173/256
// - Gas Used: 7540796
// - Storage Diff: -2273
// - CPU Cycles: 6466146
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_173_after 1237506355
// STATE CLOCK launchpad_withdraw_174_before 1237506360
// Launchpad Numerics CollectDepositGns call=174/256
// - Gas Used: 7538373
// - Storage Diff: -2273
// - CPU Cycles: 6465331
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_174_after 1237506360
// STATE CLOCK launchpad_withdraw_175_before 1237506365
// Launchpad Numerics CollectDepositGns call=175/256
// - Gas Used: 7537420
// - Storage Diff: -2273
// - CPU Cycles: 6465986
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_175_after 1237506365
// STATE CLOCK launchpad_withdraw_176_before 1237506370
// Launchpad Numerics CollectDepositGns call=176/256
// - Gas Used: 7655047
// - Storage Diff: -5754
// - CPU Cycles: 6556056
// - Realm gno.land/r/gnoswap/launchpad: -5754
// STATE CLOCK launchpad_withdraw_176_after 1237506370
// STATE CLOCK launchpad_withdraw_177_before 1237506375
// Launchpad Numerics CollectDepositGns call=177/256
// - Gas Used: 7439443
// - Storage Diff: -2280
// - CPU Cycles: 6473939
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_177_after 1237506375
// STATE CLOCK launchpad_withdraw_178_before 1237506380
// Launchpad Numerics CollectDepositGns call=178/256
// - Gas Used: 7438487
// - Storage Diff: -2280
// - CPU Cycles: 6474594
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_178_after 1237506380
// STATE CLOCK launchpad_withdraw_179_before 1237506385
// Launchpad Numerics CollectDepositGns call=179/256
// - Gas Used: 7427856
// - Storage Diff: -2280
// - CPU Cycles: 6465574
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_179_after 1237506385
// STATE CLOCK launchpad_withdraw_180_before 1237506390
// Launchpad Numerics CollectDepositGns call=180/256
// - Gas Used: 7426897
// - Storage Diff: -2280
// - CPU Cycles: 6466226
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_180_after 1237506390
// STATE CLOCK launchpad_withdraw_181_before 1237506395
// Launchpad Numerics CollectDepositGns call=181/256
// - Gas Used: 7424474
// - Storage Diff: -2280
// - CPU Cycles: 6465414
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_181_after 1237506395
// STATE CLOCK launchpad_withdraw_182_before 1237506400
// Launchpad Numerics CollectDepositGns call=182/256
// - Gas Used: 7423518
// - Storage Diff: -2280
// - CPU Cycles: 6466069
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_182_after 1237506400
// STATE CLOCK launchpad_withdraw_183_before 1237506405
// Launchpad Numerics CollectDepositGns call=183/256
// - Gas Used: 7421827
// - Storage Diff: -2280
// - CPU Cycles: 6465989
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_183_after 1237506405
// STATE CLOCK launchpad_withdraw_184_before 1237506410
// Launchpad Numerics CollectDepositGns call=184/256
// - Gas Used: 7542330
// - Storage Diff: -2280
// - CPU Cycles: 6554333
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_184_after 1237506410
// STATE CLOCK launchpad_withdraw_185_before 1237506415
// Launchpad Numerics CollectDepositGns call=185/256
// - Gas Used: 7541374
// - Storage Diff: -2280
// - CPU Cycles: 6554988
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_185_after 1237506415
// STATE CLOCK launchpad_withdraw_186_before 1237506420
// Launchpad Numerics CollectDepositGns call=186/256
// - Gas Used: 7530743
// - Storage Diff: -2280
// - CPU Cycles: 6545968
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_186_after 1237506420
// STATE CLOCK launchpad_withdraw_187_before 1237506425
// Launchpad Numerics CollectDepositGns call=187/256
// - Gas Used: 7529052
// - Storage Diff: -2280
// - CPU Cycles: 6545888
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_187_after 1237506425
// STATE CLOCK launchpad_withdraw_188_before 1237506430
// Launchpad Numerics CollectDepositGns call=188/256
// - Gas Used: 7538395
// - Storage Diff: -5761
// - CPU Cycles: 6556674
// - Realm gno.land/r/gnoswap/launchpad: -5761
// STATE CLOCK launchpad_withdraw_188_after 1237506430
// STATE CLOCK launchpad_withdraw_189_before 1237506435
// Launchpad Numerics CollectDepositGns call=189/256
// - Gas Used: 7431970
// - Storage Diff: -2280
// - CPU Cycles: 6466466
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_189_after 1237506435
// STATE CLOCK launchpad_withdraw_190_before 1237506440
// Launchpad Numerics CollectDepositGns call=190/256
// - Gas Used: 7431014
// - Storage Diff: -2280
// - CPU Cycles: 6467121
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_190_after 1237506440
// STATE CLOCK launchpad_withdraw_191_before 1237506445
// Launchpad Numerics CollectDepositGns call=191/256
// - Gas Used: 7436061
// - Storage Diff: -2280
// - CPU Cycles: 6473779
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_191_after 1237506445
// STATE CLOCK launchpad_withdraw_192_before 1237506450
// Launchpad Numerics CollectDepositGns call=192/256
// - Gas Used: 7435105
// - Storage Diff: -2280
// - CPU Cycles: 6474434
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_192_after 1237506450
// STATE CLOCK launchpad_withdraw_193_before 1237506455
// Launchpad Numerics CollectDepositGns call=193/256
// - Gas Used: 7424474
// - Storage Diff: -2280
// - CPU Cycles: 6465414
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_193_after 1237506455
// STATE CLOCK launchpad_withdraw_194_before 1237506460
// Launchpad Numerics CollectDepositGns call=194/256
// - Gas Used: 7422783
// - Storage Diff: -2280
// - CPU Cycles: 6465334
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_194_after 1237506460
// STATE CLOCK launchpad_withdraw_195_before 1237506465
// Launchpad Numerics CollectDepositGns call=195/256
// - Gas Used: 7421827
// - Storage Diff: -2280
// - CPU Cycles: 6465989
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_195_after 1237506465
// STATE CLOCK launchpad_withdraw_196_before 1237506470
// Launchpad Numerics CollectDepositGns call=196/256
// - Gas Used: 7535134
// - Storage Diff: -5761
// - CPU Cycles: 6555084
// - Realm gno.land/r/gnoswap/launchpad: -5761
// STATE CLOCK launchpad_withdraw_196_after 1237506470
// STATE CLOCK launchpad_withdraw_197_before 1237506475
// Launchpad Numerics CollectDepositGns call=197/256
// - Gas Used: 7431973
// - Storage Diff: -2280
// - CPU Cycles: 6466469
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_197_after 1237506475
// STATE CLOCK launchpad_withdraw_198_before 1237506480
// Launchpad Numerics CollectDepositGns call=198/256
// - Gas Used: 7430282
// - Storage Diff: -2280
// - CPU Cycles: 6466389
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_198_after 1237506480
// STATE CLOCK launchpad_withdraw_199_before 1237506485
// Launchpad Numerics CollectDepositGns call=199/256
// - Gas Used: 7436787
// - Storage Diff: -2280
// - CPU Cycles: 6474505
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_199_after 1237506485
// STATE CLOCK launchpad_withdraw_200_before 1237506490
// Launchpad Numerics CollectDepositGns call=200/256
// - Gas Used: 7426897
// - Storage Diff: -2280
// - CPU Cycles: 6466226
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_200_after 1237506490
// STATE CLOCK launchpad_withdraw_201_before 1237506495
// Launchpad Numerics CollectDepositGns call=201/256
// - Gas Used: 7425941
// - Storage Diff: -2280
// - CPU Cycles: 6466881
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_201_after 1237506495
// STATE CLOCK launchpad_withdraw_202_before 1237506500
// Launchpad Numerics CollectDepositGns call=202/256
// - Gas Used: 7423518
// - Storage Diff: -2280
// - CPU Cycles: 6466069
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_202_after 1237506500
// STATE CLOCK launchpad_withdraw_203_before 1237506505
// Launchpad Numerics CollectDepositGns call=203/256
// - Gas Used: 7422562
// - Storage Diff: -2280
// - CPU Cycles: 6466724
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_203_after 1237506505
// STATE CLOCK launchpad_withdraw_204_before 1237506510
// Launchpad Numerics CollectDepositGns call=204/256
// - Gas Used: 7534813
// - Storage Diff: -5749
// - CPU Cycles: 6556434
// - Realm gno.land/r/gnoswap/launchpad: -5749
// STATE CLOCK launchpad_withdraw_204_after 1237506510
// STATE CLOCK launchpad_withdraw_205_before 1237506515
// Launchpad Numerics CollectDepositGns call=205/256
// - Gas Used: 7419325
// - Storage Diff: -2280
// - CPU Cycles: 6453821
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_205_after 1237506515
// STATE CLOCK launchpad_withdraw_206_before 1237506520
// Launchpad Numerics CollectDepositGns call=206/256
// - Gas Used: 7418369
// - Storage Diff: -2280
// - CPU Cycles: 6454476
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_206_after 1237506520
// STATE CLOCK launchpad_withdraw_207_before 1237506525
// Launchpad Numerics CollectDepositGns call=207/256
// - Gas Used: 7407738
// - Storage Diff: -2280
// - CPU Cycles: 6445456
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_207_after 1237506525
// STATE CLOCK launchpad_withdraw_208_before 1237506530
// Launchpad Numerics CollectDepositGns call=208/256
// - Gas Used: 7406047
// - Storage Diff: -2280
// - CPU Cycles: 6445376
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_208_after 1237506530
// STATE CLOCK launchpad_withdraw_209_before 1237506535
// Launchpad Numerics CollectDepositGns call=209/256
// - Gas Used: 7405091
// - Storage Diff: -2280
// - CPU Cycles: 6446031
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_209_after 1237506535
// STATE CLOCK launchpad_withdraw_210_before 1237506540
// Launchpad Numerics CollectDepositGns call=210/256
// - Gas Used: 7403397
// - Storage Diff: -2280
// - CPU Cycles: 6445948
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_210_after 1237506540
// STATE CLOCK launchpad_withdraw_211_before 1237506545
// Launchpad Numerics CollectDepositGns call=211/256
// - Gas Used: 7401709
// - Storage Diff: -2280
// - CPU Cycles: 6445871
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_211_after 1237506545
// STATE CLOCK launchpad_withdraw_212_before 1237506550
// Launchpad Numerics CollectDepositGns call=212/256
// - Gas Used: 7531301
// - Storage Diff: -2280
// - CPU Cycles: 6541756
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_212_after 1237506550
// STATE CLOCK launchpad_withdraw_213_before 1237506555
// Launchpad Numerics CollectDepositGns call=213/256
// - Gas Used: 7530345
// - Storage Diff: -2280
// - CPU Cycles: 6542411
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_213_after 1237506555
// STATE CLOCK launchpad_withdraw_214_before 1237506560
// Launchpad Numerics CollectDepositGns call=214/256
// - Gas Used: 7519714
// - Storage Diff: -2280
// - CPU Cycles: 6533391
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_214_after 1237506560
// STATE CLOCK launchpad_withdraw_215_before 1237506565
// Launchpad Numerics CollectDepositGns call=215/256
// - Gas Used: 7518023
// - Storage Diff: -2280
// - CPU Cycles: 6533311
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_215_after 1237506565
// STATE CLOCK launchpad_withdraw_216_before 1237506570
// Launchpad Numerics CollectDepositGns call=216/256
// - Gas Used: 7517067
// - Storage Diff: -2280
// - CPU Cycles: 6533966
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_216_after 1237506570
// STATE CLOCK launchpad_withdraw_217_before 1237506575
// Launchpad Numerics CollectDepositGns call=217/256
// - Gas Used: 7519630
// - Storage Diff: -5761
// - CPU Cycles: 6542922
// - Realm gno.land/r/gnoswap/launchpad: -5761
// STATE CLOCK launchpad_withdraw_217_after 1237506575
// STATE CLOCK launchpad_withdraw_218_before 1237506580
// Launchpad Numerics CollectDepositGns call=218/256
// - Gas Used: 7420051
// - Storage Diff: -2280
// - CPU Cycles: 6454547
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_218_after 1237506580
// STATE CLOCK launchpad_withdraw_219_before 1237506585
// Launchpad Numerics CollectDepositGns call=219/256
// - Gas Used: 7418360
// - Storage Diff: -2280
// - CPU Cycles: 6454467
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_219_after 1237506585
// STATE CLOCK launchpad_withdraw_220_before 1237506590
// Launchpad Numerics CollectDepositGns call=220/256
// - Gas Used: 7425606
// - Storage Diff: -2280
// - CPU Cycles: 6463324
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_220_after 1237506590
// STATE CLOCK launchpad_withdraw_221_before 1237506595
// Launchpad Numerics CollectDepositGns call=221/256
// - Gas Used: 7423918
// - Storage Diff: -2280
// - CPU Cycles: 6463247
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_221_after 1237506595
// STATE CLOCK launchpad_withdraw_222_before 1237506600
// Launchpad Numerics CollectDepositGns call=222/256
// - Gas Used: 7422962
// - Storage Diff: -2280
// - CPU Cycles: 6463902
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_222_after 1237506600
// STATE CLOCK launchpad_withdraw_223_before 1237506605
// Launchpad Numerics CollectDepositGns call=223/256
// - Gas Used: 7420536
// - Storage Diff: -2280
// - CPU Cycles: 6463087
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_223_after 1237506605
// STATE CLOCK launchpad_withdraw_224_before 1237506610
// Launchpad Numerics CollectDepositGns call=224/256
// - Gas Used: 7419580
// - Storage Diff: -2280
// - CPU Cycles: 6463742
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_224_after 1237506610
// STATE CLOCK launchpad_withdraw_225_before 1237506615
// Launchpad Numerics CollectDepositGns call=225/256
// - Gas Used: 7534693
// - Storage Diff: -2244
// - CPU Cycles: 6544041
// - Realm gno.land/r/gnoswap/launchpad: -2244
// STATE CLOCK launchpad_withdraw_225_after 1237506615
// STATE CLOCK launchpad_withdraw_226_before 1237506620
// Launchpad Numerics CollectDepositGns call=226/256
// - Gas Used: 7533737
// - Storage Diff: -2280
// - CPU Cycles: 6544696
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_226_after 1237506620
// STATE CLOCK launchpad_withdraw_227_before 1237506625
// Launchpad Numerics CollectDepositGns call=227/256
// - Gas Used: 7530573
// - Storage Diff: -2280
// - CPU Cycles: 6543143
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_227_after 1237506625
// STATE CLOCK launchpad_withdraw_228_before 1237506630
// Launchpad Numerics CollectDepositGns call=228/256
// - Gas Used: 7529617
// - Storage Diff: -2280
// - CPU Cycles: 6543798
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_228_after 1237506630
// STATE CLOCK launchpad_withdraw_229_before 1237506635
// Launchpad Numerics CollectDepositGns call=229/256
// - Gas Used: 7527926
// - Storage Diff: -2280
// - CPU Cycles: 6543718
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_229_after 1237506635
// STATE CLOCK launchpad_withdraw_230_before 1237506640
// Launchpad Numerics CollectDepositGns call=230/256
// - Gas Used: 7526235
// - Storage Diff: -2280
// - CPU Cycles: 6543638
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_230_after 1237506640
// STATE CLOCK launchpad_withdraw_231_before 1237506645
// Launchpad Numerics CollectDepositGns call=231/256
// - Gas Used: 7528960
// - Storage Diff: -5607
// - CPU Cycles: 6553944
// - Realm gno.land/r/gnoswap/launchpad: -5607
// STATE CLOCK launchpad_withdraw_231_after 1237506645
// STATE CLOCK launchpad_withdraw_232_before 1237506650
// Launchpad Numerics CollectDepositGns call=232/256
// - Gas Used: 7418521
// - Storage Diff: -2280
// - CPU Cycles: 6453038
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_232_after 1237506650
// STATE CLOCK launchpad_withdraw_233_before 1237506655
// Launchpad Numerics CollectDepositGns call=233/256
// - Gas Used: 7396769
// - Storage Diff: -2275
// - CPU Cycles: 6432882
// - Realm gno.land/r/gnoswap/gov/xgns: 5
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_233_after 1237506655
// STATE CLOCK launchpad_withdraw_234_before 1237506660
// Launchpad Numerics CollectDepositGns call=234/256
// - Gas Used: 7509807
// - Storage Diff: -2274
// - CPU Cycles: 6433537
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_234_after 1237506660
// STATE CLOCK launchpad_withdraw_235_before 1237506665
// Launchpad Numerics CollectDepositGns call=235/256
// - Gas Used: 7508116
// - Storage Diff: -2274
// - CPU Cycles: 6433457
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_235_after 1237506665
// STATE CLOCK launchpad_withdraw_236_before 1237506670
// Launchpad Numerics CollectDepositGns call=236/256
// - Gas Used: 7507160
// - Storage Diff: -2274
// - CPU Cycles: 6434112
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_236_after 1237506670
// STATE CLOCK launchpad_withdraw_237_before 1237506675
// Launchpad Numerics CollectDepositGns call=237/256
// - Gas Used: 7504734
// - Storage Diff: -2274
// - CPU Cycles: 6433297
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_237_after 1237506675
// STATE CLOCK launchpad_withdraw_238_before 1237506680
// Launchpad Numerics CollectDepositGns call=238/256
// - Gas Used: 7503778
// - Storage Diff: -2274
// - CPU Cycles: 6433952
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_238_after 1237506680
// STATE CLOCK launchpad_withdraw_239_before 1237506685
// Launchpad Numerics CollectDepositGns call=239/256
// - Gas Used: 7612589
// - Storage Diff: -2274
// - CPU Cycles: 6513931
// - Realm gno.land/r/gnoswap/launchpad: -2274
// STATE CLOCK launchpad_withdraw_239_after 1237506685
// STATE CLOCK launchpad_withdraw_240_before 1237506690
// Launchpad Numerics CollectDepositGns call=240/256
// - Gas Used: 7629645
// - Storage Diff: -2273
// - CPU Cycles: 6530990
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_240_after 1237506690
// STATE CLOCK launchpad_withdraw_241_before 1237506695
// Launchpad Numerics CollectDepositGns call=241/256
// - Gas Used: 7610651
// - Storage Diff: -9446
// - CPU Cycles: 6532462
// - Realm gno.land/r/gnoswap/launchpad: -9446
// STATE CLOCK launchpad_withdraw_241_after 1237506695
// STATE CLOCK launchpad_withdraw_242_before 1237506700
// Launchpad Numerics CollectDepositGns call=242/256
// - Gas Used: 7445428
// - Storage Diff: -2273
// - CPU Cycles: 6373446
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_242_after 1237506700
// STATE CLOCK launchpad_withdraw_243_before 1237506705
// Launchpad Numerics CollectDepositGns call=243/256
// - Gas Used: 7444475
// - Storage Diff: -2273
// - CPU Cycles: 6374101
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_243_after 1237506705
// STATE CLOCK launchpad_withdraw_244_before 1237506710
// Launchpad Numerics CollectDepositGns call=244/256
// - Gas Used: 7442052
// - Storage Diff: -2273
// - CPU Cycles: 6373286
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_244_after 1237506710
// STATE CLOCK launchpad_withdraw_245_before 1237506715
// Launchpad Numerics CollectDepositGns call=245/256
// - Gas Used: 7441099
// - Storage Diff: -2273
// - CPU Cycles: 6373941
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_245_after 1237506715
// STATE CLOCK launchpad_withdraw_246_before 1237506720
// Launchpad Numerics CollectDepositGns call=246/256
// - Gas Used: 7439411
// - Storage Diff: -2273
// - CPU Cycles: 6373861
// - Realm gno.land/r/gnoswap/launchpad: -2273
// STATE CLOCK launchpad_withdraw_246_after 1237506720
// STATE CLOCK launchpad_withdraw_247_before 1237506725
// Launchpad Numerics CollectDepositGns call=247/256
// - Gas Used: 7327257
// - Storage Diff: -2280
// - CPU Cycles: 6378917
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_247_after 1237506725
// STATE CLOCK launchpad_withdraw_248_before 1237506730
// Launchpad Numerics CollectDepositGns call=248/256
// - Gas Used: 7325278
// - Storage Diff: -2280
// - CPU Cycles: 6378549
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_248_after 1237506730
// STATE CLOCK launchpad_withdraw_249_before 1237506735
// Launchpad Numerics CollectDepositGns call=249/256
// - Gas Used: 7314647
// - Storage Diff: -2280
// - CPU Cycles: 6369529
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_249_after 1237506735
// STATE CLOCK launchpad_withdraw_250_before 1237506740
// Launchpad Numerics CollectDepositGns call=250/256
// - Gas Used: 7301768
// - Storage Diff: -2280
// - CPU Cycles: 6358261
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_250_after 1237506740
// STATE CLOCK launchpad_withdraw_251_before 1237506745
// Launchpad Numerics CollectDepositGns call=251/256
// - Gas Used: 7299345
// - Storage Diff: -2280
// - CPU Cycles: 6357449
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_251_after 1237506745
// STATE CLOCK launchpad_withdraw_252_before 1237506750
// Launchpad Numerics CollectDepositGns call=252/256
// - Gas Used: 7298389
// - Storage Diff: -2280
// - CPU Cycles: 6358104
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_252_after 1237506750
// STATE CLOCK launchpad_withdraw_253_before 1237506755
// Launchpad Numerics CollectDepositGns call=253/256
// - Gas Used: 7296698
// - Storage Diff: -2280
// - CPU Cycles: 6358024
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_253_after 1237506755
// STATE CLOCK launchpad_withdraw_254_before 1237506760
// Launchpad Numerics CollectDepositGns call=254/256
// - Gas Used: 7281617
// - Storage Diff: -2280
// - CPU Cycles: 6344554
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_254_after 1237506760
// STATE CLOCK launchpad_withdraw_255_before 1237506765
// Launchpad Numerics CollectDepositGns call=255/256
// - Gas Used: 7280661
// - Storage Diff: -2280
// - CPU Cycles: 6345209
// - Realm gno.land/r/gnoswap/launchpad: -2280
// STATE CLOCK launchpad_withdraw_255_after 1237506765
// STATE CLOCK launchpad_withdraw_256_before 1237506770
// Launchpad Numerics CollectDepositGns call=256/256
// - Gas Used: 7259369
// - Storage Diff: -8812
// - CPU Cycles: 6230949
// - Realm gno.land/r/gnoswap/gns: -2055
// - Realm gno.land/r/gnoswap/gov/xgns: -1039
// - Realm gno.land/r/gnoswap/launchpad: -5718
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
