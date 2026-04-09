// Gas and performance metrics for p/gnoswap/rbac package
// Measures optimizations from optimize-rbac-package-gas:
// 1. Removed redundant .String() calls
// 2. Map preallocation in GetAllRoleAddresses
package main

import (
	"testing"

	"gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	"gno.land/r/gnoswap/scenario/metric"
)

var t *testing.T

func main() {
	NewRBACWithAddress()
	RegisterRole()
	UpdateRoleAddress()
	GetRoleAddress()
	IsAuthorized()
	RemoveRole()
	GetAllRoleAddresses_Empty()
	GetAllRoleAddresses_SingleRole()
	GetAllRoleAddresses_MultipleRoles()
	SystemRoleString()
}

// RBAC Package Functions

func NewRBACWithAddress() {
	metric.PrintMetricsBy("NewRBACWithAddress", func() {
		adminAddr := testutils.TestAddress("admin")
		rbac.NewRBACWithAddress(adminAddr)
	})
}

func RegisterRole() {
	metric.PrintMetricsBy("RegisterRole", func() {
		adminAddr := testutils.TestAddress("admin")
		manager := rbac.NewRBACWithAddress(adminAddr)

		testAddr := testutils.TestAddress("test")
		manager.RegisterRole("test_role", testAddr)
	})
}

func UpdateRoleAddress() {
	metric.PrintMetricsBy("UpdateRoleAddress", func() {
		adminAddr := testutils.TestAddress("admin")
		manager := rbac.NewRBACWithAddress(adminAddr)

		testAddr := testutils.TestAddress("test")
		manager.RegisterRole("test_role", testAddr)

		newAddr := testutils.TestAddress("new")
		manager.UpdateRoleAddress("test_role", newAddr)
	})
}

func GetRoleAddress() {
	metric.PrintMetricsBy("GetRoleAddress", func() {
		adminAddr := testutils.TestAddress("admin")
		manager := rbac.NewRBACWithAddress(adminAddr)

		testAddr := testutils.TestAddress("test")
		manager.RegisterRole("test_role", testAddr)

		manager.GetRoleAddress("test_role")
	})
}

func IsAuthorized() {
	metric.PrintMetricsBy("IsAuthorized", func() {
		adminAddr := testutils.TestAddress("admin")
		manager := rbac.NewRBACWithAddress(adminAddr)

		testAddr := testutils.TestAddress("test")
		manager.RegisterRole("test_role", testAddr)

		manager.IsAuthorized("test_role", testAddr)
	})
}

func RemoveRole() {
	metric.PrintMetricsBy("RemoveRole", func() {
		adminAddr := testutils.TestAddress("admin")
		manager := rbac.NewRBACWithAddress(adminAddr)

		testAddr := testutils.TestAddress("test")
		manager.RegisterRole("custom_role", testAddr)

		manager.RemoveRole("custom_role")
	})
}

// GetAllRoleAddresses with different sizes - tests map preallocation optimization
func GetAllRoleAddresses_Empty() {
	metric.PrintMetricsBy("GetAllRoleAddresses (empty)", func() {
		adminAddr := testutils.TestAddress("admin")
		manager := rbac.NewRBACWithAddress(adminAddr)

		manager.GetAllRoleAddresses()
	})
}

func GetAllRoleAddresses_SingleRole() {
	metric.PrintMetricsBy("GetAllRoleAddresses (1 role)", func() {
		adminAddr := testutils.TestAddress("admin")
		manager := rbac.NewRBACWithAddress(adminAddr)

		testAddr := testutils.TestAddress("test")
		manager.RegisterRole("role1", testAddr)

		manager.GetAllRoleAddresses()
	})
}

func GetAllRoleAddresses_MultipleRoles() {
	metric.PrintMetricsBy("GetAllRoleAddresses (10 roles)", func() {
		adminAddr := testutils.TestAddress("admin")
		manager := rbac.NewRBACWithAddress(adminAddr)

		// Register 10 roles
		for i := 0; i < 10; i++ {
			addr := testutils.TestAddress("test" + string(rune('0'+i)))
			manager.RegisterRole("role"+string(rune('0'+i)), addr)
		}

		manager.GetAllRoleAddresses()
	})
}

// SystemRole.String() - tests .String() call optimization
func SystemRoleString() {
	metric.PrintMetricsBy("SystemRole.String()", func() {
		_ = rbac.ROLE_ADMIN.String()
		_ = rbac.ROLE_GOVERNANCE.String()
		_ = rbac.ROLE_POOL.String()
	})
}
