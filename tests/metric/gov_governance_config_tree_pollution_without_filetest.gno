// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Control scenario (0 entries) for
// gov_governance_config_tree_pollution_with_1000_filetest.gno and
// gov_governance_config_tree_pollution_with_10000_filetest.gno. Identical
// flow, minus the NewConfigTree pollution step. Compare the "Propose Text"
// metrics across all three files to see whether unauthorized pollution of
// governance.NewConfigTree()'s returned tree has any effect on the cost of
// governance's own legitimate writes.
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

func main(cur realm) {
	initializeSetup(cur)

	// (no pollution step here)

	// 3. measured governance write, no pollution
	// NOTE: title/description text must be byte-identical to the "with"
	// scenario, otherwise gas/storage differences from string length would
	// be mistaken for an effect of the pollution step.
	metric.PrintMetricsBy("Propose Text (no pollution)", func() {
		governance.ProposeText(cross(cur), "Test Proposal", "This is a test proposal")
	})
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)

	// 1. baseline config write (unmeasured warmup)
	governance.Reconfigure(cross(cur), 0, 604800, 0, 50, 0, 86400, 2592000)

	gns.Approve(cross(cur), govStakerAddr, maxInt64)
	govstaker.Delegate(cross(cur), adminAddr, int64(1000000000), "")

	testing.SkipHeights(5)
}

// Output:
