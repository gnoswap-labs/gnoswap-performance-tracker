// Direct bit-search metrics exclude input construction and result assertions.
package main

import (
	"gno.land/p/gnoswap/gnsmath"
	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/scenario/metric"
)

func main() {
	cases := []struct {
		name string
		x    u256.Uint
		msb  uint8
		lsb  uint8
	}{
		{"one", u256.Uint{1, 0, 0, 0}, 0, 0},
		{"limb1", u256.Uint{0, 1, 0, 0}, 64, 64},
		{"limb2", u256.Uint{0, 0, 1, 0}, 128, 128},
		{"limb3", u256.Uint{0, 0, 0, 1}, 192, 192},
		{"max", u256.Uint{^uint64(0), ^uint64(0), ^uint64(0), ^uint64(0)}, 255, 0},
	}
	for _, tc := range cases {
		var msb, lsb uint8
		before := tc.x
		metric.PrintMetricsBy("BitMathMSB_"+tc.name, func() {
			msb = gnsmath.BitMathMostSignificantBit(&tc.x)
		})
		metric.PrintMetricsBy("BitMathLSB_"+tc.name, func() {
			lsb = gnsmath.BitMathLeastSignificantBit(&tc.x)
		})
		if msb != tc.msb || lsb != tc.lsb || tc.x != before {
			panic("incorrect bit search result or input mutation: " + tc.name)
		}
	}

	ratio := u256.NewUint(1)
	ratio.Lsh(ratio, 96)
	var tick int32
	metric.PrintMetricsBy("TickMathGetTickAtSqrtRatio_Q96", func() {
		tick = gnsmath.TickMathGetTickAtSqrtRatio(ratio)
	})
	if tick != 0 {
		panic("Q96 must map to tick zero")
	}
}
