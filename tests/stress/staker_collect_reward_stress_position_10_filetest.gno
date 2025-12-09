// Gas and performance metrics for staker CollectReward with 10 staked positions
// NOTE: Position count has minimal impact on gas (~3.7M gas even at 10000 positions, never reaches 1B)
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	"gno.land/r/gnoswap/emission"
	_ "gno.land/r/gnoswap/rbac"

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

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	barPath = "gno.land/r/onbloc/bar"
	fooPath = "gno.land/r/onbloc/foo"

	maxInt64 int64 = 9223372036854775807
)

const positionCount = 10

func main() {
	initializeSetup()
	createPoolAndSetTier()

	startTokenId := mintAndStakePositions(positionCount)
	testing.SkipHeights(600000)
	collectRewardMetric(startTokenId)
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

	startTokenId := uint64(1)

	for i := 0; i < count; i++ {
		minTick := int32(-600 - (i%10)*60)
		maxTick := int32(600 + (i%10)*60)

		tokenId, _, _, _ := position.Mint(
			cross,
			barPath,
			fooPath,
			3000,
			minTick,
			maxTick,
			"1000000",
			"1000000",
			"0",
			"0",
			time.Now().Unix()+3600,
			aliceAddr,
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

func collectRewardMetric(tokenId uint64) {
	testing.SetRealm(aliceRealm)

	metric.PrintMetricsBy("stress CollectReward (10 positions)", func() {
		staker.CollectReward(cross, tokenId, false)
	})
}
