// Gas and performance metrics for r/gnoswap/rbac realm
// Measures optimizations from optimize-rbac-realm-gas:
// 1. Cached .String() calls in initRbac (3 calls -> 1 call)
// 2. Removed redundant UpdateRoleAddress call in RegisterRole
package main

import (
	"testing"

	"gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
)

var t *testing.T

func main() {
	GetRoleAddress_Admin()
	GetRoleAddress_Governance()
	GetRoleAddress_Router()
	GetRoleAddress_Pool()
	GetRoleAddress_Position()
	GetRoleAddress_Staker()
}

// RBAC Realm Functions
// Note: Most realm functions (RegisterRole, UpdateRoleAddress, RemoveRole)
// require realm context and cannot be tested directly in filetest.
// These are measured indirectly through integration tests.

// GetRoleAddress - Read-only function that can be called directly
func GetRoleAddress_Admin() {
	metric.PrintMetricsBy("GetRoleAddress (admin)", func() {
		rbac.GetRoleAddress("admin")
	})
}

func GetRoleAddress_Governance() {
	metric.PrintMetricsBy("GetRoleAddress (governance)", func() {
		rbac.GetRoleAddress("governance")
	})
}

func GetRoleAddress_Router() {
	metric.PrintMetricsBy("GetRoleAddress (router)", func() {
		rbac.GetRoleAddress("router")
	})
}

func GetRoleAddress_Pool() {
	metric.PrintMetricsBy("GetRoleAddress (pool)", func() {
		rbac.GetRoleAddress("pool")
	})
}

func GetRoleAddress_Position() {
	metric.PrintMetricsBy("GetRoleAddress (position)", func() {
		rbac.GetRoleAddress("position")
	})
}

func GetRoleAddress_Staker() {
	metric.PrintMetricsBy("GetRoleAddress (staker)", func() {
		rbac.GetRoleAddress("staker")
	})
}
