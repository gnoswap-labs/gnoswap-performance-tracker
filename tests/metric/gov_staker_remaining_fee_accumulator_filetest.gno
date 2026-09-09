// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Public governance-staker lifecycle for the persisted protocol-fee accumulator.
// Fee-token cardinality and repeated distribution/claim windows are measured
// separately from deterministic reward, payout, and membership snapshots.
package main

import (
	"sort"
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	govstaker "gno.land/r/gnoswap/gov/staker"
	"gno.land/r/gnoswap/protocol_fee"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/obl"
	"gno.land/r/onbloc/qux"

	"gno.land/r/gnoswap/scenario/metric"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)
	stakerAddr, _      = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm        = testing.NewUserRealm(stakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())

	delegateeAddr = testutils.TestAddress("remain-fee")

	barPath = "gno.land/r/onbloc/bar.BAR"
	bazPath = "gno.land/r/onbloc/baz.BAZ"
	quxPath = "gno.land/r/onbloc/qux.QUX"
	oblPath = "gno.land/r/onbloc/obl.OBL"

	feeTokens = []string{barPath, bazPath, quxPath, oblPath}

	maxInt64                int64 = 9223372036854775807
	stakeAmount             int64 = 1_000_000
	feeAmount               int64 = 1_000_000
	fundAmount              int64 = 2_000_000_000
	registeredFeeTokenCount int
)

func main(cur realm) {
	printInitialRealmStorage()
	initializeFeeSetup(cur)
	printFeeState(cur, "after-init", adminAddr)

	delegateMetric(cur)
	printFeeState(cur, "after-first-delegation", adminAddr)

	// Register one through four fee tokens in monotonic rounds. The manager keeps
	// omitted tokens, so each label identifies the number of registered tokens.
	for k := 1; k <= len(feeTokens); k++ {
		addFeesForFirstK(cur, k)
		distributeFees(cur)
		testing.SkipHeights(1)
		testing.SetRealm(adminRealm)
		metric.PrintMetricsBy(ufmt.Sprintf("Remaining gov fee accumulator tokens-%d", k), func() {
			govstaker.CollectReward(cross(cur))
		})
		printFeeState(cur, ufmt.Sprintf("after-token-case-%d", k), adminAddr)
	}

	for _, rounds := range []int64{1, 10, 100, 1000} {
		repeatedFeeMetric(cur, rounds)
		printFeeState(cur, ufmt.Sprintf("after-repeat-%d", rounds), adminAddr)
	}

	// A claim with no newly distributed reward is a sparse/no-op control.
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Remaining gov fee accumulator no-new-reward claim", func() {
		govstaker.CollectReward(cross(cur))
	})
	printFeeState(cur, "after-no-new-reward-claim", adminAddr)

	lifecycleMetric(cur)
	printFeeState(cur, "after-lifecycle", adminAddr)
}

func printInitialRealmStorage() {
	diffs := testing.GetRealmStorageDiffs()
	paths := make([]string, 0, len(diffs))
	for path := range diffs {
		paths = append(paths, path)
	}
	sort.Strings(paths)
	for _, path := range paths {
		ufmt.Printf("- Initial Realm Storage: %s %d\n", path, diffs[path])
	}
}

func initializeFeeSetup(cur realm) {
	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()

	testing.SetRealm(adminRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)

	// Fund the real staker caller and approve both protocol-fee proxy and v1
	// implementation, matching the deployed public transfer path.
	bar.Transfer(cross(cur), stakerAddr, fundAmount)
	baz.Transfer(cross(cur), stakerAddr, fundAmount)
	qux.Transfer(cross(cur), stakerAddr, fundAmount)
	obl.Transfer(cross(cur), stakerAddr, fundAmount)

	testing.SetRealm(stakerRealm)
	bar.Approve(cross(cur), protocolFeeAddr, maxInt64)
	baz.Approve(cross(cur), protocolFeeAddr, maxInt64)
	qux.Approve(cross(cur), protocolFeeAddr, maxInt64)
	obl.Approve(cross(cur), protocolFeeAddr, maxInt64)
	bar.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
	baz.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
	qux.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
	obl.Approve(cross(cur), protocolFeeV1Addr, maxInt64)
}

func delegateMetric(cur realm) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Remaining gov fee accumulator delegate allocation", func() {
		govstaker.Delegate(cross(cur), delegateeAddr, stakeAmount, "")
	})
}

func addFeesForFirstK(cur realm, k int) {
	testing.SetRealm(stakerRealm)
	for i := 0; i < k; i++ {
		if err := protocol_fee.AddToProtocolFee(cross(cur), feeTokens[i], feeAmount); err != nil {
			panic(err)
		}
	}
	if k > registeredFeeTokenCount {
		registeredFeeTokenCount = k
	}
}

func distributeFees(cur realm) {
	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross(cur))
}

func repeatedFeeMetric(cur realm, rounds int64) {
	for i := int64(0); i < rounds; i++ {
		addFeesForFirstK(cur, len(feeTokens))
		distributeFees(cur)
		testing.SkipHeights(1)
		testing.SetRealm(adminRealm)
		metric.PrintMetricsBy(ufmt.Sprintf("Remaining gov fee accumulator repeat-%d claim-%d", rounds, i+1), func() {
			govstaker.CollectReward(cross(cur))
		})
	}
}

func lifecycleMetric(cur realm) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Remaining gov fee accumulator lifecycle undelegate", func() {
		govstaker.Undelegate(cross(cur), delegateeAddr, stakeAmount)
	})

	testing.SkipHeights(govstaker.GetUnDelegationLockupPeriod()/5 + 1)
	var withdrawn int64
	metric.PrintMetricsBy("Remaining gov fee accumulator lifecycle withdraw", func() {
		withdrawn = govstaker.CollectUndelegatedGns(cross(cur))
	})
	if withdrawn != stakeAmount || govstaker.GetTotalLockedAmount() != 0 {
		panic("full undelegated principal was not withdrawn")
	}

	metric.PrintMetricsBy("Remaining gov fee accumulator lifecycle restake", func() {
		govstaker.Delegate(cross(cur), delegateeAddr, stakeAmount, "")
	})
}

func printFeeState(cur realm, label string, account address) {
	claimableEmission, claimableFees, err := govstaker.GetClaimableRewardByAddress(account)
	if err != nil {
		panic(err)
	}

	ids := govstaker.GetUserDelegationIDs(account, delegateeAddr)
	idText := ""
	for i, id := range ids {
		if i > 0 {
			idText += ","
		}
		idText += ufmt.Sprintf("%d", id)
	}

	claimableText := ""
	for _, token := range feeTokens {
		if len(claimableText) > 0 {
			claimableText += ","
		}
		claimableText += ufmt.Sprintf("%s:%d", token, claimableFees[token])
	}

	accumulatorText := ""
	for i, token := range feeTokens {
		if len(accumulatorText) > 0 {
			accumulatorText += ","
		}
		if i >= registeredFeeTokenCount {
			accumulatorText += ufmt.Sprintf("%s:missing", token)
			continue
		}
		accumulatorText += ufmt.Sprintf(
			"%s:%s/%d",
			token,
			govstaker.GetProtocolFeeAccumulatedX128PerStake(token).ToString(),
			govstaker.GetProtocolFeeAmount(token),
		)
	}

	println(
		ufmt.Sprintf(
			"- State: %s account=%s delegated=%d locked=%d delegation_ids=%s fee_accumulators=%s fee_timestamp=%d claimable_emission=%d claimable_fees=%s gns_balance=%d token_balances=%s",
			label,
			account.String(),
			govstaker.GetTotalDelegated(),
			govstaker.GetTotalLockedAmount(),
			idText,
			accumulatorText,
			govstaker.GetProtocolFeeAccumulatedTimestamp(),
			claimableEmission,
			claimableText,
			gns.BalanceOf(account),
			feeBalanceText(account),
		),
	)

	_ = cur
}

func feeBalanceText(account address) string {
	balances := []int64{
		bar.BalanceOf(account),
		baz.BalanceOf(account),
		qux.BalanceOf(account),
		obl.BalanceOf(account),
	}
	balanceText := ""
	for i, token := range feeTokens {
		if len(balanceText) > 0 {
			balanceText += ","
		}
		balanceText += ufmt.Sprintf("%s:%d", token, balances[i])
	}
	return balanceText
}
