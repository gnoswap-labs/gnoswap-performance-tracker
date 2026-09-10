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
// - Gas Used: 1689865
// - Storage Diff: 0
// - CPU Cycles: 1565901
// TickMathGetSqrtRatioAtTick (maxTick)
// - Gas Used: 2058854
// - Storage Diff: 0
// - CPU Cycles: 2010200
// TickMathGetSqrtRatioAtTick (zero)
// - Gas Used: 334802
// - Storage Diff: 0
// - CPU Cycles: 322554
// TickMathGetSqrtRatioAtTick
// - Gas Used: 1527883
// - Storage Diff: 0
// - CPU Cycles: 1501949
// TickMathGetTickAtSqrtRatio
// - Gas Used: 3863554
// - Storage Diff: 0
// - CPU Cycles: 3733669
// GetLiquidityForAmounts
// - Gas Used: 3211535
// - Storage Diff: 0
// - CPU Cycles: 3153602
// GetAmountsForLiquidity
// - Gas Used: 2981525
// - Storage Diff: 0
// - CPU Cycles: 2937658
// LiquidityMathAddDelta (positive)
// - Gas Used: 449547
// - Storage Diff: 0
// - CPU Cycles: 431320
// LiquidityMathAddDelta (negative)
// - Gas Used: 471588
// - Storage Diff: 0
// - CPU Cycles: 463867
// LiquidityMathAddDelta
// - Gas Used: 437865
// - Storage Diff: 0
// - CPU Cycles: 431320
