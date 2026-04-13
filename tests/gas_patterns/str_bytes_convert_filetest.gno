// Pattern: repeated string<->[]byte conversion (ConvertStrBytes 16 -> 363)
// Bad: []byte(s) inside the hot loop
// Good: convert once, reuse the []byte variable
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

var sink int64

func main() {
	s := "hello gnoland performance"

	gaspatterns.PrintMetricsBy("str<->bytes per-iter (bad)", func() {
		var total int64
		for i := 0; i < N; i++ {
			b := []byte(s)
			total += int64(len(b))
		}
		sink += total
	})
	gaspatterns.PrintMetricsBy("str<->bytes once (good)", func() {
		b := []byte(s)
		var total int64
		for i := 0; i < N; i++ {
			total += int64(len(b))
		}
		sink += total
	})
}
