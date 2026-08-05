// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and performance metrics for staker collect reward
// Test cases based on tests/integration/testdata/staker/collect_reward_immediately_after_stake_token.txtar
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/gnoswap/gnsmath"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/r/gnoswap/emission"
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

	barPath = "gno.land/r/onbloc/bar.BAR"
	fooPath = "gno.land/r/onbloc/foo.FOO"

	maxInt64 int64 = 9223372036854775807
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createPoolMetric(cur)
	mintPositionMetric(cur)
	setPoolTierSetup(cur)
	stakeTokenSetup(cur)

	testing.SkipHeights(1)
	collectRewardMetric(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(1)

	bar.Transfer(cross(cur), aliceAddr, 100000000)
	foo.Transfer(cross(cur), aliceAddr, 100000000)

	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
}

func createPoolMetric(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
}

func mintPositionMetric(cur realm) {
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

	poolPath := barPath + ":" + fooPath + ":3000"
	staker.SetPoolTier(cross(cur), poolPath, 1)
}

func stakeTokenSetup(cur realm) {
	testing.SetRealm(aliceRealm)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(1)))
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(2)))
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(3)))
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(4)))

	staker.StakeToken(cross(cur), uint64(1), "")
	staker.StakeToken(cross(cur), uint64(2), "")
	staker.StakeToken(cross(cur), uint64(3), "")
	staker.StakeToken(cross(cur), uint64(4), "")
}

func collectRewardMetric(cur realm) {
	testing.SetRealm(aliceRealm)

	secondsInDay := int64(86400)
	blockTime := int64(5)

	testing.SkipHeights(1)

	metric.PrintMetricsBy("CollectReward with Warmup Range (30% ~ 30%)", func() {
		staker.CollectReward(cross(cur), uint64(1))
	})

	testing.SkipHeights(5 * secondsInDay / blockTime) // 5 days

	metric.PrintMetricsBy("CollectReward with Warmup Range (30% ~ 50%)", func() {
		staker.CollectReward(cross(cur), uint64(2))
	})

	testing.SkipHeights(10 * secondsInDay / blockTime) // total 15 days (10 days + 5 days)

	metric.PrintMetricsBy("CollectReward with Warmup Range (30% ~ 70%)", func() {
		staker.CollectReward(cross(cur), uint64(3))
	})

	testing.SkipHeights(30 * secondsInDay / blockTime) // total 45 days (30 days + 5 days)

	metric.PrintMetricsBy("CollectReward with Warmup Range (30% ~ 100%)", func() {
		staker.CollectReward(cross(cur), uint64(4))
	})

	testing.SkipHeights(secondsInDay / blockTime) // total 46 days
	staker.CollectReward(cross(cur), uint64(1))
	testing.SkipHeights(secondsInDay / blockTime) // total 47 days

	metric.PrintMetricsBy("CollectReward with Warmup Range (100% ~)", func() {
		staker.CollectReward(cross(cur), uint64(1))
	})

	testing.SkipHeights(1)

	metric.PrintMetricsBy("CollectReward with Warmup Range 2nd (100% ~)", func() {
		staker.CollectReward(cross(cur), uint64(1))
	})
}
