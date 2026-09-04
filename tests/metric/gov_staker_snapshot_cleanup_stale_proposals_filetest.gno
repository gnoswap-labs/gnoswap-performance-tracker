// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Measures administrative delegation-snapshot cleanup after text proposals
// have become terminal without cancellation or execution.
package main

import (
	"testing"

	prbac "gno.land/p/gnoswap/rbac"
	ufmt "gno.land/p/nt/ufmt/v0"
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

const staleProposalCount = 1000

var (
	adminAddr, _ = access.GetAddress(prbac.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _ = access.GetAddress(prbac.ROLE_GOV_STAKER.String())
)

func main(cur realm) {
	setup(cur)
	createTerminalTextProposals(cur, staleProposalCount)

	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy(ufmt.Sprintf("Clean delegation snapshots (%d stale proposals)", staleProposalCount), func() {
		// Zero is an eligible cutoff because the benchmark config has no
		// voting-weight smoothing period.
		govstaker.CleanStakerDelegationSnapshotByAdmin(cross(cur), 0, adminAddr)
	})
}

func setup(cur realm) {
	testing.SetRealm(adminRealm)
	governance.Reconfigure(cross(cur), 0, 1, 0, 50, 0, 0, 1)
	gns.Approve(cross(cur), govStakerAddr, 1_000_000_000)
	govstaker.Delegate(cross(cur), adminAddr, 1_000_000_000, "")
	testing.SkipHeights(1)
}

func createTerminalTextProposals(cur realm, count int) {
	testing.SetRealm(adminRealm)
	for i := 0; i < count; i++ {
		governance.ProposeText(cross(cur), "terminal", "terminal proposal for cleanup gas measurement")
		// The configured one-second voting period ends before the next proposal.
		testing.SkipHeights(1)
	}
}
