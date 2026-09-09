// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Public governance-staker lifecycle for the persisted emission accumulator.
// The measured windows cover actual emission distribution and reward claims;
// state lines remain outside those windows for baseline/candidate parity checks.
package main

import (
	"sort"
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gns"
	govstaker "gno.land/r/gnoswap/gov/staker"

	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/scenarioutils"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	govStakerAddr, _ = access.GetAddress(prabc.ROLE_GOV_STAKER.String())

	delegateeAddr = testutils.TestAddress("remain-emission")

	maxInt64    int64 = 9223372036854775807
	stakeAmount int64 = 1_000_000
)

func main(cur realm) {
	printInitialRealmStorage()
	initializeEmissionSetup(cur)
	printEmissionState("after-init", delegateeAddr)

	delegateMetric(cur)
	printEmissionState("after-first-delegation", adminAddr)

	for _, rounds := range []int64{1, 10, 100, 1000} {
		repeatedEmissionMetric(cur, rounds)
		printEmissionState(ufmt.Sprintf("after-repeat-%d", rounds), adminAddr)
	}

	// A claim with no newly distributed reward is a sparse/no-op control.
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Remaining gov emission accumulator no-new-reward claim", func() {
		govstaker.CollectEmissionReward(cross(cur))
	})
	printEmissionState("after-no-new-reward-claim", adminAddr)

	lifecycleMetric(cur)
	printEmissionState("after-lifecycle", adminAddr)
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

func initializeEmissionSetup(cur realm) {
	testing.SetRealm(adminRealm)
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	gns.Approve(cross(cur), govStakerAddr, maxInt64)

	// Make the governance-staker distribution non-zero using the real admin API.
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	emission.ChangeDistributionPct(cross(cur), 6500, 2000, 500, 1000)
	testing.SkipHeights(1)
}

func delegateMetric(cur realm) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Remaining gov emission accumulator delegate allocation", func() {
		govstaker.Delegate(cross(cur), delegateeAddr, stakeAmount, "")
	})
}

func repeatedEmissionMetric(cur realm, rounds int64) {
	for i := int64(0); i < rounds; i++ {
		testing.SetRealm(adminRealm)
		testing.SkipHeights(1)
		emission.MintAndDistributeGns(cross(cur))
		metric.PrintMetricsBy(ufmt.Sprintf("Remaining gov emission accumulator repeat-%d claim-%d", rounds, i+1), func() {
			govstaker.CollectEmissionReward(cross(cur))
		})
	}
}

func lifecycleMetric(cur realm) {
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Remaining gov emission accumulator lifecycle undelegate", func() {
		govstaker.Undelegate(cross(cur), delegateeAddr, stakeAmount)
	})

	testing.SkipHeights(govstaker.GetUnDelegationLockupPeriod()/5 + 1)
	var withdrawn int64
	metric.PrintMetricsBy("Remaining gov emission accumulator lifecycle withdraw", func() {
		withdrawn = govstaker.CollectUndelegatedGns(cross(cur))
	})
	if withdrawn != stakeAmount || govstaker.GetTotalLockedAmount() != 0 {
		panic("full undelegated principal was not withdrawn")
	}

	metric.PrintMetricsBy("Remaining gov emission accumulator lifecycle restake", func() {
		govstaker.Delegate(cross(cur), delegateeAddr, stakeAmount, "")
	})
}

func printEmissionState(label string, account address) {
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

	accumulated := govstaker.GetEmissionAccumulatedX128PerStake()
	println(
		ufmt.Sprintf(
			"- State: %s account=%s delegated=%d locked=%d delegation_ids=%s emission_accumulator=%s emission_distributed=%d emission_timestamp=%d claimable_emission=%d claimable_fee_tokens=%d gns_balance=%d",
			label,
			account.String(),
			govstaker.GetTotalDelegated(),
			govstaker.GetTotalLockedAmount(),
			idText,
			accumulated.ToString(),
			govstaker.GetEmissionDistributedAmount(),
			govstaker.GetEmissionAccumulatedTimestamp(),
			claimableEmission,
			len(claimableFees),
			gns.BalanceOf(account),
		),
	)
}
