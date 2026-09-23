// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Measures implementation-local raw-reward and warmup reuse through the public
// CollectReward entry point. Four distinct external reward tokens share one
// pool, while their 90-day incentive windows start one day apart.
//
// The first collection is before incentives 3 and 4 start, so only incentives
// 1 and 2 advance their external cursors. The second collection discovers all
// four, uses the stake-time fallback for the two untouched cursors, and crosses
// the first five-day warmup boundary. A third collection repeats all four token
// paths after the boundary. Payout, penalty, cumulative accounting, transfer,
// and cursor assertions run outside each measured window.
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	"gno.land/p/gnoswap/gnsmath"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/staker"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/foo"
	"gno.land/r/onbloc/obl"
	"gno.land/r/onbloc/qux"

	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/scenario/metric"
)

const (
	secondsInDay int64 = 86400
	blockSeconds int64 = 5
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

	rewardTokens = []string{bazPath, quxPath, oblPath, barPath}

	incentiveStarts []int64
	incentiveEnds   []int64
	incentiveIDs    map[string]string

	positionID uint64
	stakeTime  int64

	expectedDistributed map[string]int64
	expectedPenalties   map[string]int64
	expectedCollected   map[string]int64
)

var t *testing.T

func main(cur realm) {
	initializeSetup(cur)
	createPoolAndIncentives(cur)
	mintAndStakePosition(cur)
	indexIncentives()

	// Incentives 1 and 2 have started; incentives 3 and 4 have not.
	skipUntil(incentiveStarts[1] + blockSeconds)
	rewards, penalties, before, after := collectRewardMetric(
		cur,
		"CollectReward reuse (2 active of 4; before 5-day warmup boundary)",
	)
	assertCollection(rewards, penalties, before, after, 2)
	assertFirstCursorMismatch()

	// All four incentives have started, and this timestamp is after the first
	// five-day warmup period for the staked position.
	skipUntil(incentiveStarts[0] + 5*secondsInDay + blockSeconds)
	rewards, penalties, before, after = collectRewardMetric(
		cur,
		"CollectReward reuse (4 active; crosses 5-day warmup boundary)",
	)
	assertCollection(rewards, penalties, before, after, 4)
	assertWarmupBoundaryCrossed()

	// Keep the same four-token workload after all cursors are aligned so the
	// repeated public collection remains directly comparable.
	skipUntil(incentiveStarts[0] + 6*secondsInDay + blockSeconds)
	rewards, penalties, before, after = collectRewardMetric(
		cur,
		"CollectReward reuse repeated (4 active; post-boundary)",
	)
	assertCollection(rewards, penalties, before, after, 4)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)

	// Pool tokens are accepted as external rewards; add the other three to the
	// staker allow-list.
	staker.AddToken(cross(cur), bazPath)
	staker.AddToken(cross(cur), quxPath)
	staker.AddToken(cross(cur), oblPath)

	start := (time.Now().Unix()/secondsInDay + 2) * secondsInDay
	incentiveStarts = make([]int64, len(rewardTokens))
	incentiveEnds = make([]int64, len(rewardTokens))
	for i := range rewardTokens {
		incentiveStarts[i] = start + int64(i)*secondsInDay
		incentiveEnds[i] = incentiveStarts[i] + 90*secondsInDay
	}

	// Approve pool tokens and every reward token to the contracts used by setup
	// and collection. GNS funds the external-incentive deposit.
	bar.Approve(cross(cur), poolAddr, maxInt64)
	foo.Approve(cross(cur), poolAddr, maxInt64)
	bar.Approve(cross(cur), stakerAddr, maxInt64)
	foo.Approve(cross(cur), stakerAddr, maxInt64)
	baz.Approve(cross(cur), stakerAddr, maxInt64)
	qux.Approve(cross(cur), stakerAddr, maxInt64)
	obl.Approve(cross(cur), stakerAddr, maxInt64)
	gns.Approve(cross(cur), stakerAddr, maxInt64)
}

func createPoolAndIncentives(cur realm) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross(cur), barPath, fooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())

	for i, rewardToken := range rewardTokens {
		staker.CreateExternalIncentive(
			cross(cur),
			poolPath(),
			rewardToken,
			1_000_000_000,
			incentiveStarts[i],
			incentiveEnds[i],
		)
	}
}

func mintAndStakePosition(cur realm) {
	testing.SetRealm(adminRealm)
	positionID, _, _, _ = position.Mint(
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
		adminAddr,
		"",
	)

	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.Itoa(int(positionID))))
	staker.StakeToken(cross(cur), positionID, "")
	stakeTime = mustAmount(staker.GetDepositStakeTime(positionID))
}

func indexIncentives() {
	incentiveIDs = make(map[string]string)
	incentives, err := staker.GetExternalIncentiveByPoolPath(poolPath())
	if err != nil {
		panic(err)
	}
	for _, incentive := range incentives {
		incentiveIDs[incentive.RewardToken()] = incentive.IncentiveId()
	}
	if len(incentiveIDs) != len(rewardTokens) {
		panic("expected four distinct external incentives")
	}

	expectedDistributed = make(map[string]int64)
	expectedPenalties = make(map[string]int64)
	expectedCollected = make(map[string]int64)
}

func poolPath() string {
	return barPath + ":" + fooPath + ":3000"
}

func skipUntil(target int64) {
	now := time.Now().Unix()
	if target > now {
		testing.SkipHeights((target-now)/blockSeconds + 1)
	}
}

func collectRewardMetric(cur realm, label string) (
	map[string]int64,
	map[string]int64,
	map[string]int64,
	map[string]int64,
) {
	testing.SetRealm(adminRealm)
	before := tokenBalances(adminAddr)
	var rewards map[string]int64
	var penalties map[string]int64

	metric.PrintMetricsBy(label, func() {
		_, _, rewards, penalties = staker.CollectReward(cross(cur), positionID)
	})

	after := tokenBalances(adminAddr)
	return rewards, penalties, before, after
}

func assertCollection(
	rewards, penalties, before, after map[string]int64,
	activeCount int,
) {
	active := 0
	for _, token := range rewardTokens {
		reward := rewards[token]
		penalty := penalties[token]
		if reward > 0 {
			active++
			if penalty <= 0 {
				panic("active external reward did not record a warmup penalty")
			}
			feeAmount := reward * int64(staker.GetUnstakingFee()) / 10000
			assertEqual(after[token]-before[token], reward-feeAmount, "user payout for "+token)
		} else {
			if penalty != 0 {
				panic("inactive token recorded an external penalty")
			}
			assertEqual(after[token]-before[token], int64(0), "inactive token transfer for "+token)
		}

		id := incentiveIDs[token]
		expectedDistributed[token] += reward
		expectedPenalties[token] += penalty
		expectedCollected[token] += reward + penalty

		assertEqual(
			mustAmount(staker.GetIncentiveDistributedRewardAmount(poolPath(), id)),
			expectedDistributed[token],
			"distributed reward for "+token,
		)
		assertEqual(
			mustAmount(staker.GetIncentiveAccumulatedPenaltyAmount(poolPath(), id)),
			expectedPenalties[token],
			"accumulated penalty for "+token,
		)
		assertEqual(
			mustAmount(staker.GetDepositCollectedExternalReward(positionID, id)),
			expectedCollected[token],
			"collected reward for "+token,
		)
	}

	if active != activeCount {
		panic("unexpected number of active external reward tokens")
	}
}

func assertFirstCursorMismatch() {
	for i, token := range rewardTokens {
		cursor := mustAmount(staker.GetDepositExternalRewardLastCollectTimestamp(positionID, incentiveIDs[token]))
		if i < 2 {
			if cursor <= stakeTime {
				panic("started incentive cursor did not advance")
			}
			continue
		}

		if cursor != stakeTime {
			panic("unstarted incentive cursor did not retain stake-time fallback")
		}
	}
}

func assertWarmupBoundaryCrossed() {
	warmups, err := staker.GetDepositWarmUp(positionID)
	if err != nil {
		panic(err)
	}

	firstBoundary := warmups[0].NextWarmupTime
	for _, token := range rewardTokens {
		if mustAmount(staker.GetDepositExternalRewardLastCollectTimestamp(positionID, incentiveIDs[token])) <= firstBoundary {
			panic("collection did not cross the first warmup boundary")
		}
	}
}

func tokenBalances(owner address) map[string]int64 {
	balances := make(map[string]int64)
	for _, token := range rewardTokens {
		balances[token] = tokenBalance(token, owner)
	}
	return balances
}

func tokenBalance(token string, owner address) int64 {
	switch token {
	case barPath:
		return bar.BalanceOf(owner)
	case bazPath:
		return baz.BalanceOf(owner)
	case quxPath:
		return qux.BalanceOf(owner)
	case oblPath:
		return obl.BalanceOf(owner)
	default:
		panic("unknown reward token")
	}
}

func assertEqual(got, want int64, label string) {
	if got != want {
		panic(label)
	}
}

func mustAmount(value int64, err error) int64 {
	if err != nil {
		panic(err)
	}
	return value
}
