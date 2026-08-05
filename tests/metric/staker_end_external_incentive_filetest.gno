// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for staker end external incentive
// Test cases based on tests/integration/testdata/staker/end_non_existent_external_incentive_fail.txtar
package main

import (
	"gno.land/p/gnoswap/gnsmath"
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/gns"
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

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath = "gno.land/r/onbloc/bar.BAR"
	fooPath = "gno.land/r/onbloc/foo.FOO"

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createPoolMetric(cur)
	mintPositionMetric(cur)
	createExternalIncentiveMetric(cur)
	endExternalIncentiveMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	bar.Transfer(cross(cur), aliceAddr, 100000000)
	foo.Transfer(cross(cur), aliceAddr, 100000000)

	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
}

func createPoolMetric(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, 100, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
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
		"1",
		"1",
		time.Now().Unix()+3600,
		aliceAddr,
		"",
	)
}

func createExternalIncentiveMetric(cur realm) {
	testing.SetRealm(adminRealm)
	bar.Transfer(cross(cur), aliceAddr, 1000000000)
	gns.Transfer(cross(cur), aliceAddr, 1000000000)

	testing.SetRealm(aliceRealm)

	poolPath := barPath + ":" + fooPath + ":100"

	bar.Approve(cross(cur), stakerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64)

	staker.CreateExternalIncentive(
		cross(cur),
		poolPath,
		barPath,
		int64(1000000000),
		1234569600,
		1234569600+60*60*24*90,
	)
}

func endExternalIncentiveMetric(cur realm) {
	testing.SetRealm(aliceRealm)

	poolPath := barPath + ":" + fooPath + ":100"

	incentiveID := ufmt.Sprintf("%s:%d:%d", aliceAddr, time.Now().Unix(), 1)

	testing.SkipHeights(1234569600 + 60*60*24*90/5)

	metric.PrintMetricsBy("EndExternalIncentive", func() {
		staker.EndExternalIncentive(cross(cur), poolPath, incentiveID, aliceAddr)
	})
}
