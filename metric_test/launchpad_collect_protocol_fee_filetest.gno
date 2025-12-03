// Gas and performance metrics for launchpad collect protocol fee
// Test cases based on tests/integration/testdata/launchpad/collect_protocol_fee_failure.txtar
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/launchpad/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/launchpad"

	"gno.land/r/onbloc/bar"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	launchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main() {
	initializeSetup()
	createProjectMetric()
	depositGnsMetric()
	collectProtocolFeeMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)

	bar.Transfer(cross, aliceAddr, 100000000)
	gns.Transfer(cross, aliceAddr, 100000000)

	bar.Approve(cross, launchpadAddr, maxInt64)
	gns.Approve(cross, launchpadAddr, maxInt64)
}

func createProjectMetric() {
	testing.SetRealm(adminRealm)

	launchpad.CreateProject(
		cross,
		"Bar Launchpad Project",
		"gno.land/r/onbloc/bar",
		adminAddr,
		int64(1000000000),
		"gno.land/r/gnoswap/gns",
		"1000000",
		int64(10),
		int64(20),
		int64(70),
		int64(0),
	)
}

func depositGnsMetric() {
	testing.SetRealm(aliceRealm)
	gns.Approve(cross, launchpadAddr, maxInt64)

	projectId := "gno.land/r/onbloc/bar:8"
	launchpad.DepositGns(cross, projectId+":30", int64(1000000), "")
}

func collectProtocolFeeMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("DecreaseLiquidity", func() {
		launchpad.CollectProtocolFee(cross)
	})
}
