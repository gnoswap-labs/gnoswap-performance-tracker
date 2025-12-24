// Gas and performance metrics for GNS MintGns
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/rbac"
	_ "gno.land/r/gnoswap/emission"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	emissionAddr, _ = access.GetAddress(prabc.ROLE_EMISSION.String())
	emissionRealm   = testing.NewCodeRealm("gno.land/r/gnoswap/emission")
)

var t *testing.T

func main() {
	initializeSetup()
	mintGnsMetric()
}

func initializeSetup() {
	testing.SetRealm(emissionRealm)
	gns.InitEmissionState(cross, 1, time.Now().Unix())
}

func mintGnsMetric() {
	testing.SetRealm(emissionRealm)

	metric.PrintMetricsBy("GNS MintGns", func() {
		gns.MintGns(cross, emissionAddr)
	})
}
