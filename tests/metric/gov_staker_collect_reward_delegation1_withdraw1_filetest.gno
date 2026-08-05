// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
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

	delegateCount   int64 = 1
	undelegateCount int64 = 1

	undelegateAmount int64 = 1000000
	delegateAmount   int64 = undelegateAmount * undelegateCount
)

func main(cur realm) {
	initializeSetup(cur)

	delegateTokens(cur)
	setupProtocolFee(cur)

	testing.SkipHeights(1)
	collectRewardMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
}

func delegateTokens(cur realm) {
	testing.SetRealm(adminRealm)
	for i := int64(0); i < delegateCount; i++ {
		govstaker.Delegate(cross(cur), aliceAddr, delegateAmount, "")
		testing.SkipHeights(1)
	}
}

func setupProtocolFee(cur realm) {
	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()

	testing.SetRealm(adminRealm)
	gns.Transfer(cross(cur), stakerAddr, 1000000)

	testing.SetRealm(stakerRealm)
	gns.Approve(cross(cur), protocolFeeAddr, 1000000)
	gns.Approve(cross(cur), protocolFeeV1Addr, 1000000)
	protocol_fee.AddToProtocolFee(cross(cur), "gno.land/r/gnoswap/gns", 1000000)

	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross(cur))
}

func collectRewardMetric(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectReward (%d delegation, %d withdraws)", delegateCount, undelegateCount/delegateCount), func() {
		govstaker.CollectReward(cross(cur))
	})
}
