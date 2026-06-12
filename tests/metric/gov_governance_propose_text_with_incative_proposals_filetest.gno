// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for governance propose text
// Test cases based on tests/integration/testdata/gov/governance/create_text_proposal.txtar
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/ufmt/v0"
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

func main(cur realm) {
	initializeSetup(cur)

	for i := 0; i < inactiveProposalCount; i++ {
		proposeInactiveText(cur)
	}

	proposeTextMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)

	// Reconfigure governance with votingWeightSmoothingDuration set to 25
	governance.Reconfigure(cross(cur), 25, 604800, 25, 50, 0, 86400, 2592000)

	// Approve and delegate GNS to get voting power
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
	govstaker.Delegate(cross(cur), adminAddr, int64(1000000000), "")

	// Skip blocks for delegation to be counted (25+ for votingWeightSmoothingDuration)
	testing.SkipHeights(30)
}

func proposeInactiveText(cur realm) {
	testing.SetRealm(adminRealm)
	proposalId := governance.ProposeText(cross(cur), "Test Proposal Inactive", "This is a test proposal inactive")
	testing.SkipHeights(1)
	governance.Cancel(cross(cur), proposalId)
	testing.SkipHeights(1)
}

func proposeTextMetric(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("Propose Text with Inactive: %d", inactiveProposalCount), func() {
		governance.ProposeText(cross(cur), "Test Proposal", "This is a test proposal")
	})
}

// Output:
// Propose Text with Inactive: 100
// - Gas Used: 3401131
// - Storage Diff: 8501
// - CPU Cycles: 2894248
