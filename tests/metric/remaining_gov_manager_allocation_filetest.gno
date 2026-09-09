// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Supplemental persisted-factory allocation microbenchmark, not a production
// transaction or a complete deployment-fee quote. Real user workflows are in
// the separate fee/emission accumulator fixtures and remain isolated from this.
package main

import (
	"testing"

	prbac "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoswap/access"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
)

func main(cur realm) {
	admin := access.MustGetAddress(prbac.ROLE_ADMIN.String())
	testing.SetRealm(testing.NewUserRealm(admin))
	metric.PrintMetricsBy("Remaining gov allocation factory fee manager", func() {
		metric.AllocateRemainingFeeManager(cross(cur))
	})
	metric.PrintMetricsBy("Remaining gov allocation factory emission manager", func() {
		metric.AllocateRemainingEmissionManager(cross(cur))
	})
}
