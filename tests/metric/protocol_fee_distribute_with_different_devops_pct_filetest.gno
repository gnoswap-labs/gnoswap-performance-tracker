// Gas and performance metrics for protocol fee distribution with DevOps percentages
package main

// PKGPATH: gno.land/r/gnoswap/v1/main

import (
	"testing"

	prbac "gno.land/p/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	pf "gno.land/r/gnoswap/protocol_fee"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"

	"gno.land/r/onbloc/bar"
)

var t *testing.T

const barPath = "gno.land/r/onbloc/bar"

var (
	adminAddr, _       = access.GetAddress(prbac.ROLE_ADMIN.String())
	protocolFeeAddr, _ = access.GetAddress(prbac.ROLE_PROTOCOL_FEE.String())
	govStakerAddr, _   = access.GetAddress(prbac.ROLE_GOV_STAKER.String())
	devOpsAddr, _      = access.GetAddress(prbac.ROLE_DEVOPS.String())
)

var (
	adminRealm       = testing.NewUserRealm(adminAddr)
	stakerRealm      = testing.NewCodeRealm("gno.land/r/gnoswap/staker")
	govStakerRealm   = testing.NewCodeRealm("gno.land/r/gnoswap/gov/staker")
	protocolFeeRealm = testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee")
)

func main() {
	runCase("0%", 0, 0, 1000)
	runCase("25%", 2500, 250, 750)
	runCase("50%", 5000, 500, 500)
	runCase("100%", 10000, 1000, 0)
	runCase("33.33%", 3333, 333, 667)
}

func runCase(label string, devOpsPct int, expectedDevOps int64, expectedGovStaker int64) {
	resetBalances()

	testing.SetRealm(adminRealm)
	pf.SetDevOpsPct(cross, int64(devOpsPct))

	bar.Transfer(cross, protocolFeeAddr, 1000)

	testing.SetRealm(stakerRealm)
	metric.PrintMetricsBy("AddToProtocolFee ("+label+")", func() {
		pf.AddToProtocolFee(cross, barPath, 1000)
	})

	testing.SetRealm(govStakerRealm)
	metric.PrintMetricsBy("DistributeProtocolFee ("+label+")", func() {
		pf.DistributeProtocolFee(cross)
	})
}

func resetBalances() {
	if balance := bar.BalanceOf(protocolFeeAddr); balance > 0 {
		testing.SetRealm(protocolFeeRealm)
		bar.Transfer(cross, adminAddr, balance)
	}
	if balance := bar.BalanceOf(devOpsAddr); balance > 0 {
		testing.SetRealm(testing.NewUserRealm(devOpsAddr))
		bar.Transfer(cross, adminAddr, balance)
	}
	if balance := bar.BalanceOf(govStakerAddr); balance > 0 {
		testing.SetRealm(testing.NewUserRealm(govStakerAddr))
		bar.Transfer(cross, adminAddr, balance)
	}
}
