// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Gas and storage metrics for the persisted staker Deposit liquidity field.
package main

import (
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
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/scenarioutils"
	"gno.land/r/gnoswap/staker"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/foo"
)

var (
	depositAdmin, _  = access.GetAddress(prabc.ROLE_ADMIN.String())
	depositRealm     = testing.NewUserRealm(depositAdmin)
	depositPool, _   = access.GetAddress(prabc.ROLE_POOL.String())
	depositStaker, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	depositAlice      = testutils.TestAddress("alice")
	depositAliceRealm = testing.NewUserRealm(depositAlice)

	depositBarPath  = "gno.land/r/onbloc/bar.BAR"
	depositFooPath  = "gno.land/r/onbloc/foo.FOO"
	depositPoolPath = depositBarPath + ":" + depositFooPath + ":3000"

	depositMaxInt64 int64 = 9223372036854775807
)

func main(cur realm) {
	initializeDepositLiquidity(cur)
	createDepositPool(cur)
	mintDepositPosition(cur)
	setDepositPoolTier(cur)
	stakeDepositPosition(cur)
	collectDepositRewardMetrics(cur)
	queryDepositLiquidityMetrics(cur)
	unstakeDepositPosition(cur)
}

func initializeDepositLiquidity(cur realm) {
	testing.SetRealm(depositRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(1)

	bar.Transfer(cross(cur), depositAlice, 10000000000)
	foo.Transfer(cross(cur), depositAlice, 10000000000)
	gns.Transfer(cross(cur), depositAlice, staker.GetDepositGnsAmount())

	bar.Approve(cross(cur), depositPool, depositMaxInt64)
	foo.Approve(cross(cur), depositPool, depositMaxInt64)
	bar.Approve(cross(cur), depositStaker, depositMaxInt64)
	foo.Approve(cross(cur), depositStaker, depositMaxInt64)

	testing.SetRealm(depositAliceRealm)
	bar.Approve(cross(cur), depositStaker, depositMaxInt64)
	foo.Approve(cross(cur), depositStaker, depositMaxInt64)
	gns.Approve(cross(cur), depositStaker, depositMaxInt64)
}

func createDepositPool(cur realm) {
	testing.SetRealm(depositRealm)
	pool.CreatePool(cross(cur), depositBarPath, depositFooPath, 3000, "79228162514264337593543950336")
}

func mintDepositPosition(cur realm) {
	testing.SetRealm(depositAliceRealm)
	bar.Approve(cross(cur), depositPool, depositMaxInt64)
	foo.Approve(cross(cur), depositPool, depositMaxInt64)
	position.Mint(
		cross(cur),
		depositBarPath,
		depositFooPath,
		3000,
		-60,
		60,
		"5000000",
		"5000000",
		"1",
		"1",
		time.Now().Unix()+3600,
		depositAlice,
		"",
	)
}

func setDepositPoolTier(cur realm) {
	testing.SetRealm(depositRealm)
	staker.SetPoolTier(cross(cur), depositPoolPath, 1)
}

func stakeDepositPosition(cur realm) {
	testing.SetRealm(depositAliceRealm)
	gnft.Approve(cross(cur), depositStaker, grc721.TokenID(strconv.Itoa(1)))
	metric.PrintMetricsBy("Remaining staker deposit liquidity allocation StakeToken", func() {
		staker.StakeToken(cross(cur), 1, "")
	})
}

func collectDepositRewardMetrics(cur realm) {
	testing.SetRealm(depositAliceRealm)
	metric.PrintMetricsBy("Remaining staker deposit liquidity repeat zero reward 1", func() {
		staker.CollectReward(cross(cur), 1)
	})

	for _, count := range []int{1, 10, 100} {
		for i := 0; i < count; i++ {
			testing.SkipHeights(1)
			before := gns.BalanceOf(depositAlice)
			var collected string
			metric.PrintMetricsBy("Remaining staker deposit liquidity repeat accrued "+strconv.Itoa(count)+" call "+strconv.Itoa(i+1), func() {
				collected, _, _, _ = staker.CollectReward(cross(cur), 1)
			})
			amount, err := strconv.ParseInt(collected, 10, 64)
			if err != nil || amount <= 0 || gns.BalanceOf(depositAlice)-before != amount {
				panic("accrued emission payout did not match the public result")
			}
		}
	}

	depositLiquidityState(cur, "active")
}

func queryDepositLiquidityMetrics(cur realm) {
	testing.SetRealm(depositAliceRealm)
	metric.PrintMetricsBy("Remaining staker deposit liquidity query 1", func() {
		_, err := staker.GetDepositLiquidityAsString(1)
		if err != nil {
			panic(err)
		}
	})
	metric.PrintMetricsBy("Remaining staker deposit liquidity query 10", func() {
		for i := 0; i < 10; i++ {
			_, err := staker.GetDepositLiquidityAsString(1)
			if err != nil {
				panic(err)
			}
		}
	})
	metric.PrintMetricsBy("Remaining staker deposit liquidity query 100", func() {
		for i := 0; i < 100; i++ {
			_, err := staker.GetDepositLiquidityAsString(1)
			if err != nil {
				panic(err)
			}
		}
	})
}

func unstakeDepositPosition(cur realm) {
	testing.SetRealm(depositAliceRealm)
	metric.PrintMetricsBy("Remaining staker deposit liquidity lifecycle UnStakeToken", func() {
		staker.UnStakeToken(cross(cur), 1)
	})
	if staker.IsStaked(1) {
		panic("deposit remained after UnStakeToken")
	}
	poolLiquidity, err := staker.GetPoolStakedLiquidity(depositPoolPath)
	if err != nil {
		panic(err)
	}
	println("- State: deposit_staked=false pool_staked=" + poolLiquidity)
}

func depositLiquidityState(_ realm, phase string) {
	deposit, err := staker.GetDeposit(1)
	if err != nil {
		panic(err)
	}
	if deposit == nil {
		panic("missing deposit during " + phase)
	}
	liquidity, err := staker.GetDepositLiquidity(1)
	if err != nil {
		panic(err)
	}
	owner, err := staker.GetDepositOwner(1)
	if err != nil {
		panic(err)
	}
	poolLiquidity, err := staker.GetPoolStakedLiquidity(depositPoolPath)
	if err != nil {
		panic(err)
	}
	println("- State: phase=" + phase + " deposit_liquidity=" + liquidity.ToString() + " owner=" + owner.String() + " pool_staked=" + poolLiquidity)
}
