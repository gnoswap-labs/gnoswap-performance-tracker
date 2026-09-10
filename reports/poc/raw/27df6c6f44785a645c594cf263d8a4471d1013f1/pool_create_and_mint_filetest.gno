// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for pool create and mint scenario
// Test cases based on tests/integration/testdata/pool/create_pool_and_mint.txtar
package main

import (
	"chain"
	"gno.land/p/gnoswap/gnsmath"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"

	"gno.land/r/gnoland/wugnot"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _ = access.GetAddress(prabc.ROLE_POOL.String())

	wugnotPath = "gno.land/r/gnoland/wugnot.wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns.GNS"

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	wugnot.Deposit(cross(cur))
	testing.SetOriginSend(chain.Coins{})

	createPoolMetric(cur)
	mintPositionMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})

	gns.Approve(cross(cur), poolAddr, maxInt64)
	wugnot.Approve(cross(cur), poolAddr, maxInt64)
}

func createPoolMetric(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("CreatePool", func() {
		pool.CreatePool(
			cross(cur),
			wugnotPath,
			gnsPath,
			3000,
			gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
		)
	})
}

func mintPositionMetric(cur realm) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Mint (fee:3000, wide range)", func() {
		position.Mint(
			cross(cur),
			gnsPath,
			wugnotPath,
			3000,
			-887220,
			887220,
			"50000000",
			"50000000",
			"1",
			"1",
			9999999999,
			adminAddr,
			"",
		)
	})
}

// Output:
// CreatePool
// - Gas Used: 6718031
// - Storage Diff: 25361
// - CPU Cycles: 5871037
// - Realm gno.land/r/gnoswap/pool: 24669
// - Realm gno.land/r/gnoswap/pool/v1: 692
// Mint (fee:3000, wide range)
// - Gas Used: 31555821
// - Storage Diff: 22702
// - CPU Cycles: 29304202
// - Realm gno.land/r/gnoland/wugnot: 2029
// - Realm gno.land/r/gnoswap/gnft: 3170
// - Realm gno.land/r/gnoswap/gns: 2056
// - Realm gno.land/r/gnoswap/pool: 11169
// - Realm gno.land/r/gnoswap/pool/v1: 6
// - Realm gno.land/r/gnoswap/position: 4272
