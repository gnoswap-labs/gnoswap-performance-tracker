// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Real launchpad Deposit value-payload PoC. The fixture scales project creation,
// deposit insertion, reward mutation, reward-state deletion, and project
// refunds while retaining boundary records for semantic checks.
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	uassert "gno.land/p/nt/uassert/v0"
	ufmt "gno.land/p/nt/ufmt/v0"

	_ "gno.land/r/gnoswap/gov/staker"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	_ "gno.land/r/gnoswap/launchpad/v1"
	"gno.land/r/gnoswap/launchpad"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	"gno.land/r/onbloc/obl"

	"gno.land/r/gnoswap/scenario/metric"
)

const (
	blockTimeSeconds int64 = 5
	daySeconds       int64 = 24 * 60 * 60
	depositAmount    int64 = 1_000_000
	projectReward    int64 = 100_000_000
	maxInt64         int64 = 9223372036854775807

	projectCount       int = 3
	depositorCount     int = 1
	largeDepositCount  int = 64
	smallDepositCount  int = 32
	depositBatchSize   int = 16
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	launchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	projectIDs            = make([]string, projectCount)
	projectRecipients     = make([]address, projectCount)
	projectCreatedAt      = make([]int64, projectCount)
	projectCreatedHeight  = make([]int64, projectCount)
	projectDepositCounts  = []int{largeDepositCount, smallDepositCount, 0}
	projectWithdrawnCounts = make([]int, projectCount)
	projectDepositIDs     = make([][]string, projectCount)
	depositorAddrs        = make([]address, depositorCount)
)

var t *testing.T

func main(cur realm) {
	initializeLaunchpadDepositSetup(cur)
	createLaunchpadDepositProjects(cur)

	// Creation uses a three-day contract minimum; the extra day and blocks make
	// activation deterministic while keeping all setup outside measured calls.
	testing.SkipHeights((4 * daySeconds) / blockTimeSeconds + 20)
	assertProjectsActive()
	printLaunchpadDepositProjectState()

	fundLaunchpadDepositors(cur)
	createLaunchpadDeposits(cur)
	assertAggregateState(totalDepositCount())
	printLaunchpadDepositState("deposited", 0, largeDepositCount-1)
	printLaunchpadDepositState("deposited", 1, smallDepositCount-1)

	// Every deposit has a one-day reward claim window. Claims are measured in
	// four batches of 16 against the 64-record project.
	testing.SkipHeights(daySeconds/blockTimeSeconds + 1)
	claimLaunchpadDepositRewards(cur)
	printLaunchpadDepositState("claimed", 0, largeDepositCount-1)

	// The 30-day tier is ended. Withdrawals are measured as reward-state
	// deletions in four batches, leaving the 32-record project for refund work.
	testing.SkipHeights((30*daySeconds)/blockTimeSeconds + 1)
	withdrawLaunchpadDeposits(cur, 0, "principal withdraw")
	printLaunchpadDepositState("withdrawn", 0, largeDepositCount-1)

	// The project itself ends at the 180-day tier. Keep project 1's deposits
	// active so TransferLeftFromProjectByAdmin traverses retained records.
	testing.SkipHeights((180*daySeconds)/blockTimeSeconds + 1)
	refundLaunchpadProject(cur, 1)
	refundLaunchpadProject(cur, 2)

	// Refund leaves exactly the claimable reward reserve for active deposits;
	// collecting those deposits completes the second lifecycle.
	withdrawLaunchpadDeposits(cur, 1, "refund cleanup withdraw")
	refundLaunchpadProject(cur, 0)
	assertFinalLaunchpadDepositState()
	printLaunchpadDepositState("final", 0, 0)
	printLaunchpadDepositState("final", 0, largeDepositCount-1)
	printLaunchpadDepositState("final", 1, 0)
	printLaunchpadDepositState("final", 1, smallDepositCount-1)

	// Preserve baseline error precedence on a withdrawn record: reward lookup
	// fails before the inner already-withdrawn guard.
	testing.SetRealm(testing.NewUserRealm(depositorAddrs[0]))
	uassert.AbortsContains(t, cur, "not exist deposit", func() {
		launchpad.CollectDepositGns(cross(cur), projectDepositIDs[0][0])
	})
	metric.PrintMetricsBy("launchpad-deposit retained getters", func() {
		launchpad.GetDeposit(projectDepositIDs[0][0])
		launchpad.GetDepositProjectID(projectDepositIDs[0][0])
		launchpad.GetDepositTier(projectDepositIDs[0][0])
		launchpad.GetDepositProjectTierID(projectDepositIDs[0][0])
		launchpad.GetDepositAmount(projectDepositIDs[0][0])
		launchpad.GetDepositCreatedHeight(projectDepositIDs[0][0])
		launchpad.GetDepositCreatedAt(projectDepositIDs[0][0])
		launchpad.GetDepositEndTime(projectDepositIDs[0][0])
		launchpad.GetDepositWithdrawnHeight(projectDepositIDs[0][0])
		launchpad.GetDepositWithdrawnTime(projectDepositIDs[0][0])
		launchpad.GetProjectTierRewards(projectIDs[0], 30)
	})
}

func initializeLaunchpadDepositSetup(cur realm) {
	for i := 0; i < depositorCount; i++ {
		depositorAddrs[i] = testutils.TestAddress(ufmt.Sprintf("lp-deposit-user-%d", i))
	}

	testing.SetRealm(adminRealm)
	obl.Approve(cross(cur), launchpadAddr, maxInt64)
}

func createLaunchpadDepositProjects(cur realm) {
	for i := 0; i < projectCount; i++ {
		projectRecipients[i] = testutils.TestAddress(ufmt.Sprintf("lp-dep-rec-%d", i))
		startTime := time.Now().Unix() + 4*daySeconds

		testing.SetRealm(adminRealm)
		metric.PrintMetricsBy(ufmt.Sprintf("launchpad-deposit project create projects=%d", i+1), func() {
			projectIDs[i] = launchpad.CreateProject(
				cross(cur),
				ufmt.Sprintf("Launchpad deposit value project %d", i+1),
				"gno.land/r/onbloc/obl.OBL",
				projectRecipients[i],
				projectReward,
				"",
				"",
				10,
				20,
				70,
				startTime,
			)
		})
		if projectIDs[i] == "" {
			panic("project creation returned an empty ID")
		}
		if i > 0 && projectIDs[i] == projectIDs[i-1] {
			panic("project IDs were not separated by block height")
		}

		var err error
		projectCreatedAt[i], err = launchpad.GetProjectCreatedAt(projectIDs[i])
		if err != nil {
			panic(err)
		}
		projectCreatedHeight[i], err = launchpad.GetProjectCreatedHeight(projectIDs[i])
		if err != nil {
			panic(err)
		}

		// Project IDs are height-derived, so each measured insertion starts in a
		// distinct block without charging the next CreateProject callback.
		if i+1 < projectCount {
			testing.SkipHeights(1)
		}
	}
}

func assertProjectsActive() {
	for i := 0; i < projectCount; i++ {
		name, err := launchpad.GetProjectName(projectIDs[i])
		if err != nil || name == "" {
			panic("project name getter lost a created project")
		}
		tokenPath, err := launchpad.GetProjectTokenPath(projectIDs[i])
		if err != nil || tokenPath != "gno.land/r/onbloc/obl.OBL" {
			panic("project token getter lost a created project")
		}
		amount, err := launchpad.GetProjectDepositAmount(projectIDs[i])
		if err != nil || amount != projectReward {
			panic("project reward amount mismatch")
		}
		recipient, err := launchpad.GetProjectRecipient(projectIDs[i])
		if err != nil || recipient != projectRecipients[i] {
			panic("project recipient mismatch")
		}
		ratio, err := launchpad.GetProjectTiersRatios(projectIDs[i])
		if err != nil || ratio[30]+ratio[90]+ratio[180] != 100 {
			panic("project tier ratios mismatch")
		}
		for _, tier := range []int64{30, 90, 180} {
			if _, err := launchpad.GetProjectTier(projectIDs[i], tier); err != nil {
				panic(err)
			}
		}
		active, err := launchpad.GetProjectActiveStatus(projectIDs[i])
		if err != nil || !active {
			panic("created project is not active after activation delay")
		}
		if projectCreatedAt[i] <= 0 || projectCreatedHeight[i] <= 0 {
			panic("project creation cursor was not persisted")
		}
	}
}

func printLaunchpadDepositProjectState() {
	for i := 0; i < projectCount; i++ {
		name, err := launchpad.GetProjectName(projectIDs[i])
		if err != nil {
			panic(err)
		}
		tokenPath, err := launchpad.GetProjectTokenPath(projectIDs[i])
		if err != nil {
			panic(err)
		}
		amount, err := launchpad.GetProjectDepositAmount(projectIDs[i])
		if err != nil {
			panic(err)
		}
		recipient, err := launchpad.GetProjectRecipient(projectIDs[i])
		if err != nil {
			panic(err)
		}
		ratio, err := launchpad.GetProjectTiersRatios(projectIDs[i])
		if err != nil {
			panic(err)
		}
		active, err := launchpad.GetProjectActiveStatus(projectIDs[i])
		if err != nil {
			panic(err)
		}
		ufmt.Printf(
			"STATE launchpad-deposit phase=project index=%d project=%s name=%s token=%s projectDeposit=%d recipient=%s projectCreatedHeight=%d projectCreatedAtSet=%t active=%t ratios=%d/%d/%d\n",
			i,
			projectIDs[i],
			name,
			tokenPath,
			amount,
			recipient.String(),
			projectCreatedHeight[i],
			projectCreatedAt[i] > 0,
			active,
			ratio[30],
			ratio[90],
			ratio[180],
		)
	}

	printLaunchpadDepositProjectTierState(0, 30)
	printLaunchpadDepositProjectTierState(0, 90)
	printLaunchpadDepositProjectTierState(0, 180)
	printLaunchpadDepositProjectTierState(projectCount-1, 30)
}

func printLaunchpadDepositProjectTierState(projectIndex int, tier int64) {
	projectTier, err := launchpad.GetProjectTier(projectIDs[projectIndex], tier)
	if err != nil {
		panic(err)
	}
	perSecond, err := launchpad.GetProjectTierDistributeAmountPerSecondX128(projectIDs[projectIndex], tier)
	if err != nil {
		panic(err)
	}
	ufmt.Printf(
		"STATE launchpad-deposit phase=project-tier projectIndex=%d project=%s tier=%d id=%s perSecond=%s distribute=%d startOffset=%d endOffset=%d\n",
		projectIndex,
		projectIDs[projectIndex],
		tier,
		projectTier.ID(),
		perSecond.ToString(),
		projectTier.TotalDistributeAmount(),
		projectTier.StartTime()-projectCreatedAt[projectIndex],
		projectTier.EndTime()-projectCreatedAt[projectIndex],
	)
}

func fundLaunchpadDepositors(cur realm) {
	perUserDepositCount := totalDepositCount() / depositorCount
	perUserAmount := depositAmount * int64(perUserDepositCount)
	for i := 0; i < depositorCount; i++ {
		testing.SetRealm(adminRealm)
		gns.Transfer(cross(cur), depositorAddrs[i], perUserAmount)
		testing.SetRealm(testing.NewUserRealm(depositorAddrs[i]))
		gns.Approve(cross(cur), launchpadAddr, maxInt64)
	}
}

func createLaunchpadDeposits(cur realm) {
	for projectIndex := 0; projectIndex < projectCount; projectIndex++ {
		count := projectDepositCounts[projectIndex]
		projectDepositIDs[projectIndex] = make([]string, count)
		for start := 0; start < count; start += depositBatchSize {
			end := start + depositBatchSize
			if end > count {
				end = count
			}
			testing.SetRealm(testing.NewUserRealm(depositorAddrs[start%depositorCount]))
			metric.PrintMetricsBy(ufmt.Sprintf("launchpad-deposit create project=%d deposits=%d", projectIndex+1, end), func() {
				for i := start; i < end; i++ {
					userIndex := i % depositorCount
					testing.SetRealm(testing.NewUserRealm(depositorAddrs[userIndex]))
					projectDepositIDs[projectIndex][i] = launchpad.DepositGns(
						cross(cur),
						projectTierID(projectIndex),
						depositAmount,
						"",
					)
					if projectDepositIDs[projectIndex][i] == "" {
						panic("deposit creation returned an empty ID")
					}
				}
			})
			assertDepositBatchState(projectIndex, end)
			if end < count {
				testing.SkipHeights(1)
			}
		}
	}
}

func assertDepositBatchState(projectIndex, count int) {
	expectedGlobal := totalDepositsThroughProject(projectIndex, count)
	assertAggregateState(expectedGlobal)

	projectID := projectIDs[projectIndex]
	total, err := launchpad.GetProjectTierTotalDepositAmount(projectID, 30)
	if err != nil || total != int64(count)*depositAmount {
		panic("project tier deposit amount mismatch")
	}
	depositCount, err := launchpad.GetProjectTierTotalDepositCount(projectID, 30)
	if err != nil || depositCount != int64(count) {
		panic("project tier deposit count mismatch")
	}
	assertDepositRecord(projectIndex, 0, false)
	assertDepositRecord(projectIndex, count-1, false)
}

func claimLaunchpadDepositRewards(cur realm) {
	projectIndex := 0
	count := projectDepositCounts[projectIndex]
	for start := 0; start < count; start += depositBatchSize {
		end := start + depositBatchSize
		if end > count {
			end = count
		}
		testing.SetRealm(testing.NewUserRealm(depositorAddrs[start%depositorCount]))
		metric.PrintMetricsBy(ufmt.Sprintf("launchpad-deposit claim project=1 deposits=%d", end), func() {
			for i := start; i < end; i++ {
				userIndex := i % depositorCount
				testing.SetRealm(testing.NewUserRealm(depositorAddrs[userIndex]))
				claimed := launchpad.CollectRewardByDepositId(cross(cur), projectDepositIDs[projectIndex][i])
				if claimed <= 0 {
					panic("reward claim returned no reward")
				}
			}
		})
		assertClaimBatchState(projectIndex, start, end)
	}
}

func assertClaimBatchState(projectIndex, start, end int) {
	claimed, err := launchpad.GetProjectTierRewardTotalClaimedAmount(projectIDs[projectIndex] + ":30")
	if err != nil || claimed <= 0 {
		panic("project reward manager lost claimed accounting")
	}
	collected, err := launchpad.GetProjectTierTotalCollectedAmount(projectIDs[projectIndex], 30)
	if err != nil || collected != claimed {
		panic("project tier collected accounting mismatched reward manager")
	}
	assertAggregateState(totalDepositCount())
	assertDepositRecord(projectIndex, start, false)
	assertDepositRecord(projectIndex, end-1, false)
	assertClaimedRecord(projectIndex, start)
	assertClaimedRecord(projectIndex, end-1)
}

func withdrawLaunchpadDeposits(cur realm, projectIndex int, phase string) {
	count := projectDepositCounts[projectIndex]
	withdrawnSoFar := 0
	for start := 0; start < count; start += depositBatchSize {
		end := start + depositBatchSize
		if end > count {
			end = count
		}
		testing.SetRealm(testing.NewUserRealm(depositorAddrs[start%depositorCount]))
		metric.PrintMetricsBy(ufmt.Sprintf("launchpad-deposit %s project=%d withdrawn=%d", phase, projectIndex+1, end), func() {
			for i := start; i < end; i++ {
				userIndex := i % depositorCount
				testing.SetRealm(testing.NewUserRealm(depositorAddrs[userIndex]))
				withdrawn, err := launchpad.CollectDepositGns(cross(cur), projectDepositIDs[projectIndex][i])
				if err != nil || withdrawn != depositAmount {
					panic("principal withdrawal amount mismatch")
				}
			}
		})
		withdrawnSoFar = end
		projectWithdrawnCounts[projectIndex] = withdrawnSoFar
		assertWithdrawBatchState(projectIndex, start, end, withdrawnSoFar)
	}
}

func assertWithdrawBatchState(projectIndex, start, end, withdrawnCount int) {
	active := totalDepositCount() - totalWithdrawnDepositCount()
	assertAggregateState(active)

	projectID := projectIDs[projectIndex]
	withdrawnAmount, err := launchpad.GetProjectTierTotalWithdrawAmount(projectID, 30)
	if err != nil || withdrawnAmount != int64(withdrawnCount)*depositAmount {
		panic("project tier withdrawal amount mismatch")
	}
	withdrawCount, err := launchpad.GetProjectTierTotalWithdrawCount(projectID, 30)
	if err != nil || withdrawCount != int64(withdrawnCount) {
		panic("project tier withdrawal count mismatch")
	}
	assertDepositRecord(projectIndex, start, true)
	assertDepositRecord(projectIndex, end-1, true)

	rewards := launchpad.GetProjectTierRewards(projectID, 30)
	if rewards == nil || rewards.Size() != projectDepositCounts[projectIndex]-withdrawnCount {
		panic("reward-state deletion count mismatch after withdrawal")
	}
}

func refundLaunchpadProject(cur realm, projectIndex int) {
	testing.SetRealm(adminRealm)
	before := obl.BalanceOf(projectRecipients[projectIndex])
	var refunded int64
	metric.PrintMetricsBy(ufmt.Sprintf("launchpad-deposit refund project=%d active=%d", projectIndex+1, projectDepositCounts[projectIndex]-projectWithdrawnCounts[projectIndex]), func() {
		refunded = launchpad.TransferLeftFromProjectByAdmin(cross(cur), projectIDs[projectIndex], projectRecipients[projectIndex])
	})
	after := obl.BalanceOf(projectRecipients[projectIndex])
	if refunded <= 0 || after-before != refunded {
		panic("project refund did not transfer the reported amount")
	}
	isActive, err := launchpad.GetProjectActiveStatus(projectIDs[projectIndex])
	if err != nil || isActive {
		panic("ended project became active during refund")
	}
	assertAggregateState(totalDepositCount() - totalWithdrawnDepositCount())
}

func assertFinalLaunchpadDepositState() {
	if launchpad.GetDepositCount() != totalDepositCount() || launchpad.GetCurrentDepositId() != int64(totalDepositCount()) {
		panic("final deposit cursor mismatch")
	}
	// Fixed-point reward distribution can leave sub-unit dust; reject anything
	// larger than one atomic unit per persisted deposit.
	if launchpad.GetTotalGNSStakedAmount() != 0 || gns.BalanceOf(launchpadAddr) != 0 || obl.BalanceOf(launchpadAddr) >= int64(totalDepositCount()) {
		panic("final active balance was not released")
	}

	for projectIndex := 0; projectIndex < projectCount; projectIndex++ {
		active, err := launchpad.GetProjectActiveStatus(projectIDs[projectIndex])
		if err != nil || active {
			panic("final project lifecycle state is still active")
		}
		count := projectDepositCounts[projectIndex]
		withdrawCount, err := launchpad.GetProjectTierTotalWithdrawCount(projectIDs[projectIndex], 30)
		if err != nil || withdrawCount != int64(count) {
			panic("final project withdrawal count mismatch")
		}
		if count > 0 {
			withdrawnAmount, err := launchpad.GetProjectTierTotalWithdrawAmount(projectIDs[projectIndex], 30)
			if err != nil || withdrawnAmount != int64(count)*depositAmount {
				panic("final project withdrawal amount mismatch")
			}
			assertDepositRecord(projectIndex, 0, true)
			assertDepositRecord(projectIndex, count-1, true)
			rewards := launchpad.GetProjectTierRewards(projectIDs[projectIndex], 30)
			if rewards == nil || rewards.Size() != 0 {
				panic("final reward-state tree still contains withdrawn records")
			}
		}
		if obl.BalanceOf(projectRecipients[projectIndex]) <= 0 {
			panic("final project recipient did not receive a refund")
		}
	}
}

func assertAggregateState(activeDepositCount int) {
	if launchpad.GetDepositCount() < activeDepositCount {
		panic("global deposit count dropped during lifecycle")
	}
	if launchpad.GetTotalGNSStakedAmount() != int64(activeDepositCount)*depositAmount {
		panic("global active GNS stake mismatch")
	}
}

func assertDepositRecord(projectIndex, depositIndex int, withdrawn bool) {
	depositID := projectDepositIDs[projectIndex][depositIndex]
	deposit, err := launchpad.GetDeposit(depositID)
	if err != nil || deposit == nil {
		panic("missing boundary deposit record")
	}
	if deposit.ID() != depositID || deposit.ProjectID() != projectIDs[projectIndex] || deposit.Tier() != 30 {
		panic("deposit identity fields mismatch")
	}
	if deposit.Depositor() != depositorAddrs[depositIndex%depositorCount] {
		panic("deposit owner mismatch")
	}
	if deposit.CreatedHeight() <= projectCreatedHeight[projectIndex] || deposit.CreatedAt() < projectCreatedAt[projectIndex] {
		panic("deposit creation cursor mismatch")
	}
	if deposit.EndTime() <= deposit.CreatedAt() {
		panic("deposit lock end was not persisted")
	}
	if withdrawn {
		if deposit.DepositAmount() != 0 || !deposit.IsWithdrawn() || deposit.WithdrawnHeight() <= deposit.CreatedHeight() || deposit.WithdrawnTime() <= deposit.CreatedAt() {
			panic("withdrawn boundary record state mismatch")
		}
		return
	}
	if deposit.DepositAmount() != depositAmount || deposit.WithdrawnHeight() != 0 || deposit.WithdrawnTime() != 0 || deposit.IsWithdrawn() {
		panic("active boundary record state mismatch")
	}
}

func assertClaimedRecord(projectIndex, depositIndex int) {
	rewardState, err := launchpad.GetRewardState(projectIDs[projectIndex]+":30", projectDepositIDs[projectIndex][depositIndex])
	if err != nil || rewardState == nil || rewardState.DepositAmount() != depositAmount || rewardState.ClaimedAmount() <= 0 {
		panic("claimed boundary reward state mismatch")
	}
}

func printLaunchpadDepositState(phase string, projectIndex, depositIndex int) {
	depositID := projectDepositIDs[projectIndex][depositIndex]
	deposit, err := launchpad.GetDeposit(depositID)
	if err != nil {
		panic(err)
	}
	withdrawnHeight, err := launchpad.GetDepositWithdrawnHeight(depositID)
	if err != nil {
		panic(err)
	}
	projectID := projectIDs[projectIndex]
	projectDeposit, err := launchpad.GetProjectTierTotalDepositAmount(projectID, 30)
	if err != nil {
		panic(err)
	}
	projectWithdraw, err := launchpad.GetProjectTierTotalWithdrawAmount(projectID, 30)
	if err != nil {
		panic(err)
	}
	projectCollected, err := launchpad.GetProjectTierTotalCollectedAmount(projectID, 30)
	if err != nil {
		panic(err)
	}
	rewardClaimed, err := launchpad.GetProjectTierRewardTotalClaimedAmount(projectID + ":30")
	if err != nil {
		panic(err)
	}
	rewards := launchpad.GetProjectTierRewards(projectID, 30)
	rewardCount := -1
	if rewards != nil {
		rewardCount = rewards.Size()
	}
	rewardPresent := int64(0)
	if _, rewardErr := launchpad.GetRewardState(projectID+":30", depositID); rewardErr == nil {
		rewardPresent = 1
	}
	ufmt.Printf(
		"STATE launchpad-deposit phase=%s projectIndex=%d project=%s depositIndex=%d depositID=%s depositor=%s amount=%d createdHeight=%d endOffset=%d withdrawnHeight=%d withdrawn=%t projectDeposit=%d projectWithdraw=%d projectDepositCount=%d projectWithdrawCount=%d projectCollected=%d deposits=%d currentDepositID=%d totalStaked=%d rewardClaimed=%d rewardCount=%d rewardPresent=%d recipientObl=%d gnsLaunchpad=%d oblLaunchpad=%d\n",
		phase,
		projectIndex,
		projectID,
		depositIndex,
		deposit.ID(),
		deposit.Depositor().String(),
		deposit.DepositAmount(),
		deposit.CreatedHeight(),
		deposit.EndTime()-deposit.CreatedAt(),
		withdrawnHeight,
		deposit.IsWithdrawn(),
		projectDeposit,
		projectWithdraw,
		projectDepositCounts[projectIndex],
		projectWithdrawnCounts[projectIndex],
		projectCollected,
		launchpad.GetDepositCount(),
		launchpad.GetCurrentDepositId(),
		launchpad.GetTotalGNSStakedAmount(),
		rewardClaimed,
		rewardCount,
		rewardPresent,
		obl.BalanceOf(projectRecipients[projectIndex]),
		gns.BalanceOf(launchpadAddr),
		obl.BalanceOf(launchpadAddr),
	)
}

func projectTierID(projectIndex int) string {
	return projectIDs[projectIndex] + ":30"
}

func totalDepositCount() int {
	total := 0
	for _, count := range projectDepositCounts {
		total += count
	}
	return total
}

func totalDepositsThroughProject(projectIndex, count int) int {
	total := count
	for i := 0; i < projectIndex; i++ {
		total += projectDepositCounts[i]
	}
	return total
}

func totalWithdrawnDepositCount() int {
	total := 0
	for _, count := range projectWithdrawnCounts {
		total += count
	}
	return total
}

