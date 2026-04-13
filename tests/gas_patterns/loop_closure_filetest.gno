// Pattern: loop closure creation (FuncLit 61 -> 269, +341%)
// Bad: closure allocated per iteration
// Good: function declared once outside loop, value passed as arg
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

var sink int64

func main() {
	gaspatterns.PrintMetricsBy("loop closure (bad)", func() {
		for i := 0; i < N; i++ {
			v := int64(i)
			f := func() int64 { return v * 2 }
			sink += f()
		}
	})
	gaspatterns.PrintMetricsBy("loop closure (good)", func() {
		for i := 0; i < N; i++ {
			sink += doubler(int64(i))
		}
	})
}

func doubler(v int64) int64 { return v * 2 }
