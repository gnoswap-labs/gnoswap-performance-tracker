// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Contract-path value-record PoC for governance delegation/reward and launchpad
// reward lifecycles. Setup funding and approvals are outside measured intervals;
// every measured operation calls the public proxy directly.
package main

import (
	"strconv"
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/protocol_fee"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/launchpad/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	govstaker "gno.land/r/gnoswap/gov/staker"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/obl"

	"gno.land/r/gnoswap/scenario/metric"
)

const (
	blockTimeSeconds      int64 = 5
	delegationStageSmall        = 32
	delegationStageLarge        = 128
	govDelegationAmount   int64 = 2_000_000
	launchpadDepositAmount int64 = 1_000_000
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)
	stakerAddr, _      = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm        = testing.NewUserRealm(stakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())
	launchpadAddr, _   = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	govDelegateeAddr    = testutils.TestAddress("delegation-delegatee")
	projectAddr         = testutils.TestAddress("delegation-project")
	delegationUsers     []address
	delegationIDs       []int64
	depositIDs          []string

	barPath = "gno.land/r/onbloc/bar.BAR"
	bazPath = "gno.land/r/onbloc/baz.BAZ"
	oblPath = "gno.land/r/onbloc/obl.OBL"
	maxInt64 int64 = 9223372036854775807
)

func main(cur realm) {
	initializeSetup(cur)

	// The governance stages create distinct delegation and reward-state values.
	// The first and last users each keep a live remainder after undelegation so
	// their records remain available for boundary assertions after collection.
	delegateStage(cur, 0, delegationStageSmall)
	undelegateOne(cur, 0, "DelegationRewards Gov Undelegate Stage32")
	printGovDelegationStage(delegationStageSmall, 63_000_000, 64_000_000, 1_000_000, 0, 0, 0, 0, 0)
	distributeGovFees(cur, 1_000_000)
	collectGovRewardStage(cur, delegationStageSmall)

	delegateStage(cur, delegationStageSmall, delegationStageLarge)
	undelegateOne(cur, delegationStageLarge-1, "DelegationRewards Gov Undelegate Stage128")
	printGovDelegationStage(delegationStageLarge, 254_000_000, 256_000_000, 1_000_000, 0, 0, 0, 1_000_000, 0)

	testing.SkipHeights(govstaker.GetUnDelegationLockupPeriod()/blockTimeSeconds + 1)
	collectUndelegatedSamples(cur)
	printGovDelegationStage(delegationStageLarge, 254_000_000, 254_000_000, 1_000_000, 1_000_000, 0, 0, 1_000_000, 1_000_000)
	distributeGovFees(cur, 1_000_000)
	collectGovRewardStage(cur, delegationStageLarge)

	// Launchpad deposits create another large reward-state tree. The first
	// stage is claimed before the second stage is added, then the large-stage
	// claim repeats the first records and claims every newly-created record.
	projectID := createProject(cur)
	depositStage(cur, projectID, 0, delegationStageSmall)
	printLaunchpadStage(projectID, delegationStageSmall)

	testing.SkipHeights(3*24*60*60/blockTimeSeconds + 1)
	collectLaunchpadRewardStage(cur, projectID, 0, delegationStageSmall, delegationStageSmall)

	depositStage(cur, projectID, delegationStageSmall, delegationStageLarge)
	printLaunchpadStage(projectID, delegationStageLarge)
	testing.SkipHeights(3*24*60*60/blockTimeSeconds + 1)
	collectLaunchpadRewardStage(cur, projectID, 0, delegationStageLarge, delegationStageLarge)

	// Keep the principal-withdrawal and price-debt lifecycle explicit after the
	// large reward tree has been populated and mutated.
	testing.SkipHeights(24*24*60*60/blockTimeSeconds + 1)
	withdrawLaunchpadDeposit(cur, projectID, depositIDs[0])
}

func initializeSetup(cur realm) {
	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()

	delegationUsers = make([]address, delegationStageLarge)
	delegationIDs = make([]int64, delegationStageLarge)
	for i := 0; i < delegationStageLarge; i++ {
		delegationUsers[i] = testutils.TestAddress(ufmt.Sprintf("delegation-user-%d", i))
	}
	depositIDs = make([]string, delegationStageLarge)

	// All user funding, approvals, and protocol-fee token setup stay outside
	// measured intervals.
	testing.SetRealm(adminRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
	obl.Approve(cross(cur), launchpadAddr, maxInt64)
	gns.Transfer(cross(cur), aliceAddr, launchpadDepositAmount*int64(delegationStageLarge))
	bar.Transfer(cross(cur), stakerAddr, 10_000_000)
	baz.Transfer(cross(cur), stakerAddr, 10_000_000)

	for _, user := range delegationUsers {
		testing.SetRealm(adminRealm)
		gns.Transfer(cross(cur), user, govDelegationAmount)
		testing.SetRealm(testing.NewUserRealm(user))
		gns.Approve(cross(cur), govStakerAddr, govDelegationAmount)
	}
	testing.SetRealm(aliceRealm)
	gns.Approve(cross(cur), launchpadAddr, maxInt64)

	testing.SetRealm(stakerRealm)
	bar.Approve(cross(cur), protocolFeeAddr, maxInt64)
	bar.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
	baz.Approve(cross(cur), protocolFeeAddr, maxInt64)
	baz.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
}

func delegateStage(cur realm, start, end int) {
	gasUsed, storageDiff, cycles := int64(0), int64(0), int64(0)
	for i := start; i < end; i++ {
		testing.SetRealm(testing.NewUserRealm(delegationUsers[i]))
		index := i
		var delegatedAmount int64
		gas, storage, cpu := metric.MetricsBy("", func() {
			delegatedAmount = govstaker.Delegate(cross(cur), govDelegateeAddr, govDelegationAmount, "")
		})
		if delegatedAmount != govDelegationAmount {
			panic("delegate returned an unexpected amount")
		}
		ids := govstaker.GetUserDelegationIDs(delegationUsers[index], govDelegateeAddr)
		if len(ids) == 0 {
			panic("delegate did not create a delegation record")
		}
		delegationIDs[index] = ids[len(ids)-1]
		gasUsed += gas
		storageDiff += storage
		cycles += cpu
	}
	printMetricSummary(ufmt.Sprintf("DelegationRewards Gov Delegate stage=%d records=%d", end, end-start), gasUsed, storageDiff, cycles)
	testing.SkipHeights(1)
}

func printMetricSummary(name string, gasUsed, storageDiff, cycles int64) {
	println(name)
	ufmt.Printf("- Gas Used: %d\n", gasUsed)
	ufmt.Printf("- Storage Diff: %d\n", storageDiff)
	ufmt.Printf("- CPU Cycles: %d\n", cycles)
}

func undelegateOne(cur realm, index int, label string) {
	user := delegationUsers[index]
	testing.SetRealm(testing.NewUserRealm(user))
	var undelegated int64
	metric.PrintMetricsBy(label, func() {
		undelegated = govstaker.Undelegate(cross(cur), govDelegateeAddr, 1_000_000)
	})
	if undelegated != 1_000_000 {
		panic("undelegate returned an unexpected amount")
	}
	testing.SkipHeights(1)
}

func collectUndelegatedSamples(cur realm) {
	gasUsed, storageDiff, cycles := int64(0), int64(0), int64(0)
	for _, index := range []int{0, delegationStageLarge - 1} {
		testing.SetRealm(testing.NewUserRealm(delegationUsers[index]))
		var collected int64
		gas, storage, cpu := metric.MetricsBy("", func() {
			collected = govstaker.CollectUndelegatedGns(cross(cur))
		})
		if collected != 1_000_000 {
			panic("collect undelegated amount invariant failed")
		}
		gasUsed += gas
		storageDiff += storage
		cycles += cpu
	}
	printMetricSummary("DelegationRewards Gov CollectUndelegatedGns Stage128 Samples", gasUsed, storageDiff, cycles)
}

func printGovDelegationStage(stage int, expectedDelegated, expectedLocked int64, firstUndelegated, firstCollected, middleUndelegated, middleCollected, lastUndelegated, lastCollected int64) {
	if govstaker.GetDelegations().Size() != stage {
		panic("delegation count invariant failed")
	}
	if govstaker.GetTotalDelegated() != expectedDelegated || govstaker.GetTotalLockedAmount() != expectedLocked {
		panic("governance delegation total invariant failed")
	}

	first := assertDelegationSample(0, firstUndelegated, firstCollected, firstUndelegated > firstCollected)
	middleIndex := stage / 2
	middle := assertDelegationSample(middleIndex, middleUndelegated, middleCollected, middleUndelegated > middleCollected)
	last := assertDelegationSample(stage-1, lastUndelegated, lastCollected, lastUndelegated > lastCollected)
	ufmt.Printf("STATE delegation-rewards gov stage=%d delegation_count=%d total_delegated=%d total_locked=%d first_id=%d first_total=%d first_undelegated=%d first_collected=%d first_withdraw_count=%d middle_id=%d middle_total=%d middle_undelegated=%d middle_collected=%d middle_withdraw_count=%d last_id=%d last_total=%d last_undelegated=%d last_collected=%d last_withdraw_count=%d\n",
		stage,
		govstaker.GetDelegations().Size(),
		govstaker.GetTotalDelegated(),
		govstaker.GetTotalLockedAmount(),
		delegationIDs[0], first.TotalDelegatedAmount(), first.UnDelegatedAmount(), first.CollectedAmount(), len(first.Withdraws()),
		delegationIDs[middleIndex], middle.TotalDelegatedAmount(), middle.UnDelegatedAmount(), middle.CollectedAmount(), len(middle.Withdraws()),
		delegationIDs[stage-1], last.TotalDelegatedAmount(), last.UnDelegatedAmount(), last.CollectedAmount(), len(last.Withdraws()),
	)
}

func assertDelegationSample(index int, expectedUndelegated, expectedCollected int64, expectWithdraw bool) *govstaker.Delegation {
	delegation := getDelegation(delegationIDs[index])
	if delegation.DelegateFrom() != delegationUsers[index] || delegation.DelegateTo() != govDelegateeAddr {
		panic("delegation address invariant failed")
	}
	if delegation.TotalDelegatedAmount() != govDelegationAmount || delegation.UnDelegatedAmount() != expectedUndelegated || delegation.CollectedAmount() != expectedCollected {
		panic("delegation amount invariant failed")
	}
	if expectWithdraw && len(delegation.Withdraws()) != 1 {
		panic("delegation withdraw invariant failed")
	}
	if !expectWithdraw && len(delegation.Withdraws()) != 0 {
		panic("unexpected delegation withdraw record")
	}
	return delegation
}

func distributeGovFees(cur realm, amount int64) {
	testing.SetRealm(stakerRealm)
	protocol_fee.AddToProtocolFee(cross(cur), barPath, amount)
	protocol_fee.AddToProtocolFee(cross(cur), bazPath, amount)
	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross(cur))
	testing.SkipHeights(1)
}

func collectGovRewardStage(cur realm, stage int) {
	testing.SetRealm(adminRealm)
	firstBefore := claimableGovReward(delegationUsers[0])
	middleBefore := claimableGovReward(delegationUsers[stage/2])
	lastBefore := claimableGovReward(delegationUsers[stage-1])
	if firstBefore.bar <= 0 || firstBefore.baz <= 0 || middleBefore.bar <= 0 || middleBefore.baz <= 0 || lastBefore.bar <= 0 || lastBefore.baz <= 0 {
		panic("governance reward state was not populated")
	}

	gasUsed, storageDiff, cycles := int64(0), int64(0), int64(0)
	for i := 0; i < stage; i++ {
		testing.SetRealm(testing.NewUserRealm(delegationUsers[i]))
		gas, storage, cpu := metric.MetricsBy("", func() {
			govstaker.CollectReward(cross(cur))
		})
		gasUsed += gas
		storageDiff += storage
		cycles += cpu
	}
	printMetricSummary(ufmt.Sprintf("DelegationRewards Gov CollectReward stage=%d records=%d", stage, stage), gasUsed, storageDiff, cycles)

	testing.SetRealm(adminRealm)
	firstAfter := claimableGovReward(delegationUsers[0])
	middleAfter := claimableGovReward(delegationUsers[stage/2])
	lastAfter := claimableGovReward(delegationUsers[stage-1])
	if firstAfter.emission != 0 || firstAfter.bar != 0 || firstAfter.baz != 0 || middleAfter.emission != 0 || middleAfter.bar != 0 || middleAfter.baz != 0 || lastAfter.emission != 0 || lastAfter.bar != 0 || lastAfter.baz != 0 {
		panic("governance reward claim state was not cleared")
	}
	ufmt.Printf("STATE delegation-rewards gov_rewards stage=%d reward_state_count=%d first_before_bar=%d first_after_bar=%d middle_before_bar=%d middle_after_bar=%d last_before_bar=%d last_after_bar=%d protocol_cursor=%d emission_cursor=%s\n",
		stage,
		stage,
		firstBefore.bar, firstAfter.bar,
		middleBefore.bar, middleAfter.bar,
		lastBefore.bar, lastAfter.bar,
		govstaker.GetProtocolFeeAccumulatedTimestamp(),
		govstaker.GetEmissionAccumulatedX128PerStake().ToString(),
	)
}

type govRewardSample struct {
	emission int64
	bar      int64
	baz      int64
}

func claimableGovReward(user address) govRewardSample {
	emission, protocol, err := govstaker.GetClaimableRewardByAddress(user)
	if err != nil {
		panic(err)
	}
	return govRewardSample{emission: emission, bar: protocol[barPath], baz: protocol[bazPath]}
}

func createProject(cur realm) string {
	testing.SetRealm(adminRealm)
	var projectID string
	metric.PrintMetricsBy("DelegationRewards Launchpad CreateProject", func() {
		projectID = launchpad.CreateProject(
			cross(cur),
			"Delegation Rewards Value Project",
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


func depositStage(cur realm, projectID string, start, end int) {
	projectTierID := projectID + ":30"
	testing.SetRealm(aliceRealm)
	metric.PrintMetricsBy(ufmt.Sprintf("DelegationRewards Launchpad DepositGns stage=%d records=%d", end, end-start), func() {
		for i := start; i < end; i++ {
			depositIDs[i] = launchpad.DepositGns(cross(cur), projectTierID, launchpadDepositAmount, "")
			if depositIDs[i] == "" {
				panic("launchpad deposit was not created")
			}
		}
	})
	testing.SkipHeights(1)
	if launchpad.GetDepositCount() != end {
		panic("launchpad deposit count invariant failed")
	}
}

func printLaunchpadStage(projectID string, stage int) {
	projectTierID := projectID + ":30"
	totalDeposit, err := launchpad.GetProjectTierTotalDepositAmount(projectID, 30)
	if err != nil || totalDeposit != launchpadDepositAmount*int64(stage) {
		panic("launchpad total deposit invariant failed")
	}
	if launchpad.GetDepositCount() != stage {
		panic("launchpad global deposit count invariant failed")
	}

	first := mustRewardState(projectTierID, depositIDs[0])
	middle := mustRewardState(projectTierID, depositIDs[stage/2])
	last := mustRewardState(projectTierID, depositIDs[stage-1])
	assertRewardSample(first)
	assertRewardSample(middle)
	assertRewardSample(last)
	ufmt.Printf("STATE delegation-rewards launchpad stage=%d deposit_count=%d total_deposit=%d first_id=%s first_price_debt=%s first_deposit_amount=%d first_accumulated=%d first_claimed=%d middle_id=%s middle_price_debt=%s middle_deposit_amount=%d middle_accumulated=%d middle_claimed=%d last_id=%s last_price_debt=%s last_deposit_amount=%d last_accumulated=%d last_claimed=%d manager_total_claimed=%d manager_active_deposit=%d manager_accumulated_time=%d\n",
		stage,
		launchpad.GetDepositCount(),
		totalDeposit,
		depositIDs[0], first.PriceDebtX128().ToString(), first.DepositAmount(), first.AccumulatedRewardAmount(), first.ClaimedAmount(),
		depositIDs[stage/2], middle.PriceDebtX128().ToString(), middle.DepositAmount(), middle.AccumulatedRewardAmount(), middle.ClaimedAmount(),
		depositIDs[stage-1], last.PriceDebtX128().ToString(), last.DepositAmount(), last.AccumulatedRewardAmount(), last.ClaimedAmount(),
		mustProjectTierRewardTotalClaimed(projectTierID),
		mustProjectTierRewardActiveDeposit(projectTierID),
		mustProjectTierRewardAccumulatedTime(projectTierID),
	)
}

func assertRewardSample(state *launchpad.RewardState) {
	if state == nil || state.PriceDebtX128() == nil || state.DepositAmount() != launchpadDepositAmount {
		panic("launchpad reward state invariant failed")
	}
}

func collectLaunchpadRewardStage(cur realm, projectID string, start, end, stage int) {
	projectTierID := projectID + ":30"
	testing.SetRealm(aliceRealm)
	firstBefore := mustRewardState(projectTierID, depositIDs[0]).ClaimedAmount()
	middleBefore := mustRewardState(projectTierID, depositIDs[stage/2]).ClaimedAmount()
	lastBefore := mustRewardState(projectTierID, depositIDs[stage-1]).ClaimedAmount()

	metric.PrintMetricsBy(ufmt.Sprintf("DelegationRewards Launchpad CollectReward stage=%d records=%d", stage, end-start), func() {
		for i := start; i < end; i++ {
			launchpad.CollectRewardByDepositId(cross(cur), depositIDs[i])
		}
	})

	firstAfter := mustRewardState(projectTierID, depositIDs[0]).ClaimedAmount()
	middleAfter := mustRewardState(projectTierID, depositIDs[stage/2]).ClaimedAmount()
	lastAfter := mustRewardState(projectTierID, depositIDs[stage-1]).ClaimedAmount()
	if firstAfter <= firstBefore || middleAfter <= middleBefore || lastAfter <= lastBefore {
		panic("launchpad reward claim state did not advance")
	}
	printLaunchpadStage(projectID, stage)
}

func withdrawLaunchpadDeposit(cur realm, projectID, depositID string) {
	projectTierID := projectID + ":30"
	testing.SetRealm(aliceRealm)
	var withdrawn int64
	metric.PrintMetricsBy("DelegationRewards Launchpad CollectDepositGns Stage128 First", func() {
		withdrawn, _ = launchpad.CollectDepositGns(cross(cur), depositID)
	})
	if withdrawn != launchpadDepositAmount {
		panic("launchpad withdrawal amount invariant failed")
	}
	if mustDepositWithdrawnHeight(depositID) <= 0 || mustDepositWithdrawnTime(depositID) <= 0 {
		panic("launchpad withdrawal cursor invariant failed")
	}
	if _, err := launchpad.GetRewardState(projectTierID, depositID); err == nil {
		panic("launchpad reward state should be deleted after withdrawal")
	}
	ufmt.Printf("STATE delegation-rewards launchpad withdrawal deposit_id=%s project_tier=%s deposit_amount=%d withdrawn=%d withdrawn_height=%d withdrawn_time=%d reward_present=0 manager_total_claimed=%d manager_active_deposit=%d manager_accumulated_time=%d\n",
		depositID,
		projectTierID,
		mustDepositAmount(depositID),
		withdrawn,
		mustDepositWithdrawnHeight(depositID),
		mustDepositWithdrawnTime(depositID),
		mustProjectTierRewardTotalClaimed(projectTierID),
		mustProjectTierRewardActiveDeposit(projectTierID),
		mustProjectTierRewardAccumulatedTime(projectTierID),
	)
}

func getDelegation(delegationID int64) *govstaker.Delegation {
	value := govstaker.GetDelegations().Get(strconv.FormatInt(delegationID, 10))
	delegation, ok := value.(*govstaker.Delegation)
	if !ok || delegation == nil {
		panic("delegation record missing from public getter")
	}
	return delegation
}

func mustRewardState(projectTierID, depositID string) *launchpad.RewardState {
	state, err := launchpad.GetRewardState(projectTierID, depositID)
	if err != nil || state == nil {
		panic("launchpad reward state missing from public getter")
	}
	return state
}


func mustProjectTierRewardTotalClaimed(projectTierID string) int64 {
	value, err := launchpad.GetProjectTierRewardTotalClaimedAmount(projectTierID)
	if err != nil {
		panic(err)
	}
	return value
}

func mustProjectTierRewardActiveDeposit(projectTierID string) int64 {
	manager, err := launchpad.GetProjectTierRewardManager(projectTierID)
	if err != nil || manager == nil {
		panic("launchpad reward manager missing")
	}
	return manager.ActiveDepositAmount()
}

func mustProjectTierRewardAccumulatedTime(projectTierID string) int64 {
	value, err := launchpad.GetProjectTierRewardAccumulatedTime(projectTierID)
	if err != nil {
		panic(err)
	}
	return value
}

func mustDepositAmount(depositID string) int64 {
	value, err := launchpad.GetDepositAmount(depositID)
	if err != nil {
		panic(err)
	}
	return value
}

func mustDepositWithdrawnHeight(depositID string) int64 {
	value, err := launchpad.GetDepositWithdrawnHeight(depositID)
	if err != nil {
		panic(err)
	}
	return value
}

func mustDepositWithdrawnTime(depositID string) int64 {
	value, err := launchpad.GetDepositWithdrawnTime(depositID)
	if err != nil {
		panic(err)
	}
	return value
}
