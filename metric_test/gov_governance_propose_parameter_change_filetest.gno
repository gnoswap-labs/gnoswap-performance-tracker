// Gas and performance metrics for governance propose parameter change
// Test cases based on tests/integration/testdata/gov/governance/create_parameter_change_proposal.txtar
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/governance/v1"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/pool/v1"

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
	proposeParameterChangeMetric()
	voteMetric()
	executeMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)

	// Set votingPeriod to 1 for quick testing
	governance.Reconfigure(cross, 0, 1, 0, 50, 0, 0, 2592000)

	gns.Approve(cross, govStakerAddr, maxInt64)
	govstaker.Delegate(cross, adminAddr, int64(1000000000), "")

	testing.SkipHeights(5)
}

func proposeParameterChangeMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Propose Parameter Change", func() {
		governance.ProposeParameterChange(
			cross,
			"poolcreationfee",
			"set",
			1,
			"gno.land/r/gnoswap/pool*EXE*SetPoolCreationFee*EXE*0",
		)
	})
}

func voteMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Vote", func() {
		governance.Vote(cross, 1, true)
	})
}

func executeMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Execute", func() {
		governance.Execute(cross, 1)
	})
}
