// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for same-start-time incentive buckets.
package main

import (
	"strconv"

	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/staker"
)

var incentiveBucketSizes = []int{1, 10, 50, 100}

func main(cur realm) {
	measureIncentiveAdd(0)
	for _, size := range incentiveBucketSizes {
		measureIncentiveAdd(size)
		measureIncentiveRemove(size)
		measureIncentiveIteration(size)
		measureIncentiveEarlyStop(size)
	}
}

func measureIncentiveAdd(siblingCount int) {
	incentives := newIncentiveBucket(siblingCount)
	name := strconv.Itoa(siblingCount)

	metric.PrintMetricsBy("Incentive Index Add ("+name+" existing siblings)", func() {
		incentives.AddIncentiveByStartTime(100, "added")
	})
}

func measureIncentiveRemove(bucketSize int) {
	incentives := newIncentiveBucket(bucketSize)
	name := strconv.Itoa(bucketSize)

	metric.PrintMetricsBy("Incentive Index Remove ("+name+" same-start incentives)", func() {
		incentives.RemoveIncentiveByStartTime(100, strconv.Itoa(bucketSize-1))
	})
}

func measureIncentiveIteration(bucketSize int) {
	incentives := newIncentiveBucket(bucketSize)
	name := strconv.Itoa(bucketSize)

	metric.PrintMetricsBy("Incentive Index Iterate ("+name+" same-start incentives)", func() {
		incentives.IterateIncentiveIdsByTime(100, 100, func(_ string) bool {
			return false
		})
	})
}

func measureIncentiveEarlyStop(bucketSize int) {
	incentives := newIncentiveBucket(bucketSize)
	name := strconv.Itoa(bucketSize)

	metric.PrintMetricsBy("Incentive Index Early Stop ("+name+" same-start incentives)", func() {
		incentives.IterateIncentiveIdsByTime(100, 100, func(_ string) bool {
			return true
		})
	})
}

func newIncentiveBucket(size int) *staker.Incentives {
	incentives := staker.NewIncentives("pool")
	for index := 0; index < size; index++ {
		incentives.AddIncentiveByStartTime(100, strconv.Itoa(index))
	}
	return incentives
}

// Output:
