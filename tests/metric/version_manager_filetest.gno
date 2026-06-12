// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for p/gnoswap/version_manager package
// Measures optimizations from perf-version-manager-string-concat:
// Replaced ufmt.Sprintf with + operator for string concatenation (~28% gas reduction)
package main

import (
	"testing"

	"gno.land/p/gnoswap/store"
	"gno.land/p/gnoswap/version_manager"
	"gno.land/p/nt/testutils/v0"
	"gno.land/r/gnoswap/scenario/metric"
)

var t *testing.T

func main(cur realm) {
	RegisterInitializer_V1(cur)
	RegisterInitializer_V2(cur)
}

// Version Manager Package Functions

// RegisterInitializer - Core optimization: string concatenation in isContainDomainPath
// This function internally calls isContainDomainPath which was optimized
func RegisterInitializer_V1(cur realm) {
	// Create test address for domain
	domainAddr := testutils.TestAddress("test_domain")

	// Set realm to a code realm that matches the domain path pattern
	// This simulates a v1 implementation calling RegisterInitializer
	v1Realm := testing.NewCodeRealm("gno.land/r/gnoswap/test_domain/v1")
	testing.SetRealm(v1Realm)

	// Create a test domain store with the domain address
	domainStore := store.NewKVStore(domainAddr)

	// Create version manager for a test domain
	vm := version_manager.NewVersionManager(
		"gno.land/r/gnoswap/test_domain",
		domainStore,
		func(_ int, rlm realm, kvStore store.KVStore) any {
			return kvStore
		},
	)

	metric.PrintMetricsBy("RegisterInitializer (v1)", func() {
		vm.RegisterInitializer(0, cur, func(_ int, rlm realm, store any) any {
			return "v1_implementation"
		})
	})
}

func RegisterInitializer_V2(cur realm) {
	// Create test address for domain
	domainAddr := testutils.TestAddress("test_domain_2")

	// Set realm to v2 implementation
	v2Realm := testing.NewCodeRealm("gno.land/r/gnoswap/test_domain_2/v2")
	testing.SetRealm(v2Realm)

	// Create a test domain store with the domain address
	domainStore := store.NewKVStore(domainAddr)

	// Create version manager for a test domain
	vm := version_manager.NewVersionManager(
		"gno.land/r/gnoswap/test_domain_2",
		domainStore,
		func(_ int, rlm realm, kvStore store.KVStore) any {
			return kvStore
		},
	)

	metric.PrintMetricsBy("RegisterInitializer (v2)", func() {
		vm.RegisterInitializer(0, cur, func(_ int, rlm realm, store any) any {
			return "v2_implementation"
		})
	})
}

// Output:
// RegisterInitializer (v1)
// - Gas Used: 79533
// - Storage Diff: 0
// - CPU Cycles: 52142
// RegisterInitializer (v2)
// - Gas Used: 61518
// - Storage Diff: 0
// - CPU Cycles: 54856
