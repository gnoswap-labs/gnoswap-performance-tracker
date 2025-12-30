package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	"gno.land/p/nt/ufmt"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	govstaker "gno.land/r/gnoswap/gov/staker"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _ = access.GetAddress(prabc.ROLE_GOV_STAKER.String())

	aliceAddr = testutils.TestAddress("alice")

	maxInt64 int64 = 9223372036854775807

	delegateCount   int64 = 10
	undelegateCount int64 = 10

	undelegateAmount int64 = 1000000
	delegateAmount   int64 = undelegateAmount * (undelegateCount / delegateCount)
)

func main() {
	testing.SetRealm(adminRealm)
	gns.Approve(cross, govStakerAddr, maxInt64)

	for i := int64(0); i < delegateCount; i++ {
		govstaker.Delegate(cross, aliceAddr, delegateAmount, "")
		testing.SkipHeights(1)
	}

	testing.SkipHeights(17280)

	for i := int64(0); i < undelegateCount; i++ {
		govstaker.Undelegate(cross, aliceAddr, undelegateAmount)
		testing.SkipHeights(1)
	}

	metric.PrintMetricsBy(ufmt.Sprintf("Collect (%d delegations, %d withdraws)", delegateCount, undelegateCount), func() {
		govstaker.CollectUndelegatedGns(cross)
	})
}
