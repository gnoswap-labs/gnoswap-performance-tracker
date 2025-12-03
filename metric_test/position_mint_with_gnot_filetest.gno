// Gas and performance metrics for position mint with native GNOT
// Test cases based on tests/integration/testdata/position/position_mint_with_gnot.txtar
package main

import (
	"chain"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _ = access.GetAddress(prabc.ROLE_POOL.String())

	wugnotPath = "gno.land/r/gnoland/wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns"

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main() {
	initializeSetup()

	createPoolMetric()
	mintPositionWithGnotMetric()
	increaseLiquidityMetric()
	decreaseLiquidityMetric()
	collectFeeMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})

	gns.Approve(cross, poolAddr, maxInt64)
}

func createPoolMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("CreatePool (wugnot:gns:3000)", func() {
		pool.CreatePool(
			cross,
			wugnotPath,
			gnsPath,
			3000,
			common.TickMathGetSqrtRatioAtTick(0).ToString(),
		)
	})
}

func mintPositionWithGnotMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{{"ugnot", 50000000}})

	metric.PrintMetricsBy("Mint (w. GNOT)", func() {
		position.Mint(
			cross,
			gnsPath,
			"ugnot",
			3000,
			-887220,
			887220,
			"50000000",
			"50000000",
			"1",
			"1",
			9999999999,
			adminAddr,
			adminAddr,
			"",
		)
	})
}

func increaseLiquidityMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{{"ugnot", 10000000}})

	metric.PrintMetricsBy("IncreaseLiquidity (w. GNOT)", func() {
		position.IncreaseLiquidity(
			cross,
			1,
			"10000000",
			"10000000",
			"1",
			"1",
			9999999999,
		)
	})
}

func decreaseLiquidityMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("DecreaseLiquidity (unwrap=false)", func() {
		position.DecreaseLiquidity(
			cross,
			1,
			"5000000",
			"1",
			"1",
			9999999999,
			false,
		)
	})
}

func collectFeeMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("CollectFee (with unwrap)", func() {
		position.CollectFee(
			cross,
			1,
			true,
		)
	})
}
