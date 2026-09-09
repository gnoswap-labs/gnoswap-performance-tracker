// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Public-workflow controls for staked-liquidity history writes. The first
// stake/unstake pair intentionally shares one timestamp and must collapse to a
// zero-liquidity state; later separated transitions exercise zero/positive
// changes at distinct timestamps.
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

const maxInt64 int64 = 9223372036854775807

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

	testing.SetRealm(aliceRealm)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(positionID, 10)))
	metric.PrintMetricsBy("StakedLiquidity Control SameTimestamp Stake", func() {
		staker.StakeToken(cross(cur), positionID, "")
	})
	assertStakedState()

	metric.PrintMetricsBy("StakedLiquidity Control SameTimestamp Unstake", func() {
		staker.UnStakeToken(cross(cur), positionID)
	})
	assertUnstakedState()

	testing.SkipHeights(1)
	gnft.Approve(cross(cur), stakerAddr, grc721.TokenID(strconv.FormatUint(positionID, 10)))
	metric.PrintMetricsBy("StakedLiquidity Control PositiveTransition", func() {
		staker.StakeToken(cross(cur), positionID, "")
	})
	assertStakedState()

	testing.SkipHeights(1)
	metric.PrintMetricsBy("StakedLiquidity Control ZeroTransition", func() {
		staker.UnStakeToken(cross(cur), positionID)
	})
	assertUnstakedState()

	if common.BalanceOf(barPath, aliceAddr) != barBalance || common.BalanceOf(fooPath, aliceAddr) != fooBalance {
		panic("pool token balance changed during transition controls")
	}
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
	barBalance = common.BalanceOf(barPath, aliceAddr)
	fooBalance = common.BalanceOf(fooPath, aliceAddr)
}

func assertStakedState() {
	if !staker.IsStaked(positionID) {
		panic("position is not staked")
	}
	if got := poolLiquidity(); got != positionLiquidity {
		panic("positive transition did not restore position liquidity")
	}
	if owner := gnft.MustOwnerOf(grc721.TokenID(strconv.FormatUint(positionID, 10))); owner != stakerAddr {
		panic("staked position is not owned by the staker")
	}
	if owner := depositOwner(); owner != aliceAddr {
		panic("staker deposit owner changed")
	}
}

func assertUnstakedState() {
	if staker.IsStaked(positionID) {
		panic("position remained staked")
	}
	if got := poolLiquidity(); got != "0" {
		panic("zero transition did not clear pool liquidity")
	}
	if owner := gnft.MustOwnerOf(grc721.TokenID(strconv.FormatUint(positionID, 10))); owner != aliceAddr {
		panic("unstaked position was not returned to its owner")
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
