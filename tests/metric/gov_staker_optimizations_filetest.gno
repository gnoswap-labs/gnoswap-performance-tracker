// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Performance metrics for gov staker optimizations
// Tests various delegation and collection scenarios
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
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

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	bobAddr  = testutils.TestAddress("bob")
	bobRealm = testing.NewUserRealm(bobAddr)

	carolAddr  = testutils.TestAddress("carol")
	carolRealm = testing.NewUserRealm(carolAddr)

	daveAddr  = testutils.TestAddress("dave")
	daveRealm = testing.NewUserRealm(daveAddr)

	eveAddr  = testutils.TestAddress("eve")
	eveRealm = testing.NewUserRealm(eveAddr)

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)

	multipleDelegationsUndelegateMetric(cur)
	singleDelegateMetric(cur)
	earlyExitUndelegateMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)

	// Give tokens to all test users
	gns.Transfer(cross(cur), aliceAddr, 1000000000)
	gns.Transfer(cross(cur), bobAddr, 1000000000)
	gns.Transfer(cross(cur), carolAddr, 1000000000)
	gns.Transfer(cross(cur), daveAddr, 1000000000)
	gns.Transfer(cross(cur), eveAddr, 1000000000)

	// Approve gov staker
	gns.Approve(cross(cur), govStakerAddr, maxInt64)

	testing.SetRealm(aliceRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)

	testing.SetRealm(bobRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)

	testing.SetRealm(carolRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)

	testing.SetRealm(daveRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)

	testing.SetRealm(eveRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
}

// Undelegate with 5 delegations to same delegatee
// Tests external call caching optimization
func multipleDelegationsUndelegateMetric(cur realm) {
	testing.SetRealm(adminRealm)

	// Create 5 separate delegations to alice
	govstaker.Delegate(cross(cur), aliceAddr, int64(1000000), "")
	govstaker.Delegate(cross(cur), aliceAddr, int64(1000000), "")
	govstaker.Delegate(cross(cur), aliceAddr, int64(1000000), "")
	govstaker.Delegate(cross(cur), aliceAddr, int64(1000000), "")
	govstaker.Delegate(cross(cur), aliceAddr, int64(1000000), "")

	// Measure undelegating across all 5 delegations
	metric.PrintMetricsBy("Undelegate (5 delegations, cached external calls)", func() {
		govstaker.Undelegate(cross(cur), aliceAddr, int64(5000000))
	})
}

// Single delegate with cached external calls
func singleDelegateMetric(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("Delegate (cached external calls)", func() {
		govstaker.Delegate(cross(cur), bobAddr, int64(1000000), "")
	})
}

// Undelegate with early exit optimization
// Tests processing only necessary delegations when undelegating partial amount
func earlyExitUndelegateMetric(cur realm) {
	testing.SetRealm(adminRealm)

	// Create 10 delegations to dave (minimum 1M each)
	for i := 0; i < 10; i++ {
		govstaker.Delegate(cross(cur), daveAddr, int64(1000000), "")
	}

	// Undelegate only 3M (needs only 3 delegations)
	metric.PrintMetricsBy("Undelegate (early exit, 3 of 10 delegations)", func() {
		govstaker.Undelegate(cross(cur), daveAddr, int64(3000000))
	})
}

// Output:
// Undelegate (5 delegations, cached external calls)
// - Gas Used: 14842132
// - Storage Diff: 3510
// - CPU Cycles: 10891166
// Delegate (cached external calls)
// - Gas Used: 3902315
// - Storage Diff: 3210
// - CPU Cycles: 2961818
// Undelegate (early exit, 3 of 10 delegations)
// - Gas Used: 9744713
// - Storage Diff: 2088
// - CPU Cycles: 7250297
