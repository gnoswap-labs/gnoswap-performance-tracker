// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Public gov/staker reward-debt lifecycle for one delegator and four
// protocol-fee tokens. Setup and expected-state checks stay outside metric
// windows; each labeled crossing measures only the lifecycle operation.
//
// The first delegation is the upfront state allocation. Claims cover one
// token, emission, all remaining fee tokens, and an idempotent repeat. The
// final windows cover full undelegation, withdrawal, and a restake.
package main

import (
	"sort"
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gns"
	gs "gno.land/r/gnoswap/gov/staker"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	"gno.land/r/gnoswap/protocol_fee"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/scenario/metric"
	"gno.land/r/gnoswap/scenarioutils"

	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/foo"
	"gno.land/r/onbloc/qux"
)

const (
	stakeAmount int64 = 1_000_000
	maxInt64    int64 = 9223372036854775807

	barPath = "gno.land/r/onbloc/bar.BAR"
	bazPath = "gno.land/r/onbloc/baz.BAZ"
	fooPath = "gno.land/r/onbloc/foo.FOO"
	quxPath = "gno.land/r/onbloc/qux.QUX"
	gnsPath = "gno.land/r/gnoswap/gns.GNS"
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	stakerAddr, _      = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm        = testing.NewUserRealm(stakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())
	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)

	focusAddr  = testutils.TestAddress("gov-debt-focus")
	focusRealm = testing.NewUserRealm(focusAddr)
)

type rewardSnapshot struct {
	emission      int64
	fees          map[string]int64
	gnsBalance    int64
	tokenBalances map[string]int64
}

func main(cur realm) {
	tokens := []string{barPath, bazPath, fooPath, quxPath}
	setup(cur)

	initial := takeRewardSnapshot(tokens)
	assertNoClaimable(initial, tokens, "initial state")
	assertEqualInt64("initial GNS balance", initial.gnsBalance, stakeAmount)
	assertEqualInt64("initial total delegated", gs.GetTotalDelegated(), 0)

	// This is the upfront allocation window: no focus-user delegation exists in
	// setup, while all manager/token configuration is already initialized.
	testing.SetRealm(focusRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
	beforeStake := takeRewardSnapshot(tokens)
	printDebtMetrics("STAKE users=1 tokens=4", func() {
		gs.Delegate(cross(cur), focusAddr, stakeAmount, "")
	})
	afterStake := takeRewardSnapshot(tokens)
	assertNoClaimable(afterStake, tokens, "after initial delegate")
	assertEqualInt64("GNS after initial delegate", afterStake.gnsBalance, 0)
	assertEqualInt64("total delegated after initial delegate", gs.GetTotalDelegated(), stakeAmount)
	assertEqualInt64("locked after initial delegate", gs.GetTotalLockedAmount(), stakeAmount)
	assertTokenBalancesUnchanged(beforeStake, afterStake, tokens, "initial delegate")

	// Funding and emission accrual are deliberately outside every claim window.
	setupPostStake(cur, tokens)

	claimSingleFee(cur, tokens)
	claimEmission(cur, tokens)
	claimAllFees(cur, tokens)

	// A later block with no new distribution measures repeated-claim behavior
	// without mixing a second funding window into the lifecycle accounting.
	testing.SkipHeights(1)
	beforeRepeat := takeRewardSnapshot(tokens)
	printDebtMetrics("CLAIM_REPEAT_NOOP users=1 tokens=4", func() {
		testing.SetRealm(focusRealm)
		gs.CollectReward(cross(cur))
	})
	afterRepeat := takeRewardSnapshot(tokens)
	assertSnapshotUnchanged(beforeRepeat, afterRepeat, tokens, "repeat claim")
	assertNoClaimable(afterRepeat, tokens, "after repeat claim")

	beforeUndelegate := takeRewardSnapshot(tokens)
	testing.SetRealm(focusRealm)
	printDebtMetrics("UNSTAKE_FULL users=1 tokens=4", func() {
		gs.Undelegate(cross(cur), focusAddr, stakeAmount)
	})
	afterUndelegate := takeRewardSnapshot(tokens)
	assertBalancesUnchanged(beforeUndelegate, afterUndelegate, tokens, "full undelegate")
	assertEqualInt64("total delegated after full undelegate", gs.GetTotalDelegated(), 0)
	assertEqualInt64("locked after full undelegate", gs.GetTotalLockedAmount(), stakeAmount)

	// Lockup is zero, but advance one height so withdrawal is a distinct
	// lifecycle window from undelegation.
	testing.SkipHeights(1)
	beforeWithdraw := takeRewardSnapshot(tokens)
	collected := int64(0)
	testing.SetRealm(focusRealm)
	printDebtMetrics("COLLECT_UNSTAKE users=1 tokens=4", func() {
		collected = gs.CollectUndelegatedGns(cross(cur))
	})
	afterWithdraw := takeRewardSnapshot(tokens)
	assertEqualInt64("withdrawal amount", collected, stakeAmount)
	assertEqualInt64("GNS after withdrawal", afterWithdraw.gnsBalance, beforeWithdraw.gnsBalance+stakeAmount)
	assertTokenBalancesUnchanged(beforeWithdraw, afterWithdraw, tokens, "withdrawal")
	assertEqualInt64("total delegated after withdrawal", gs.GetTotalDelegated(), 0)
	assertEqualInt64("locked after withdrawal", gs.GetTotalLockedAmount(), 0)

	// Re-approve outside the measured crossing because TransferFrom consumes the
	// prior allowance. This is the lifecycle comparison to the upfront stake.
	testing.SetRealm(focusRealm)
	gns.Approve(cross(cur), govStakerAddr, maxInt64)
	beforeRestake := takeRewardSnapshot(tokens)
	printDebtMetrics("RESTAKE users=1 tokens=4", func() {
		gs.Delegate(cross(cur), focusAddr, stakeAmount, "")
	})
	afterRestake := takeRewardSnapshot(tokens)
	assertEqualInt64("GNS after restake", afterRestake.gnsBalance, beforeRestake.gnsBalance-stakeAmount)
	assertTokenBalancesUnchanged(beforeRestake, afterRestake, tokens, "restake")
	assertEqualInt64("total delegated after restake", gs.GetTotalDelegated(), stakeAmount)
	assertEqualInt64("locked after restake", gs.GetTotalLockedAmount(), stakeAmount)
}

func setup(cur realm) {
	testing.SetRealm(adminRealm)
	gs.SetUnDelegationLockupPeriodByAdmin(cross(cur), 0)
	emission.ChangeDistributionPct(cross(cur), 0, 0, 0, 10000)

	// Emission initialization requires the canonical default pool to exist.
	scenarioutils.EnsureCanonicalDefaultPool(cross(cur))
	emission.SetDistributionStartTime(cross(cur), time.Now().Unix()+1)
	testing.SkipHeights(2)
	emission.MintAndDistributeGns(cross(cur))

	// Seed one token while total stake is zero. The initial delegate therefore
	// snapshots a zero debt for a present token while other tokens are absent.
	addProtocolFee(cur, barPath, 1000)
	flushProtocolFees(cur)

	testing.SetRealm(adminRealm)
	gns.Transfer(cross(cur), focusAddr, stakeAmount)
}

func setupPostStake(cur realm, tokens []string) {
	for i, tokenPath := range tokens {
		addProtocolFee(cur, tokenPath, int64(1000+i*100))
	}
	flushProtocolFees(cur)

	testing.SkipHeights(25)
	testing.SetRealm(adminRealm)
	emission.MintAndDistributeGns(cross(cur))
	funded := takeRewardSnapshot(tokens)
	if funded.emission <= 0 {
		panic("gov debt fixture requires funded emission rewards")
	}
	for _, token := range tokens {
		if funded.fees[token] <= 0 {
			panic("gov debt fixture requires rewards for each fee token")
		}
	}
}

func claimSingleFee(cur realm, tokens []string) {
	before := takeRewardSnapshot(tokens)
	testing.SetRealm(focusRealm)
	printDebtMetrics("CLAIM_SINGLE_FEE users=1 tokens=4", func() {
		gs.CollectProtocolFeeReward(cross(cur), tokens[0])
	})
	after := takeRewardSnapshot(tokens)
	assertClaimTransition(before, after, tokens, false, tokens[0], false, "single fee claim")
}

func claimEmission(cur realm, tokens []string) {
	before := takeRewardSnapshot(tokens)
	testing.SetRealm(focusRealm)
	printDebtMetrics("CLAIM_EMISSION users=1 tokens=4", func() {
		gs.CollectEmissionReward(cross(cur))
	})
	after := takeRewardSnapshot(tokens)
	assertClaimTransition(before, after, tokens, true, "", false, "emission claim")
}

func claimAllFees(cur realm, tokens []string) {
	before := takeRewardSnapshot(tokens)
	testing.SetRealm(focusRealm)
	printDebtMetrics("CLAIM_ALL_FEES users=1 tokens=4", func() {
		gs.CollectReward(cross(cur))
	})
	after := takeRewardSnapshot(tokens)
	assertClaimTransition(before, after, tokens, true, "", true, "all-fee claim")
}

func addProtocolFee(cur realm, tokenPath string, amount int64) {
	testing.SetRealm(adminRealm)
	transferToken(cur, tokenPath, stakerAddr, amount)

	protocolFeeV1Addr := testing.NewCodeRealm("gno.land/r/gnoswap/protocol_fee/v1").Address()
	testing.SetRealm(stakerRealm)
	approveToken(cur, tokenPath, protocolFeeAddr, amount)
	approveToken(cur, tokenPath, protocolFeeV1Addr, amount)
	if err := protocol_fee.AddToProtocolFee(cross(cur), tokenPath, amount); err != nil {
		panic(err)
	}
}

func flushProtocolFees(cur realm) {
	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross(cur))
}

func transferToken(cur realm, tokenPath string, to address, amount int64) {
	switch tokenPath {
	case barPath:
		bar.Transfer(cross(cur), to, amount)
	case bazPath:
		baz.Transfer(cross(cur), to, amount)
	case fooPath:
		foo.Transfer(cross(cur), to, amount)
	case quxPath:
		qux.Transfer(cross(cur), to, amount)
	default:
		panic("unknown gov debt fixture token")
	}
}

func approveToken(cur realm, tokenPath string, spender address, amount int64) {
	switch tokenPath {
	case barPath:
		bar.Approve(cross(cur), spender, amount)
	case bazPath:
		baz.Approve(cross(cur), spender, amount)
	case fooPath:
		foo.Approve(cross(cur), spender, amount)
	case quxPath:
		qux.Approve(cross(cur), spender, amount)
	default:
		panic("unknown gov debt fixture token")
	}
}

func takeRewardSnapshot(tokens []string) rewardSnapshot {
	emissionReward, feeRewards, err := gs.GetClaimableRewardByAddress(focusAddr)
	if err != nil {
		panic(err)
	}

	fees := make(map[string]int64)
	tokenBalances := make(map[string]int64)
	for _, tokenPath := range tokens {
		fees[tokenPath] = feeRewards[tokenPath]
		tokenBalances[tokenPath] = common.BalanceOf(tokenPath, focusAddr)
	}

	return rewardSnapshot{
		emission:      emissionReward,
		fees:          fees,
		gnsBalance:    common.BalanceOf(gnsPath, focusAddr),
		tokenBalances: tokenBalances,
	}
}

func assertClaimTransition(before, after rewardSnapshot, tokens []string, claimEmission bool, claimedToken string, claimAllFees bool, label string) {
	expectedEmission := before.emission
	expectedGnsBalance := before.gnsBalance
	if claimEmission {
		expectedEmission = 0
		expectedGnsBalance += before.emission
	}
	assertEqualInt64(label+" emission claimable", after.emission, expectedEmission)
	assertEqualInt64(label+" GNS balance", after.gnsBalance, expectedGnsBalance)

	for _, tokenPath := range tokens {
		expectedFee := before.fees[tokenPath]
		expectedBalance := before.tokenBalances[tokenPath]
		if claimAllFees || tokenPath == claimedToken {
			expectedFee = 0
			expectedBalance += before.fees[tokenPath]
		}
		assertEqualInt64(label+" fee claimable "+tokenPath, after.fees[tokenPath], expectedFee)
		assertEqualInt64(label+" token balance "+tokenPath, after.tokenBalances[tokenPath], expectedBalance)
	}
}

func assertNoClaimable(snapshot rewardSnapshot, tokens []string, label string) {
	assertEqualInt64(label+" emission claimable", snapshot.emission, 0)
	for _, tokenPath := range tokens {
		assertEqualInt64(label+" fee claimable "+tokenPath, snapshot.fees[tokenPath], 0)
	}
}

func assertSnapshotUnchanged(before, after rewardSnapshot, tokens []string, label string) {
	assertEqualInt64(label+" emission claimable", after.emission, before.emission)
	assertEqualInt64(label+" GNS balance", after.gnsBalance, before.gnsBalance)
	for _, tokenPath := range tokens {
		assertEqualInt64(label+" fee claimable "+tokenPath, after.fees[tokenPath], before.fees[tokenPath])
		assertEqualInt64(label+" token balance "+tokenPath, after.tokenBalances[tokenPath], before.tokenBalances[tokenPath])
	}
}

func assertBalancesUnchanged(before, after rewardSnapshot, tokens []string, label string) {
	assertEqualInt64(label+" GNS balance", after.gnsBalance, before.gnsBalance)
	assertTokenBalancesUnchanged(before, after, tokens, label)
}

func assertTokenBalancesUnchanged(before, after rewardSnapshot, tokens []string, label string) {
	for _, tokenPath := range tokens {
		assertEqualInt64(label+" token balance "+tokenPath, after.tokenBalances[tokenPath], before.tokenBalances[tokenPath])
	}
}

func assertEqualInt64(label string, got, want int64) {
	if got != want {
		panic(ufmt.Sprintf("gov debt lifecycle %s: got %d, want %d", label, got, want))
	}
}

// Retain signed per-realm deltas for deposit/refund accounting. These reads
// and prints are outside the standard metric interval.
func printDebtMetrics(name string, fn func()) {
	before := testing.GetRealmStorageDiffs()
	metric.PrintMetricsBy(name, fn)
	after := testing.GetRealmStorageDiffs()
	deltas := make(map[string]int64)
	for path, value := range after {
		deltas[path] = value
	}
	for path, value := range before {
		deltas[path] -= value
	}
	paths := make([]string, 0, len(deltas))
	for path := range deltas {
		paths = append(paths, path)
	}
	sort.Strings(paths)
	for _, path := range paths {
		ufmt.Printf("- Realm Storage: %s %d\n", path, deltas[path])
	}
}

// Output:
// STAKE users=1 tokens=4
// - Gas Used: 3563209
// - Storage Diff: 34686
// - CPU Cycles: 2672677
// - Realm Storage: gno.land/r/demo/defi/grc20reg 0
// - Realm Storage: gno.land/r/gnoswap/access 0
// - Realm Storage: gno.land/r/gnoswap/common 0
// - Realm Storage: gno.land/r/gnoswap/emission 0
// - Realm Storage: gno.land/r/gnoswap/gns -2040
// - Realm Storage: gno.land/r/gnoswap/gov/staker 35775
// - Realm Storage: gno.land/r/gnoswap/gov/staker/v1 0
// - Realm Storage: gno.land/r/gnoswap/gov/xgns 1043
// - Realm Storage: gno.land/r/gnoswap/halt 0
// - Realm Storage: gno.land/r/gnoswap/pool 0
// - Realm Storage: gno.land/r/gnoswap/pool/v1 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee -92
// - Realm Storage: gno.land/r/gnoswap/protocol_fee/v1 0
// - Realm Storage: gno.land/r/gnoswap/referral 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric/main 0
// - Realm Storage: gno.land/r/gnoswap/scenarioutils 0
// - Realm Storage: gno.land/r/gnoswap/staker 0
// - Realm Storage: gno.land/r/gnoswap/staker/v1 0
// - Realm Storage: gno.land/r/onbloc/bar 0
// - Realm Storage: gno.land/r/onbloc/baz 0
// - Realm Storage: gno.land/r/onbloc/foo 0
// - Realm Storage: gno.land/r/onbloc/qux 0
// CLAIM_SINGLE_FEE users=1 tokens=4
// - Gas Used: 2752890
// - Storage Diff: 2197
// - CPU Cycles: 2437067
// - Realm Storage: gno.land/r/demo/defi/grc20reg 0
// - Realm Storage: gno.land/r/gnoswap/access 0
// - Realm Storage: gno.land/r/gnoswap/common 0
// - Realm Storage: gno.land/r/gnoswap/emission 0
// - Realm Storage: gno.land/r/gnoswap/gns 0
// - Realm Storage: gno.land/r/gnoswap/gov/staker 183
// - Realm Storage: gno.land/r/gnoswap/gov/staker/v1 0
// - Realm Storage: gno.land/r/gnoswap/gov/xgns 0
// - Realm Storage: gno.land/r/gnoswap/halt 0
// - Realm Storage: gno.land/r/gnoswap/pool 0
// - Realm Storage: gno.land/r/gnoswap/pool/v1 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee -49
// - Realm Storage: gno.land/r/gnoswap/protocol_fee/v1 0
// - Realm Storage: gno.land/r/gnoswap/referral 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric/main 0
// - Realm Storage: gno.land/r/gnoswap/scenarioutils 0
// - Realm Storage: gno.land/r/gnoswap/staker 0
// - Realm Storage: gno.land/r/gnoswap/staker/v1 0
// - Realm Storage: gno.land/r/onbloc/bar 2063
// - Realm Storage: gno.land/r/onbloc/baz 0
// - Realm Storage: gno.land/r/onbloc/foo 0
// - Realm Storage: gno.land/r/onbloc/qux 0
// CLAIM_EMISSION users=1 tokens=4
// - Gas Used: 2673332
// - Storage Diff: 2079
// - CPU Cycles: 2345245
// - Realm Storage: gno.land/r/demo/defi/grc20reg 0
// - Realm Storage: gno.land/r/gnoswap/access 0
// - Realm Storage: gno.land/r/gnoswap/common 0
// - Realm Storage: gno.land/r/gnoswap/emission 0
// - Realm Storage: gno.land/r/gnoswap/gns 2043
// - Realm Storage: gno.land/r/gnoswap/gov/staker 36
// - Realm Storage: gno.land/r/gnoswap/gov/staker/v1 0
// - Realm Storage: gno.land/r/gnoswap/gov/xgns 0
// - Realm Storage: gno.land/r/gnoswap/halt 0
// - Realm Storage: gno.land/r/gnoswap/pool 0
// - Realm Storage: gno.land/r/gnoswap/pool/v1 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee/v1 0
// - Realm Storage: gno.land/r/gnoswap/referral 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric/main 0
// - Realm Storage: gno.land/r/gnoswap/scenarioutils 0
// - Realm Storage: gno.land/r/gnoswap/staker 0
// - Realm Storage: gno.land/r/gnoswap/staker/v1 0
// - Realm Storage: gno.land/r/onbloc/bar 0
// - Realm Storage: gno.land/r/onbloc/baz 0
// - Realm Storage: gno.land/r/onbloc/foo 0
// - Realm Storage: gno.land/r/onbloc/qux 0
// CLAIM_ALL_FEES users=1 tokens=4
// - Gas Used: 8744022
// - Storage Diff: 10484
// - CPU Cycles: 7685312
// - Realm Storage: gno.land/r/demo/defi/grc20reg 0
// - Realm Storage: gno.land/r/gnoswap/access 0
// - Realm Storage: gno.land/r/gnoswap/common 0
// - Realm Storage: gno.land/r/gnoswap/emission 0
// - Realm Storage: gno.land/r/gnoswap/gns 0
// - Realm Storage: gno.land/r/gnoswap/gov/staker 4701
// - Realm Storage: gno.land/r/gnoswap/gov/staker/v1 0
// - Realm Storage: gno.land/r/gnoswap/gov/xgns 0
// - Realm Storage: gno.land/r/gnoswap/halt 0
// - Realm Storage: gno.land/r/gnoswap/pool 0
// - Realm Storage: gno.land/r/gnoswap/pool/v1 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee -304
// - Realm Storage: gno.land/r/gnoswap/protocol_fee/v1 0
// - Realm Storage: gno.land/r/gnoswap/referral 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric/main 0
// - Realm Storage: gno.land/r/gnoswap/scenarioutils 0
// - Realm Storage: gno.land/r/gnoswap/staker 0
// - Realm Storage: gno.land/r/gnoswap/staker/v1 0
// - Realm Storage: gno.land/r/onbloc/bar 0
// - Realm Storage: gno.land/r/onbloc/baz 2029
// - Realm Storage: gno.land/r/onbloc/foo 2029
// - Realm Storage: gno.land/r/onbloc/qux 2029
// CLAIM_REPEAT_NOOP users=1 tokens=4
// - Gas Used: 3297381
// - Storage Diff: 0
// - CPU Cycles: 2734260
// - Realm Storage: gno.land/r/demo/defi/grc20reg 0
// - Realm Storage: gno.land/r/gnoswap/access 0
// - Realm Storage: gno.land/r/gnoswap/common 0
// - Realm Storage: gno.land/r/gnoswap/emission 0
// - Realm Storage: gno.land/r/gnoswap/gns 0
// - Realm Storage: gno.land/r/gnoswap/gov/staker 0
// - Realm Storage: gno.land/r/gnoswap/gov/staker/v1 0
// - Realm Storage: gno.land/r/gnoswap/gov/xgns 0
// - Realm Storage: gno.land/r/gnoswap/halt 0
// - Realm Storage: gno.land/r/gnoswap/pool 0
// - Realm Storage: gno.land/r/gnoswap/pool/v1 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee/v1 0
// - Realm Storage: gno.land/r/gnoswap/referral 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric/main 0
// - Realm Storage: gno.land/r/gnoswap/scenarioutils 0
// - Realm Storage: gno.land/r/gnoswap/staker 0
// - Realm Storage: gno.land/r/gnoswap/staker/v1 0
// - Realm Storage: gno.land/r/onbloc/bar 0
// - Realm Storage: gno.land/r/onbloc/baz 0
// - Realm Storage: gno.land/r/onbloc/foo 0
// - Realm Storage: gno.land/r/onbloc/qux 0
// UNSTAKE_FULL users=1 tokens=4
// - Gas Used: 6134830
// - Storage Diff: 1597
// - CPU Cycles: 5264711
// - Realm Storage: gno.land/r/demo/defi/grc20reg 0
// - Realm Storage: gno.land/r/gnoswap/access 0
// - Realm Storage: gno.land/r/gnoswap/common 0
// - Realm Storage: gno.land/r/gnoswap/emission 0
// - Realm Storage: gno.land/r/gnoswap/gns 6
// - Realm Storage: gno.land/r/gnoswap/gov/staker 1591
// - Realm Storage: gno.land/r/gnoswap/gov/staker/v1 0
// - Realm Storage: gno.land/r/gnoswap/gov/xgns 0
// - Realm Storage: gno.land/r/gnoswap/halt 0
// - Realm Storage: gno.land/r/gnoswap/pool 0
// - Realm Storage: gno.land/r/gnoswap/pool/v1 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee/v1 0
// - Realm Storage: gno.land/r/gnoswap/referral 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric/main 0
// - Realm Storage: gno.land/r/gnoswap/scenarioutils 0
// - Realm Storage: gno.land/r/gnoswap/staker 0
// - Realm Storage: gno.land/r/gnoswap/staker/v1 0
// - Realm Storage: gno.land/r/onbloc/bar 0
// - Realm Storage: gno.land/r/onbloc/baz 0
// - Realm Storage: gno.land/r/onbloc/foo 0
// - Realm Storage: gno.land/r/onbloc/qux 0
// COLLECT_UNSTAKE users=1 tokens=4
// - Gas Used: 3132128
// - Storage Diff: -6665
// - CPU Cycles: 2658041
// - Realm Storage: gno.land/r/demo/defi/grc20reg 0
// - Realm Storage: gno.land/r/gnoswap/access 0
// - Realm Storage: gno.land/r/gnoswap/common 0
// - Realm Storage: gno.land/r/gnoswap/emission 0
// - Realm Storage: gno.land/r/gnoswap/gns -6
// - Realm Storage: gno.land/r/gnoswap/gov/staker -5631
// - Realm Storage: gno.land/r/gnoswap/gov/staker/v1 0
// - Realm Storage: gno.land/r/gnoswap/gov/xgns -1028
// - Realm Storage: gno.land/r/gnoswap/halt 0
// - Realm Storage: gno.land/r/gnoswap/pool 0
// - Realm Storage: gno.land/r/gnoswap/pool/v1 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee/v1 0
// - Realm Storage: gno.land/r/gnoswap/referral 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric/main 0
// - Realm Storage: gno.land/r/gnoswap/scenarioutils 0
// - Realm Storage: gno.land/r/gnoswap/staker 0
// - Realm Storage: gno.land/r/gnoswap/staker/v1 0
// - Realm Storage: gno.land/r/onbloc/bar 0
// - Realm Storage: gno.land/r/onbloc/baz 0
// - Realm Storage: gno.land/r/onbloc/foo 0
// - Realm Storage: gno.land/r/onbloc/qux 0
// RESTAKE users=1 tokens=4
// - Gas Used: 4553190
// - Storage Diff: 6828
// - CPU Cycles: 3815810
// - Realm Storage: gno.land/r/demo/defi/grc20reg 0
// - Realm Storage: gno.land/r/gnoswap/access 0
// - Realm Storage: gno.land/r/gnoswap/common 0
// - Realm Storage: gno.land/r/gnoswap/emission 0
// - Realm Storage: gno.land/r/gnoswap/gns 0
// - Realm Storage: gno.land/r/gnoswap/gov/staker 5800
// - Realm Storage: gno.land/r/gnoswap/gov/staker/v1 0
// - Realm Storage: gno.land/r/gnoswap/gov/xgns 1028
// - Realm Storage: gno.land/r/gnoswap/halt 0
// - Realm Storage: gno.land/r/gnoswap/pool 0
// - Realm Storage: gno.land/r/gnoswap/pool/v1 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee 0
// - Realm Storage: gno.land/r/gnoswap/protocol_fee/v1 0
// - Realm Storage: gno.land/r/gnoswap/referral 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric 0
// - Realm Storage: gno.land/r/gnoswap/scenario/metric/main 0
// - Realm Storage: gno.land/r/gnoswap/scenarioutils 0
// - Realm Storage: gno.land/r/gnoswap/staker 0
// - Realm Storage: gno.land/r/gnoswap/staker/v1 0
// - Realm Storage: gno.land/r/onbloc/bar 0
// - Realm Storage: gno.land/r/onbloc/baz 0
// - Realm Storage: gno.land/r/onbloc/foo 0
// - Realm Storage: gno.land/r/onbloc/qux 0
