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
// UintTree Set (0)
// - Gas Used: 75309
// - Storage Diff: 0
// - CPU Cycles: 50337
// UintTree Get (0)
// - Gas Used: 56160
// - Storage Diff: 0
// - CPU Cycles: 53997
// UintTree Set (1)
// - Gas Used: 57342
// - Storage Diff: 0
// - CPU Cycles: 53281
// UintTree Get (1)
// - Gas Used: 56160
// - Storage Diff: 0
// - CPU Cycles: 53997
// UintTree Set (255)
// - Gas Used: 57342
// - Storage Diff: 0
// - CPU Cycles: 53281
// UintTree Get (255)
// - Gas Used: 56160
// - Storage Diff: 0
// - CPU Cycles: 53997
// UintTree Set (256)
// - Gas Used: 57342
// - Storage Diff: 0
// - CPU Cycles: 53281
// UintTree Get (256)
// - Gas Used: 56160
// - Storage Diff: 0
// - CPU Cycles: 53997
// UintTree Set (65535)
// - Gas Used: 57342
// - Storage Diff: 0
// - CPU Cycles: 53281
// UintTree Get (65535)
// - Gas Used: 56160
// - Storage Diff: 0
// - CPU Cycles: 53997
// UintTree Set (4294967295)
// - Gas Used: 57342
// - Storage Diff: 0
// - CPU Cycles: 53281
// UintTree Get (4294967295)
// - Gas Used: 56160
// - Storage Diff: 0
// - CPU Cycles: 53997
// UintTree Set (9223372036854775807)
// - Gas Used: 57342
// - Storage Diff: 0
// - CPU Cycles: 53281
// UintTree Get (9223372036854775807)
// - Gas Used: 56160
// - Storage Diff: 0
// - CPU Cycles: 53997
