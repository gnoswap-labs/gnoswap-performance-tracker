// Gas and performance metrics for r/gnoswap/rbac realm
// Measures optimizations from optimize-rbac-realm-gas:
// 1. Cached .String() calls in initRbac (3 calls -> 1 call)
// 2. Removed redundant UpdateRoleAddress call in RegisterRole
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"

	"gno.land/p/nt/testutils"
)

var (
	adminAddr, _  = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm    = testing.NewUserRealm(adminAddr)
	testRoleCount = 0
)

var t *testing.T

func main() {
	// Core optimization: RegisterRole (removed redundant UpdateRoleAddress)
	RegisterRole_NewCustomRole()

	// Read operations
	GetRoleAddress_Admin()
	GetRoleAddress_Governance()
	GetRoleAddress_Router()
	GetRoleAddress_Pool()
	GetRoleAddress_Position()
	GetRoleAddress_Staker()
}

// RBAC Write Operations (require realm context)

// RegisterRole - Core optimization: removed redundant UpdateRoleAddress call
func RegisterRole_NewCustomRole() {
	testing.SetRealm(adminRealm)

	testRoleCount++
	roleName := "test_role_" + testutils.TestAddress("test").String()[:8]
	roleAddr := testutils.TestAddress(roleName)

	metric.PrintMetricsBy("RegisterRole", func() {
		rbac.RegisterRole(cross, roleName, roleAddr)
	})
}

// RBAC Read Operations

// GetRoleAddress - Read-only function
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
