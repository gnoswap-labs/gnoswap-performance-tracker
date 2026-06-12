// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for launchpad DepositGns
// Test cases based on gnoswap/contract/r/scenario/launchpad/launchpad_deposit_gns_basic_filetest.gno
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/staker"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/launchpad/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/onbloc/obl"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	launchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	projectAddr = testutils.TestAddress("project-owner")

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	projectId := createLaunchpadProject(cur)
	depositGnsMetric(cur, projectId)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	obl.Approve(cross(cur), launchpadAddr, maxInt64)
}

func createLaunchpadProject(cur realm) string {
	testing.SetRealm(adminRealm)

	projectId := launchpad.CreateProject(
		cross(cur),
		"OBL Launchpad Project",
		"gno.land/r/onbloc/obl",
		projectAddr,
		int64(1_000_000_000),
		"",
		"",
		int64(10),
		int64(20),
		int64(70),
		time.Now().Unix()+604800,
	)

	// Activate project.
	testing.SkipHeights(604800 / 5)

	return projectId
}

func depositGnsMetric(cur realm, projectId string) {
	projectTierId := projectId + ":30"
	depositAmount := int64(1_000_000)

	testing.SetRealm(adminRealm)
	gns.Transfer(cross(cur), aliceAddr, depositAmount)

	testing.SetRealm(aliceRealm)
	gns.Approve(cross(cur), launchpadAddr, depositAmount)

	metric.PrintMetricsBy("Launchpad DepositGns", func() {
		launchpad.DepositGns(cross(cur), projectTierId, depositAmount, "")
	})
}

// Output:
// Launchpad DepositGns
// - Gas Used: 5403816
// - Storage Diff: 24234
// - CPU Cycles: 3066566
