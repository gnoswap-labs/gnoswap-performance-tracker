// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for staker collect reward when the external
// incentive discovery scan has to walk incentives that belong to OTHER pools.
//
// This isolates the cost optimized by gnoswap-labs/gnoswap#1372. Before that
// PR, external incentives are held in a single global creation-time index
// (creationTime -> poolPath -> []incentiveId) and CollectReward discovers a
// pool's incentives via getExternalIncentiveIdsBy, which iterates EVERY
// creation-time bucket in the window and probes the queried pool at each one.
// So a pool with a single incentive still pays to walk every incentive created
// system-wide. #1372 re-keys the index per pool, bounding discovery to the
// queried pool's own incentives.
//
// Setup: the target pool (bar:foo:3000) holds exactly ONE incentive, while a
// noise pool (bar:foo:100) holds `crossPoolIncentiveCount` incentives created
// at DISTINCT block times so each lands in its own global creation-time bucket.
// The measured CollectReward runs on the target pool. Compare its 1st-collect
// gas across the pre/post-#1372 commits: pre-#1372 it scales with the noise
// count, post-#1372 it should not.
package main

import (
	"gno.land/p/gnoswap/gnsmath"
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/r/gnoswap/emission"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/staker"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"

	"gno.land/r/gnoswap/gns"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath = "gno.land/r/onbloc/bar.BAR"
	fooPath = "gno.land/r/onbloc/foo.FOO"

	// target pool: holds a single external incentive; CollectReward is measured here.
	poolPath = barPath + ":" + fooPath + ":3000"
	// noise pool: holds many external incentives that are irrelevant to the
	// target pool but still sit in the shared global creation-time index.
	noisePoolPath = barPath + ":" + fooPath + ":100"

	maxInt64 int64 = 9223372036854775807

	// number of unrelated (other-pool) incentives seeded into the global index.
	crossPoolIncentiveCount = 30

	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createPoolSetup(cur)
	createNoisePoolSetup(cur)
	mintPositionSetup(cur)
	setPoolTierSetup(cur)
	stakeTokenSetup(cur)
	createIncentivesSetup(cur)

	testing.SkipHeights(1)
	collectRewardMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(1)

	// Fund alice enough to bankroll one target incentive plus every noise
	// incentive: each incentive costs its reward amount (bar) + the GNS deposit.
	bar.Transfer(cross(cur), aliceAddr, 100_000_000_000)
	foo.Transfer(cross(cur), aliceAddr, 10_000_000_000)
	gns.Transfer(cross(cur), aliceAddr, 100_000_000_000)

	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64)

	testing.SetRealm(aliceRealm)
	gns.Approve(cross(cur), stakerAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
}

func createPoolSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
}

func createNoisePoolSetup(cur realm) {
	testing.SetRealm(adminRealm)
	// Same token pair at a different fee tier => a distinct poolPath that shares
	// the global creation-time index but is unrelated to the target pool.
	pool.CreatePool(cross(cur), barPath, fooPath, 100, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
}

func mintPositionSetup(cur realm) {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)

	position.Mint(
		cross(cur),
		barPath,
		fooPath,
		3000,
		-60,
		60,
		"5000000",
		"5000000",
		"1",
		"1",
		time.Now().Unix()+3600,
		aliceAddr,
		"",
	)
}

func setPoolTierSetup(cur realm) {
	testing.SetRealm(adminRealm)
	staker.SetPoolTier(cross(cur), poolPath, 1)
}

func stakeTokenSetup(cur realm) {
	testing.SetRealm(aliceRealm)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(1)))

	staker.StakeToken(cross(cur), uint64(1), "")
}

func createIncentivesSetup(cur realm) {
	testing.SetRealm(aliceRealm)

	// Incentives are created AFTER staking so they fall inside the deposit's
	// first-collect discovery window. Start time is shared; creation times
	// differ per block, which is what produces distinct global index buckets.
	incentiveStartTime := time.Now().AddDate(0, 0, 1).Truncate(24 * time.Hour).Unix()
	incentiveEndTime := incentiveStartTime + TIMESTAMP_90DAYS

	// One incentive on the target pool (the reward the deposit actually earns).
	staker.CreateExternalIncentive(
		cross(cur),
		poolPath,
		barPath,
		1_000_000_000,
		incentiveStartTime,
		incentiveEndTime,
	)

	// Many incentives on the noise pool, each at a distinct creation time so it
	// occupies its own bucket in the shared global creation-time index.
	for i := 0; i < crossPoolIncentiveCount; i++ {
		testing.SkipHeights(1)
		staker.CreateExternalIncentive(
			cross(cur),
			noisePoolPath,
			barPath,
			1_000_000_000,
			incentiveStartTime,
			incentiveEndTime,
		)
	}

	// Advance to the incentive start so rewards accrue for the target position.
	testing.SkipHeights((incentiveStartTime-time.Now().Unix())/5 + 1)
}

func collectRewardMetric(cur realm) {
	testing.SetRealm(aliceRealm)

	// 1st collect: discovery walks the whole global creation-time window, i.e.
	// the target bucket plus every noise bucket. This is the number #1372 cuts.
	metric.PrintMetricsBy("CollectReward Target Pool With 30 Cross-Pool Incentives (1st)", func() {
		staker.CollectReward(cross(cur), uint64(1))
	})

	testing.SkipHeights(1)

	// 2nd collect: the deposit's incentive list is already populated and the
	// discovery window has shrunk, so this pays little of the scan cost.
	metric.PrintMetricsBy("CollectReward Target Pool With 30 Cross-Pool Incentives (2nd)", func() {
		staker.CollectReward(cross(cur), uint64(1))
	})
}
