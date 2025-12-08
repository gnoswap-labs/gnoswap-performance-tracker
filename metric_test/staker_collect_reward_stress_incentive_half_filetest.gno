// Gas and performance metrics for staker CollectReward at half of 1B gas limit threshold
// Tests CollectReward with 17650 external incentives (≈ 500M gas, half of 1B threshold)
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gnft"
	"gno.land/r/gnoswap/gns"
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

	poolPath = barPath + ":" + fooPath + ":3000"

	maxInt64 int64 = 9223372036854775807

	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60
)

// 17650 external incentives ≈ half of 1B gas threshold for CollectReward
const incentiveCount = 17650

func main() {
	initializeSetup()
	createPoolAndSetTier()
	tokenId := mintAndStakePosition()
	createExternalIncentives()
	testing.SkipHeights(10)
	collectRewardMetric(tokenId)
}

func initializeSetup() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)
	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)

	bar.Transfer(cross, aliceAddr, 20_000_000_000_000)
	foo.Transfer(cross, aliceAddr, 10_000_000_000_000)
	gns.Transfer(cross, aliceAddr, 20_000_000_000_000)

	testing.SetRealm(aliceRealm)
	bar.Approve(cross, poolAddr, maxInt64)
	foo.Approve(cross, poolAddr, maxInt64)
	bar.Approve(cross, stakerAddr, maxInt64)
	foo.Approve(cross, stakerAddr, maxInt64)
	gns.Approve(cross, stakerAddr, maxInt64)
}

func createPoolAndSetTier() {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, barPath, fooPath, 3000, common.TickMathGetSqrtRatioAtTick(0).ToString())
	staker.SetPoolTier(cross, poolPath, 1)
}

func mintAndStakePosition() uint64 {
	testing.SetRealm(aliceRealm)

	tokenId, _, _, _ := position.Mint(
		cross,
		barPath,
		fooPath,
		3000,
		int32(-600),
		int32(600),
		"1000000",
		"1000000",
		"0",
		"0",
		time.Now().Unix()+3600,
		aliceAddr,
		aliceAddr,
		"",
	)

	gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(tokenId, 10)))
	staker.StakeToken(cross, tokenId, "")
	testing.SkipHeights(1)

	return tokenId
}

func createExternalIncentives() {
	testing.SetRealm(aliceRealm)

	startTime := int64(1234569600)

	for i := 0; i < incentiveCount; i++ {
		incentiveStartTime := startTime + int64(i*86400)
		incentiveEndTime := incentiveStartTime + TIMESTAMP_90DAYS

		staker.CreateExternalIncentive(
			cross,
			poolPath,
			barPath,
			1_000_000_000,
			incentiveStartTime,
			incentiveEndTime,
		)
	}
}

func collectRewardMetric(tokenId uint64) {
	testing.SetRealm(aliceRealm)

	metric.PrintMetricsBy("CollectReward (17650 incentives)", func() {
		staker.CollectReward(cross, tokenId, false)
	})
}
