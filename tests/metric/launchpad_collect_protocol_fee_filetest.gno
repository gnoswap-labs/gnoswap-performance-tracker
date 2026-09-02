// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for launchpad protocol fee collection
// Test cases based on gnoswap/contract/r/scenario/launchpad/launchpad_deposit_project_single_recipient_filetest.gno
package main

import (
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc20"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
	"gno.land/r/demo/defi/grc20reg"
	"gno.land/r/gnoswap/launchpad"
	pf "gno.land/r/gnoswap/protocol_fee"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/staker"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/launchpad/v1"
	"gno.land/r/gnoswap/protocol_fee"
	_ "gno.land/r/gnoswap/protocol_fee/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/onbloc/obl"

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

	tokenCount int = 10
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	projectId := createLaunchpadProject(cur)
	depositGns(cur, projectId)

	// setup protocol fee for each token
	for index := 0; index < tokenCount; index++ {
		name := ufmt.Sprintf("Token%d", index)
		symbol := ufmt.Sprintf("TKN%d", index)
		tokenPath := ufmt.Sprintf("gno.land/r/onbloc/token%d.%s", index, symbol)
		mintAmount := int64(1000)
		addToProtocolFee(cur, tokenPath, name, symbol, mintAmount)
	}
	testing.SkipHeights(1)

	distributeProtocolFee(cur)
	testing.SkipHeights(1)

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
		"gno.land/r/onbloc/obl.OBL",
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

func addToProtocolFee(cur realm, tokenPath string, name string, symbol string, mintAmount int64) {
	testing.SetRealm(testing.NewCodeRealm(tokenPath))

	token, ledger := grc20.NewToken(name, symbol, 6, 0, cur)
	ledger.Mint(stakerAddr, mintAmount)
	grc20reg.Register(cross(cur), token, "")

	recordProtocolFees(cur, tokenPath, mintAmount)
}

func recordProtocolFees(cur realm, tokenPath string, amount int64) {
	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()

	testing.SetRealm(stakerRealm)
	common.SafeGRC20Approve(0, cur, tokenPath, protocolFeeAddr, amount)
	common.SafeGRC20Approve(0, cur, tokenPath, protocolFeeV1Addr, amount)
	pf.AddToProtocolFee(cross(cur), tokenPath, amount)
}

func distributeProtocolFee(cur realm) {
	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross(cur))
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

func collectProtocolFeeMetric(cur realm) {
	testing.SetRealm(projectRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("Launchpad CollectProtocolFee (tokens: %d)", tokenCount), func() {
		launchpad.CollectProtocolFee(cross(cur))
	})
}
