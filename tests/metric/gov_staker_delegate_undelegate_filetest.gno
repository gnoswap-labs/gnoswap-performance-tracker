// Gas and performance metrics for gov staker delegate and undelegate
// Test cases based on tests/integration/testdata/gov/staker/delegate_and_undelegate.txtar
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

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main() {
	initializeSetup()
	delegateMetric()
	undelegateMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)

	gns.Transfer(cross, aliceAddr, 100000000)
	gns.Approve(cross, govStakerAddr, maxInt64)
}

func delegateMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Delegate", func() {
		govstaker.Delegate(cross, aliceAddr, int64(1000000), "")
	})
}

func undelegateMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Undelegate", func() {
		govstaker.Undelegate(cross, aliceAddr, int64(1000000))
	})
}
