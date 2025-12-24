// Gas and performance metrics for emission MintAndDistributeGns
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/emission"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
)

var t *testing.T

func main() {
	initializeDistribution()
	mintAndDistributeMetric()
}

func initializeDistribution() {
	testing.SetOriginCaller(adminAddr)
	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func mintAndDistributeMetric() {
	testing.SetRealm(testing.NewCodeRealm("gno.land/r/gnoswap/emission"))

	metric.PrintMetricsBy("Emission MintAndDistributeGns", func() {
		_, _ = emission.MintAndDistributeGns(cross)
	})
}
