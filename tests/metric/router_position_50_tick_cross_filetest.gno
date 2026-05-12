// Gas and performance metrics for staker CollectReward with 100 staked positions
// NOTE: Position count has minimal impact on gas (~3.7M gas even at 10000 positions, never reaches 1B)
package main

import (
	"chain"
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/emission"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/router"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/gnft"
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
	routerAddr, _ = access.GetAddress(prabc.ROLE_ROUTER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath = "gno.land/r/onbloc/bar"
	fooPath = "gno.land/r/onbloc/foo"

	maxInt64 int64 = 9223372036854775807
)

const positionCount = 50

var (
	tierTickSpacings = map[uint32]int32{100: 1, 500: 10, 3000: 60, 10000: 200}
	tierMinTicks     = map[uint32]int32{100: -887272, 500: -887270, 3000: -887220, 10000: -887200}
	tierMaxTicks     = map[uint32]int32{100: 887272, 500: 887270, 3000: 887220, 10000: 887200}
)

func main() {
	initializeSetup()

	for tier := range tierTickSpacings {
		createPoolAndSetTier(barPath, fooPath, tier)
	}

	for tier := range tierTickSpacings {
		mintAndStakePositions(barPath, fooPath, tier, positionCount)
	}

	testing.SkipHeights(600000)

	for tier := range tierTickSpacings {
		exactInSwap(barPath, fooPath, tier)
	}
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	bar.Transfer(cross, aliceAddr, 10000000000000)
	foo.Transfer(cross, aliceAddr, 10000000000000)

	testing.SetRealm(aliceRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)

	testing.SetRealm(adminRealm)
	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func createPoolAndSetTier(token0 string, token1 string, tier uint32) {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, token0, token1, tier, common.TickMathGetSqrtRatioAtTick(0).ToString())

	poolPath := token0 + ":" + token1 + ":" + strconv.FormatUint(uint64(tier), 10)
	staker.SetPoolTier(cross, poolPath, 1)
}

func mintAndStakePositions(token0 string, token1 string, tier uint32, count int) {
	testing.SetRealm(aliceRealm)

	// Mint full-range position
	position.Mint(
		cross,
		token0,
		token1,
		tier,
		tierMinTicks[tier],
		tierMaxTicks[tier],
		"1000000",
		"1000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		aliceAddr,
		"",
	)

	tickSpacing := tierTickSpacings[tier]

	startMinTick := -int32(tickSpacing) * int32(count+1)
	positionTickRange := int32(tickSpacing) - startMinTick

	for i := 0; i < count; i++ {
		minTick := int32(startMinTick) + int32(i)*int32(tickSpacing)
		maxTick := int32(minTick) + int32(positionTickRange)

		tokenId, _, _, _ := position.Mint(
			cross,
			token0,
			token1,
			tier,
			minTick,
			maxTick,
			"100",
			"100",
			"0",
			"0",
			time.Now().Unix()+3600,
			aliceAddr,
			"",
		)

		gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
		staker.StakeToken(cross, tokenId, "")
		testing.SkipHeights(1)
	}
}

func exactInSwap(token0 string, token1 string, tier uint32) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	bar.Approve(cross, routerAddr, maxInt64)
	foo.Approve(cross, routerAddr, maxInt64)

	poolPath := token0 + ":" + token1 + ":" + strconv.FormatUint(uint64(tier), 10)

	metric.PrintMetricsBy(ufmt.Sprintf("ExactInSwapRoute tick cross %d ticks with %d positions (tier: %d)", positionCount, positionCount, tier), func() {
		router.ExactInSwapRoute(
			cross,
			token0,
			token1,
			"100000000000",
			poolPath,
			"100",
			"0",
			9999999999,
			"",
		)
	})

	println(ufmt.Sprintf("current tick: %s(position count: %d, tier: %d)", pool.GetSlot0Tick(poolPath), positionCount, tier))
}
