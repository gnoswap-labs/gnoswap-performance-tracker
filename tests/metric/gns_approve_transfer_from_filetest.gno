// Gas and performance metrics for GNS Approve and TransferFrom
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	_ "gno.land/r/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	bobAddr  = testutils.TestAddress("bob")
	bobRealm = testing.NewUserRealm(bobAddr)
)

var t *testing.T

func main() {
	initializeSetup()
	approveMetric()
	transferFromMetric()
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	gns.Transfer(cross, aliceAddr, int64(2_000_000))
}

func approveMetric() {
	testing.SetRealm(aliceRealm)

	metric.PrintMetricsBy("GNS Approve", func() {
		gns.Approve(cross, bobAddr, int64(2_000_000))
	})
}

func transferFromMetric() {
	testing.SetRealm(bobRealm)

	metric.PrintMetricsBy("GNS TransferFrom", func() {
		gns.TransferFrom(cross, aliceAddr, bobAddr, int64(1_000_000))
	})
}
