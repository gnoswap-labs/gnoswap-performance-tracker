// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Measure one vote after 0, 4, and 9 distinct voters on the same proposal.
// Funding, delegation, proposal creation, and prior votes are outside each interval.
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/gov/governance"
	_ "gno.land/r/gnoswap/gov/governance/v1"
	govstaker "gno.land/r/gnoswap/gov/staker"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
)

const voteWeight int64 = 1000000

func main(cur realm) {
	admin, _ := access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm := testing.NewUserRealm(admin)
	govStaker, _ := access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	voters := make([]address, 10)

	testing.SetRealm(adminRealm)
	governance.Reconfigure(cross(cur), 0, 1, 0, 50, 0, 0, 2592000)
	for i := range voters {
		voters[i] = testutils.TestAddress(ufmt.Sprintf("accumulated-voter-%d", i+1))
		testing.SetRealm(adminRealm)
		gns.Transfer(cross(cur), voters[i], voteWeight)
		testing.SetRealm(testing.NewUserRealm(voters[i]))
		gns.Approve(cross(cur), govStaker, voteWeight)
		govstaker.Delegate(cross(cur), voters[i], voteWeight, "")
	}
	// Populate delegation history before the proposal snapshot is taken.
	testing.SkipHeights(5)

	description4KiB := ""
	for i := 0; i < 80; i++ {
		description4KiB += "GnoSwap governance proposal metadata benchmark payload."
	}

	testing.SetRealm(adminRealm)
	textID := governance.ProposeText(cross(cur), "Accumulated text votes", description4KiB+description4KiB)
	measureVotes(cur, textID, "text 8KiB", voters)
	testing.SkipHeights(2)

	testing.SetRealm(adminRealm)
	parameterID := governance.ProposeParameterChange(
		cross(cur), "Accumulated parameter votes", description4KiB, 1,
		"gno.land/r/gnoswap/pool*EXE*SetPoolCreationFee*EXE*0",
	)
	measureVotes(cur, parameterID, "parameter 4KiB", voters)
}

func measureVotes(cur realm, proposalID int64, kind string, voters []address) {
	for i, voter := range voters {
		testing.SetRealm(testing.NewUserRealm(voter))
		if governance.GetVotingInfos(proposalID).Size() != i {
			panic("unexpected number of prior voters")
		}
		status, err := governance.GetProposalStatusByProposalId(proposalID)
		if err != nil || status != "active" {
			panic("proposal must remain active for every measured vote")
		}

		ordinal := i + 1
		if ordinal == 1 || ordinal == 5 || ordinal == 10 {
			metric.PrintMetricsBy(ufmt.Sprintf("Accumulated vote %s #%d", kind, ordinal), func() {
				governance.Vote(cross(cur), proposalID, true)
			})
		} else {
			governance.Vote(cross(cur), proposalID, true)
		}

		yes, yesErr := governance.GetYeaByProposalId(proposalID)
		no, noErr := governance.GetNayByProposalId(proposalID)
		count := governance.GetVotingInfos(proposalID).Size()
		if yesErr != nil || noErr != nil || yes != int64(ordinal)*voteWeight || no != 0 || count != ordinal {
			panic("vote must add exactly one voter and its full snapshot weight")
		}
		if ordinal == 1 || ordinal == 5 || ordinal == 10 {
			println("STATE accumulated-vote", kind, ordinal, "voters", count, "yes", yes, "no", no)
		}
	}
}
