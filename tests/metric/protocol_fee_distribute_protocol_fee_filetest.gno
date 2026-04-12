// Gas and performance metrics for protocol fee distribution (bar + qux)
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
	"gno.land/r/onbloc/qux"
)

var t *testing.T

const (
	barPath = "gno.land/r/onbloc/bar"
	quxPath = "gno.land/r/onbloc/qux"
)

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
	resetBalances()
	setupTokens()
	recordProtocolFees()
	distributeProtocolFees()
}

func setupTokens() {
	testing.SetRealm(adminRealm)
	bar.Transfer(cross, protocolFeeAddr, 1000)
	qux.Transfer(cross, protocolFeeAddr, 1000)
}

func recordProtocolFees() {
	testing.SetRealm(stakerRealm)
	metric.PrintMetricsBy("AddToProtocolFee (bar)", func() {
		pf.AddToProtocolFee(cross, barPath, 1000)
	})
	metric.PrintMetricsBy("AddToProtocolFee (qux)", func() {
		pf.AddToProtocolFee(cross, quxPath, 1000)
	})
}

func distributeProtocolFees() {
	testing.SetRealm(govStakerRealm)
	metric.PrintMetricsBy("DistributeProtocolFee (bar+qux)", func() {
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

	if balance := qux.BalanceOf(protocolFeeAddr); balance > 0 {
		testing.SetRealm(protocolFeeRealm)
		qux.Transfer(cross, adminAddr, balance)
	}
	if balance := qux.BalanceOf(devOpsAddr); balance > 0 {
		testing.SetRealm(testing.NewUserRealm(devOpsAddr))
		qux.Transfer(cross, adminAddr, balance)
	}
	if balance := qux.BalanceOf(govStakerAddr); balance > 0 {
		testing.SetRealm(testing.NewUserRealm(govStakerAddr))
		qux.Transfer(cross, adminAddr, balance)
	}
}
