// Pattern: defer abuse (ReturnCallDefers 78 -> 724, +828%)
// Bad: defer in hot function body
// Good: direct call without defer
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

var sink int64

func main() {
	gaspatterns.PrintMetricsBy("defer abuse (bad)", func() {
		for i := 0; i < N; i++ {
			sink += withDefer(int64(i))
		}
	})
	gaspatterns.PrintMetricsBy("defer abuse (good)", func() {
		for i := 0; i < N; i++ {
			sink += withoutDefer(int64(i))
		}
	})
}

func withDefer(x int64) int64 {
	defer func() {}()
	return x + 1
}

func withoutDefer(x int64) int64 {
	return x + 1
}
