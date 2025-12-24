// Performance test for redelegate with many delegations
// Tests getUserDelegationsWithDelegatee optimization with large delegation set
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	govstaker "gno.land/r/gnoswap/gov/staker"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _ = access.GetAddress(prabc.ROLE_GOV_STAKER.String())

	aliceAddr = testutils.TestAddress("alice")
	bobAddr   = testutils.TestAddress("bob")

	maxInt64 int64 = 9223372036854775807
)

func main() {
	testing.SetRealm(adminRealm)

	gns.Approve(cross, govStakerAddr, maxInt64)

	// Create 100 delegations to same delegatee (alice)
	for i := 0; i < 100; i++ {
		govstaker.Delegate(cross, aliceAddr, int64(1000000), "")
	}

	// Redelegate 50M to bob - processes 50 of 100 delegations
	metric.PrintMetricsBy("Redelegate (50 of 100 delegations, optimized)", func() {
		govstaker.Redelegate(cross, aliceAddr, bobAddr, int64(50000000))
	})
}
