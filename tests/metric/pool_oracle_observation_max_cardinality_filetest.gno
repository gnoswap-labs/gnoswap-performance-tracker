// PKGPATH: gno.land/r/demo/oraclemax/main

// Measures the steady-state oracle paths after reserving the maximum supported
// observation cardinality (uint16 max: 65,535).
package main

import (
	"testing"

	"gno.land/p/gnoswap/gnsmath"
	prbac "gno.land/p/gnoswap/rbac"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	_ "gno.land/r/gnoswap/staker/v1"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"
)

const (
	maxInt64          int64  = 9223372036854775807
	liquidityDelta    string = "1000000"
	maximumCardinality uint16 = 65535
	fee                uint32 = 3000
)

var (
	adminAddr  = access.MustGetAddress(prbac.ROLE_ADMIN.String())
	adminRealm = testing.NewUserRealm(adminAddr)
	poolAddr   = access.MustGetAddress(prbac.ROLE_POOL.String())

	barPath  = "gno.land/r/onbloc/bar.BAR"
	fooPath  = "gno.land/r/onbloc/foo.FOO"
	poolPath = barPath + ":" + fooPath + ":3000"
)

func main(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)

	pool.CreatePool(cross(cur), barPath, fooPath, fee, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	_, _, _, _ = position.Mint(
		cross(cur), barPath, fooPath, fee, -1020, 1020,
		"50000000", "50000000", "0", "0", 9999999999, adminAddr, "",
	)

	// Allocation is deliberately outside the metric blocks. It models an
	// already-configured pool at the maximum supported observation capacity.
	pool.IncreaseObservationCardinalityNext(cross(cur), barPath, fooPath, fee, maximumCardinality)
	reservedSlot0 := pool.GetSlot0(poolPath)
	if reservedSlot0.ObservationCardinalityNext() != maximumCardinality {
		panic("failed to reserve maximum observation cardinality")
	}
	testing.SkipHeights(1)

	metric.PrintMetricsBy("IncreaseLiquidity oracle write (cardinality:65535)", func() {
		_, _, _, _, _ = position.IncreaseLiquidity(
			cross(cur), 1, liquidityDelta, liquidityDelta, "0", "0", 9999999999,
		)
	})

	slot0 := pool.GetSlot0(poolPath)
	metric.PrintMetricsBy("GetObservationAt current (cardinality:65535)", func() {
		_, err := pool.GetObservationAt(poolPath, slot0.ObservationIndex())
		if err != nil {
			panic(err)
		}
	})
}
