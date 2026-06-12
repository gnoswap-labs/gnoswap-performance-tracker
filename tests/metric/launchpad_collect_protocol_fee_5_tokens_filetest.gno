// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for launchpad protocol fee collection with 5 protocol fee tokens
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
	"gno.land/r/gnoswap/protocol_fee"
	_ "gno.land/r/gnoswap/protocol_fee/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/foo"
	"gno.land/r/onbloc/obl"
	"gno.land/r/onbloc/qux"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	launchpadAddr, _   = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())
	stakerAddr, _      = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm        = testing.NewUserRealm(stakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())
	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	projectAddr  = testutils.TestAddress("project-owner")
	projectRealm = testing.NewUserRealm(projectAddr)

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	projectId := createLaunchpadProject(cur)
	depositGns(cur, projectId)
	setupProtocolFee(cur)
	collectProtocolFeeMetric(cur)
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

	testing.SkipHeights(604800 / 5)
	return projectId
}

func depositGns(cur realm, projectId string) {
	projectTierId := projectId + ":30"
	depositAmount := int64(1_000_000)

	testing.SetRealm(adminRealm)
	gns.Transfer(cross(cur), aliceAddr, depositAmount)

	testing.SetRealm(aliceRealm)
	gns.Approve(cross(cur), launchpadAddr, depositAmount)
	launchpad.DepositGns(cross(cur), projectTierId, depositAmount, "")

	testing.SkipHeights(1)
}

func setupProtocolFee(cur realm) {
	testing.SetRealm(adminRealm)
	bar.Transfer(cross(cur), stakerAddr, 1000)
	qux.Transfer(cross(cur), stakerAddr, 2500)
	foo.Transfer(cross(cur), stakerAddr, 1500)
	baz.Transfer(cross(cur), stakerAddr, 2000)
	obl.Transfer(cross(cur), stakerAddr, 3000)

	testing.SetRealm(stakerRealm)
	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()
	bar.Approve(cross(cur), protocolFeeAddr, 1000)
	bar.Approve(cross(cur), protocolFeeV1Addr, 1000)
	qux.Approve(cross(cur), protocolFeeAddr, 2500)
	qux.Approve(cross(cur), protocolFeeV1Addr, 2500)
	foo.Approve(cross(cur), protocolFeeAddr, 1500)
	foo.Approve(cross(cur), protocolFeeV1Addr, 1500)
	baz.Approve(cross(cur), protocolFeeAddr, 2000)
	baz.Approve(cross(cur), protocolFeeV1Addr, 2000)
	obl.Approve(cross(cur), protocolFeeAddr, 3000)
	obl.Approve(cross(cur), protocolFeeV1Addr, 3000)
	protocol_fee.AddToProtocolFee(cross(cur), "gno.land/r/onbloc/bar", 1000)
	protocol_fee.AddToProtocolFee(cross(cur), "gno.land/r/onbloc/qux", 2500)
	protocol_fee.AddToProtocolFee(cross(cur), "gno.land/r/onbloc/foo", 1500)
	protocol_fee.AddToProtocolFee(cross(cur), "gno.land/r/onbloc/baz", 2000)
	protocol_fee.AddToProtocolFee(cross(cur), "gno.land/r/onbloc/obl", 3000)

	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross(cur))
}

func collectProtocolFeeMetric(cur realm) {
	testing.SetRealm(projectRealm)

	metric.PrintMetricsBy("CollectProtocolFee (5 tokens)", func() {
		launchpad.CollectProtocolFee(cross(cur))
	})
}
