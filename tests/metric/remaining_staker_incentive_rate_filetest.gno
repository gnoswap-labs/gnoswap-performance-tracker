// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and storage metrics for the persisted external-incentive Q128 reward rate.
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	"gno.land/p/gnoswap/gnsmath"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/staker"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"
)

const incentiveRate90Days int64 = 90 * 24 * 60 * 60

var (
	incentiveRateAdmin, _  = access.GetAddress(prabc.ROLE_ADMIN.String())
	incentiveRateRealm     = testing.NewUserRealm(incentiveRateAdmin)
	incentiveRatePool, _   = access.GetAddress(prabc.ROLE_POOL.String())
	incentiveRateStaker, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	incentiveRateAlice      = testutils.TestAddress("alice")
	incentiveRateAliceRealm = testing.NewUserRealm(incentiveRateAlice)

	incentiveRateBarPath  = "gno.land/r/onbloc/bar.BAR"
	incentiveRateFooPath  = "gno.land/r/onbloc/foo.FOO"
	incentiveRatePoolPath = incentiveRateBarPath + ":" + incentiveRateFooPath + ":3000"

	incentiveRateMaxInt64 int64 = 9223372036854775807
	incentiveRateAmount   int64 = 1_000_000_000_000
	incentiveRateStart    int64
	incentiveRateEnd      int64
	incentiveRateID       string
	incentiveCancelID     string
)

func main(cur realm) {
	initializeIncentiveRate(cur)
	createIncentiveRatePool(cur)
	mintIncentiveRatePosition(cur)
	setIncentiveRatePoolTier(cur)
	stakeIncentiveRatePosition(cur)
	createIncentivesForRate(cur)
	queryIncentiveRate(cur)
	cancelBeforeStartMetric(cur)
	collectIncentiveRateMetrics(cur)
	endIncentiveRateMetric(cur)
	cleanupIncentiveRatePosition(cur)
}

func initializeIncentiveRate(cur realm) {
	testing.SetRealm(incentiveRateRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	bar.Transfer(cross(cur), incentiveRateAlice, incentiveRateAmount+100000000)
	foo.Transfer(cross(cur), incentiveRateAlice, 1_100_000_000)
	gns.Transfer(cross(cur), incentiveRateAlice, staker.GetDepositGnsAmount()*2)

	bar.Approve(cross(cur), incentiveRatePool, incentiveRateMaxInt64)
	foo.Approve(cross(cur), incentiveRatePool, incentiveRateMaxInt64)
	bar.Approve(cross(cur), incentiveRateStaker, incentiveRateMaxInt64)
	foo.Approve(cross(cur), incentiveRateStaker, incentiveRateMaxInt64)

	// BAR and FOO are non-default external reward tokens in a fresh realm.
	staker.AddToken(cross(cur), incentiveRateBarPath)
	staker.AddToken(cross(cur), incentiveRateFooPath)

	testing.SetRealm(incentiveRateAliceRealm)
	bar.Approve(cross(cur), incentiveRateStaker, incentiveRateMaxInt64)
	foo.Approve(cross(cur), incentiveRateStaker, incentiveRateMaxInt64)
	gns.Approve(cross(cur), incentiveRateStaker, incentiveRateMaxInt64)
}

func createIncentiveRatePool(cur realm) {
	testing.SetRealm(incentiveRateRealm)
	pool.CreatePool(cross(cur), incentiveRateBarPath, incentiveRateFooPath, 3000, gnsmath.TickMathGetSqrtRatioAtTick(0).ToString())
}

func mintIncentiveRatePosition(cur realm) {
	testing.SetRealm(incentiveRateAliceRealm)
	bar.Approve(cross(cur), incentiveRatePool, incentiveRateMaxInt64)
	foo.Approve(cross(cur), incentiveRatePool, incentiveRateMaxInt64)
	position.Mint(
		cross(cur),
		incentiveRateBarPath,
		incentiveRateFooPath,
		3000,
		-60,
		60,
		"5000000",
		"5000000",
		"1",
		"1",
		time.Now().Unix()+3600,
		incentiveRateAlice,
		"",
	)
}

func setIncentiveRatePoolTier(cur realm) {
	testing.SetRealm(incentiveRateRealm)
	staker.SetPoolTier(cross(cur), incentiveRatePoolPath, 1)
}

func stakeIncentiveRatePosition(cur realm) {
	testing.SetRealm(incentiveRateAliceRealm)
	gnft.Approve(cross(cur), incentiveRateStaker, grc721.TokenID(strconv.Itoa(1)))
	staker.StakeToken(cross(cur), 1, "")
}

func createIncentivesForRate(cur realm) {
	incentiveRateStart = (time.Now().Unix()/86400 + 2) * 86400
	incentiveRateEnd = incentiveRateStart + incentiveRate90Days
	testing.SetRealm(incentiveRateAliceRealm)
	metric.PrintMetricsBy("Remaining staker incentive rate allocation CreateExternalIncentive", func() {
		staker.CreateExternalIncentive(cross(cur), incentiveRatePoolPath, incentiveRateBarPath, incentiveRateAmount, incentiveRateStart, incentiveRateEnd)
	})

	incentives, err := staker.GetExternalIncentiveByPoolPath(incentiveRatePoolPath)
	if err != nil {
		panic(err)
	}
	if len(incentives) != 1 {
		panic("expected one primary external incentive")
	}
	incentiveRateID = incentives[0].IncentiveId()

	// A sibling reward token supplies a real not-yet-started cancellation control.
	metric.PrintMetricsBy("Remaining staker incentive rate allocation CreateExternalIncentive sibling", func() {
		staker.CreateExternalIncentive(cross(cur), incentiveRatePoolPath, incentiveRateFooPath, 1000000000, incentiveRateStart, incentiveRateEnd)
	})
	incentives, err = staker.GetExternalIncentiveByPoolPath(incentiveRatePoolPath)
	if err != nil {
		panic(err)
	}
	for _, incentive := range incentives {
		if incentive.RewardToken() == incentiveRateFooPath {
			incentiveCancelID = incentive.IncentiveId()
		}
	}
	if incentiveCancelID == "" {
		panic("missing cancellation control incentive")
	}
}

func queryIncentiveRate(cur realm) {
	testing.SetRealm(incentiveRateAliceRealm)
	metric.PrintMetricsBy("Remaining staker incentive rate query 1", func() {
		rate, err := staker.GetIncentiveRewardPerSecondX128(incentiveRatePoolPath, incentiveRateID)
		if err != nil {
			panic(err)
		}
		_ = rate
	})
	metric.PrintMetricsBy("Remaining staker incentive rate query 10", func() {
		for i := 0; i < 10; i++ {
			rate, err := staker.GetIncentiveRewardPerSecondX128(incentiveRatePoolPath, incentiveRateID)
			if err != nil {
				panic(err)
			}
			_ = rate
		}
	})
	metric.PrintMetricsBy("Remaining staker incentive rate query 100", func() {
		for i := 0; i < 100; i++ {
			rate, err := staker.GetIncentiveRewardPerSecondX128(incentiveRatePoolPath, incentiveRateID)
			if err != nil {
				panic(err)
			}
			_ = rate
		}
	})

	rate, err := staker.GetIncentiveRewardPerSecondX128(incentiveRatePoolPath, incentiveRateID)
	if err != nil {
		panic(err)
	}
	println("- State: incentive_id=" + incentiveRateID + " reward_per_second_x128=" + rate.ToString())
}

func cancelBeforeStartMetric(cur realm) {
	testing.SetRealm(incentiveRateAliceRealm)
	metric.PrintMetricsBy("Remaining staker incentive rate lifecycle CancelExternalIncentive before start", func() {
		staker.CancelExternalIncentive(cross(cur), incentiveRatePoolPath, incentiveCancelID)
	})
	incentives, err := staker.GetExternalIncentiveByPoolPath(incentiveRatePoolPath)
	if err != nil {
		panic(err)
	}
	if len(incentives) != 1 {
		panic("cancelled incentive remained in pool index")
	}
	println("- State: cancel_before_start=true foo_balance=" + strconv.FormatInt(foo.BalanceOf(incentiveRateAlice), 10) + " gns_balance=" + strconv.FormatInt(gns.BalanceOf(incentiveRateAlice), 10))
}

func collectIncentiveRateMetrics(cur realm) {
	testing.SetRealm(incentiveRateAliceRealm)
	metric.PrintMetricsBy("Remaining staker incentive rate repeat pre-start zero 1", func() {
		staker.CollectReward(cross(cur), 1)
	})

	testing.SkipHeights((incentiveRateStart-time.Now().Unix())/5 + 2)
	for _, count := range []int{1, 10, 100} {
		for i := 0; i < count; i++ {
			testing.SkipHeights(1)
			before := bar.BalanceOf(incentiveRateAlice)
			var collected int64
			metric.PrintMetricsBy("Remaining staker incentive rate repeat accrued "+strconv.Itoa(count)+" call "+strconv.Itoa(i+1), func() {
				collected, _ = staker.CollectExternalIncentiveReward(cross(cur), 1, incentiveRateID)
			})
			fee := gnsmath.SafeMulDivInt64(collected, int64(staker.GetUnstakingFee()), 10000)
			if collected <= 0 || bar.BalanceOf(incentiveRateAlice)-before != collected-fee {
				panic("accrued incentive payout did not match the returned gross reward minus its fee")
			}
		}
	}
}

func endIncentiveRateMetric(cur realm) {
	testing.SetRealm(incentiveRateAliceRealm)
	testing.SkipHeights((incentiveRateEnd-time.Now().Unix())/5 + 2)
	metric.PrintMetricsBy("Remaining staker incentive rate lifecycle EndExternalIncentive", func() {
		staker.EndExternalIncentive(cross(cur), incentiveRatePoolPath, incentiveRateID, incentiveRateAlice)
	})
	refunded, err := staker.GetIncentiveRefunded(incentiveRatePoolPath, incentiveRateID)
	if err != nil {
		panic(err)
	}
	println("- State: incentive_refunded=" + strconv.FormatBool(refunded) + " bar_balance=" + strconv.FormatInt(bar.BalanceOf(incentiveRateAlice), 10))
}

func cleanupIncentiveRatePosition(cur realm) {
	testing.SetRealm(incentiveRateAliceRealm)
	metric.PrintMetricsBy("Remaining staker incentive rate lifecycle UnStakeToken cleanup", func() {
		staker.UnStakeToken(cross(cur), 1)
	})
	if staker.IsStaked(1) {
		panic("position remained staked after incentive cleanup")
	}
	println("- State: position_staked=false")
}
