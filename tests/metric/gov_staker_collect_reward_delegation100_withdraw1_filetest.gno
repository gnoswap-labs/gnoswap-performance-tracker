package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	"gno.land/p/nt/ufmt"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	govstaker "gno.land/r/gnoswap/gov/staker"
	"gno.land/r/gnoswap/protocol_fee"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)
	stakerAddr, _      = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm        = testing.NewUserRealm(stakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())

	aliceAddr = testutils.TestAddress("alice")

	maxInt64 int64 = 9223372036854775807

	delegateCount   int64 = 100
	undelegateCount int64 = 100

	undelegateAmount int64 = 1000000
	delegateAmount   int64 = undelegateAmount * (undelegateCount / delegateCount)
)

func main() {
	initializeSetup()

	delegateTokens()
	setupProtocolFee()

	testing.SkipHeights(1)
	collectRewardMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	gns.Approve(cross, govStakerAddr, maxInt64)
}

func delegateTokens() {
	testing.SetRealm(adminRealm)
	for i := int64(0); i < delegateCount; i++ {
		govstaker.Delegate(cross, aliceAddr, delegateAmount, "")
		testing.SkipHeights(1)
	}
}

func setupProtocolFee() {
	testing.SetRealm(adminRealm)
	gns.Transfer(cross, protocolFeeAddr, 1000000)

	testing.SetRealm(stakerRealm)
	protocol_fee.AddToProtocolFee(cross, "gno.land/r/gnoswap/gns", 1000000)

	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross)
}

func collectRewardMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectReward (%d delegations, %d withdraws)", delegateCount, undelegateCount/delegateCount), func() {
		govstaker.CollectReward(cross)
	})
}
