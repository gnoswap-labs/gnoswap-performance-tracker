// Gas and performance metrics for r/gnoswap/common package
// Test cases are identical to tests/integration/testdata/base/common_gas_measurement.txtar
package main

import (
	"gno.land/p/gnoswap/gnsmath"
	"testing"

	i256 "gno.land/p/gnoswap/int256"
	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/scenario/metric"
)

var t *testing.T

func main() {
	TickMathGetSqrtRatioAtTick_MinTick()
	TickMathGetSqrtRatioAtTick_MaxTick()
	TickMathGetSqrtRatioAtTick_Zero()
	TickMathGetSqrtRatioAtTick()
	TickMathGetTickAtSqrtRatio()
	GetLiquidityForAmounts()
	GetAmountsForLiquidity()
	LiquidityMathAddDelta_Positive()
	LiquidityMathAddDelta_Negative()
	LiquidityMathAddDelta()
}

// Common Package Functions - Identical to common_gas_measurement.txtar

func TickMathGetSqrtRatioAtTick_MinTick() {
	metric.PrintMetricsBy("TickMathGetSqrtRatioAtTick (minTick)", func() {
		gnsmath.TickMathGetSqrtRatioAtTick(-887272)
	})
}

func TickMathGetSqrtRatioAtTick_MaxTick() {
	metric.PrintMetricsBy("TickMathGetSqrtRatioAtTick (maxTick)", func() {
		gnsmath.TickMathGetSqrtRatioAtTick(887272)
	})
}

func TickMathGetSqrtRatioAtTick_Zero() {
	metric.PrintMetricsBy("TickMathGetSqrtRatioAtTick (zero)", func() {
		gnsmath.TickMathGetSqrtRatioAtTick(0)
	})
}

func TickMathGetSqrtRatioAtTick() {
	metric.PrintMetricsBy("TickMathGetSqrtRatioAtTick", func() {
		gnsmath.TickMathGetSqrtRatioAtTick(1000)
	})
}

func TickMathGetTickAtSqrtRatio() {
	metric.PrintMetricsBy("TickMathGetTickAtSqrtRatio", func() {
		sqrtPriceX96 := u256.MustFromDecimal("79228162514264337593543950336")
		gnsmath.TickMathGetTickAtSqrtRatio(sqrtPriceX96)
	})
}

func GetLiquidityForAmounts() {
	metric.PrintMetricsBy("GetLiquidityForAmounts", func() {
		sqrtPriceX96 := u256.MustFromDecimal("79228162514264337593543950336")
		sqrtPriceAX96 := u256.MustFromDecimal("70710678118654752440084436210")
		sqrtPriceBX96 := u256.MustFromDecimal("88817841970012523233890533447")
		amount0 := u256.MustFromDecimal("1000000")
		amount1 := u256.MustFromDecimal("1000000")

		gnsmath.GetLiquidityForAmounts(sqrtPriceX96, sqrtPriceAX96, sqrtPriceBX96, amount0, amount1)
	})
}

func GetAmountsForLiquidity() {
	metric.PrintMetricsBy("GetAmountsForLiquidity", func() {
		sqrtPriceX96 := u256.MustFromDecimal("79228162514264337593543950336")
		sqrtPriceAX96 := u256.MustFromDecimal("70710678118654752440084436210")
		sqrtPriceBX96 := u256.MustFromDecimal("88817841970012523233890533447")
		liquidity := u256.MustFromDecimal("1000000")

		gnsmath.GetAmountsForLiquidity(sqrtPriceX96, sqrtPriceAX96, sqrtPriceBX96, liquidity)
	})
}

func LiquidityMathAddDelta_Positive() {
	metric.PrintMetricsBy("LiquidityMathAddDelta (positive)", func() {
		x := u256.MustFromDecimal("1000000")
		y := i256.MustFromDecimal("500000")

		gnsmath.LiquidityMathAddDelta(x, y)
	})
}

func LiquidityMathAddDelta_Negative() {
	metric.PrintMetricsBy("LiquidityMathAddDelta (negative)", func() {
		x := u256.MustFromDecimal("1000000")
		y := i256.MustFromDecimal("-300000")

		gnsmath.LiquidityMathAddDelta(x, y)
	})
}

func LiquidityMathAddDelta() {
	metric.PrintMetricsBy("LiquidityMathAddDelta", func() {
		x := u256.MustFromDecimal("1000000")
		y := i256.MustFromDecimal("500000")

		gnsmath.LiquidityMathAddDelta(x, y)
	})
}

// Output:
// TickMathGetSqrtRatioAtTick (minTick)
// - Gas Used: 1796156
// - Storage Diff: 0
// - CPU Cycles: 1564855
// TickMathGetSqrtRatioAtTick (maxTick)
// - Gas Used: 2153780
// - Storage Diff: 0
// - CPU Cycles: 2014557
// TickMathGetSqrtRatioAtTick (zero)
// - Gas Used: 327274
// - Storage Diff: 0
// - CPU Cycles: 301208
// TickMathGetSqrtRatioAtTick
// - Gas Used: 1599994
// - Storage Diff: 0
// - CPU Cycles: 1497962
// TickMathGetTickAtSqrtRatio
// - Gas Used: 4048216
// - Storage Diff: 0
// - CPU Cycles: 3713107
// GetLiquidityForAmounts
// - Gas Used: 3365129
// - Storage Diff: 0
// - CPU Cycles: 3126606
// GetAmountsForLiquidity
// - Gas Used: 3132189
// - Storage Diff: 0
// - CPU Cycles: 2919489
// LiquidityMathAddDelta (positive)
// - Gas Used: 475326
// - Storage Diff: 0
// - CPU Cycles: 426230
// LiquidityMathAddDelta (negative)
// - Gas Used: 496669
// - Storage Diff: 0
// - CPU Cycles: 460071
// LiquidityMathAddDelta
// - Gas Used: 460563
// - Storage Diff: 0
// - CPU Cycles: 426230
