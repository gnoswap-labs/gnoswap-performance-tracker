// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for staker create external incentive
// Test cases based on tests/integration/testdata/staker/staker_create_external_incentive.txtar
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/staker"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"

	"gno.land/r/gnoswap/gns"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath = "gno.land/r/onbloc/bar"
	fooPath = "gno.land/r/onbloc/foo"

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createBarFooPool(cur)

	mintPositionMetric(cur)
	createExternalIncentiveMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	bar.Transfer(cross(cur), aliceAddr, 2000000000)
	foo.Transfer(cross(cur), aliceAddr, 2000000000)
	gns.Transfer(cross(cur), aliceAddr, 2000000000)

	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)

	testing.SetRealm(aliceRealm)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64)
}

func createBarFooPool(cur realm) {
	testing.SetRealm(adminRealm)

	pool.CreatePool(cross(cur), barPath, fooPath, 100, "70710695859404174631")
}

func mintPositionMetric(cur realm) {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)

	position.Mint(
		cross(cur),
		barPath,
		fooPath,
		100,
		-1,
		1,
		"5000000",
		"5000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		aliceAddr,
		"",
	)
}

func createExternalIncentiveMetric(cur realm) {
	testing.SetRealm(aliceRealm)

	poolPath := barPath + ":" + fooPath + ":100"

	// Use timestamp at midnight (86400 * 100000 = 8640000000)
	// Duration must be 90, 180, or 365 days
	startTime := int64(8640000000)
	endTime := startTime + (86400 * 90) // 90 days

	metric.PrintMetricsBy("CreateExternalIncentive", func() {
		staker.CreateExternalIncentive(
			cross(cur),
			poolPath,
			barPath,
			int64(1000000000),
			startTime,
			endTime,
		)
	})
}

// Output:
// CreateExternalIncentive
// - Gas Used: 6910203
// - Storage Diff: 71222
// - CPU Cycles: 4444327
