// PKGPATH: gno.land/r/gnoswap/scenario/stress/main

// Gas and performance metrics for EndExternalIncentive with many accumulated unclaimable periods.
//
// A single position is repeatedly unstaked/restaked inside the incentive window,
// leaving one disjoint zero-liquidity (unclaimable) gap per cycle. Before the
// O(1) accumulator fix, the refund path scanned the pool's unbounded
// unclaimablePeriods tree, so EndExternalIncentive gas grew linearly with the
// number of accumulated periods. This benchmark makes that scaling visible:
// compare this report across the fix commits and the Gas Used for the labeled
// EndExternalIncentive call should collapse to a near-constant regardless of the
// unclaimablePeriods count (see the 10 / 50 / 100 variants).
package main

import (
	"gno.land/p/gnoswap/gnsmath"
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/emission"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/staker"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath  = "gno.land/r/onbloc/bar.BAR"
	fooPath  = "gno.land/r/onbloc/foo.FOO"
	poolPath = barPath + ":" + fooPath + ":3000"

	maxInt64 int64 = 9223372036854775807

	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60

	incentiveStartTime int64
	incentiveEndTime   int64
	incentiveID        string
	stakedTokenId      uint64
)

// unclaimablePeriodCount is the number of disjoint unclaimable gaps accumulated
// in the pool before the refund. Each stake/unstake cycle produces exactly one.
const unclaimablePeriodCount = 10

func main(cur realm) {
	initializeSetup(cur)
	createPoolAndSetTier(cur)
	createExternalIncentive(cur)
	stakeAtIncentiveStart(cur)
	accumulateUnclaimablePeriods(cur)
	endExternalIncentiveMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	staker.SetUnStakingFee(cross(cur), 0)

	bar.Transfer(cross(cur), aliceAddr, 10000000000000)
	foo.Transfer(cross(cur), aliceAddr, 10000000000000)

	testing.SetRealm(aliceRealm)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)

	testing.SetRealm(adminRealm)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64)
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func createPoolAndSetTier(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	staker.SetPoolTier(cross(cur), poolPath, 1)
}

func createExternalIncentive(cur realm) {
	testing.SetRealm(adminRealm)

	incentiveStartTime = time.Now().AddDate(0, 0, 1).Truncate(24 * time.Hour).Unix()
	incentiveEndTime = incentiveStartTime + TIMESTAMP_90DAYS

	// incentiveID is creator:createTimestamp:counter; capture it at creation time.
	createTimestamp := time.Now().Unix()
	incentiveID = ufmt.Sprintf("%s:%d:%d", adminAddr, createTimestamp, 1)

	staker.CreateExternalIncentive(
		cross(cur),
		poolPath,
		barPath,
		1_000_000_000,
		incentiveStartTime,
		incentiveEndTime,
	)

	// Move chain time to the incentive start so every cycle below lands inside
	// the incentive window.
	testing.SkipHeights((incentiveStartTime-time.Now().Unix())/5 + 1)
}

func stakeAtIncentiveStart(cur realm) {
	testing.SetRealm(aliceRealm)

	tokenId, _, _, _ := position.Mint(
		cross(cur),
		barPath,
		fooPath,
		3000,
		-600,
		600,
		"1000000",
		"1000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		aliceAddr,
		"",
	)
	stakedTokenId = tokenId

	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
	staker.StakeToken(cross(cur), tokenId, "")
	testing.SkipHeights(1)
}

// accumulateUnclaimablePeriods runs unstake/restake cycles. Each cycle drops the
// pool's staked liquidity to zero (opening an unclaimable period) and then back
// to positive (closing it), leaving one disjoint closed period per cycle. A gap
// in block time between unstake and restake is required so the period's start
// and end timestamps differ (equal timestamps are dropped, not recorded).
func accumulateUnclaimablePeriods(cur realm) {
	testing.SetRealm(aliceRealm)

	tokenID := grc721.TokenID(strconv.FormatUint(stakedTokenId, 10))

	for i := 0; i < unclaimablePeriodCount; i++ {
		testing.SkipHeights(2) // staked run
		staker.UnStakeToken(cross(cur), stakedTokenId)

		testing.SkipHeights(2) // unclaimable gap (start != end)
		gnft.Approve(cross(cur), stakerAddr, tokenID)
		staker.StakeToken(cross(cur), stakedTokenId, "")
	}

	// Skip past incentive end without collecting so the whole window (minus the
	// accumulated gaps) is refundable.
	testing.SkipHeights((incentiveEndTime-time.Now().Unix())/5 + 100)
}

func endExternalIncentiveMetric(cur realm) {
	testing.SetRealm(adminRealm)

	metric.PrintMetricsBy(ufmt.Sprintf("stress EndExternalIncentive (unclaimablePeriods=%d)", unclaimablePeriodCount), func() {
		staker.EndExternalIncentive(cross(cur), poolPath, incentiveID, adminAddr)
	})
}
