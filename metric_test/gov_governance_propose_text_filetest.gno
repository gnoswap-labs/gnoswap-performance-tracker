// Gas and performance metrics for governance propose text
// Test cases based on tests/integration/testdata/gov/governance/create_text_proposal.txtar
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/governance/v1"
	_ "gno.land/r/gnoswap/gov/staker/v1"

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

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main() {
	initializeSetup()
	delegateMetric()
	proposeTextMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)

	// Reconfigure governance with votingWeightSmoothingDuration set to 0
	governance.Reconfigure(cross, 0, 604800, 0, 50, 0, 86400, 2592000)

	gns.Approve(cross, govStakerAddr, maxInt64)
}

func delegateMetric() {
	testing.SetRealm(adminRealm)

	govstaker.Delegate(cross, adminAddr, int64(1000000000), "")
}

func proposeTextMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Propose Text", func() {
		governance.ProposeText(cross, "Test Proposal", "This is a test proposal")
	})
}
