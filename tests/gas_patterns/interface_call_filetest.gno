// Pattern: interface method call in hot loop (SelectorInterface 32 -> 751 base)
// Bad: call through interface each iteration
// Good: type-assert once to concrete, then call concrete method
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

type adder interface {
	Add(x int64) int64
}

type intAdder struct{ base int64 }

func (a intAdder) Add(x int64) int64 { return a.base + x }

var sink int64

func main() {
	var a adder = intAdder{base: 42}

	gaspatterns.PrintMetricsBy("interface call (bad)", func() {
		var s int64
		for i := 0; i < N; i++ {
			s += a.Add(int64(i))
		}
		sink += s
	})
	gaspatterns.PrintMetricsBy("interface call (good)", func() {
		c := a.(intAdder)
		var s int64
		for i := 0; i < N; i++ {
			s += c.Add(int64(i))
		}
		sink += s
	})
}
