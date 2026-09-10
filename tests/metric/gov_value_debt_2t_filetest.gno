// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Matched public-operation workload for governance reward debt.  This fixture
// keeps token setup, fee distribution, emission minting, and time movement out
// of measured closures; only one logical caller crosses each measured call.
package main

import (
	"testing"
	"time"

	u256 "gno.land/p/gnoswap/uint256"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/launchpad/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gns"
	govstaker "gno.land/r/gnoswap/gov/staker"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/gnoswap/protocol_fee"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/scenarioutils"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/foo"
	"gno.land/r/onbloc/obl"
	"gno.land/r/onbloc/qux"
)

const (
	tokenLabel       = "bar-baz"
	activeTokenCount = 2
	includeLaunchpad = false

	blockTimeSeconds int64 = 5
	maxInt64         int64 = 9223372036854775807
	stakeAmount      int64 = 2_000_000
	cohortSize             = 128
	initialFeeAmount int64 = 1_000_000
	smallFeeAmount   int64 = 1_000_000
	largeFeeAmount   int64 = 1_000_000_000
	maxUint128Text         = "340282366920938463463374607431768211455"
	launchpadAmount  int64 = 1_000_000
	lockupSeconds    int64 = 10

	barPath = "gno.land/r/onbloc/bar.BAR"
	bazPath = "gno.land/r/onbloc/baz.BAZ"
	fooPath = "gno.land/r/onbloc/foo.FOO"
	quxPath = "gno.land/r/onbloc/qux.QUX"
	oblPath = "gno.land/r/onbloc/obl.OBL"
)

var (
	adminAddr, _       = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm         = testing.NewUserRealm(adminAddr)
	stakerAddr, _      = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm        = testing.NewUserRealm(stakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())
	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)
	launchpadAddr, _   = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	focusAddr       = testutils.TestAddress("gov-value-debt-focus")
	focusRealm      = testing.NewUserRealm(focusAddr)
	delegateeAddr   = testutils.TestAddress("gvd-delegatee")
	launchUserAddr  = testutils.TestAddress("gvd-launch-user")
	launchUserRealm = testing.NewUserRealm(launchUserAddr)
	missingAddr     = testutils.TestAddress("gvd-missing")
	projectAddr     = testutils.TestAddress("gvd-project")
)

func main(cur realm) {
	tokens := fixtureTokens()
	setup(cur, tokens)
	users := setupCohort(cur)

	// Empty-state getter control precedes the first public delegation.
	measureQuery(cur, tokens, "users=0 operation=query control=empty", adminAddr, missingAddr)

	delegateStage(cur, users, 0, 1, 1)
	measureQuery(cur, tokens, "users=1 operation=query control=present-zero", adminAddr, focusAddr)
	printGovState(tokens, users, "after-users-1")

	accrue(cur, tokens, smallFeeAmount)
	measureClaim(cur, tokens, 1, 1, "accrued", 1, 0)
	printGovState(tokens, users, "after-claim-users-1")

	delegateStage(cur, users, 1, 32, 32)
	accrue(cur, tokens, smallFeeAmount)
	measureClaim(cur, tokens, 32, 1, "accrued", 1, 0)
	printGovState(tokens, users, "after-claim-users-32")
	delegateStage(cur, users, 32, cohortSize, cohortSize)
	if activeTokenCount == 4 {
		runRepeatWindows(cur, tokens)
	} else {
		accrue(cur, tokens, smallFeeAmount)
		measureClaim(cur, tokens, cohortSize, 1, "accrued", 1, 0)
		measureClaim(cur, tokens, cohortSize, 1, "noop", 1, 0)
	}
	printGovState(tokens, users, "after-claim-users-128")

	runGovLifecycle(cur, tokens, users)
	if includeLaunchpad {
		runLaunchpadLifecycle(cur, tokens)
	}
	printGovState(tokens, users, "after-restake")
}

func fixtureTokens() []string {
	switch activeTokenCount {
	case 1:
		return []string{barPath}
	case 2:
		return []string{barPath, bazPath}
	case 4:
		return []string{barPath, bazPath, fooPath, quxPath}
	default:
		panic("unsupported token cardinality")
	}
}

func setup(cur realm, tokens []string) {
	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()

	testing.SetRealm(adminRealm)
	govstaker.SetUnDelegationLockupPeriodByAdmin(cross(cur), lockupSeconds)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.ChangeDistributionPct(cross(cur), 6500, 2000, 500, 1000)
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(2)
	emission.MintAndDistributeGns(cross(cur))

	// Seed one fee token while total governance stake is zero.  The first
	// delegate therefore gets an explicit zero debt for a present token while
	// the other token debt entries are still absent.
	for i, tokenPath := range tokens {
		amount := initialFeeAmount
		if i > 0 {
			amount = 0
		}
		if amount > 0 {
			addProtocolFee(cur, tokenPath, amount, protocolFeeV1Addr)
		}
	}
	flushProtocolFees(cur)

	if includeLaunchpad {
		testing.SetRealm(adminRealm)
		obl.Approve(cross(cur), launchpadAddr, maxInt64)
	}
}

func setupCohort(cur realm) []address {
	users := make([]address, cohortSize)
	for i := 0; i < cohortSize; i++ {
		if i == 0 {
			users[i] = focusAddr
		} else {
			users[i] = testutils.TestAddress(ufmt.Sprintf("gvd-user-%d", i))
		}
		amount := int64(1_000_000)
		if i == 0 {
			amount = stakeAmount
		}
		testing.SetRealm(adminRealm)
		gns.Transfer(cross(cur), users[i], amount)
		testing.SetRealm(testing.NewUserRealm(users[i]))
		gns.Approve(cross(cur), govStakerAddr, maxInt64)
	}
	return users
}

func delegateStage(cur realm, users []address, start, end, scale int) {
	for i := start; i < end; i++ {
		amount := delegationAmount(i)
		label := ufmt.Sprintf("GovDebtIncrement tokens=%s users=%d operation=delegate index=%d repeats=1", tokenLabel, scale, i)
		printActor(label, users[i])
		testing.SetRealm(testing.NewUserRealm(users[i]))
		delegated := int64(0)
		metric.PrintMetricsBy(label, func() {
			delegated = govstaker.Delegate(cross(cur), delegateeAddr, amount, "")
		})
		if delegated != amount {
			panic("delegate returned an unexpected amount")
		}
		testing.SkipHeights(1)
	}
}

func delegationAmount(index int) int64 {
	if index == 0 {
		return stakeAmount
	}
	return 1_000_000
}

func measureQuery(cur realm, tokens []string, suffix string, actor, target address) {
	label := ufmt.Sprintf("GovDebtIncrement tokens=%s %s repeats=1", tokenLabel, suffix)
	printActor(label, actor)
	var emissionReward int64
	var rewards map[string]int64
	var err error
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy(label, func() {
		emissionReward, rewards, err = govstaker.GetClaimableRewardByRewardID(target.String())
	})
	if err != nil {
		panic(err)
	}
	present := int64(0)
	if rewards != nil {
		if _, ok := rewards[tokens[0]]; ok {
			present = 1
		}
	}
	ufmt.Printf("STATE GovDebtIncrement tokens=%s phase=query target=%s claimable_emission=%d fee_keys=%d first_fee_present=%d first_fee=%d protocol_timestamp=%d emission_timestamp=%d\n",
		tokenLabel, target.String(), emissionReward, len(rewards), present, feeValue(rewards, tokens[0]), govstaker.GetProtocolFeeAccumulatedTimestamp(), govstaker.GetEmissionAccumulatedTimestamp())
}

func accrue(cur realm, tokens []string, amount int64) {
	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()
	for _, tokenPath := range tokens {
		addProtocolFee(cur, tokenPath, amount, protocolFeeV1Addr)
	}
	flushProtocolFees(cur)
	testing.SetRealm(adminRealm)
	testing.SkipHeights(2)
	emission.MintAndDistributeGns(cross(cur))
}

func addProtocolFee(cur realm, tokenPath string, amount int64, protocolFeeV1Addr address) {
	if amount <= 0 {
		return
	}
	testing.SetRealm(adminRealm)
	transferToken(cur, tokenPath, stakerAddr, amount)
	testing.SetRealm(stakerRealm)
	approveToken(cur, tokenPath, protocolFeeAddr, maxInt64)
	approveToken(cur, tokenPath, protocolFeeV1Addr, maxInt64)
	if err := protocol_fee.AddToProtocolFee(cross(cur), tokenPath, amount); err != nil {
		panic(err)
	}
}

func flushProtocolFees(cur realm) {
	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross(cur))
	testing.SkipHeights(1)
}

func runRepeatWindows(cur realm, tokens []string) {
	for windowIndex, windowRepeats := range []int{1, 10, 100, 1000} {
		for callIndex := 0; callIndex < windowRepeats; callIndex++ {
			amount := smallFeeAmount
			if windowIndex == 0 && callIndex == 0 {
				// At the 128-user state this normal fee distribution drives
				// the per-stake Q128 debt above the exact uint128 boundary.
				amount = largeFeeAmount
			}
			accrue(cur, tokens, amount)
			measureClaim(cur, tokens, cohortSize, windowRepeats, "accrued", windowRepeats, callIndex)
			if windowIndex == 0 && callIndex == 0 && debtOver128(tokens) != 1 {
				panic("large protocol-fee distribution did not exceed uint128")
			}
		}
		for callIndex := 0; callIndex < windowRepeats; callIndex++ {
			measureClaim(cur, tokens, cohortSize, windowRepeats, "noop", windowRepeats, callIndex)
		}
	}
}

func measureClaim(cur realm, tokens []string, scale, repeats int, kind string, windowRepeats, callIndex int) {
	label := ufmt.Sprintf("GovDebtIncrement tokens=%s users=%d operation=claim-%s window_repeats=%d index=%d repeats=%d", tokenLabel, scale, kind, windowRepeats, callIndex, repeats)
	printActor(label, focusAddr)
	testing.SetRealm(focusRealm)
	metric.PrintMetricsBy(label, func() {
		govstaker.CollectReward(cross(cur))
	})
	printGovState(tokens, nil, ufmt.Sprintf("claim-%s-users-%d-window-%d-index-%d", kind, scale, windowRepeats, callIndex))
}

func runGovLifecycle(cur realm, tokens []string, users []address) {
	partialLabel := ufmt.Sprintf("GovDebtIncrement tokens=%s users=%d operation=undelegate-partial index=0 repeats=1", tokenLabel, cohortSize)
	printActor(partialLabel, focusAddr)
	testing.SetRealm(focusRealm)
	partial := int64(0)
	metric.PrintMetricsBy(partialLabel, func() {
		partial = govstaker.Undelegate(cross(cur), delegateeAddr, stakeAmount/2)
	})
	if partial != stakeAmount/2 {
		panic("partial undelegate returned an unexpected amount")
	}
	testing.SkipHeights(1)
	printGovState(tokens, users, "after-undelegate-partial")

	fullLabel := ufmt.Sprintf("GovDebtIncrement tokens=%s users=%d operation=undelegate-full index=0 repeats=1", tokenLabel, cohortSize)
	printActor(fullLabel, focusAddr)
	testing.SetRealm(focusRealm)
	full := int64(0)
	metric.PrintMetricsBy(fullLabel, func() {
		full = govstaker.Undelegate(cross(cur), delegateeAddr, stakeAmount/2)
	})
	if full != stakeAmount/2 {
		panic("full undelegate returned an unexpected amount")
	}
	testing.SkipHeights(1)
	printGovState(tokens, users, "after-undelegate-full")

	for i := 1; i < len(users); i++ {
		amount := delegationAmount(i)
		label := ufmt.Sprintf("GovDebtIncrement tokens=%s users=%d operation=undelegate-full index=%d repeats=1", tokenLabel, cohortSize, i)
		printActor(label, users[i])
		testing.SetRealm(testing.NewUserRealm(users[i]))
		undelegated := int64(0)
		metric.PrintMetricsBy(label, func() {
			undelegated = govstaker.Undelegate(cross(cur), delegateeAddr, amount)
		})
		if undelegated != amount {
			panic("cohort undelegate returned an unexpected amount")
		}
		testing.SkipHeights(1)
	}

	testing.SkipHeights(govstaker.GetUnDelegationLockupPeriod()/blockTimeSeconds + 1)
	withdrawnTotal := int64(0)
	for i := 0; i < len(users); i++ {
		amount := delegationAmount(i)
		label := ufmt.Sprintf("GovDebtIncrement tokens=%s users=%d operation=withdraw index=%d repeats=1", tokenLabel, cohortSize, i)
		printActor(label, users[i])
		testing.SetRealm(testing.NewUserRealm(users[i]))
		withdrawn := int64(0)
		metric.PrintMetricsBy(label, func() {
			withdrawn = govstaker.CollectUndelegatedGns(cross(cur))
		})
		if withdrawn != amount {
			panic("cohort withdrawal returned an unexpected amount")
		}
		withdrawnTotal += withdrawn
		claimLabel := ufmt.Sprintf("GovDebtIncrement tokens=%s users=%d operation=claim-final index=%d repeats=1", tokenLabel, cohortSize, i)
		printActor(claimLabel, users[i])
		metric.PrintMetricsBy(claimLabel, func() {
			govstaker.CollectReward(cross(cur))
		})
		pendingEmission, pendingFees, err := govstaker.GetClaimableRewardByRewardID(users[i].String())
		if err != nil || pendingEmission != 0 {
			panic("final emission reward was not settled")
		}
		for _, amount := range pendingFees {
			if amount != 0 {
				panic("final protocol fee reward was not settled")
			}
		}
	}
	if withdrawnTotal != stakeAmount+int64(cohortSize-1)*1_000_000 || govstaker.GetTotalDelegated() != 0 || govstaker.GetTotalLockedAmount() != 0 {
		panic("all cohort principal was not withdrawn")
	}
	printCohortState(tokens, users, withdrawnTotal, "all-principal-withdrawn")

	testing.SetRealm(focusRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
	restakeLabel := ufmt.Sprintf("GovDebtIncrement tokens=%s users=%d operation=restake index=0 repeats=1", tokenLabel, cohortSize)
	printActor(restakeLabel, focusAddr)
	restaked := int64(0)
	metric.PrintMetricsBy(restakeLabel, func() {
		restaked = govstaker.Delegate(cross(cur), delegateeAddr, stakeAmount, "")
	})
	if restaked != stakeAmount {
		panic("restake returned an unexpected amount")
	}
	printCohortState(tokens, users, withdrawnTotal, "after-restake")
}

func runLaunchpadLifecycle(cur realm, tokens []string) {
	projectID := createLaunchpadProject(cur)
	projectTierID := projectID + ":30"

	testing.SetRealm(adminRealm)
	gns.Transfer(cross(cur), launchUserAddr, launchpadAmount)
	testing.SetRealm(launchUserRealm)
	gns.Approve(cross(cur), launchpadAddr, launchpadAmount)

	depositLabel := ufmt.Sprintf("GovDebtIncrement tokens=%s users=launchpad operation=deposit-gns repeats=1", tokenLabel)
	printActor(depositLabel, launchUserAddr)
	depositID := ""
	metric.PrintMetricsBy(depositLabel, func() {
		depositID = launchpad.DepositGns(cross(cur), projectTierID, launchpadAmount, "")
	})
	if depositID == "" {
		panic("launchpad deposit was not created")
	}
	printLaunchpadState(tokens, projectID, projectTierID, depositID, "after-deposit")

	// Governance-fee and emission accrual is outside the launchpad metrics.
	accrue(cur, tokens, smallFeeAmount)
	testing.SkipHeights(3*24*60*60/blockTimeSeconds + 1)

	claimLabel := ufmt.Sprintf("GovDebtIncrement tokens=%s users=launchpad operation=reward-claim repeats=1", tokenLabel)
	printActor(claimLabel, launchUserAddr)
	testing.SetRealm(launchUserRealm)
	claimAmount := int64(0)
	metric.PrintMetricsBy(claimLabel, func() {
		claimAmount = launchpad.CollectRewardByDepositId(cross(cur), depositID)
	})
	if claimAmount <= 0 {
		panic("launchpad reward claim was empty")
	}
	printLaunchpadState(tokens, projectID, projectTierID, depositID, "after-reward-claim")

	// The 30-day tier is already active; moving past the full project duration
	// makes the principal withdrawal unambiguously post-expiry.
	testing.SkipHeights(180*24*60*60/blockTimeSeconds + 1)
	withdrawLabel := ufmt.Sprintf("GovDebtIncrement tokens=%s users=launchpad operation=withdraw-deposit repeats=1", tokenLabel)
	printActor(withdrawLabel, launchUserAddr)
	testing.SetRealm(launchUserRealm)
	withdrawn := int64(0)
	var withdrawErr error
	metric.PrintMetricsBy(withdrawLabel, func() {
		withdrawn, withdrawErr = launchpad.CollectDepositGns(cross(cur), depositID)
	})
	if withdrawErr != nil || withdrawn != launchpadAmount {
		panic("launchpad principal withdrawal failed")
	}
	printLaunchpadState(tokens, projectID, projectTierID, depositID, "after-principal-withdrawal")

	refundLabel := ufmt.Sprintf("GovDebtIncrement tokens=%s users=admin operation=project-refund repeats=1", tokenLabel)
	printActor(refundLabel, adminAddr)
	testing.SetRealm(adminRealm)
	refunded := int64(0)
	metric.PrintMetricsBy(refundLabel, func() {
		refunded = launchpad.TransferLeftFromProjectByAdmin(cross(cur), projectID, projectAddr)
	})
	if refunded <= 0 {
		panic("launchpad project refund was empty")
	}
	printLaunchpadState(tokens, projectID, projectTierID, depositID, "after-project-refund")
}

func createLaunchpadProject(cur realm) string {
	label := ufmt.Sprintf("GovDebtIncrement tokens=%s users=admin operation=create-project repeats=1", tokenLabel)
	printActor(label, adminAddr)
	testing.SetRealm(adminRealm)
	projectID := ""
	metric.PrintMetricsBy(label, func() {
		projectID = launchpad.CreateProject(
			cross(cur),
			"Gov value debt project",
			oblPath,
			projectAddr,
			1_000_000_000,
			"",
			"",
			10,
			20,
			70,
			time.Now().Unix()+7*24*60*60,
		)
	})
	if projectID == "" {
		panic("launchpad project was not created")
	}
	testing.SkipHeights(7*24*60*60/blockTimeSeconds + 1)
	return projectID
}

func printLaunchpadState(tokens []string, projectID, projectTierID, depositID, phase string) {
	govEmission, govFees, err := govstaker.GetClaimableRewardByRewardID("launchpad:" + projectAddr.String())
	if err != nil {
		panic(err)
	}
	launchEmission, launchFees, err := govstaker.GetClaimableRewardByLaunchpad(projectAddr)
	if err != nil {
		panic(err)
	}
	if govEmission != launchEmission || feeTextFor(tokens, govFees) != feeTextFor(tokens, launchFees) {
		panic("launchpad reward ID getter mismatch")
	}
	projectDeposit, projectDepositPresent := govstaker.GetLaunchpadProjectDeposit(projectAddr.String())
	rewardState, rewardErr := launchpad.GetRewardState(projectTierID, depositID)
	rewardPresent := 0
	claimedAmount := int64(0)
	depositAmount := int64(0)
	debt := ""
	claimableTime := int64(0)
	if rewardErr == nil && rewardState != nil {
		rewardPresent = 1
		claimedAmount = rewardState.ClaimedAmount()
		depositAmount = rewardState.DepositAmount()
		debt = rewardState.PriceDebtX128().ToString()
		claimableTime = rewardState.ClaimableTime()
	}
	ufmt.Printf("STATE GovDebtIncrement tokens=%s phase=%s project=%s deposit=%s gov_reward_id=launchpad:%s gov_claimable_emission=%d gov_fee_values=%s gov_reward_state_retained=%d gov_project_deposit=%d gov_project_deposit_present=%d launchpad_reward_present=%d launchpad_deposit_amount=%d launchpad_claimed=%d launchpad_debt=%s launchpad_claimable_time=%d launchpad_token_balance=%d\n",
		tokenLabel, phase, projectID, depositID, projectAddr.String(), govEmission, feeTextFor(tokens, govFees), boolInt(len(govFees) >= len(tokens)), projectDeposit, boolInt(projectDepositPresent), rewardPresent, depositAmount, claimedAmount, debt, claimableTime, obl.BalanceOf(projectAddr))
}

func boolInt(value bool) int {
	if value {
		return 1
	}
	return 0
}

func printActor(label string, actor address) {
	ufmt.Printf("ACTOR %s actor=%s\n", label, actor.String())
}

func printGovState(tokens []string, users []address, phase string) {
	claimableEmission, claimableFees, err := govstaker.GetClaimableRewardByRewardID(focusAddr.String())
	if err != nil {
		panic(err)
	}
	ids := govstaker.GetUserDelegationIDs(focusAddr, delegateeAddr)
	idText := joinIDs(ids)
	feeText := feeTextFor(tokens, claimableFees)
	balanceText := balanceTextFor(tokens, focusAddr)
	debtText := debtTextFor(tokens)
	retained := 0
	if len(claimableFees) >= len(tokens) {
		retained = 1
	}
	ufmt.Printf("STATE GovDebtIncrement tokens=%s phase=%s delegated=%d locked=%d focus_ids=%s claimable_emission=%d fee_values=%s focus_balances=%s debt_values=%s reward_state_retained=%d debt_over_128=%d protocol_timestamp=%d emission_timestamp=%d gns_balance=%d\n",
		tokenLabel, phase, govstaker.GetTotalDelegated(), govstaker.GetTotalLockedAmount(), idText, claimableEmission, feeText, balanceText, debtText, retained, debtOver128(tokens), govstaker.GetProtocolFeeAccumulatedTimestamp(), govstaker.GetEmissionAccumulatedTimestamp(), gns.BalanceOf(focusAddr))
	if users != nil && phase == "all-principal-withdrawn" {
		retainedCount := countRetained(users)
		ufmt.Printf("STATE GovDebtIncrement tokens=%s phase=reward-state-retention retained=%d/%d\n", tokenLabel, retainedCount, len(users))
	}
}

func printCohortState(tokens []string, users []address, withdrawnTotal int64, phase string) {
	ufmt.Printf("STATE GovDebtIncrement tokens=%s phase=%s cohort_principal=%d cohort_withdrawn=%d delegated=%d locked=%d reward_states_retained=%d/%d\n",
		tokenLabel, phase, stakeAmount+int64(cohortSize-1)*1_000_000, withdrawnTotal, govstaker.GetTotalDelegated(), govstaker.GetTotalLockedAmount(), countRetained(users), cohortSize)
	if phase == "all-principal-withdrawn" {
		for i, user := range users {
			claimableEmission, claimableFees, err := govstaker.GetClaimableRewardByRewardID(user.String())
			if err != nil {
				panic(err)
			}
			ufmt.Printf("STATE GovDebtIncrement tokens=%s phase=%s index=%d user=%s gns_balance=%d fee_balances=%s claimable_emission=%d claimable_fees=%s\n",
				tokenLabel, phase, i, user.String(), gns.BalanceOf(user), balanceTextFor(tokens, user), claimableEmission, feeTextFor(tokens, claimableFees))
		}
	}
}

func countRetained(users []address) int {
	if users == nil {
		if _, fees, err := govstaker.GetClaimableRewardByRewardID(focusAddr.String()); err == nil && len(fees) >= activeTokenCount {
			return 1
		}
		return 0
	}
	count := 0
	for _, user := range users {
		_, fees, err := govstaker.GetClaimableRewardByRewardID(user.String())
		if err == nil && len(fees) >= activeTokenCount {
			count++
		}
	}
	return count
}

func joinIDs(ids []int64) string {
	result := ""
	for i, id := range ids {
		if i > 0 {
			result += ","
		}
		result += ufmt.Sprintf("%d", id)
	}
	return result
}

func feeTextFor(tokens []string, rewards map[string]int64) string {
	result := ""
	for i, tokenPath := range tokens {
		if i > 0 {
			result += ","
		}
		result += ufmt.Sprintf("%s:%d", tokenName(tokenPath), feeValue(rewards, tokenPath))
	}
	return result
}

func balanceTextFor(tokens []string, owner address) string {
	result := ""
	for i, tokenPath := range tokens {
		if i > 0 {
			result += ","
		}
		result += ufmt.Sprintf("%s:%d", tokenName(tokenPath), common.BalanceOf(tokenPath, owner))
	}
	return result
}

func debtTextFor(tokens []string) string {
	result := ""
	for i, tokenPath := range tokens {
		if i > 0 {
			result += ","
		}
		result += ufmt.Sprintf("%s:%s", tokenName(tokenPath), govstaker.GetProtocolFeeAccumulatedX128PerStake(tokenPath).ToString())
	}
	return result
}

func debtOver128(tokens []string) int {
	maxUint128 := u256.MustFromDecimal(maxUint128Text)
	for _, tokenPath := range tokens {
		if govstaker.GetProtocolFeeAccumulatedX128PerStake(tokenPath).Cmp(maxUint128) > 0 {
			return 1
		}
	}
	return 0
}

func feeValue(rewards map[string]int64, tokenPath string) int64 {
	if rewards == nil {
		return 0
	}
	return rewards[tokenPath]
}

func tokenName(tokenPath string) string {
	switch tokenPath {
	case barPath:
		return "bar"
	case bazPath:
		return "baz"
	case fooPath:
		return "foo"
	case quxPath:
		return "qux"
	default:
		return tokenPath
	}
}

func transferToken(cur realm, tokenPath string, to address, amount int64) {
	switch tokenPath {
	case barPath:
		bar.Transfer(cross(cur), to, amount)
	case bazPath:
		baz.Transfer(cross(cur), to, amount)
	case fooPath:
		foo.Transfer(cross(cur), to, amount)
	case quxPath:
		qux.Transfer(cross(cur), to, amount)
	default:
		panic("unknown protocol-fee token")
	}
}

func approveToken(cur realm, tokenPath string, spender address, amount int64) {
	switch tokenPath {
	case barPath:
		bar.Approve(cross(cur), spender, amount)
	case bazPath:
		baz.Approve(cross(cur), spender, amount)
	case fooPath:
		foo.Approve(cross(cur), spender, amount)
	case quxPath:
		qux.Approve(cross(cur), spender, amount)
	default:
		panic("unknown protocol-fee token")
	}
}
