package gaspatterns

import (
	"testing"

	"gno.land/p/nt/ufmt/v0"
)

func PrintMetricsBy(name string, fn func()) {
	beforeCycles := testing.GetCycles()
	beforeGas := testing.GetGas()
	beforeRealmStorageDiff := testing.GetRealmStorageDiffs()

	fn()

	afterCycles := testing.GetCycles()
	afterGas := testing.GetGas()
	afterRealmStorageDiff := testing.GetRealmStorageDiffs()

	total := int64(0)
	for _, d := range afterRealmStorageDiff {
		total += d
	}
	for _, d := range beforeRealmStorageDiff {
		total -= d
	}

	println(name)
	ufmt.Printf("- Gas Used: %d\n", afterGas-beforeGas)
	ufmt.Printf("- Storage Diff: %d\n", total)
	ufmt.Printf("- CPU Cycles: %d\n", afterCycles-beforeCycles)
}
