// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Issue #1 verification: CollectReward gas scales linearly with the number of
// processed reward items (external-incentive reward tokens), independent of time.
//
// Setup keeps everything identical across four pools (same token pair, same
// position range/size, same stake time, same elapsed active time, same warmup
// state) and varies ONLY the number of distinct external-incentive reward
// tokens (1, 2, 3, 4). CollectReward then iterates one item per reward token,
// so a roughly constant per-token gas increment confirms the report's claim
// that tx gas is dominated by the number of processed items.
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
	"gno.land/r/gnoswap/gnft"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/foo"
	"gno.land/r/onbloc/obl"
	"gno.land/r/onbloc/qux"

	"gno.land/r/gnoswap/gns"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	barPath = "gno.land/r/onbloc/bar.BAR"
	fooPath = "gno.land/r/onbloc/foo.FOO"
	bazPath = "gno.land/r/onbloc/baz.BAZ"
	quxPath = "gno.land/r/onbloc/qux.QUX"
	oblPath = "gno.land/r/onbloc/obl.OBL"

	maxInt64 int64 = 9223372036854775807

	// distinct reward tokens; setup for k items uses the first k of these
	rewardTokens = []string{bazPath, quxPath, oblPath, barPath}

	// absolute incentive window shared by every pool so that active duration at
	// collect time is identical regardless of when each incentive was created.
	incentiveStart int64
	incentiveEnd   int64

	// captured staked position ids, one per pool
	stakedIds []uint64
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)

	// One pool per fee tier, each with k external-incentive reward tokens.
	// Fee tier only distinguishes the pools; it does not affect the reward loop.
	setupPool(cur, 100, 1)   // 1 reward token
	setupPool(cur, 500, 2)   // 2 reward tokens
	setupPool(cur, 3000, 3)  // 3 reward tokens
	setupPool(cur, 10000, 4) // 4 reward tokens

	// Advance once into the active incentive window; identical for all pools.
	nowSec := time.Now().Unix()
	testing.SkipHeights((incentiveStart-nowSec)/5 + (86400 / 5)) // reach start + 1 day

	collectMetrics(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	// allow the reward tokens for external incentives (default allows only GNS/WUGNOT)
	staker.AddToken(cross(cur), bazPath)
	staker.AddToken(cross(cur), quxPath)
	staker.AddToken(cross(cur), oblPath)
	staker.AddToken(cross(cur), barPath)

	// midnight-aligned start, 90 day duration (staker requires 90/180/365 days)
	incentiveStart = (time.Now().Unix()/86400 + 1) * 86400
	incentiveEnd = incentiveStart + 86400*90

	// approve pool tokens and every reward token to pool + staker
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
	baz.Approve(cross(cur), stakerAddr, maxInt64)
	qux.Approve(cross(cur), stakerAddr, maxInt64)
	obl.Approve(cross(cur), stakerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64) // external incentive deposit fee
}

// setupPool creates a bar:foo pool at the given fee, attaches `count` external
// incentives with distinct reward tokens, mints an identical position, and stakes it.
func setupPool(cur realm, fee uint32, count int) {
	testing.SetRealm(adminRealm)

	pool.CreatePool(cross(cur), barPath, fooPath, fee, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())

	poolPath := barPath + ":" + fooPath + ":" + strconv.Itoa(int(fee))
	for i := 0; i < count; i++ {
		staker.CreateExternalIncentive(
			cross(cur),
			poolPath,
			rewardTokens[i],
			1_000_000_000,
			incentiveStart,
			incentiveEnd,
		)
	}

	positionId, _, _, _ := position.Mint(
		cross(cur),
		barPath,
		fooPath,
		fee,
		-600, // multiple of every fee tier's tick spacing (1/10/60/200)
		600,
		"5000000",
		"5000000",
		"1",
		"1",
		time.Now().Unix()+3600,
		adminAddr,
		"",
	)

	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(int(positionId))))
	staker.StakeToken(cross(cur), positionId, "")

	stakedIds = append(stakedIds, positionId)
}

func collectMetrics(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy("staker CollectReward (1 external-incentive token)", func() {
		staker.CollectReward(cross(cur), stakedIds[0])
	})
	metric.PrintMetricsBy("staker CollectReward (2 external-incentive tokens)", func() {
		staker.CollectReward(cross(cur), stakedIds[1])
	})
	metric.PrintMetricsBy("staker CollectReward (3 external-incentive tokens)", func() {
		staker.CollectReward(cross(cur), stakedIds[2])
	})
	metric.PrintMetricsBy("staker CollectReward (4 external-incentive tokens)", func() {
		staker.CollectReward(cross(cur), stakedIds[3])
	})
}
