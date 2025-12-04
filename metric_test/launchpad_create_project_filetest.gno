// Gas and performance metrics for launchpad create project
// Test cases based on tests/integration/testdata/launchpad/create_new_launchpad_project.txtar
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/launchpad/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/onbloc/bar"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	launchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main() {
	initializeSetup()
	createLaunchpadProjectMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	bar.Approve(cross, launchpadAddr, maxInt64)
}

func createLaunchpadProjectMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Create Launchpad Project", func() {
		launchpad.CreateProject(
			cross,
			"Bar Launchpad Project",
			"gno.land/r/onbloc/bar",
			adminAddr,
			int64(1000000000),
			"gno.land/r/onbloc/bar",
			"1000000",
			int64(10),
			int64(20),
			int64(70),
			int64(9999999999), // Far future timestamp to avoid time issues
		)
	})
}
