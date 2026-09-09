// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Public Launchpad lifecycle with one hundred measured deposits and one seed
// deposit. The seed keeps an active reservation while refunds are exercised
// after a partial withdrawal; all measured operations use public workflows.
package main

import (
	"strconv"
	"testing"
	"time"

	prbac "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gns"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	lp "gno.land/r/gnoswap/launchpad"
	_ "gno.land/r/gnoswap/launchpad/v1"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/scenarioutils"
	"gno.land/r/onbloc/obl"
)

const count = 100

var (
	adminAddr           = access.MustGetAddress(prbac.ROLE_ADMIN.String())
	adminRealm          = testing.NewUserRealm(adminAddr)
	launchpadAddr       = access.MustGetAddress(prbac.ROLE_LAUNCHPAD.String())
	userAddr            = testutils.TestAddress("remain-launch-user")
	userRealm           = testing.NewUserRealm(userAddr)
	recipient           = testutils.TestAddress("remain-launch-pay")
	seedAmount    int64 = 1_000_000
	maxInt64      int64 = 9_223_372_036_854_775_807
)

func metricName(operation string) string {
	return "Remaining launch " + operation + " n=" + strconv.Itoa(count)
}

func main(cur realm) {
	initializeSetup(cur)
	projectID := createProject(cur)
	tierID := projectID + ":30"

	seedID := seedActiveDeposit(cur, tierID)
	ids := make([]string, 0, count)
	for i := 0; i < count; i++ {
		amount := int64(1_000_000 * (1 + i%3))
		testing.SetRealm(adminRealm)
		gns.Transfer(cross(cur), userAddr, amount)
		testing.SetRealm(userRealm)
		testing.SkipHeights(1)
		var depositID string
		metric.PrintMetricsBy(metricName("deposit index="+strconv.Itoa(i)), func() {
			depositID = lp.DepositGns(cross(cur), tierID, amount, "")
		})
		ids = append(ids, depositID)
	}

	queryLaunchpadGetters(cur, projectID, tierID)
	printState(projectID, tierID, seedID, ids, "after-deposit", true)

	testing.SkipHeights((3 * 24 * 60 * 60 / 5) + 1)
	for i, depositID := range ids {
		testing.SetRealm(userRealm)
		before := obl.BalanceOf(userAddr)
		var claimed int64
		metric.PrintMetricsBy(metricName("claim index="+strconv.Itoa(i)), func() {
			claimed = lp.CollectRewardByDepositId(cross(cur), depositID)
		})
		if claimed <= 0 || obl.BalanceOf(userAddr) <= before {
			panic("real reward was not transferred")
		}
	}

	// Claim once more after an accrued interval, then repeat at the same time.
	testing.SkipHeights((24 * 60 * 60 / 5) + 1)
	testing.SetRealm(userRealm)
	before := obl.BalanceOf(userAddr)
	var repeatedClaim int64
	metric.PrintMetricsBy(metricName("claim repeated-accrued"), func() {
		repeatedClaim = lp.CollectRewardByDepositId(cross(cur), ids[0])
	})
	if repeatedClaim <= 0 || obl.BalanceOf(userAddr) <= before {
		panic("accrued repeat claim was not transferred")
	}

	before = obl.BalanceOf(userAddr)
	var zeroTimeClaim int64
	metric.PrintMetricsBy(metricName("claim repeated-zero-time"), func() {
		zeroTimeClaim = lp.CollectRewardByDepositId(cross(cur), ids[0])
	})
	if zeroTimeClaim != 0 || obl.BalanceOf(userAddr) != before {
		panic("zero-time repeat claim was not idempotent")
	}

	printState(projectID, tierID, seedID, ids, "after-claims", true)

	// The project is fully ended, so this refund reserves all active claims.
	testing.SkipHeights((180 * 24 * 60 * 60 / 5) + 6)
	testing.SetRealm(adminRealm)
	var refundBefore int64
	metric.PrintMetricsBy(metricName("refund before-withdraw"), func() {
		refundBefore = lp.TransferLeftFromProjectByAdmin(cross(cur), projectID, recipient)
	})
	if refundBefore < 0 {
		panic("negative refund before withdrawal")
	}
	ufmt.Printf("- State: refund-before amount=%d\n", refundBefore)
	printState(projectID, tierID, seedID, ids, "after-refund-before-withdraw", true)

	partialCount := count / 2
	if partialCount == 0 {
		partialCount = 1
	}
	for i := 0; i < partialCount; i++ {
		withdrawDeposit(cur, ids[i], i, int64(1_000_000*(1+i%3)))
	}

	// Keep the seed reservation active so this is a valid post-withdraw refund
	// even for the one-deposit workload.
	testing.SetRealm(adminRealm)
	var refundAfter int64
	metric.PrintMetricsBy(metricName("refund after-withdraw"), func() {
		refundAfter = lp.TransferLeftFromProjectByAdmin(cross(cur), projectID, recipient)
	})
	if refundAfter < 0 {
		panic("negative refund after withdrawal")
	}
	ufmt.Printf("- State: refund-after amount=%d\n", refundAfter)
	printState(projectID, tierID, seedID, ids, "after-refund-after-withdraw", true)

	for i := partialCount; i < count; i++ {
		withdrawDeposit(cur, ids[i], i, int64(1_000_000*(1+i%3)))
	}
	withdrawSeedDeposit(cur, seedID)
	printState(projectID, tierID, seedID, ids, "after-final-cleanup", false)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(2)
	emission.MintAndDistributeGns(cross(cur))
	obl.Approve(cross(cur), launchpadAddr, maxInt64)
}

func createProject(cur realm) string {
	testing.SetRealm(adminRealm)
	var projectID string
	metric.PrintMetricsBy(metricName("allocation"), func() {
		projectID = lp.CreateProject(
			cross(cur),
			"Remaining Launchpad Public Lifecycle",
			"gno.land/r/onbloc/obl.OBL",
			recipient,
			1_000_000_000,
			"",
			"",
			30,
			30,
			40,
			time.Now().Unix()+604800,
		)
	})
	testing.SkipHeights(604800/5 + 20)
	return projectID
}

func seedActiveDeposit(cur realm, tierID string) string {
	testing.SetRealm(adminRealm)
	gns.Transfer(cross(cur), userAddr, seedAmount)
	testing.SetRealm(userRealm)
	gns.Approve(cross(cur), launchpadAddr, maxInt64)
	var id string
	metric.PrintMetricsBy(metricName("deposit seed"), func() {
		id = lp.DepositGns(cross(cur), tierID, seedAmount, "")
	})
	return id
}

func queryLaunchpadGetters(cur realm, projectID, tierID string) {
	testing.SetRealm(userRealm)
	var tierRate string
	var managerRate string
	var accumulator string
	var activeDebt string
	metric.PrintMetricsBy(metricName("query getters"), func() {
		tierValue, err := lp.GetProjectTierDistributeAmountPerSecondX128(projectID, 30)
		if err != nil || tierValue == nil {
			panic("tier rate query failed")
		}
		tierRate = tierValue.ToString()

		manager, err := lp.GetProjectTierRewardManager(tierID)
		if err != nil || manager == nil {
			panic("manager query failed")
		}
		managerRate = manager.DistributeAmountPerSecondX128().ToString()
		activeDebt = manager.ActivePriceDebtX128().ToString()

		managerRateValue, err := lp.GetProjectTierRewardDistributeAmountPerSecondX128(tierID)
		if err != nil || managerRateValue == nil {
			panic("manager rate query failed")
		}
		if managerRate != managerRateValue.ToString() {
			panic("manager rate getter mismatch")
		}

		accumulatorValue, err := lp.GetProjectTierRewardAccumulatedRewardPerDepositX128(tierID)
		if err != nil || accumulatorValue == nil {
			panic("accumulator query failed")
		}
		accumulator = accumulatorValue.ToString()
	})
	if tierRate == "" || managerRate == "" || accumulator == "" || activeDebt == "" {
		panic("empty query result")
	}
	if tierRate != managerRate {
		panic("tier and manager rate mismatch")
	}
}

func withdrawDeposit(cur realm, depositID string, index int, expected int64) {
	testing.SetRealm(userRealm)
	var principal int64
	var err error
	metric.PrintMetricsBy(metricName("withdraw index="+strconv.Itoa(index)), func() {
		principal, err = lp.CollectDepositGns(cross(cur), depositID)
	})
	if err != nil || principal != expected {
		panic("principal mismatch")
	}
	ufmt.Printf("- State: principal index=%d amount=%d\n", index, principal)
}

func withdrawSeedDeposit(cur realm, depositID string) {
	testing.SetRealm(userRealm)
	var principal int64
	var err error
	metric.PrintMetricsBy(metricName("withdraw seed"), func() {
		principal, err = lp.CollectDepositGns(cross(cur), depositID)
	})
	if err != nil || principal != seedAmount {
		panic("seed principal mismatch")
	}
	ufmt.Printf("- State: principal seed amount=%d\n", principal)
}

func printState(projectID, tierID, seedID string, ids []string, stage string, seedExpected bool) {
	tier, err := lp.GetProjectTier(projectID, 30)
	if err != nil || tier == nil {
		panic("tier state query failed")
	}
	manager, err := lp.GetProjectTierRewardManager(tierID)
	if err != nil || manager == nil {
		panic("manager state query failed")
	}
	seedState, seedErr := lp.GetRewardState(tierID, seedID)
	seedPresent := seedErr == nil && seedState != nil
	if seedExpected != seedPresent {
		panic("unexpected seed lifecycle state")
	}

	ufmt.Printf(
		"- State: stage=%s tierDeposits=%d tierWithdraws=%d tierCollected=%d managerRate=%s accumulator=%s activeDeposits=%d activeClaimed=%d activeDebt=%s totalClaimed=%d seedPresent=%t userGns=%d userReward=%d launchReward=%d recipientReward=%d\n",
		stage,
		tier.TotalDepositAmount(),
		tier.TotalWithdrawAmount(),
		tier.TotalCollectedAmount(),
		manager.DistributeAmountPerSecondX128().ToString(),
		manager.AccumulatedRewardPerDepositX128().ToString(),
		manager.ActiveDepositAmount(),
		manager.ActiveClaimedAmount(),
		manager.ActivePriceDebtX128().ToString(),
		manager.TotalClaimedAmount(),
		seedPresent,
		gns.BalanceOf(userAddr),
		obl.BalanceOf(userAddr),
		obl.BalanceOf(launchpadAddr),
		obl.BalanceOf(recipient),
	)
	for i, depositID := range ids {
		state, err := lp.GetRewardState(tierID, depositID)
		if err != nil || state == nil {
			ufmt.Printf("- State: deposit index=%d present=false\n", i)
			continue
		}
		ufmt.Printf(
			"- State: deposit index=%d present=true principal=%d claimed=%d priceDebt=%s\n",
			i,
			state.DepositAmount(),
			state.ClaimedAmount(),
			state.PriceDebtX128().ToString(),
		)
	}
}
