// Gas and performance metrics for governance propose text
// Test cases based on tests/integration/testdata/gov/governance/create_text_proposal.txtar
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/ufmt"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/governance/v1"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/gov/governance"
	govstaker "gno.land/r/gnoswap/gov/staker"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _ = access.GetAddress(prabc.ROLE_GOV_STAKER.String())

	inactiveProposalCount       = 100
	maxInt64              int64 = 9223372036854775807
)

var t *testing.T

func main() {
	initializeSetup()

	for i := 0; i < inactiveProposalCount; i++ {
		proposeInactiveText()
	}

	proposeTextMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)

	// Reconfigure governance with votingWeightSmoothingDuration set to 25
	governance.Reconfigure(cross, 25, 604800, 25, 50, 0, 86400, 2592000)

	// Approve and delegate GNS to get voting power
	gns.Approve(cross, govStakerAddr, maxInt64)
	govstaker.Delegate(cross, adminAddr, int64(1000000000), "")

	// Skip blocks for delegation to be counted (25+ for votingWeightSmoothingDuration)
	testing.SkipHeights(30)
}

func proposeInactiveText() {
	testing.SetRealm(adminRealm)
	proposalId := governance.ProposeText(cross, "Test Proposal Inactive", "This is a test proposal inactive")
	testing.SkipHeights(1)
	governance.Cancel(cross, proposalId)
	testing.SkipHeights(1)
}

func proposeTextMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("Propose Text with Inactive: %d", inactiveProposalCount), func() {
		governance.ProposeText(cross, "Test Proposal", "This is a test proposal")
	})
}
