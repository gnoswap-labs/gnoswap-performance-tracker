package metric

import (
	"sort"
	"testing"

	"gno.land/p/nt/ufmt/v0"
)

func MetricsBy(name string, fn func()) (int64, int64, int64) {
	beforeRealmStorageDiff := testing.GetRealmStorageDiffs()
	beforeCycles := testing.GetCycles()
	beforeGas := testing.GetGas()

	fn()

	afterCycles := testing.GetCycles()
	afterGas := testing.GetGas()
	afterRealmStorageDiff := testing.GetRealmStorageDiffs()

	totalRealmStorageDiff := int64(0)

	for _, diff := range afterRealmStorageDiff {
		totalRealmStorageDiff += diff
	}

	for _, diff := range beforeRealmStorageDiff {
		totalRealmStorageDiff -= diff
	}

	return afterGas - beforeGas, totalRealmStorageDiff, afterCycles - beforeCycles
}

func PrintMetricsBy(name string, fn func()) {
	beforeRealmStorageDiff := testing.GetRealmStorageDiffs()
	beforeCycles := testing.GetCycles()
	beforeGas := testing.GetGas()

	fn()

	afterCycles := testing.GetCycles()
	afterGas := testing.GetGas()
	afterRealmStorageDiff := testing.GetRealmStorageDiffs()

	totalRealmStorageDiff := int64(0)

	for _, diff := range afterRealmStorageDiff {
		totalRealmStorageDiff += diff
	}

	for _, diff := range beforeRealmStorageDiff {
		totalRealmStorageDiff -= diff
	}

	println(name)
	ufmt.Printf("- Gas Used: %d\n", afterGas-beforeGas)
	ufmt.Printf("- Storage Diff: %d\n", totalRealmStorageDiff)
	ufmt.Printf("- CPU Cycles: %d\n", afterCycles-beforeCycles)
	printRealmDiffs(beforeRealmStorageDiff, afterRealmStorageDiff)
}

// Emit the realm ledger after the timed operation; the standard table parser
// ignores these detail lines while raw captures retain deposit/refund inputs.
func printRealmDiffs(before, after map[string]int64) {
	paths := make([]string, 0, len(after))
	for path := range after {
		paths = append(paths, path)
	}
	for path := range before {
		if _, ok := after[path]; !ok {
			paths = append(paths, path)
		}
	}
	sort.Strings(paths)
	for _, path := range paths {
		if diff := after[path] - before[path]; diff != 0 {
			ufmt.Printf("- Realm Storage Diff: %s %d\n", path, diff)
		}
	}
}
