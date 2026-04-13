// Pattern: map 2-value index (Index2 195 -> 1014, +420% vs Index1 106)
// Bad: v, ok := m[k] when ok is unused
// Good: v := m[k]
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

var sink int64

func main() {
	m := make(map[int64]int64, N)
	for i := int64(0); i < int64(N); i++ {
		m[i] = i * 3
	}

	gaspatterns.PrintMetricsBy("map index2 (bad)", func() {
		var s int64
		for i := int64(0); i < int64(N); i++ {
			v, _ := m[i]
			s += v
		}
		sink += s
	})
	gaspatterns.PrintMetricsBy("map index1 (good)", func() {
		var s int64
		for i := int64(0); i < int64(N); i++ {
			v := m[i]
			s += v
		}
		sink += s
	})
}
