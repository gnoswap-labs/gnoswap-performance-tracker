// Performance test for collect with many withdraws
// Tests single iteration optimization when collecting many withdraw records
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

	maxInt64 int64 = 9223372036854775807
)

func main() {
	testing.SetRealm(adminRealm)

	gns.Approve(cross, govStakerAddr, maxInt64)

	// Create 100 delegations
	for i := 0; i < 100; i++ {
		govstaker.Delegate(cross, aliceAddr, int64(1000000), "")
	}

	// Undelegate all to create 100 withdraw records
	for i := 0; i < 100; i++ {
		govstaker.Undelegate(cross, aliceAddr, int64(1000000))
	}

	// Collect all 100 withdraws
	metric.PrintMetricsBy("Collect (100 withdraws, single iteration)", func() {
		govstaker.CollectUndelegatedGns(cross)
	})
}
