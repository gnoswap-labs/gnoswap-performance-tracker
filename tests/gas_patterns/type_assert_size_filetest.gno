// Pattern: type assertion to large interface (TypeAssert1 + 349/method)
// Bad: assert to interface with many methods
// Good: assert to the smallest interface that fits the use site
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

type big interface {
	M1() int64
	M2() int64
	M3() int64
	M4() int64
	M5() int64
	M6() int64
	M7() int64
	M8() int64
}

type small interface {
	M1() int64
}

type impl struct{}

func (impl) M1() int64 { return 1 }
func (impl) M2() int64 { return 2 }
func (impl) M3() int64 { return 3 }
func (impl) M4() int64 { return 4 }
func (impl) M5() int64 { return 5 }
func (impl) M6() int64 { return 6 }
func (impl) M7() int64 { return 7 }
func (impl) M8() int64 { return 8 }

var sink int64

func main() {
	var x interface{} = impl{}

	gaspatterns.PrintMetricsBy("type assert large iface (bad)", func() {
		var s int64
		for i := 0; i < N; i++ {
			b := x.(big)
			s += b.M1()
		}
		sink += s
	})
	gaspatterns.PrintMetricsBy("type assert small iface (good)", func() {
		var s int64
		for i := 0; i < N; i++ {
			b := x.(small)
			s += b.M1()
		}
		sink += s
	})
}
