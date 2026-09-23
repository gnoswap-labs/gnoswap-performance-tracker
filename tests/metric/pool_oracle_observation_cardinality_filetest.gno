// PKGPATH: gno.land/r/demo/main

// Measures the effect of oracle observation cardinality on the steady-state
// paths that update and read observations. Setup is intentionally outside the
// metric blocks: only the operation against a cardinality-1 or cardinality-1024
// pool is measured.
package main

import (
	"strconv"
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
	maxInt64       int64  = 9223372036854775807
	liquidityDelta string = "1000000"
	cardinalityBig uint16 = 1024
)

var (
	adminAddr  = access.MustGetAddress(prbac.ROLE_ADMIN.String())
	adminRealm = testing.NewUserRealm(adminAddr)
	poolAddr   = access.MustGetAddress(prbac.ROLE_POOL.String())

	barPath = "gno.land/r/onbloc/bar.BAR"
	fooPath = "gno.land/r/onbloc/foo.FOO"
)

func main(cur realm) {
	initialize(cur)
	createAndMint(cur, 100)
	createAndMint(cur, 500)

	// Reserve a large buffer before measurement. The first subsequent oracle
	// write promotes its active cardinality, as in Uniswap V3.
	testing.SetRealm(adminRealm)
	pool.IncreaseObservationCardinalityNext(cross(cur), barPath, fooPath, 500, cardinalityBig)
	testing.SkipHeights(1)

	measureIncreaseLiquidity(cur, 1, 100, "IncreaseLiquidity oracle write (cardinality:1)")
	measureIncreaseLiquidity(cur, 2, 500, "IncreaseLiquidity oracle write (cardinality:1024)")

	baselinePoolPath := poolPath(100)
	largePoolPath := poolPath(500)
	baselineSlot0 := pool.GetSlot0(baselinePoolPath)
	largeSlot0 := pool.GetSlot0(largePoolPath)
	measureCurrentObservationRead(
		cur,
		baselinePoolPath,
		baselineSlot0.ObservationIndex(),
		"GetObservationAt current (cardinality:1)",
	)
	measureCurrentObservationRead(
		cur,
		largePoolPath,
		largeSlot0.ObservationIndex(),
		"GetObservationAt current (cardinality:1024)",
	)
}

func initialize(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
}

func createAndMint(cur realm, fee uint32) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(
		cross(cur),
		barPath,
		fooPath,
		fee,
		gnsmath.TickMathGetSqrtRatioAtTick(0).ToString(),
	)

	_, _, _, _ = position.Mint(
		cross(cur),
		barPath,
		fooPath,
		fee,
		-1000,
		1000,
		"50000000",
		"50000000",
		"0",
		"0",
		9999999999,
		adminAddr,
		"",
	)
}

func measureIncreaseLiquidity(cur realm, tokenID uint64, fee uint32, name string) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy(name, func() {
		_, _, _, _, _ = position.IncreaseLiquidity(
			cross(cur),
			tokenID,
			liquidityDelta,
			liquidityDelta,
			"0",
			"0",
			9999999999,
		)
	})
}

func poolPath(fee uint32) string {
	return barPath + ":" + fooPath + ":" + strconv.Itoa(int(fee))
}

func measureCurrentObservationRead(cur realm, poolPath string, index uint16, name string) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy(name, func() {
		_, err := pool.GetObservationAt(poolPath, index)
		if err != nil {
			panic(err)
		}
	})
}
