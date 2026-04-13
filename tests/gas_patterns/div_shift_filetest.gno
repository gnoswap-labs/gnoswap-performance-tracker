// Pattern: integer division / remainder by power of 2 (QuoInt 16->138, RemAssign 46->169)
// Bad: x / 2, x % 8
// Good: x >> 1, x & 7
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

var sink int64

func main() {
	gaspatterns.PrintMetricsBy("div mod pow2 (bad)", func() {
		var s int64
		for i := int64(0); i < int64(N); i++ {
			s += (i / 2) + (i % 8)
		}
		sink += s
	})
	gaspatterns.PrintMetricsBy("shift mask pow2 (good)", func() {
		var s int64
		for i := int64(0); i < int64(N); i++ {
			s += (i >> 1) + (i & 7)
		}
		sink += s
	})
}
