// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for position reposition
// Test cases based on tests/integration/testdata/position/reposition.txtar
package main

import (
	"gno.land/p/gnoswap/gnsmath"
	"testing"

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

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _ = access.GetAddress(prabc.ROLE_POOL.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath = "gno.land/r/onbloc/bar"
	fooPath = "gno.land/r/onbloc/foo"

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createPool500(cur)
	mintInitialPosition(cur)

	decreaseAndRemovePositionMetric(cur)
	mintNewPositionMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	bar.Transfer(cross(cur), aliceAddr, 100000000)
	foo.Transfer(cross(cur), aliceAddr, 100000000)

	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
}

func createPool500(cur realm) {
	testing.SetRealm(adminRealm)

	pool.CreatePool(
		cross(cur),
		barPath,
		fooPath,
		500,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func mintInitialPosition(cur realm) {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)

	position.Mint(
		cross(cur),
		barPath,
		fooPath,
		500,
		-1000,
		1000,
		"50000000",
		"50000000",
		"0",
		"0",
		9999999999,
		aliceAddr,
		"",
	)
}

func decreaseAndRemovePositionMetric(cur realm) {
	testing.SetRealm(aliceRealm)

	metric.PrintMetricsBy("DecreaseLiquidity (w. Remove)", func() {
		position.DecreaseLiquidity(
			cross(cur),
			1,
			"100",
			"0",
			"0",
			9999999999,
		)
	})
}

func mintNewPositionMetric(cur realm) {
	testing.SetRealm(aliceRealm)

	metric.PrintMetricsBy("Mint (reposition)", func() {
		position.Mint(
			cross(cur),
			barPath,
			fooPath,
			500,
			-2000,
			2000,
			"30000000",
			"30000000",
			"0",
			"0",
			9999999999,
			aliceAddr,
			"",
		)
	})
}

// Output:
// DecreaseLiquidity (w. Remove)
// - Gas Used: 21163551
// - Storage Diff: 72
// - CPU Cycles: 18373912
// Mint (reposition)
// - Gas Used: 25702013
// - Storage Diff: 8623
// - CPU Cycles: 23186146
