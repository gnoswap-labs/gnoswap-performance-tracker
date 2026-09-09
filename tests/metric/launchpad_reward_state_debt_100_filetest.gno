// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Standard public lifecycle for the Launchpad RewardState.priceDebtX128 storage PoC.
// This exercises repeated real project, deposit, reward, refund, and withdrawal
// entry points with staggered heterogeneous deposits.
package main

import (
	"strconv"
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	"gno.land/r/gnoswap/launchpad"
	_ "gno.land/r/gnoswap/launchpad/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/onbloc/obl"
)

const (
	depositCount        = 100
	projectRewardAmount = int64(1_000_000_000)
	activationDelay     = int64(604_800)
	projectLockSeconds  = int64(180 * 24 * 60 * 60)
	baseDepositAmount   = int64(1_000_000)
	maxInt64            = int64(9_223_372_036_854_775_807)
)

var (
	adminAddr, _     = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm       = testing.NewUserRealm(adminAddr)
	launchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	userAddr  = testutils.TestAddress("launch-debt-100")
	userRealm = testing.NewUserRealm(userAddr)
	recipient = testutils.TestAddress("launch-refund-100")
)

func main(cur realm) {
	initializeSetup(cur)

	projectID, startTime := createProject(cur)
	tierID := projectID + ":30"
	testing.SkipHeights(activationDelay/5 + 20)

	depositIDs, amounts := depositLifecycle(cur, tierID)
	printClock("after-all-deposits")
	printState(tierID, depositIDs, amounts, "after-all-deposits")

	// One full day makes every deposit claimable. The extra time gives the
	// staggered deposits the same positive reward boundary as the small run.
	testing.SkipHeights((3*24*60*60)/5 + 2)
	printClock("before-reward-claims")
	rewardLifecycle(cur, tierID, depositIDs, amounts)
	printState(tierID, depositIDs, amounts, "after-reward-claims")

	// TransferLeftFromProjectByAdmin requires the standard (180-day) tier to
	// have ended, even though these deposits use the 30-day tier.
	skipTo(startTime + projectLockSeconds)
	printClock("lock-end")
	printState(tierID, depositIDs, amounts, "lock-end")

	refundBeforeWithdraw(cur, projectID)
	printClock("before-withdrawals")
	printState(tierID, depositIDs, amounts, "before-withdrawals")

	withdrawLifecycle(cur, tierID, depositIDs, amounts)
	printClock("after-withdrawals")
	printState(tierID, depositIDs, amounts, "after-withdrawals")

	finalRefund(cur, projectID, tierID, depositIDs, amounts)
}

func initializeSetup(cur realm) {
	testing.SetRealm(adminRealm)
	obl.Approve(cross(cur), launchpadAddr, maxInt64)
}

func createProject(cur realm) (string, int64) {
	testing.SetRealm(adminRealm)
	startTime := time.Now().Unix() + activationDelay
	var projectID string
	metric.PrintMetricsBy("Remaining launch-deposit allocation 100 CreateProject", func() {
		projectID = launchpad.CreateProject(
			cross(cur),
			"Remaining Launch Deposit Debt 100",
			"gno.land/r/onbloc/obl.OBL",
			recipient,
			projectRewardAmount,
			"",
			"",
			30,
			30,
			40,
			startTime,
		)
	})
	printClock("project-created")
	return projectID, startTime
}

func depositLifecycle(cur realm, tierID string) ([]string, []int64) {
	depositIDs := make([]string, 0, depositCount)
	amounts := make([]int64, 0, depositCount)

	for i := 0; i < depositCount; i++ {
		amount := baseDepositAmount * int64(1+i%3)
		testing.SetRealm(adminRealm)
		gns.Transfer(cross(cur), userAddr, amount)

		testing.SetRealm(userRealm)
		gns.Approve(cross(cur), launchpadAddr, amount)
		var depositID string
		label := "Remaining launch-deposit allocation 100 DepositGns index=" + strconv.Itoa(i+1)
		metric.PrintMetricsBy(label, func() {
			depositID = launchpad.DepositGns(cross(cur), tierID, amount, "")
		})
		if gns.BalanceOf(userAddr) != 0 {
			panic("GNS principal was not transferred into Launchpad")
		}
		depositIDs = append(depositIDs, depositID)
		amounts = append(amounts, amount)
		if i == 0 {
			assertRewardStateCloneIsolation(tierID, depositID)
			printClock("first-deposit")
		} else {
			printClock("deposit-" + strconv.Itoa(i+1))
		}
		testing.SkipHeights(1)
	}

	return depositIDs, amounts
}

func rewardLifecycle(cur realm, tierID string, depositIDs []string, amounts []int64) {
	for i, depositID := range depositIDs {
		testing.SetRealm(userRealm)
		beforeBalance := obl.BalanceOf(userAddr)
		var rewardAmount int64
		label := "Remaining launch-deposit reward 100 CollectReward index=" + strconv.Itoa(i+1)
		metric.PrintMetricsBy(label, func() {
			rewardAmount = launchpad.CollectRewardByDepositId(cross(cur), depositID)
		})
		printClock("reward-" + strconv.Itoa(i+1))
		if rewardAmount <= 0 {
			panic("real reward was not generated")
		}
		if obl.BalanceOf(userAddr)-beforeBalance != rewardAmount {
			panic("reward balance does not match public return value")
		}
	}

	testing.SetRealm(userRealm)
	beforeBalance := obl.BalanceOf(userAddr)
	var repeatedReward int64
	metric.PrintMetricsBy("Remaining launch-deposit repeat 100 CollectReward same-time", func() {
		repeatedReward = launchpad.CollectRewardByDepositId(cross(cur), depositIDs[0])
	})
	printClock("reward-repeat")
	if repeatedReward != 0 || obl.BalanceOf(userAddr) != beforeBalance {
		panic("same-time reward collection was not idempotent")
	}
}

func refundBeforeWithdraw(cur realm, projectID string) {
	testing.SetRealm(adminRealm)
	beforeBalance := obl.BalanceOf(recipient)
	var refunded int64
	metric.PrintMetricsBy("Remaining launch-deposit refund 100 before-withdraw", func() {
		refunded = launchpad.TransferLeftFromProjectByAdmin(cross(cur), projectID, recipient)
	})
	printClock("refund-before-withdraw")
	if refunded <= 0 {
		panic("refund-before-withdraw did not transfer project balance")
	}
	if obl.BalanceOf(recipient)-beforeBalance != refunded {
		panic("refund balance does not match public return value")
	}
	if obl.BalanceOf(launchpadAddr) <= 0 {
		panic("refund-before-withdraw removed the active reward reserve")
	}
}

func withdrawLifecycle(cur realm, tierID string, depositIDs []string, amounts []int64) {
	for i, depositID := range depositIDs {
		testing.SetRealm(userRealm)
		beforeGNS := gns.BalanceOf(userAddr)
		beforeOBL := obl.BalanceOf(userAddr)
		var principal int64
		var err error
		label := "Remaining launch-deposit withdraw 100 CollectDepositGns index=" + strconv.Itoa(i+1)
		metric.PrintMetricsBy(label, func() {
			principal, err = launchpad.CollectDepositGns(cross(cur), depositID)
		})
		printClock("withdraw-" + strconv.Itoa(i+1))
		if err != nil {
			panic(err)
		}
		if principal != amounts[i] || gns.BalanceOf(userAddr)-beforeGNS != principal {
			panic("GNS principal withdrawal mismatch")
		}
		if obl.BalanceOf(userAddr) < beforeOBL {
			panic("withdrawal reduced accumulated reward balance")
		}
	}
}

func finalRefund(cur realm, projectID, tierID string, depositIDs []string, amounts []int64) {
	testing.SetRealm(adminRealm)
	finalAmount := int64(0)
	// Per-deposit reward rounding can leave a small final project balance. The
	// 100-deposit run exercises the real final-refund transfer when that dust exists.
	if obl.BalanceOf(launchpadAddr) > 0 {
		beforeBalance := obl.BalanceOf(recipient)
		metric.PrintMetricsBy("Remaining launch-deposit refund 100 final", func() {
			finalAmount = launchpad.TransferLeftFromProjectByAdmin(cross(cur), projectID, recipient)
		})
		printClock("refund-final")
		if obl.BalanceOf(recipient)-beforeBalance != finalAmount {
			panic("final refund balance does not match public return value")
		}
	}
	ufmt.Printf("- State: refund-final amount=%d\n", finalAmount)
	printState(tierID, depositIDs, amounts, "after-final-refund")
}

func skipTo(endTime int64) {
	remaining := endTime - time.Now().Unix()
	if remaining > 0 {
		testing.SkipHeights(remaining/5 + 2)
	}
}

func printClock(stage string) {
	ufmt.Printf("- State: clock %s %d\n", stage, time.Now().Unix())
}

func assertRewardStateCloneIsolation(tierID, depositID string) {
	state, err := launchpad.GetRewardState(tierID, depositID)
	if err != nil {
		panic(err)
	}
	before := state.PriceDebtX128().ToString()
	state.PriceDebtX128().Set(u256.Zero())
	persisted, err := launchpad.GetRewardState(tierID, depositID)
	if err != nil {
		panic(err)
	}
	if persisted.PriceDebtX128().ToString() != before {
		panic("RewardState getter leaked mutable debt state")
	}
}

func printState(tierID string, depositIDs []string, amounts []int64, stage string) {
	manager, err := launchpad.GetProjectTierRewardManager(tierID)
	if err != nil {
		panic(err)
	}
	ufmt.Printf(
		"- State: manager %s active-deposit=%d active-claimed=%d active-debt=%s total-claimed=%d\n",
		stage,
		manager.ActiveDepositAmount(),
		manager.ActiveClaimedAmount(),
		manager.ActivePriceDebtX128().ToString(),
		manager.TotalClaimedAmount(),
	)
	for i, depositID := range depositIDs {
		state, err := launchpad.GetRewardState(tierID, depositID)
		if err != nil {
			ufmt.Printf("- State: deposit %s index=%d missing\n", stage, i+1)
			continue
		}
		ufmt.Printf(
			"- State: deposit %s index=%d debt=%s principal=%d claimed=%d\n",
			stage,
			i+1,
			state.PriceDebtX128().ToString(),
			amounts[i],
			state.ClaimedAmount(),
		)
	}
	ufmt.Printf(
		"- State: balances %s gns-user=%d obl-user=%d obl-launchpad=%d obl-recipient=%d\n",
		stage,
		gns.BalanceOf(userAddr),
		obl.BalanceOf(userAddr),
		obl.BalanceOf(launchpadAddr),
		obl.BalanceOf(recipient),
	)
}
