// Gas and performance metrics for launchpad protocol fee collection
// Test cases based on gnoswap/contract/r/scenario/launchpad/launchpad_deposit_project_single_recipient_filetest.gno
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/staker"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	"gno.land/r/gnoswap/protocol_fee"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/launchpad/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/obl"
	"gno.land/r/onbloc/qux"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	launchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())
	stakerAddr, _    = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm      = testing.NewUserRealm(stakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())
	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	projectAddr = testutils.TestAddress("project-owner")
	projectRealm = testing.NewUserRealm(projectAddr)

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main() {
	initializeSetup()
	projectId := createLaunchpadProject()
	depositGns(projectId)
	setupProtocolFee(1000, 2500)
	collectProtocolFeeMetric()
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
		time.Now().Unix()+3600,
	)

	// Activate project.
	testing.SkipHeights(3600 / 5)

	return projectId
}

func depositGns(projectId string) {
	projectTierId := projectId + ":30"
	depositAmount := int64(1_000_000)

	testing.SetRealm(adminRealm)
	gns.Transfer(cross, aliceAddr, depositAmount)

	testing.SetRealm(aliceRealm)
	gns.Approve(cross, launchpadAddr, depositAmount)
	launchpad.DepositGns(cross, projectTierId, depositAmount, "")

	testing.SkipHeights(1)
}

func setupProtocolFee(barAmount, quxAmount int64) {
	testing.SetRealm(adminRealm)
	bar.Transfer(cross, protocolFeeAddr, barAmount)
	qux.Transfer(cross, protocolFeeAddr, quxAmount)

	testing.SetRealm(stakerRealm)
	protocol_fee.AddToProtocolFee(cross, "gno.land/r/onbloc/bar", barAmount)
	protocol_fee.AddToProtocolFee(cross, "gno.land/r/onbloc/qux", quxAmount)

	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross)
}

func collectProtocolFeeMetric() {
	testing.SetRealm(projectRealm)

	metric.PrintMetricsBy("Launchpad CollectProtocolFee", func() {
		launchpad.CollectProtocolFee(cross)
	})
}
