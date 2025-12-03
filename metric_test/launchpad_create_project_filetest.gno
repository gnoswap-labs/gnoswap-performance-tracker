// Gas and performance metrics for launchpad create project
// Test cases based on tests/integration/testdata/launchpad/create_new_launchpad_project.txtar
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/launchpad/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/launchpad"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)
)

var t *testing.T

func main() {
	createLaunchpadProjectMetric()
}

func createLaunchpadProjectMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("CreateProject", func() {
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
			time.Now().Unix()+100,
		)
	})
}
