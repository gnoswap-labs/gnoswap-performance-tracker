// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Measures administrative delegation-snapshot cleanup after text proposals
// have been cancelled without execution.
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

const cancelledProposalCount = 1000

var (
	adminAddr, _ = access.GetAddress(prbac.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _ = access.GetAddress(prbac.ROLE_GOV_STAKER.String())
)

func main(cur realm) {
	setup(cur)
	createCancelledTextProposals(cur, cancelledProposalCount)

	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy(ufmt.Sprintf("Clean delegation snapshots (%d cancelled proposals)", cancelledProposalCount), func() {
		// Zero is an eligible cutoff because the benchmark config has no
		// voting-weight smoothing period.
		govstaker.CleanStakerDelegationSnapshotByAdmin(cross(cur), 0, adminAddr)
	})
}

func setup(cur realm) {
	testing.SetRealm(adminRealm)
	// A large voting-start delay keeps every proposal in the "upcoming"
	// status long enough to be canceled before the benchmark loop's
	// cumulative height skips would otherwise start its voting period.
	governance.Reconfigure(cross(cur), 1_000_000, 1, 0, 50, 0, 0, 1)
	gns.Approve(cross(cur), govStakerAddr, 1_000_000_000)
	govstaker.Delegate(cross(cur), adminAddr, 1_000_000_000, "")
	testing.SkipHeights(1)
}

func createCancelledTextProposals(cur realm, count int) {
	testing.SetRealm(adminRealm)
	for i := 0; i < count; i++ {
		proposalID := governance.ProposeCommunityPoolSpend(
			cross(cur),
			"cancelled",
			"cancelled proposal for cleanup gas measurement",
			adminAddr,
			"gno.land/r/gnoswap/gns.GNS",
			100,
		)
		// Cancel while the proposal is still upcoming (voting has not
		// started), which is the only state Cancel allows.
		governance.Cancel(cross(cur), proposalID)
		testing.SkipHeights(1)
	}
}

// Output:
