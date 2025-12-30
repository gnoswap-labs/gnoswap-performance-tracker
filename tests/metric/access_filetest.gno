// Gas and performance metrics for r/gnoswap/access realm
// Measures optimizations from optimize-access-gas:
// 1. AssertIsAuthorized: Removed duplicate GetAddress calls (2 -> 1)
// 2. AssertIsAdminOrGovernance: Cached .String() calls
package main

import (
	"testing"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/scenario/metric"
)

var t *testing.T

func main() {
	GetAddress_Admin()
	GetAddress_Governance()
	GetAddress_Router()
	GetAddress_Pool()
	GetAddress_Position()
	GetAddress_Staker()
	IsAuthorized_Admin()
	IsAuthorized_Governance()
	GetRoleAddresses()
}

// GetAddress - Read-only function that retrieves role addresses
func GetAddress_Admin() {
	metric.PrintMetricsBy("GetAddress (admin)", func() {
		access.GetAddress("admin")
	})
}

func GetAddress_Governance() {
	metric.PrintMetricsBy("GetAddress (governance)", func() {
		access.GetAddress("governance")
	})
}

func GetAddress_Router() {
	metric.PrintMetricsBy("GetAddress (router)", func() {
		access.GetAddress("router")
	})
}

func GetAddress_Pool() {
	metric.PrintMetricsBy("GetAddress (pool)", func() {
		access.GetAddress("pool")
	})
}

func GetAddress_Position() {
	metric.PrintMetricsBy("GetAddress (position)", func() {
		access.GetAddress("position")
	})
}

func GetAddress_Staker() {
	metric.PrintMetricsBy("GetAddress (staker)", func() {
		access.GetAddress("staker")
	})
}

// IsAuthorized - Checks if caller has specified role
func IsAuthorized_Admin() {
	metric.PrintMetricsBy("IsAuthorized (admin)", func() {
		adminAddr, _ := access.GetAddress("admin")
		access.IsAuthorized("admin", adminAddr)
	})
}

func IsAuthorized_Governance() {
	metric.PrintMetricsBy("IsAuthorized (governance)", func() {
		govAddr, _ := access.GetAddress("governance")
		access.IsAuthorized("governance", govAddr)
	})
}

// GetRoleAddresses - Returns all role addresses
func GetRoleAddresses() {
	metric.PrintMetricsBy("GetRoleAddresses", func() {
		access.GetRoleAddresses()
	})
}
