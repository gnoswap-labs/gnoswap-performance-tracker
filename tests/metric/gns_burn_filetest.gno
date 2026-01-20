// Gas and performance metrics for GNS Burn
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)
)

var t *testing.T

func main() {
	burnMetric()
}

func burnMetric() {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("GNS Burn", func() {
		gns.Burn(cross, adminAddr, int64(1_000_000))
	})
}
