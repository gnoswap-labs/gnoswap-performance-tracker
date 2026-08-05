// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Issue #3 verification: the staker realm grows without bound as positions are
// minted and staked, and this raises the cost of staker.CollectReward over time.
//
// Every stake appends a fresh timestamp-keyed entry to the pool's append-only
// trees (globalRewardRatioAccumulation, stakedLiquidity, historicalTick) and to
// per-position deposit/warmup state; nothing is pruned. A fixed reference
// position is collected once per round over a constant short interval (so the
// warmup contribution is held constant, isolating this component from issue #2),
// while each round mints + stakes another batch of positions to grow the trees.
//
// Two signals are reported per round:
//   - "stake batch"        : staker storage added by the batch (append-only, +)
//   - "reference collect"   : gas of the identical reference CollectReward
//
// Cumulative staker storage climbs monotonically (unbounded, no prune) and the
// reference collect gets more expensive as the trees it reads grow.
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	"gno.land/p/gnoswap/gnsmath"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/staker"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gnft"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _     = access.GetAddress(prabc.ROLE_POOL.String())
	positionAddr, _ = access.GetAddress(prabc.ROLE_POSITION.String())
	stakerAddr, _   = access.GetAddress(prabc.ROLE_STAKER.String())

	barPath = "gno.land/r/onbloc/bar.BAR"
	fooPath = "gno.land/r/onbloc/foo.FOO"

	fee      uint32 = 3000
	poolPath        = barPath + ":" + fooPath + ":3000"

	maxInt64 int64 = 9223372036854775807

	refId uint64 // fixed reference staked position, collected every round
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createPoolAndTier(cur)

	// Reference position, staked once; collected every round over a constant gap.
	refId = mintAndStake(cur)
	testing.SkipHeights(1)

	const batch = 20

	// Round 0: baseline collect with the trees still small.
	measureCollect(cur, "storage growth: CollectReward 1 staked position", false)

	stakeBatch(cur, batch)
	measureCollect(cur, "storage growth: CollectReward 20 staked positions", true)

	stakeBatch(cur, batch)
	measureCollect(cur, "storage growth: CollectReward 40 staked positions", true)

	stakeBatch(cur, batch)
	measureCollect(cur, "storage growth: CollectReward 60 staked positions", true)

	stakeBatch(cur, batch)
	measureCollect(cur, "storage growth: CollectReward 80 staked positions", true)

	stakeBatch(cur, batch)
	measureCollect(cur, "storage growth: CollectReward 100 staked positions", true)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)

	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), positionAddr, maxInt64)
	foo.Approve(cross(cur), positionAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
}

func createPoolAndTier(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, fee, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	staker.SetPoolTier(cross(cur), poolPath, 1)
}

// mintAndStake mints an identical [-60,60] position and stakes it, returning its id.
func mintAndStake(cur realm) uint64 {
	testing.SetRealm(adminRealm)
	positionId, _, _, _ := position.Mint(
		cross(cur),
		barPath, fooPath, fee,
		-60, 60,
		"5000000", "5000000",
		"0", "0",
		time.Now().Unix()+3600, adminAddr, "",
	)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(int(positionId))))
	staker.StakeToken(cross(cur), positionId, "")
	return positionId
}

// stakeBatch mints + stakes n positions, each at a new timestamp so every stake
// appends fresh entries to the pool's append-only trees. Its storage diff shows
// the (unbounded, never-pruned) staker growth per batch. The mint/stake calls are
// inlined (not routed through a helper) so cross(cur) resolves inside the closure.
func stakeBatch(cur realm, n int) {
	for i := 0; i < n; i++ {
		testing.SkipHeights(1)
		testing.SetRealm(adminRealm)
		positionId, _, _, _ := position.Mint(
			cross(cur),
			barPath, fooPath, fee,
			-60, 60,
			"5000000", "5000000",
			"0", "0",
			time.Now().Unix()+3600, adminAddr, "",
		)
		gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(int(positionId))))
		staker.StakeToken(cross(cur), positionId, "")
	}
}

// measureCollect collects the reference position over a constant short interval,
// so the only thing that changed between rounds is the size of the trees it reads.
func measureCollect(cur realm, label string, isMetric bool) {
	testing.SkipHeights(1)
	testing.SetRealm(adminRealm)
	if isMetric {
		metric.PrintMetricsBy(label, func() {
			staker.CollectReward(cross(cur), refId)
		})
	} else {
		staker.CollectReward(cross(cur), refId)
	}
}
