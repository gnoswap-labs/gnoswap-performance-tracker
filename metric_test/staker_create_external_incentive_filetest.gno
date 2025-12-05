// Gas and performance metrics for staker create external incentive
// Test cases based on tests/integration/testdata/staker/staker_create_external_incentive.txtar
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
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

func main() {
	initializeSetup()
	createBarFooPool()

	mintPositionMetric()
	createExternalIncentiveMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	bar.Transfer(cross, aliceAddr, 2000000000)
	foo.Transfer(cross, aliceAddr, 2000000000)
	gns.Transfer(cross, aliceAddr, 2000000000)

	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)

	testing.SetRealm(aliceRealm)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)
	gns.Approve(cross, stakerAddr, maxInt64)
}

func createBarFooPool() {
	testing.SetRealm(adminRealm)

	pool.CreatePool(cross, barPath, fooPath, 100, "70710695859404174631")
}

func mintPositionMetric() {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)

	position.Mint(cross, barPath, fooPath, 100, -1, 1, "5000000", "5000000", "0", "0", time.Now().Unix()+3600, aliceAddr, aliceAddr, "")
}

func createExternalIncentiveMetric() {
	testing.SetRealm(aliceRealm)

	poolPath := barPath + ":" + fooPath + ":100"

	// Use timestamp at midnight (86400 * 100000 = 8640000000)
	// Duration must be 90, 180, or 365 days
	startTime := int64(8640000000)
	endTime := startTime + (86400 * 90) // 90 days

	metric.PrintMetricsBy("CreateExternalIncentive", func() {
		staker.CreateExternalIncentive(
			cross,
			poolPath,
			barPath,
			int64(1000000000),
			startTime,
			endTime,
		)
	})
}
