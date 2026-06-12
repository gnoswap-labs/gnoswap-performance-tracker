// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for gov staker redelegate
// Test cases based on tests/integration/testdata/gov/staker/delegate_and_redelegate.txtar
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
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

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	delegateSetup(cur)

	redelegateMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)

	gns.Transfer(cross(cur), aliceAddr, 100000000)
	gns.Transfer(cross(cur), bobAddr, 100000000)

	gns.Approve(cross(cur), govStakerAddr, maxInt64)
}

func delegateSetup(cur realm) {
	testing.SetRealm(adminRealm)

	govstaker.Delegate(cross(cur), aliceAddr, int64(1000000), "")
}

func redelegateMetric(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Redelegate", func() {
		govstaker.Redelegate(cross(cur), aliceAddr, bobAddr, int64(1000000))
	})
}

// Output:
// Redelegate
// - Gas Used: 6389589
// - Storage Diff: 1423
// - CPU Cycles: 4702160
