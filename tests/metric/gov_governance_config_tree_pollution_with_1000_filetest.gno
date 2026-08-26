// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Measures whether unauthorized pollution of governance.NewConfigTree()'s
// returned *bptree.BPTree (see r/gnoswap/gov/governance/config.gno) has any
// measurable effect on the cost of governance's own legitimate writes.
//
// Flow (WITH pollution):
//  1. governance.Reconfigure(...)                         (unmeasured warmup)
//  2. acquire a tree via governance.NewConfigTree() (no authorization
//     required) and write 1000 attacker-controlled entries into it
//  3. governance.ProposeText(...), measured
//
// Compare against gov_governance_config_tree_pollution_without_filetest.gno
// (0 entries) and gov_governance_config_tree_pollution_with_10000_filetest.gno
// (10000 entries), which run the identical flow with a different pollution
// size. If NewConfigTree's tree were aliased with governance's real config
// storage, step 3 would diverge proportionally to the pollution size across
// all three scenarios.
package main

import (
	"strconv"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	bptree "gno.land/p/nt/bptree/v0"
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

	garbage *bptree.BPTree
)

func main(cur realm) {
	initializeSetup(cur)

	// 2. attacker pollutes governance's realm via NewConfigTree (WITH-only step)
	pollute(cur)

	// 3. measured governance write, after pollution
	// NOTE: title/description text must be byte-identical to the "without"
	// and "with_10000" scenarios, otherwise gas/storage differences from
	// string length would be mistaken for an effect of the pollution step.
	metric.PrintMetricsBy("Propose Text (after 1000-entry NewConfigTree pollution)", func() {
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

// pollute reproduces the write-authority-laundering path: no authorization
// is required to acquire and mutate the tree governance.NewConfigTree()
// returns.
func pollute(cur realm) {
	metric.PrintMetricsBy("Attacker pollution (acquire + 1000 Set)", func() {
		garbage = governance.NewConfigTree()
		for i := 0; i < 1000; i++ {
			k := "attacker-key-" + strconv.Itoa(i)
			garbage.Set(k, k)
		}
	})
}

// Output:
