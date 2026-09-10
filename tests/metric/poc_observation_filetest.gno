// PKGPATH: gno.land/r/demo/main

// Gas and storage metrics for a fully populated 2,048-slot oracle ring.
// The fixture grows capacity in stages, fills every slot through real swaps,
// wraps the ring, replaces old slots, and performs deep-history queries.
package main

import (
	"chain"
	"testing"

	"gno.land/p/gnoswap/gnsmath"
	ufmt "gno.land/p/nt/ufmt/v0"

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

	"gno.land/r/gnoland/wugnot"

	"gno.land/r/gnoswap/scenario/metric"
)

const (
	observationFee         uint32 = 500
	observationCardinality uint16 = 2048
	observationSwapAmount  string = "100000"
	minSqrtRatio           string = "4295128740"
	maxSqrtRatio           string = "1461446703485210103287273052203988822378723970341"
	maxInt64               int64  = 9223372036854775807
)

var (
	adminAddr, _  = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm    = testing.NewUserRealm(adminAddr)
	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	positionAddr, _ = access.GetAddress(prabc.ROLE_POSITION.String())

	wugnotPath = "gno.land/r/gnoland/wugnot.wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns.GNS"
	poolPath   = pool.GetPoolPath(wugnotPath, gnsPath, observationFee)
)

func main(cur realm) {
	initializeObservationSetup(cur)
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	wugnot.Deposit(cross(cur))
	testing.SetOriginSend(chain.Coins{})
	createObservationPool(cur)
	mintObservationPosition(cur)

	growObservationCardinality(cur, 32, "Grow observation capacity 1 to 32")
	growObservationCardinality(cur, 256, "Grow observation capacity 32 to 256")
	growObservationCardinality(cur, observationCardinality, "Grow observation capacity 256 to 2048")
	printObservationSamples("grown", []uint16{0, 1, 255, 1024, 2047})
	assertUninitializedObservation(2047)

	runObservationSwapBatch(cur, "Fill observation slots 1 to 256", 256)
	runObservationSwapBatch(cur, "Fill observation slots 257 to 1024", 768)
	runObservationSwapBatch(cur, "Fill observation slots 1025 to 2047 and wrap", 1024)
	runObservationSwapBatch(cur, "Replace 16 wrapped observation slots", 16)

	slot0 := pool.GetSlot0(poolPath)
	if slot0.ObservationCardinality() != observationCardinality {
		panic("large observation cardinality was not activated")
	}
	if slot0.ObservationIndex() != 16 {
		panic("large observation ring did not wrap to the expected index")
	}
	printObservationSamples("filled", []uint16{0, 1, 16, 17, 255, 1024, 2047})
	queryObservationHistory()
}

func initializeObservationSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})

	gns.Approve(cross(cur), poolAddr, maxInt64)
	wugnot.Approve(cross(cur), poolAddr, maxInt64)
	gns.Approve(cross(cur), positionAddr, maxInt64)
	wugnot.Approve(cross(cur), positionAddr, maxInt64)
}

func createObservationPool(cur realm) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("CreatePool observation", func() {
		pool.CreatePool(
			cross(cur),
			wugnotPath,
			gnsPath,
			observationFee,
			gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
		)
	})
}

func growObservationCardinality(cur realm, next uint16, label string) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy(label, func() {
		pool.IncreaseObservationCardinalityNext(
			cross(cur),
			wugnotPath,
			gnsPath,
			observationFee,
			next,
		)
	})
}

func mintObservationPosition(cur realm) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Mint observation position", func() {
		position.Mint(
			cross(cur),
			gnsPath,
			wugnotPath,
			observationFee,
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

func observationSwapCallback(cur realm, amount0Delta, amount1Delta int64, _ *pool.CallbackMarker) error {
	testing.SetRealm(adminRealm)
	if amount0Delta > 0 {
		common.SafeGRC20Transfer(0, cur, wugnotPath, poolAddr, amount0Delta)
	}
	if amount1Delta > 0 {
		common.SafeGRC20Transfer(0, cur, gnsPath, poolAddr, amount1Delta)
	}
	return nil
}

func runObservationSwapBatch(cur realm, label string, count int) {
	metric.PrintMetricsBy(label, func() {
		for i := 0; i < count; i++ {
			testing.SkipHeights(1)
			zeroForOne := i%2 == 0
			sqrtPriceLimitX96 := maxSqrtRatio
			if zeroForOne {
				sqrtPriceLimitX96 = minSqrtRatio
			}
			testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/router"))
			func(cur realm) {
				pool.Swap(
					cross(cur),
					wugnotPath,
					gnsPath,
					observationFee,
					adminAddr,
					zeroForOne,
					observationSwapAmount,
					sqrtPriceLimitX96,
					observationSwapCallback,
				)
			}(cross(cur))
		}
	})
}

func assertUninitializedObservation(index uint16) {
	observation, err := pool.GetObservationAt(poolPath, index)
	if err != nil {
		panic(err)
	}
	if observation.Initialized() {
		panic("grown observation slot must be uninitialized before the first write")
	}
	ufmt.Printf(
		"STATE observation uninitialized index=%d initialized=%t tick_cumulative=%d seconds_per_liquidity=%s\n",
		index,
		observation.Initialized(),
		observation.TickCumulative(),
		observation.SecondsPerLiquidityCumulativeX128(),
	)
}

func queryObservationHistory() {
	lookbacks := []uint32{5, 2560, 5120, 0}
	var (
		tickCumulatives                    []int64
		secondsPerLiquidityCumulativeX128s []string
		err                                error
	)
	metric.PrintMetricsBy("Observe large observation history", func() {
		tickCumulatives, secondsPerLiquidityCumulativeX128s, err = pool.Observe(poolPath, lookbacks)
	})
	if err != nil {
		panic(err)
	}
	if len(tickCumulatives) != len(lookbacks) ||
		len(secondsPerLiquidityCumulativeX128s) != len(lookbacks) {
		panic("observe returned an unexpected history length")
	}
	ufmt.Printf(
		"STATE observation query lookbacks=5,2560,5120,0 tick_cumulatives=%d,%d,%d,%d seconds_per_liquidity=%s,%s,%s,%s\n",
		tickCumulatives[0],
		tickCumulatives[1],
		tickCumulatives[2],
		tickCumulatives[3],
		secondsPerLiquidityCumulativeX128s[0],
		secondsPerLiquidityCumulativeX128s[1],
		secondsPerLiquidityCumulativeX128s[2],
		secondsPerLiquidityCumulativeX128s[3],
	)

	var (
		consultTick      int32
		consultLiquidity string
	)
	metric.PrintMetricsBy("OracleConsult large observation history", func() {
		consultTick, consultLiquidity, err = pool.OracleConsult(poolPath, 5120)
	})
	if err != nil {
		panic(err)
	}
	ufmt.Printf(
		"STATE observation consult lookback=%d arithmetic_mean_tick=%d harmonic_mean_liquidity=%s\n",
		5120,
		consultTick,
		consultLiquidity,
	)
}

func printObservationSamples(label string, indices []uint16) {
	slot0 := pool.GetSlot0(poolPath)
	balance0, err := pool.GetBalanceToken0(poolPath)
	if err != nil {
		panic(err)
	}
	balance1, err := pool.GetBalanceToken1(poolPath)
	if err != nil {
		panic(err)
	}
	latest, err := pool.GetObservationAt(poolPath, slot0.ObservationIndex())
	if err != nil {
		panic(err)
	}

	ufmt.Printf(
		"STATE observation %s index=%d cardinality=%d cardinality_next=%d tick=%d sqrt_price_x96=%s balance0=%d balance1=%d\n",
		label,
		slot0.ObservationIndex(),
		slot0.ObservationCardinality(),
		slot0.ObservationCardinalityNext(),
		slot0.Tick(),
		slot0.SqrtPriceX96().ToString(),
		balance0,
		balance1,
	)

	for _, index := range indices {
		observation, observationErr := pool.GetObservationAt(poolPath, index)
		if observationErr != nil {
			panic(observationErr)
		}
		timestampDelta := int64(0)
		if observation.Initialized() && latest.Initialized() {
			timestampDelta = observation.BlockTimestamp() - latest.BlockTimestamp()
		}
		ufmt.Printf(
			"STATE observation record %s index=%d initialized=%t timestamp_delta=%d tick_cumulative=%d seconds_per_liquidity=%s\n",
			label,
			index,
			observation.Initialized(),
			timestampDelta,
			observation.TickCumulative(),
			observation.SecondsPerLiquidityCumulativeX128(),
		)
	}
}
