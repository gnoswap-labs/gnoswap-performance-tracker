// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Public-workflow measurements for a position that is unstaked and restaked
// repeatedly. Every transition is separated by a block-time step so each
// staked-liquidity history update has a distinct timestamp.
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
	"gno.land/r/onbloc/foo"
)

const (
	cycleCount       = 20
	maxInt64   int64 = 9223372036854775807
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
	poolPath = barPath + ":" + fooPath + ":3000"

	positionID        uint64
	positionLiquidity string
	barBalance        int64
	fooBalance        int64
)

func main(cur realm) {
	initializeSetup(cur)
	createPoolAndTier(cur)
	mintPosition(cur)
	stakePosition(cur)

	assertStakedState()
	for cycle := 1; cycle <= cycleCount; cycle++ {
		runUnstake(cur, cycle)
		runRestake(cur, cycle)
	}

	if common.BalanceOf(barPath, aliceAddr) != barBalance {
		panic("BAR balance changed during stake/unstake cycles")
	}
	if common.BalanceOf(fooPath, aliceAddr) != fooBalance {
		panic("FOO balance changed during stake/unstake cycles")
	}
	assertStakedState()
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross(cur), 0)
	staker.SetUnStakingFee(cross(cur), 0)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(1)

	bar.Transfer(cross(cur), aliceAddr, 100_000_000_000)
	foo.Transfer(cross(cur), aliceAddr, 100_000_000_000)
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

	var amount0, amount1 string
	positionID, positionLiquidity, amount0, amount1 = position.Mint(
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
	if positionLiquidity == "0" || amount0 == "0" || amount1 == "0" {
		panic("position mint did not produce positive liquidity and amounts")
	}
	barBalance = common.BalanceOf(barPath, aliceAddr)
	fooBalance = common.BalanceOf(fooPath, aliceAddr)
	testing.SkipHeights(1)
}

func stakePosition(cur realm) {
	testing.SetRealm(aliceRealm)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(positionID, 10)))
	metric.PrintMetricsBy("StakedLiquidity Lifecycle InitialStake", func() {
		staker.StakeToken(cross(cur), positionID, "")
	})
}

func runUnstake(cur realm, cycle int) {
	testing.SetRealm(aliceRealm)
	testing.SkipHeights(1)
	metric.PrintMetricsBy("StakedLiquidity Lifecycle Unstake "+strconv.Itoa(cycle), func() {
		staker.UnStakeToken(cross(cur), positionID)
	})
	if staker.IsStaked(positionID) {
		panic("position remained staked after unstake")
	}
	if got := poolLiquidity(); got != "0" {
		panic("pool liquidity did not transition to zero")
	}
	if owner := gnft.MustOwnerOf(grc721.TokenID(strconv.FormatUint(positionID, 10))); owner != aliceAddr {
		panic("unstaked position was not returned to its owner")
	}
}

func runRestake(cur realm, cycle int) {
	testing.SetRealm(aliceRealm)
	testing.SkipHeights(1)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(positionID, 10)))
	metric.PrintMetricsBy("StakedLiquidity Lifecycle Restake "+strconv.Itoa(cycle), func() {
		staker.StakeToken(cross(cur), positionID, "")
	})
	assertStakedState()
}

func assertStakedState() {
	if !staker.IsStaked(positionID) {
		panic("position is not staked")
	}
	if got := poolLiquidity(); got != positionLiquidity {
		panic("pool liquidity does not match the position liquidity")
	}
	if owner := gnft.MustOwnerOf(grc721.TokenID(strconv.FormatUint(positionID, 10))); owner != stakerAddr {
		panic("staked position is not owned by the staker")
	}
	if owner := depositOwner(); owner != aliceAddr {
		panic("staker deposit owner changed")
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
