// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Metrics for the six UintTree histories and indexes owned by staker.Pool.
//
// NewPool seeds stakedLiquidity, rewardCache, globalRewardRatioAccumulation,
// and its Incentives' unclaimablePeriods. NewIncentives also seeds an initial
// unclaimable period. The fixture counts those constructor entries as entry 1,
// then appends ascending entries through the fanout-4 and fanout-64 split
// boundaries. Pool histories run to 129 entries; the two incentive indexes run
// to 65 entries. The constructor-returned pool is kept in a package global so
// later writes remain reachable for storage accounting.
//
// The staker constructors allocate their trees through the staker realm's
// NewUintTreeN helper, so these are real staker-owned trees. No raw BPTree or
// helper fixture realm is needed here, and all writes below use exported Pool
// and Incentives accessors.
package main

import (
	"strconv"
	"time"

	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/staker"
)

const (
	poolPath               = "staker-fanout-benchmark"
	denseEntryCount  int64 = 129
	sparseEntryCount int64 = 65
)

var (
	benchmarkStart      int64
	benchmarkPool       *staker.Pool
	benchmarkIncentives *staker.Incentives
)

func main(cur realm) {
	// Keep test keys well after NewIncentives' wall-clock seed, while remaining
	// within the nonnegative key range accepted by staker.UintTree.
	benchmarkStart = time.Now().Unix() + 1_000_000

	metric.PrintMetricsBy("staker.NewIncentives (constructor + initial period)", func() {
		benchmarkIncentives = staker.NewIncentives(poolPath)
	})
	if benchmarkIncentives == nil || benchmarkIncentives.TargetPoolPath() != poolPath {
		panic("NewIncentives did not return the expected pool index")
	}
	if benchmarkIncentives.UnclaimablePeriods().Size() != 1 {
		panic("NewIncentives did not seed one unclaimable period")
	}

	metric.PrintMetricsBy("staker.NewPool (constructor + seeded histories)", func() {
		benchmarkPool = staker.NewPool(poolPath, benchmarkStart)
	})
	assertPoolConstructorState()

	poolIncentives := benchmarkPool.Incentives()
	measurePoolHistories(poolIncentives)
	measureIncentiveIndexes(poolIncentives)
}

func assertPoolConstructorState() {
	if benchmarkPool == nil || benchmarkPool.PoolPath() != poolPath {
		panic("NewPool did not return the expected pool")
	}

	if benchmarkPool.StakedLiquidity().Size() != 1 {
		panic("NewPool should seed one staked-liquidity entry")
	}
	staked, ok := benchmarkPool.StakedLiquidity().Get(benchmarkStart)
	liquidity, liquidityOK := staked.(*u256.Uint)
	if !ok || !liquidityOK || !liquidity.IsZero() {
		panic("NewPool staked-liquidity seed mismatch")
	}

	if benchmarkPool.RewardCache().Size() != 1 {
		panic("NewPool should seed one reward-cache entry")
	}
	reward, ok := benchmarkPool.RewardCache().Get(benchmarkStart)
	rewardValue, rewardOK := reward.(int64)
	if !ok || !rewardOK || rewardValue != 0 {
		panic("NewPool reward-cache seed mismatch")
	}

	if benchmarkPool.GlobalRewardRatioAccumulation().Size() != 1 {
		panic("NewPool should seed one global-ratio entry")
	}
	accumulation, ok := benchmarkPool.GlobalRewardRatioAccumulation().Get(benchmarkStart)
	accumulationValue, accumulationOK := accumulation.(string)
	if !ok || !accumulationOK || accumulationValue != "0" {
		panic("NewPool global-ratio seed mismatch")
	}

	if benchmarkPool.HistoricalTick().Size() != 0 {
		panic("NewPool should leave historical-tick history empty")
	}
	if benchmarkPool.Incentives() == nil || benchmarkPool.Incentives().UnclaimablePeriods().Size() != 1 {
		panic("NewPool should seed one pool unclaimable period")
	}
}

func measurePoolHistories(incentives *staker.Incentives) {
	measureUintHistory(
		"staker.Pool.stakedLiquidity",
		benchmarkPool.StakedLiquidity(),
		func(entry int64) {
			benchmarkPool.SetStakedLiquidityAt(testKey(entry), u256.NewUintFromInt64(entry))
		},
		2,
		denseEntryCount,
		func(entry int64, value any) {
			liquidity, ok := value.(*u256.Uint)
			if !ok || liquidity.ToString() != strconv.FormatInt(entry, 10) {
				panic("stakedLiquidity value mismatch")
			}
		},
	)

	measureUintHistory(
		"staker.Pool.rewardCache",
		benchmarkPool.RewardCache(),
		func(entry int64) {
			benchmarkPool.SetRewardCacheAt(testKey(entry), entry*10)
		},
		2,
		denseEntryCount,
		func(entry int64, value any) {
			reward, ok := value.(int64)
			if !ok || reward != entry*10 {
				panic("rewardCache value mismatch")
			}
		},
	)

	measureUintHistory(
		"staker.Pool.globalRewardRatioAccumulation",
		benchmarkPool.GlobalRewardRatioAccumulation(),
		func(entry int64) {
			benchmarkPool.SetGlobalRewardRatioAccumulationAt(testKey(entry), strconv.FormatInt(entry, 10))
		},
		2,
		denseEntryCount,
		func(entry int64, value any) {
			accumulation, ok := value.(string)
			if !ok || accumulation != strconv.FormatInt(entry, 10) {
				panic("globalRewardRatioAccumulation value mismatch")
			}
		},
	)

	measureUintHistory(
		"staker.Pool.historicalTick",
		benchmarkPool.HistoricalTick(),
		func(entry int64) {
			benchmarkPool.SetHistoricalTickAt(testKey(entry), int32(entry))
		},
		1,
		denseEntryCount,
		func(entry int64, value any) {
			tick, ok := value.(int32)
			if !ok || tick != int32(entry) {
				panic("historicalTick value mismatch")
			}
		},
	)

	// The unclaimable period created by NewIncentives is entry 1. The pool's
	// append-only test history therefore starts at entry 2 and stops at 65.
	measureUintHistory(
		"staker.Pool.incentives.unclaimablePeriods",
		incentives.UnclaimablePeriods(),
		func(entry int64) {
			incentives.SetUnclaimablePeriod(testKey(entry), testKey(entry)+100)
		},
		2,
		sparseEntryCount,
		func(entry int64, value any) {
			endTimestamp, ok := value.(int64)
			if !ok || endTimestamp != testKey(entry)+100 {
				panic("unclaimablePeriods value mismatch")
			}
		},
	)

	metric.PrintMetricsBy("staker.Pool.incentives.unclaimablePeriods Remove (#5)", func() {
		incentives.RemoveUnclaimablePeriod(testKey(5))
	})
	if incentives.UnclaimablePeriods().Has(testKey(5)) {
		panic("unclaimablePeriods entry remained after removal")
	}
	if _, ok := incentives.UnclaimablePeriods().Get(testKey(5)); ok {
		panic("unclaimablePeriods Get found removed entry")
	}
}

func measureIncentiveIndexes(incentives *staker.Incentives) {
	name := "staker.Pool.incentives.byStartTime"
	setIndexEntry := func(entry int64) {
		incentives.AddIncentiveByStartTime(testKey(entry), benchmarkIncentiveID(entry))
	}

	writeHistoryRange(name, setIndexEntry, 1, 1)
	writeHistoryRange(name, setIndexEntry, 2, 4)
	writeHistoryRange(name, setIndexEntry, 5, 5)
	writeHistoryRange(name, setIndexEntry, 6, 13)
	writeHistoryRange(name, setIndexEntry, 14, 14)
	writeHistoryRange(name, setIndexEntry, 15, 63)
	writeHistoryRange(name, setIndexEntry, 64, 64)
	writeHistoryRange(name, setIndexEntry, 65, 65)

	assertByStartTime(incentives, 1, sparseEntryCount)
	measureByStartTimeReads(incentives, 1, sparseEntryCount)

	metric.PrintMetricsBy("staker.Pool.incentives.byStartTime Remove (#5)", func() {
		incentives.RemoveIncentiveByStartTime(testKey(5), benchmarkIncentiveID(5))
	})
	assertByStartTimeAfterRemoval(incentives, 1, sparseEntryCount, 5)
}

func measureUintHistory(
	name string,
	tree *staker.UintTree,
	setValue func(int64),
	firstEntry int64,
	maxEntries int64,
	checkValue func(int64, any),
) {
	writeHistoryRange(name, setValue, firstEntry, firstEntry)

	batchStart := firstEntry + 1
	if batchStart < 2 {
		batchStart = 2
	}
	writeHistoryRange(name, setValue, batchStart, 4)
	writeHistoryRange(name, setValue, 5, 5)
	writeHistoryRange(name, setValue, 6, 13)
	writeHistoryRange(name, setValue, 14, 14)
	writeHistoryRange(name, setValue, 15, 63)
	writeHistoryRange(name, setValue, 64, 64)
	writeHistoryRange(name, setValue, 65, 65)
	if maxEntries >= 129 {
		writeHistoryRange(name, setValue, 66, 127)
		writeHistoryRange(name, setValue, 128, 128)
		writeHistoryRange(name, setValue, 129, 129)
	}

	assertUintHistory(name, tree, firstEntry, maxEntries, checkValue)
	measureUintTreeReads(name, tree, firstEntry, maxEntries)
}

func writeHistoryRange(name string, setValue func(int64), from, to int64) {
	if from > to {
		return
	}

	metric.PrintMetricsBy(name+" Set ("+entryRange(from, to)+")", func() {
		for entry := from; entry <= to; entry++ {
			setValue(entry)
		}
	})
}

func assertUintHistory(name string, tree *staker.UintTree, firstEntry, maxEntries int64, checkValue func(int64, any)) {
	if tree.Size() != int(maxEntries) {
		panic(name + " size mismatch")
	}

	for entry := firstEntry; entry <= maxEntries; entry++ {
		value, ok := tree.Get(testKey(entry))
		if !ok {
			panic(name + " missing history entry")
		}
		checkValue(entry, value)
	}
}

func measureUintTreeReads(name string, tree *staker.UintTree, firstEntry, maxEntries int64) {
	latestKey := int64(0)
	latestCallbacks := 0
	metric.PrintMetricsBy(name+" Reverse newest", func() {
		tree.ReverseIterate(testKey(firstEntry), testKey(maxEntries), func(key int64, _ any) bool {
			latestKey = key
			latestCallbacks++
			return true
		})
	})
	if latestCallbacks != 1 || latestKey != testKey(maxEntries) {
		panic(name + " newest reverse lookup mismatch")
	}

	rangeKeys := make([]int64, 0, 4)
	metric.PrintMetricsBy(name+" Reverse range (last 4)", func() {
		tree.ReverseIterate(testKey(maxEntries-3), testKey(maxEntries), func(key int64, _ any) bool {
			rangeKeys = append(rangeKeys, key)
			return false
		})
	})
	if len(rangeKeys) != 4 {
		panic(name + " reverse range count mismatch")
	}
	for i, key := range rangeKeys {
		expected := testKey(maxEntries - int64(i))
		if key != expected {
			panic(name + " reverse range order mismatch")
		}
	}
}

func assertByStartTime(incentives *staker.Incentives, firstEntry, maxEntries int64) {
	count := int64(0)
	incentives.IterateIncentiveIdsByTime(testKey(firstEntry), testKey(maxEntries), func(id string) bool {
		expected := benchmarkIncentiveID(maxEntries - count)
		if id != expected {
			panic("byStartTime reverse order mismatch")
		}
		count++
		return false
	})
	if count != maxEntries-firstEntry+1 {
		panic("byStartTime entry count mismatch")
	}
}

func measureByStartTimeReads(incentives *staker.Incentives, firstEntry, maxEntries int64) {
	latestID := ""
	latestCallbacks := 0
	metric.PrintMetricsBy("staker.Pool.incentives.byStartTime Reverse newest", func() {
		incentives.IterateIncentiveIdsByTime(testKey(maxEntries), testKey(maxEntries), func(id string) bool {
			latestID = id
			latestCallbacks++
			return true
		})
	})
	if latestCallbacks != 1 || latestID != benchmarkIncentiveID(maxEntries) {
		panic("byStartTime newest reverse lookup mismatch")
	}

	rangeIDs := make([]string, 0, 4)
	metric.PrintMetricsBy("staker.Pool.incentives.byStartTime Reverse range (last 4)", func() {
		incentives.IterateIncentiveIdsByTime(testKey(maxEntries-3), testKey(maxEntries), func(id string) bool {
			rangeIDs = append(rangeIDs, id)
			return false
		})
	})
	if len(rangeIDs) != 4 {
		panic("byStartTime reverse range count mismatch")
	}
	for i, id := range rangeIDs {
		expected := benchmarkIncentiveID(maxEntries - int64(i))
		if id != expected {
			panic("byStartTime reverse range order mismatch")
		}
	}
}

func assertByStartTimeAfterRemoval(incentives *staker.Incentives, firstEntry, maxEntries, removedEntry int64) {
	removedCount := 0
	incentives.IterateIncentiveIdsByTime(testKey(removedEntry), testKey(removedEntry), func(_ string) bool {
		removedCount++
		return false
	})
	if removedCount != 0 {
		panic("byStartTime entry remained after removal")
	}

	expectedEntry := maxEntries
	count := int64(0)
	incentives.IterateIncentiveIdsByTime(testKey(firstEntry), testKey(maxEntries), func(id string) bool {
		for expectedEntry == removedEntry {
			expectedEntry--
		}
		if id != benchmarkIncentiveID(expectedEntry) {
			panic("byStartTime order mismatch after removal")
		}
		expectedEntry--
		count++
		return false
	})
	if count != maxEntries-firstEntry {
		panic("byStartTime count mismatch after removal")
	}
}

func testKey(entry int64) int64 {
	return benchmarkStart + entry
}

func benchmarkIncentiveID(entry int64) string {
	return "fanout-incentive-" + strconv.FormatInt(entry, 10)
}

func entryRange(from, to int64) string {
	if from == to {
		return "#" + strconv.FormatInt(from, 10)
	}
	return "#" + strconv.FormatInt(from, 10) + "-" + strconv.FormatInt(to, 10)
}

// Output:
