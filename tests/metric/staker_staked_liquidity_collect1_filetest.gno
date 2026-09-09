// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// CollectReward measurements after a long public staked-liquidity history.
// The first and same-timestamp second collections are followed by a later
// collection, with every balance delta checked against the pre-call public
// collectable getters.
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	"gno.land/p/gnoswap/gnsmath"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	_ "gno.land/r/gnoswap/pool/v1"
	"gno.land/r/gnoswap/position"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/scenarioutils"
	"gno.land/r/gnoswap/staker"
	_ "gno.land/r/gnoswap/staker/v1"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/foo"
)

const (
	historyGrowthCycles       = 32
	incentiveCount            = 1
	maxInt64            int64 = 9223372036854775807
	rewardAmount        int64 = 1_000_000_000
	incentiveDuration   int64 = 90 * 24 * 60 * 60
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	barPath  = "gno.land/r/onbloc/bar.BAR"
	fooPath  = "gno.land/r/onbloc/foo.FOO"
	bazPath  = "gno.land/r/onbloc/baz.BAZ"
	poolPath = barPath + ":" + fooPath + ":3000"

	rewardTokens      = []string{bazPath}
	incentiveStart    int64
	incentiveEnd      int64
	positionID        uint64
	positionLiquidity string
)

type rewardSnapshot struct {
	internal int64
	external []int64
	ids      []string
}

type balanceSnapshot struct {
	gns      int64
	external []int64
}

func main(cur realm) {
	initializeSetup(cur)
	createPoolAndTier(cur)
	mintPosition(cur)
	createExternalIncentives(cur)
	stakePosition(cur)
	growHistory(cur)
	collectRewardMetrics(cur)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	staker.SetUnStakingFee(cross(cur), 0)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	staker.AddToken(cross(cur), bazPath)
	testing.SkipHeights(1)

	bar.Transfer(cross(cur), aliceAddr, 100_000_000_000)
	foo.Transfer(cross(cur), aliceAddr, 100_000_000_000)
	baz.Transfer(cross(cur), aliceAddr, rewardAmount)
	gns.Transfer(cross(cur), aliceAddr, staker.GetDepositGnsAmount()*incentiveCount)
}

func createPoolAndTier(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
	staker.SetPoolTier(cross(cur), poolPath, 1)
	testing.SkipHeights(1)
}

func mintPosition(cur realm) {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	positionID, positionLiquidity, _, _ = position.Mint(
		cross(cur),
		barPath,
		fooPath,
		3000,
		-60,
		60,
		"5000000",
		"5000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		aliceAddr,
		"",
	)
	if positionLiquidity == "0" {
		panic("position mint did not produce liquidity")
	}
}

func createExternalIncentives(cur realm) {
	testing.SetRealm(aliceRealm)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	baz.Approve(cross(cur), stakerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64)

	incentiveStart = (time.Now().Unix()/86400 + 2) * 86400
	incentiveEnd = incentiveStart + incentiveDuration
	staker.CreateExternalIncentive(
		cross(cur),
		poolPath,
		bazPath,
		rewardAmount,
		incentiveStart,
		incentiveEnd,
	)
	testing.SkipHeights((incentiveStart-time.Now().Unix())/5 + 1)
}

func stakePosition(cur realm) {
	testing.SetRealm(aliceRealm)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(positionID, 10)))
	staker.StakeToken(cross(cur), positionID, "")
	if !staker.IsStaked(positionID) || poolLiquidity() != positionLiquidity {
		panic("initial stake did not establish expected liquidity")
	}
}

func growHistory(cur realm) {
	testing.SetRealm(aliceRealm)
	for i := 0; i < historyGrowthCycles; i++ {
		testing.SkipHeights(1)
		staker.UnStakeToken(cross(cur), positionID)
		if staker.IsStaked(positionID) || poolLiquidity() != "0" {
			panic("history growth unstake did not clear liquidity")
		}

		testing.SkipHeights(1)
		gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(positionID, 10)))
		staker.StakeToken(cross(cur), positionID, "")
		if !staker.IsStaked(positionID) || poolLiquidity() != positionLiquidity {
			panic("history growth restake did not restore liquidity")
		}
	}
	testing.SkipHeights(1)
}

func collectRewardMetrics(cur realm) {
	testing.SetRealm(aliceRealm)
	beforeExpected := readRewardSnapshot()
	beforeBalances := readBalances()
	if len(beforeExpected.ids) != incentiveCount || !hasPositiveExternal(beforeExpected) {
		panic("active external incentive did not produce a collectable reward")
	}

	metric.PrintMetricsBy("StakedLiquidity RewardCollect external=1 history-grown first", func() {
		staker.CollectReward(cross(cur), positionID)
	})
	afterFirstBalances := readBalances()
	assertBalanceDelta(beforeBalances, afterFirstBalances, beforeExpected)
	assertZeroReward(readRewardSnapshot())

	secondBefore := readBalances()
	metric.PrintMetricsBy("StakedLiquidity RewardCollect external=1 history-grown same-time second", func() {
		staker.CollectReward(cross(cur), positionID)
	})
	assertSameBalances(secondBefore, readBalances())
	assertZeroReward(readRewardSnapshot())

	testing.SkipHeights(1)
	laterExpected := readRewardSnapshot()
	laterBalances := readBalances()
	if !hasPositiveExternal(laterExpected) {
		panic("later active interval did not produce a collectable external reward")
	}
	metric.PrintMetricsBy("StakedLiquidity RewardCollect external=1 history-grown later", func() {
		staker.CollectReward(cross(cur), positionID)
	})
	assertBalanceDelta(laterBalances, readBalances(), laterExpected)
	assertZeroReward(readRewardSnapshot())
	assertFinalState()
}

func assertFinalState() {
	if !staker.IsStaked(positionID) || poolLiquidity() != positionLiquidity {
		panic("position liquidity changed after reward collection")
	}
	if owner := gnft.MustOwnerOf(grc721.TokenID(strconv.FormatUint(positionID, 10))); owner != stakerAddr {
		panic("reward collection changed NFT ownership")
	}
	if owner := depositOwner(); owner != aliceAddr {
		panic("reward collection changed deposit ownership")
	}
}

func poolLiquidity() string {
	got, err := staker.GetPoolStakedLiquidity(poolPath)
	if err != nil {
		panic(err.Error())
	}
	return got
}

func depositOwner() address {
	owner, err := staker.GetDepositOwner(positionID)
	if err != nil {
		panic(err.Error())
	}
	return owner
}

func incentiveRewardToken(id string) string {
	token, err := staker.GetIncentiveRewardToken(poolPath, id)
	if err != nil {
		panic(err.Error())
	}
	return token
}

func readRewardSnapshot() rewardSnapshot {
	ids, err := staker.GetDepositExternalIncentiveIdList(positionID)
	if err != nil {
		panic(err.Error())
	}
	external := make([]int64, len(ids))
	for i, id := range ids {
		amount, err := staker.CollectableExternalIncentiveReward(positionID, id)
		if err != nil {
			panic(err.Error())
		}
		external[i] = amount
	}
	internal, err := staker.CollectableEmissionReward(positionID)
	if err != nil {
		panic(err.Error())
	}
	return rewardSnapshot{internal: internal, external: external, ids: ids}
}

func readBalances() balanceSnapshot {
	return balanceSnapshot{
		gns:      gns.BalanceOf(aliceAddr),
		external: []int64{common.BalanceOf(bazPath, aliceAddr)},
	}
}

func hasPositiveExternal(snapshot rewardSnapshot) bool {
	for _, amount := range snapshot.external {
		if amount > 0 {
			return true
		}
	}
	return false
}

func assertBalanceDelta(before, after balanceSnapshot, expected rewardSnapshot) {
	if after.gns-before.gns != expected.internal {
		panic("GNS balance delta did not match collectable internal reward")
	}
	for i, id := range expected.ids {
		path := incentiveRewardToken(id)
		if path != bazPath {
			panic("unexpected reward token for one-token incentive")
		}
		if after.external[0]-before.external[0] != expected.external[i] {
			panic("external balance delta did not match collectable reward")
		}
	}
}

func assertSameBalances(before, after balanceSnapshot) {
	if before.gns != after.gns || before.external[0] != after.external[0] {
		panic("same-timestamp second collect changed balances")
	}
}

func assertZeroReward(snapshot rewardSnapshot) {
	if snapshot.internal != 0 {
		panic("internal reward remained claimable after collection")
	}
	for _, amount := range snapshot.external {
		if amount != 0 {
			panic("external reward remained claimable after collection")
		}
	}
}
