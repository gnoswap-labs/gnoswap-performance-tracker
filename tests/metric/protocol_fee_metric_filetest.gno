// PKGPATH: gno.land/r/demo/main
package main

import (
	"strconv"
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
	SetDevOpsPctMetric()
	AddToProtocolFeeMetric()
	DistributeProtocolFeeMetric()
	GetAmountOfTokenMetric()
	AddToProtocolFeeByTokenCount()
}

func SetDevOpsPctMetric() {
	resetBalances()
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("SetDevOpsPct", func() {
		pf.SetDevOpsPct(cross, 0)
	})
}

func AddToProtocolFeeMetric() {
	resetBalances()
	testing.SetRealm(adminRealm)
	pf.SetDevOpsPct(cross, 0)
	bar.Transfer(cross, protocolFeeAddr, 1000)

	testing.SetRealm(stakerRealm)
	metric.PrintMetricsBy("AddToProtocolFee", func() {
		pf.AddToProtocolFee(cross, barPath, 1000)
	})
}

func DistributeProtocolFeeMetric() {
	resetBalances()
	testing.SetRealm(adminRealm)
	pf.SetDevOpsPct(cross, 0)
	bar.Transfer(cross, protocolFeeAddr, 1000)

	testing.SetRealm(stakerRealm)
	pf.AddToProtocolFee(cross, barPath, 1000)

	testing.SetRealm(govStakerRealm)
	metric.PrintMetricsBy("DistributeProtocolFee", func() {
		pf.DistributeProtocolFee(cross)
	})
}

func GetAmountOfTokenMetric() {
	testing.SetRealm(protocolFeeRealm)
	metric.PrintMetricsBy("GetAmountOfToken", func() {
	    pf.GetAmountOfToken(barPath)
	})
}

func AddToProtocolFeeByTokenCount() {
	counts := []int{1, 5, 10, 50, 100, 300, 500, 1000}
	for _, count := range counts {
		AddToProtocolFeeWithPrefill(count)
	}
}

func AddToProtocolFeeWithPrefill(count int) {
	resetBalances()
	testing.SetRealm(adminRealm)
	pf.SetDevOpsPct(cross, 0)
	bar.Transfer(cross, protocolFeeAddr, 1000)

	testing.SetRealm(stakerRealm)
	prefillTokenList(count)

	metric.PrintMetricsBy(metricName("AddToProtocolFee-existing", count), func() {
		pf.AddToProtocolFee(cross, tokenPathAt(0), 1)
	})
	metric.PrintMetricsBy(metricName("AddToProtocolFee-new", count), func() {
		pf.AddToProtocolFee(cross, tokenPathAt(count), 1)
	})
}

func prefillTokenList(count int) {
	for i := 0; i < count; i++ {
		pf.AddToProtocolFee(cross, tokenPathAt(i), 1)
	}
}

func tokenPathAt(index int) string {
	return barPath + "/n" + strconv.Itoa(index)
}

func metricName(prefix string, count int) string {
	return prefix + "-" + strconv.Itoa(count)
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
	testing.SetRealm(govStakerRealm)
	pf.ClearTokenListWithAmount(cross)
	testing.SetRealm(adminRealm)
}
