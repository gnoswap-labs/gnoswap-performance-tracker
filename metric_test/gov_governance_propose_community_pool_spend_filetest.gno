// Gas and performance metrics for governance propose community pool spend
// Test cases based on tests/integration/testdata/gov/governance/create_community_pool_spend_proposal.txtar
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
	proposeCommunityPoolSpendMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)

	governance.Reconfigure(cross, 0, 604800, 0, 50, 0, 86400, 2592000)

	gns.Approve(cross, govStakerAddr, maxInt64)
	govstaker.Delegate(cross, adminAddr, int64(1000000000), "")

	testing.SkipHeights(5)
}

func proposeCommunityPoolSpendMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Propose Community Pool Spend", func() {
		governance.ProposeCommunityPoolSpend(cross, "Test Proposal", "This is a test proposal", adminAddr, "gno.land/r/gnoswap/gns", int64(100))
	})
}
