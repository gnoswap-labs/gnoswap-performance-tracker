// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and storage metrics for the value-backed per-proposal VotingInfo tree.
// This exercises the real governance flow with enough distinct voters to expose scaling.
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	testutils "gno.land/p/nt/testutils/v0"
	uassert "gno.land/p/nt/uassert/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/gov/governance/v1"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/gov/governance"
	govstaker "gno.land/r/gnoswap/gov/staker"
	"gno.land/r/gnoswap/scenario/metric"
)

const (
	adminVotingAmount    int64 = 2_000_000_000
	voterVotingAmount    int64 = 1_000_000
	firstStageVoterCount       = 32
	totalVoterCount            = 128
	maxInt64             int64 = 9223372036854775807
)

var (
	adminAddr, _     = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm       = testing.NewUserRealm(adminAddr)
	govStakerAddr, _ = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	voters           []address
)

func main(cur realm) {
	initializeVotingInfoLifecycle(cur)
	proposalID := proposalMetric(cur)
	voteAdminMetric(cur, proposalID)
	assertVotingState(proposalID, "after-admin-vote", 0, "active")

	voteVoterStageMetric(cur, proposalID, 0, firstStageVoterCount)
	assertVotingState(proposalID, "after-32-votes", firstStageVoterCount, "active")

	voteVoterStageMetric(cur, proposalID, firstStageVoterCount, totalVoterCount)
	assertVotingState(proposalID, "after-128-votes", totalVoterCount, "active")

	readVotingInfoMetric(proposalID)
	assertDuplicateVoteRejected(cur, proposalID, totalVoterCount/2)
	assertVotingState(proposalID, "after-duplicate-rejection", totalVoterCount, "active")

	testing.SkipHeights(6)
	assertVotingState(proposalID, "final", totalVoterCount, "passed")
}

func initializeVotingInfoLifecycle(cur realm) {
	testing.SetRealm(adminRealm)
	governance.Reconfigure(cross(cur), 0, 4, 0, 50, 0, 0, 100)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
	govstaker.Delegate(cross(cur), adminAddr, adminVotingAmount, "")

	voters = make([]address, totalVoterCount)
	for i := 0; i < totalVoterCount; i++ {
		voter := testutils.TestAddress(ufmt.Sprintf("vi-%d", i))
		voters[i] = voter

		testing.SetRealm(adminRealm)
		gns.Transfer(cross(cur), voter, voterVotingAmount)

		testing.SetRealm(testing.NewUserRealm(voter))
		gns.Approve(cross(cur), govStakerAddr, voterVotingAmount)
		delegated := govstaker.Delegate(cross(cur), voter, voterVotingAmount, "")
		if delegated != voterVotingAmount {
			panic("VotingInfo voter delegation invariant failed")
		}
	}

	// Make every delegation visible to the proposal snapshot.
	testing.SkipHeights(3)
}

func proposalMetric(cur realm) int64 {
	testing.SetRealm(adminRealm)
	proposalID := int64(0)
	metric.PrintMetricsBy("VotingInfo proposal create (empty tree)", func() {
		proposalID = governance.ProposeText(cross(cur), "VotingInfo value", "VotingInfo scaled lifecycle")
	})
	if proposalID != 1 || governance.GetCurrentProposalID() != proposalID {
		panic("VotingInfo proposal cursor invariant failed")
	}
	return proposalID
}

func voteAdminMetric(cur realm, proposalID int64) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("VotingInfo vote admin (tree size 0 -> 1)", func() {
		governance.Vote(cross(cur), proposalID, true)
	})
}

func voteVoterStageMetric(cur realm, proposalID int64, start, end int) {
	gasUsed, storageDiff, cycles := int64(0), int64(0), int64(0)
	for i := start; i < end; i++ {
		testing.SetRealm(testing.NewUserRealm(voters[i]))
		gas, storage, cpu := metric.MetricsBy("", func() {
			governance.Vote(cross(cur), proposalID, false)
		})
		gasUsed += gas
		storageDiff += storage
		cycles += cpu
	}
	printMetricSummary(ufmt.Sprintf("VotingInfo voter stage size=%d added=%d", end, end-start), gasUsed, storageDiff, cycles)
}

func readVotingInfoMetric(proposalID int64) {
	metric.PrintMetricsBy("VotingInfo read full tree size=128", func() {
		infos := governance.GetVotingInfos(proposalID)
		if infos == nil || infos.Size() != totalVoterCount+1 {
			panic("VotingInfo full tree read invariant failed")
		}
	})
}

func printMetricSummary(name string, gasUsed, storageDiff, cycles int64) {
	println(name)
	ufmt.Printf("- Gas Used: %d\n", gasUsed)
	ufmt.Printf("- Storage Diff: %d\n", storageDiff)
	ufmt.Printf("- CPU Cycles: %d\n", cycles)
}

func assertDuplicateVoteRejected(cur realm, proposalID int64, voterIndex int) {
	testing.SetRealm(testing.NewUserRealm(voters[voterIndex]))
	assertT := testing.NewT("VotingInfo duplicate vote")
	uassert.AbortsWithMessage(assertT, cur, "[GNOSWAP-GOVERNANCE-004] cannot vote twice || user has already voted", func() {
		governance.Vote(cross(cur), proposalID, true)
	})
	if assertT.Failed() {
		panic("VotingInfo duplicate vote assertion failed")
	}
}

func assertVotingState(proposalID int64, label string, voterCount int, expectedStatus string) {
	quorum, maxWeight, yesWeight, noWeight, err := governance.GetVoteStatus(proposalID)
	expectedMax := adminVotingAmount + int64(totalVoterCount)*voterVotingAmount
	expectedNo := int64(voterCount) * voterVotingAmount
	if err != nil || maxWeight != expectedMax || quorum != expectedMax/2 || yesWeight != adminVotingAmount || noWeight != expectedNo {
		panic("VotingInfo vote tally invariant failed")
	}

	infos := governance.GetVotingInfos(proposalID)
	if infos == nil || infos.Size() != voterCount+1 {
		panic("VotingInfo voter count invariant failed")
	}
	adminInfo, ok := infos.Get(adminAddr.String()).(*governance.VotingInfo)
	if !ok || adminInfo == nil || !adminInfo.IsVoted() || !adminInfo.VotedYes() || adminInfo.VotedWeight() != adminVotingAmount {
		panic("VotingInfo admin record invariant failed")
	}

	if voterCount > 0 {
		for _, index := range []int{0, voterCount / 2, voterCount - 1} {
			voter := voters[index]
			info, exists := infos.Get(voter.String()).(*governance.VotingInfo)
			weight, weightErr := governance.GetVoteWeight(proposalID, voter)
			if !exists || info == nil || !info.IsVoted() || info.VotedYes() || info.VotedWeight() != voterVotingAmount || weightErr != nil || weight != voterVotingAmount || !governance.ExistsVotingInfo(proposalID, voter) {
				panic("VotingInfo sampled voter invariant failed")
			}
		}
	}

	absentAddr := testutils.TestAddress("voting-info-absent")
	absentWeight, absentErr := governance.GetVoteWeight(proposalID, absentAddr)
	if absentErr == nil || absentWeight != 0 || governance.ExistsVotingInfo(proposalID, absentAddr) {
		panic("VotingInfo missing voter boundary invariant failed")
	}
	status, statusErr := governance.GetProposalStatusByProposalId(proposalID)
	if statusErr != nil || status != expectedStatus {
		panic("VotingInfo proposal status invariant failed")
	}

	println("STATE voting-info", label, "proposal", proposalID, "quorum", quorum, "max", maxWeight, "yes", yesWeight, "no", noWeight, "voters", infos.Size(), "status", status)
}
