// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
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

	delegateCount   int64 = 1
	undelegateCount int64 = 50

	undelegateAmount int64 = 1000000
	delegateAmount   int64 = undelegateAmount * undelegateCount
)

func main(cur realm) {
	testing.SetRealm(adminRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)

	for i := int64(0); i < delegateCount; i++ {
		govstaker.Delegate(cross(cur), aliceAddr, delegateAmount, "")
		testing.SkipHeights(1)
	}

	for i := int64(0); i < undelegateCount; i++ {
		govstaker.Undelegate(cross(cur), aliceAddr, undelegateAmount)
		testing.SkipHeights(1)
	}

	testing.SkipHeights(60 * 60 * 24 / 5)

	metric.PrintMetricsBy(ufmt.Sprintf("CollectUndelegatedGns (%d delegation, %d withdraws)", delegateCount, undelegateCount/delegateCount), func() {
		govstaker.CollectUndelegatedGns(cross(cur))
	})
}

// Output:
// CollectUndelegatedGns (1 delegation, 50 withdraws)
// - Gas Used: 1696248
// - Storage Diff: 0
// - CPU Cycles: 1414181
