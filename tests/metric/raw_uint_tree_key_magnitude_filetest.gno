// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

package main

import (
	"strconv"

	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/staker"
)

func main(cur realm) {
	values := []int64{0, 1, 255, 256, 65535, 4294967295, 9223372036854775807}

	for _, value := range values {
		tree := staker.NewUintTree()
		name := strconv.FormatInt(value, 10)
		metric.PrintMetricsBy("UintTree Set ("+name+")", func() {
			tree.Set(value, value)
		})
		metric.PrintMetricsBy("UintTree Get ("+name+")", func() {
			tree.Get(value)
		})
	}
}

// Output:
