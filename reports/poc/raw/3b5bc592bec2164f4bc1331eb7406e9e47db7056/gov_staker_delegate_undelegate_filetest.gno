// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for gov staker delegate and undelegate
// Test cases based on tests/integration/testdata/gov/staker/delegate_and_undelegate.txtar
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

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	delegateMetric(cur)
	undelegateMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)

	gns.Transfer(cross(cur), aliceAddr, 100000000)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
}

func delegateMetric(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Delegate", func() {
		govstaker.Delegate(cross(cur), aliceAddr, int64(1000000), "")
	})
}

func undelegateMetric(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Undelegate", func() {
		govstaker.Undelegate(cross(cur), aliceAddr, int64(1000000))
	})
}

// Output:
// Delegate
// - Gas Used: 4989756
// - Storage Diff: 38285
// - CPU Cycles: 1942824
// - Realm gno.land/r/gnoswap/gns: 2059
// - Realm gno.land/r/gnoswap/gov/staker: 35183
// - Realm gno.land/r/gnoswap/gov/xgns: 1043
// Undelegate
// - Gas Used: 2279200
// - Storage Diff: 840
// - CPU Cycles: 1586279
// - Realm gno.land/r/gnoswap/gov/staker: 840
