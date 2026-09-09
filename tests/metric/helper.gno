package metric

import (
	"sort"
	"testing"

	"gno.land/p/nt/ufmt/v0"
)

func MetricsBy(name string, fn func()) (int64, int64, int64) {
	beforeCycles := testing.GetCycles()
	beforeGas := testing.GetGas()
	beforeRealmStorageDiff := testing.GetRealmStorageDiffs()

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
	beforeCycles := testing.GetCycles()
	beforeGas := testing.GetGas()
	beforeRealmStorageDiff := testing.GetRealmStorageDiffs()

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
	// Keep per-realm deltas for deposit/refund accounting outside the measured window.
	diffs := make(map[string]int64)
	for path, diff := range afterRealmStorageDiff {
		diffs[path] += diff
	}
	for path, diff := range beforeRealmStorageDiff {
		diffs[path] -= diff
	}
	paths := make([]string, 0, len(diffs))
	for path, diff := range diffs {
		if diff != 0 {
			paths = append(paths, path)
		}
	}
	sort.Strings(paths)
	for _, path := range paths {
		ufmt.Printf("- Realm Storage: %s %d\n", path, diffs[path])
	}
}
