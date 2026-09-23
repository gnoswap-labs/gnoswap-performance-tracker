package main

import (
	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/scenario/metric"
)

func main() {
	cases := []struct {
		name string
		x    string
		y    string
		want string
	}{
		{"small remainder", "101", "10", "11"},
		{"uint256 remainder", "115792089237316195423570985008687907853269984665640564039457584007913129639935", "2", "57896044618658097711785492504343953926634992332820282019728792003956564819968"},
		{"Q128 remainder", "340282366920938463463374607431768211457", "1000000000000000000", "340282366920938463464"},
		{"exact division", "100", "10", "10"},
	}
	for _, tc := range cases {
		x, y := u256.MustFromDecimal(tc.x), u256.MustFromDecimal(tc.y)
		var got *u256.Uint
		metric.PrintMetricsBy("DivRoundingUp ("+tc.name+")", func() {
			got = u256.DivRoundingUp(x, y)
		})
		if got.ToString() != tc.want || x.ToString() != tc.x || y.ToString() != tc.y {
			panic("incorrect ceiling or mutated input: " + tc.name)
		}
	}
}
