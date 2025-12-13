// Gas and performance metrics for StakeToken with 100 existing external incentives
// Tests the gas cost of staking a position when there are many active incentives
package main

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils"
	"gno.land/p/nt/ufmt"
	"gno.land/r/gnoswap/emission"
	_ "gno.land/r/gnoswap/rbac"

	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
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

	barPath  = "gno.land/r/onbloc/bar"
	fooPath  = "gno.land/r/onbloc/foo"
	poolPath = barPath + ":" + fooPath + ":3000"

	maxInt64 int64 = 9223372036854775807

	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60
)

const (
	positionCount  = 100
	incentiveCount = 100
)

func main() {
	initializeSetup()
	createPoolAndSetTier()
	createExternalIncentives()
	mintAndStakePositionsMetric()
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
	bar.Approve(cross, stakerAddr, maxInt64)
	gns.Approve(cross, stakerAddr, maxInt64)
	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func createPoolAndSetTier() {
	testing.SetRealm(adminRealm)
	pool.CreatePool(cross, barPath, fooPath, 3000, common.TickMathGetSqrtRatioAtTick(0).ToString())
	staker.SetPoolTier(cross, poolPath, 1)
}

func createExternalIncentives() {
	testing.SetRealm(adminRealm)

	incentiveStartTime := time.Now().AddDate(0, 0, 1).Truncate(24 * time.Hour).Unix()
	incentiveEndTime := incentiveStartTime + TIMESTAMP_90DAYS

	// Create multiple external incentives before staking
	for i := 0; i < incentiveCount; i++ {
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

func mintAndStakePositionsMetric() {
	testing.SetRealm(aliceRealm)

	// Mint positions first (without staking)
	tokenIds := make([]uint64, positionCount)
	for i := 0; i < positionCount; i++ {
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
		tokenIds[i] = tokenId
	}

	// Approve and stake first positions without measurement
	for i := 0; i < positionCount-1; i++ {
		gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(tokenIds[i], 10)))
		staker.StakeToken(cross, tokenIds[i], "")
		testing.SkipHeights(1)
	}

	// Measure gas for staking the last position
	lastTokenId := tokenIds[positionCount-1]
	gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(lastTokenId, 10)))

	metric.PrintMetricsBy(ufmt.Sprintf("stress StakeToken (pos=%d, inc=%d)", positionCount, incentiveCount), func() {
		staker.StakeToken(cross, lastTokenId, "")
	})
}
