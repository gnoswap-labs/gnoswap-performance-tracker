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

const positionCount = 100

func main() {
	initializeSetup()
	createPoolAndSetTier()

	startTokenId := mintAndStakePositions(positionCount)
	testing.SkipHeights(600000)
	exactInSwap(startTokenId)
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

func createPoolAndSetTier() {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, barPath, fooPath, 3000, common.TickMathGetSqrtRatioAtTick(0).ToString())

	poolPath := barPath + ":" + fooPath + ":3000"
	staker.SetPoolTier(cross, poolPath, 1)
}

func mintAndStakePositions(count int) uint64 {
	testing.SetRealm(aliceRealm)

	// Mint full-range position
	position.Mint(
		cross,
		barPath,
		fooPath,
		3000,
		-887220,
		887220,
		"1000000",
		"1000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		aliceAddr,
		"",
	)

	startTokenId := uint64(1)
	startMinTick := -60*count - 60
	positionTickRange := 60 - startMinTick

	for i := 0; i < count; i++ {
		minTick := int32(startMinTick) + int32(i*60)
		maxTick := int32(minTick) + int32(positionTickRange)

		tokenId, _, _, _ := position.Mint(
			cross,
			barPath,
			fooPath,
			3000,
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

		if i == 0 {
			startTokenId = tokenId
		}

		gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
		staker.StakeToken(cross, tokenId, "")
		testing.SkipHeights(1)
	}

	return startTokenId
}

func exactInSwap(tokenId uint64) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	bar.Approve(cross, routerAddr, maxInt64)
	foo.Approve(cross, routerAddr, maxInt64)

	metric.PrintMetricsBy("ExactInSwapRoute tick cross 100 ticks with 100 positions", func() {
		router.ExactInSwapRoute(
			cross,
			barPath,
			fooPath,
			"100000000000",
			"gno.land/r/onbloc/bar:gno.land/r/onbloc/foo:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}
