// Benchmark: CollectDepositGns storage cost vs accumulated deposits
// Measures whether cumulative state (string length / map size) affects storage diff
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

const blockTimeSeconds int64 = 5

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

func main() {
	initializeSetup()
	projectId := createLaunchpadProject()

	// Create multiple deposits to accumulate state
	numDeposits := 5
	depositIds := make([]string, numDeposits)
	for i := 0; i < numDeposits; i++ {
		depositIds[i] = depositGns(projectId, int64(1_000_000*(i+1)))
		testing.SkipHeights(100) // advance between deposits
	}

	// Skip to project end so all deposits are collectible
	skipToProjectEnd()

	// Collect each deposit and measure individually
	// As earlier deposits are collected, accumulated state changes
	for i := 0; i < numDeposits; i++ {
		collectDepositGnsMetric(depositIds[i], i+1, numDeposits)
	}
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	obl.Approve(cross, launchpadAddr, maxInt64)
}

func createLaunchpadProject() string {
	testing.SetRealm(adminRealm)

	projectId := launchpad.CreateProject(
		cross,
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
	testing.SkipHeights(604800 / blockTimeSeconds)

	return projectId
}

func depositGns(projectId string, amount int64) string {
	projectTierId := projectId + ":30"

	testing.SetRealm(adminRealm)
	gns.Transfer(cross, aliceAddr, amount)

	testing.SetRealm(aliceRealm)
	gns.Approve(cross, launchpadAddr, amount)
	depositId := launchpad.DepositGns(cross, projectTierId, amount, "")

	return depositId
}

func skipToProjectEnd() {
	projectDurationSeconds := int64(30 * 24 * 60 * 60)
	testing.SkipHeights(projectDurationSeconds/blockTimeSeconds + 1)
}

func collectDepositGnsMetric(depositId string, nth int, total int) {
	testing.SetRealm(aliceRealm)

	label := "CollectDepositGns (deposit " + itoa(nth) + "/" + itoa(total) + ", remaining " + itoa(total-nth) + ")"
	metric.PrintMetricsBy(label, func() {
		_, _ = launchpad.CollectDepositGns(cross, depositId)
	})
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	s := ""
	for n > 0 {
		s = string(rune('0'+n%10)) + s
		n /= 10
	}
	return s
}
