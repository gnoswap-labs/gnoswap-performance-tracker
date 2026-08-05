// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Issue #1 verification (gov/staker path): gov/staker.CollectReward gas scales
// linearly with the number of protocol-fee reward tokens it settles.
//
// This exercises the exact mechanism the report points at
// (protocol_fee_reward_manager loops over every registered protocol-fee token,
// and staker_reward.gno transfers + emits per token). A single delegator is set
// up once; each round adds fresh protocol fees to the first k of four distinct
// tokens, distributes them, and measures gov/staker.CollectReward. Everything
// else (stake, block gap) is held constant, so the near-constant per-token gas
// increment confirms the report's "gas is dominated by processed item count,
// independent of time" claim.
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/protocol_fee"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	govstaker "gno.land/r/gnoswap/gov/staker"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/obl"
	"gno.land/r/onbloc/qux"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)
	stakerAddr, _      = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm        = testing.NewUserRealm(stakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())

	aliceAddr = testutils.TestAddress("alice")

	barPath = "gno.land/r/onbloc/bar.BAR"
	bazPath = "gno.land/r/onbloc/baz.BAZ"
	quxPath = "gno.land/r/onbloc/qux.QUX"
	oblPath = "gno.land/r/onbloc/obl.OBL"

	// four distinct protocol-fee tokens; round k settles the first k of them
	pfTokens = []string{barPath, bazPath, quxPath, oblPath}

	maxInt64 int64 = 9223372036854775807

	delegateAmount int64 = 1_000_000
	feeAmount      int64 = 1_000_000
	fundAmount     int64 = 100_000_000 // enough for all rounds
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	delegate(cur)

	// Each round re-adds fresh fees to the first k tokens so all k are settled
	// (transferred) by that CollectReward, isolating the per-token cost.
	for k := 1; k <= len(pfTokens); k++ {
		addFeesForFirstK(cur, k)
		distribute(cur)
		testing.SkipHeights(1)
		measureCollect(cur, k)
	}

	testing.SkipHeights(1)
	measureZeroCollect(cur)
}

func initializeSetup(cur realm) {
	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()

	testing.SetRealm(adminRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64) // for Delegate

	// Fund the staker role with each protocol-fee token so AddToProtocolFee
	// (caller must be pool/position/router/staker) can pull them in.
	bar.Transfer(cross(cur), stakerAddr, fundAmount)
	baz.Transfer(cross(cur), stakerAddr, fundAmount)
	qux.Transfer(cross(cur), stakerAddr, fundAmount)
	obl.Transfer(cross(cur), stakerAddr, fundAmount)

	// The staker role approves the protocol_fee contract (proxy + v1 impl).
	testing.SetRealm(stakerRealm)
	bar.Approve(cross(cur), protocolFeeAddr, maxInt64)
	baz.Approve(cross(cur), protocolFeeAddr, maxInt64)
	qux.Approve(cross(cur), protocolFeeAddr, maxInt64)
	obl.Approve(cross(cur), protocolFeeAddr, maxInt64)
	bar.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
	baz.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
	qux.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
	obl.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
}

func delegate(cur realm) {
	testing.SetRealm(adminRealm)
	govstaker.Delegate(cross(cur), aliceAddr, delegateAmount, "")
	testing.SkipHeights(1)
}

// addFeesForFirstK adds a fresh protocol fee to the first k tokens.
func addFeesForFirstK(cur realm, k int) {
	testing.SetRealm(stakerRealm)
	for i := 0; i < k; i++ {
		protocol_fee.AddToProtocolFee(cross(cur), pfTokens[i], feeAmount)
	}
}

func distribute(cur realm) {
	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross(cur))
}

func measureCollect(cur realm, k int) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy(ufmt.Sprintf("gov/staker CollectReward (%d protocol-fee tokens)", k), func() {
		govstaker.CollectReward(cross(cur))
	})
}

func measureZeroCollect(cur realm) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("gov/staker CollectReward (4 protocol-fee tokens but zero amount)", func() {
		govstaker.CollectReward(cross(cur))
	})
}
