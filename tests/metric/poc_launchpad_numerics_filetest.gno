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
