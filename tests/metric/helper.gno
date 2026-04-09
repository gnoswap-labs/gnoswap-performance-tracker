package metric

import (
	"fmt"
	"strings"
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/staker"
	"gno.land/r/onbloc/foo"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _   = access.GetAddress(prabc.ROLE_POOL.String())
	stakerAddr, _ = access.GetAddress(prabc.ROLE_STAKER.String())

	aliceAddr  = testutils.TestAddress("alice")
	aliceRealm = testing.NewUserRealm(aliceAddr)

	maxInt64         int64 = 9223372036854775807
	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60
)

func PrintCollectRewardMetrics(metricIndex int64, positionID uint64, isInternal bool, incentiveCount int64) {
	metricName := MakeDefaultMetricName(metricIndex, isInternal, incentiveCount, false)

	PrintMetricsBy(metricName, func() {
		staker.CollectReward(cross, positionID)
	})

	testing.SkipHeights(1)

	PrintMetricsBy(metricName+" 2nd", func() {
		staker.CollectReward(cross, positionID)
	})

	PrintMetricsBy(metricName+" 3nd Same time", func() {
		staker.CollectReward(cross, positionID)
	})

	PrintCollectRewardWithAdditionalIncentives(metricIndex, positionID, isInternal, incentiveCount)
}

func PrintCollectRewardWithAdditionalIncentives(metricIndex int64, positionID uint64, isInternal bool, incentiveCount int64) {
	testing.SetRealm(aliceRealm)
	foo.Approve(cross, stakerAddr, maxInt64)
	barPath := "gno.land/r/onbloc/bar"
	fooPath := "gno.land/r/onbloc/foo"
	poolPath := barPath + ":" + fooPath + ":3000"

	incentiveStartTime := time.Now().AddDate(0, 0, 1).Truncate(24 * time.Hour).Unix()
	incentiveEndTime := incentiveStartTime + TIMESTAMP_90DAYS

	staker.CreateExternalIncentive(
		cross,
		poolPath,
		fooPath,
		1_000_000_000,
		incentiveStartTime,
		incentiveEndTime,
	)

	testing.SkipHeights((incentiveStartTime - time.Now().Unix()) + 1)

	metricName := MakeDefaultMetricName(metricIndex, isInternal, incentiveCount, true)
	PrintMetricsBy(metricName, func() {
		staker.CollectReward(cross, positionID)
	})

	testing.SkipHeights(1)

	PrintMetricsBy(metricName+" 2nd", func() {
		staker.CollectReward(cross, positionID)
	})
}

func MakeDefaultMetricName(metricIndex int64, isInternal bool, incentiveCount int64, isAdditional bool) string {
	descriptions := []string{}
	if isInternal {
		descriptions = append(descriptions, "Internal")
	}
	if incentiveCount > 0 {
		descriptions = append(descriptions, fmt.Sprintf("%d External", incentiveCount))
	}

	if isAdditional {
		return ufmt.Sprintf("%d. CollectReward (%s) + Add Incentive", metricIndex, strings.Join(descriptions, " / "))
	}

	return ufmt.Sprintf("%d. CollectReward (%s)", metricIndex, strings.Join(descriptions, " / "))
}

func MetricsBy(name string, fn func()) (int64, int64, int64) {
	beforeCycles := testing.GetCycles()
	beforeGas := testing.GetGas()
	beforeRealmStorageDiff := testing.GetRealmStorageDiffs()

	fn()

	afterCycles := testing.GetCycles()
	afterGas := testing.GetGas()
	afterRealmStorageDiff := testing.GetRealmStorageDiffs()

	totalRealmStorageDiff := int64(0)

	for _, diff := range afterRealmStorageDiff {
		totalRealmStorageDiff += diff
	}

	for _, diff := range beforeRealmStorageDiff {
		totalRealmStorageDiff -= diff
	}

	return afterGas - beforeGas, totalRealmStorageDiff, afterCycles - beforeCycles
}

func PrintMetricsBy(name string, fn func()) {
	beforeCycles := testing.GetCycles()
	beforeGas := testing.GetGas()
	beforeRealmStorageDiff := testing.GetRealmStorageDiffs()

	fn()

	afterCycles := testing.GetCycles()
	afterGas := testing.GetGas()
	afterRealmStorageDiff := testing.GetRealmStorageDiffs()

	totalRealmStorageDiff := int64(0)

	for _, diff := range afterRealmStorageDiff {
		totalRealmStorageDiff += diff
	}

	for _, diff := range beforeRealmStorageDiff {
		totalRealmStorageDiff -= diff
	}

	println(name)
	ufmt.Printf("- Gas Used: %d\n", afterGas-beforeGas)
	ufmt.Printf("- Storage Diff: %d\n", totalRealmStorageDiff)
	ufmt.Printf("- CPU Cycles: %d\n", afterCycles-beforeCycles)
}
