// Gas and performance metrics for stress test with random positions
// Creates 100 positions with random tick ranges (generated from fuzzing test patterns)
package main

import (
	"chain"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/ufmt"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/router/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/router"

	"gno.land/r/gnoland/wugnot"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	routerAddr, _ = access.GetAddress(prabc.ROLE_ROUTER.String())

	wugnotPath = "gno.land/r/gnoland/wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns"

	maxInt64 int64 = 9223372036854775807
)

// Random positions generated from fuzzing test patterns (seed: 42)
// Mix of: below current tick, spanning current tick, above current tick
var randomPositions = []struct {
	minTick int32
	maxTick int32
}{
	{109500, 134100},
	{270420, 511200},
	{-750060, -26040},
	{-222000, -39960},
	{85500, 666000},
	{-856020, 29340},
	{-672300, -443580},
	{591840, 604920},
	{195480, 834360},
	{535740, 741960},
	{-445680, -156000},
	{-91560, 854580},
	{-141300, -102060},
	{415500, 582780},
	{-734400, 211680},
	{-786780, 91200},
	{-792180, 352920},
	{-293760, 260040},
	{-169920, -57000},
	{122760, 494880},
	{-344580, -200460},
	{608040, 785820},
	{189060, 881700},
	{-842220, -192120},
	{-127320, -56160},
	{-46440, -32100},
	{-513600, -240300},
	{-262320, 820020},
	{-727380, 363960},
	{-681300, 658860},
	{-197340, 672000},
	{70200, 669060},
	{168240, 693360},
	{240660, 401340},
	{-514260, 265380},
	{676500, 813420},
	{-214260, -134520},
	{-662100, -630540},
	{-492900, 263220},
	{-679860, -122280},
	{309360, 518400},
	{490800, 685320},
	{451080, 521340},
	{-750000, 242460},
	{551880, 816840},
	{-152880, 574680},
	{-4680, 573660},
	{-531420, 215640},
	{-386340, -143760},
	{-144300, -132720},
	{-736980, -120120},
	{-108600, -24960},
	{-300960, 62460},
	{-512100, 585840},
	{-367080, 247200},
	{846240, 846960},
	{708540, 736740},
	{869820, 886320},
	{-131700, 630120},
	{-777600, 288540},
	{-731760, 446040},
	{-177420, -540},
	{-395160, 749040},
	{-388200, -335880},
	{293400, 792480},
	{195540, 345840},
	{-137700, 158820},
	{765480, 878880},
	{600, 589440},
	{-406920, 19200},
	{-530400, -228060},
	{-830280, -593460},
	{77460, 161700},
	{477780, 878880},
	{-139560, -8640},
	{-761040, -112440},
	{-346800, 162360},
	{-368520, 857640},
	{415980, 520140},
	{742500, 791940},
	{306480, 698760},
	{638880, 822480},
	{-2880, 508800},
	{-768300, 243720},
	{-824280, -491880},
	{-308940, -36660},
	{-308760, -200460},
	{-817440, -121560},
	{57900, 282960},
	{-856380, -11280},
	{-817620, 505440},
	{-613500, -136260},
	{-357180, -292140},
	{867420, 885000},
	{464700, 584160},
	{-93420, 400200},
	{-794520, -699180},
	{423780, 597960},
	{-483120, 459120},
	{53280, 715260},
}

var t *testing.T

func main() {
	initializeSetup()
	createPool()
	mintRandomPositions()

	// Swap tests
	exactInSwapMetric()
	exactOutSwapMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	testing.SetRealm(adminRealm)
	wugnot.Deposit(cross)

	gns.Approve(cross, poolAddr, maxInt64)
	wugnot.Approve(cross, poolAddr, maxInt64)
	gns.Approve(cross, routerAddr, maxInt64)
	wugnot.Approve(cross, routerAddr, maxInt64)
}

func createPool() {
	testing.SetRealm(adminRealm)

	pool.CreatePool(
		cross,
		wugnotPath,
		gnsPath,
		3000,
		common.TickMathGetSqrtRatioAtTick(0).ToString(),
	)
}

func mintRandomPositions() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	for i, pos := range randomPositions {
		position.Mint(
			cross,
			wugnotPath,
			gnsPath,
			3000,
			pos.minTick,
			pos.maxTick,
			"10000000",
			"10000000",
			"0",
			"0",
			9999999999,
			adminAddr,
			adminAddr,
			"",
		)
		if i%10 == 0 {
			println(ufmt.Sprintf("minted random position %d/100", i))
		}
	}
	println("minted all 100 random positions")
}

func exactInSwapMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Stress RandomPositions ExactInSwapRoute gns->wugnot", func() {
		router.ExactInSwapRoute(
			cross,
			gnsPath,
			wugnotPath,
			"100000000",
			"gno.land/r/gnoswap/gns:gno.land/r/gnoland/wugnot:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})

	metric.PrintMetricsBy("Stress RandomPositions ExactInSwapRoute wugnot->gns", func() {
		router.ExactInSwapRoute(
			cross,
			wugnotPath,
			gnsPath,
			"100000000",
			"gno.land/r/gnoland/wugnot:gno.land/r/gnoswap/gns:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func exactOutSwapMetric() {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	metric.PrintMetricsBy("Stress RandomPositions ExactOutSwapRoute gns->wugnot", func() {
		router.ExactOutSwapRoute(
			cross,
			gnsPath,
			wugnotPath,
			"10000000",
			"gno.land/r/gnoswap/gns:gno.land/r/gnoland/wugnot:3000",
			"100",
			"100000000",
			9999999999,
			"",
		)
	})

	metric.PrintMetricsBy("Stress RandomPositions ExactOutSwapRoute wugnot->gns", func() {
		router.ExactOutSwapRoute(
			cross,
			wugnotPath,
			gnsPath,
			"10000000",
			"gno.land/r/gnoland/wugnot:gno.land/r/gnoswap/gns:3000",
			"100",
			"100000000",
			9999999999,
			"",
		)
	})
}
