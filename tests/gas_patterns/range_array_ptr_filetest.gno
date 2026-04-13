// Pattern: range over pointer-to-array (RangeIterArrayPtr 46 -> 239, +420%)
// Bad: for i,v := range &arr
// Good: for i,v := range arr
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 500

var sink int64

func main() {
	arr := [32]int64{}
	for i := range arr {
		arr[i] = int64(i)
	}

	gaspatterns.PrintMetricsBy("range array ptr (bad)", func() {
		for n := 0; n < N; n++ {
			var s int64
			for _, v := range &arr {
				s += v
			}
			sink += s
		}
	})
	gaspatterns.PrintMetricsBy("range array ptr (good)", func() {
		for n := 0; n < N; n++ {
			var s int64
			for _, v := range arr {
				s += v
			}
			sink += s
		}
	})
}
