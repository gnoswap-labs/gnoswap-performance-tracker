// Gas and performance metrics for end-to-end gnoswap stress scenarios.
//
// Phases:
//   - Phase A (router/staker): create pools, mint/stake positions, run ExactIn/ExactOut
//     swaps and staker.CollectReward iterations.
//   - Phase B (gov/staker): Delegate / Undelegate / CollectReward iterations.
//   - Phase C (gov/governance): Vote iterations.
//   - Phase D (launchpad): DepositGns / CollectRewardByDepositId iterations.
//
// Each phase iterates `iterations` (default 100) times and prints metrics only at
// `printPoints` (1, 5, 10, 100) using integration.PrintMetricsBy.
package main

import (
	"chain"
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/tokens/grc721"
	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	"gno.land/p/nt/ufmt/v0"
	"gno.land/r/gnoswap/emission"
	"gno.land/r/gnoswap/gnft"
	_ "gno.land/r/gnoswap/rbac"
	"gno.land/r/gnoswap/staker"

	_ "gno.land/r/gnoswap/gov/governance/v1"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/launchpad/v1"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/position/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/router/v1"
	_ "gno.land/r/gnoswap/staker/v1"

	_ "gno.land/r/onbloc/bar"
	_ "gno.land/r/onbloc/baz"
	_ "gno.land/r/onbloc/foo"
	"gno.land/r/onbloc/obl"
	_ "gno.land/r/onbloc/qux"
	_ "gno.land/r/onbloc/usdc"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/common"
	"gno.land/r/gnoswap/gov/governance"
	govstaker "gno.land/r/gnoswap/gov/staker"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/gnoswap/pool"
	"gno.land/r/gnoswap/position"
	"gno.land/r/gnoswap/protocol_fee"
	"gno.land/r/gnoswap/router"

	"gno.land/r/gnoland/wugnot"
	"gno.land/r/gnoswap/gns"

	"gno.land/r/gnoswap/scenario/integration"
)

const blockTimeSeconds int64 = 5

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	poolAddr, _        = access.GetAddress(prabc.ROLE_POOL.String())
	routerAddr, _      = access.GetAddress(prabc.ROLE_ROUTER.String())
	stakerAddr, _      = access.GetAddress(prabc.ROLE_STAKER.String())
	stakerRealm        = testing.NewUserRealm(stakerAddr)
	govStakerAddr, _   = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	govStakerRealm     = testing.NewUserRealm(govStakerAddr)
	protocolFeeAddr, _ = access.GetAddress(prabc.ROLE_PROTOCOL_FEE.String())
	launchpadAddr, _   = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	wugnotPath = "gno.land/r/gnoland/wugnot"
	gnsPath    = "gno.land/r/gnoswap/gns"
	barPath    = "gno.land/r/onbloc/bar"
	bazPath    = "gno.land/r/onbloc/baz"
	fooPath    = "gno.land/r/onbloc/foo"
	oblPath    = "gno.land/r/onbloc/obl"
	quxPath    = "gno.land/r/onbloc/qux"
	usdcPath   = "gno.land/r/onbloc/usdc"

	maxInt64 int64 = 9223372036854775807

	// Shared addresses for gov / launchpad phases.
	govAliceAddr      = testutils.TestAddress("gov-alice")
	launchpadUserAddr = testutils.TestAddress("lp-user")
	launchpadUserRlm  = testing.NewUserRealm(launchpadUserAddr)
	projectOwnerAddr  = testutils.TestAddress("project-owner")
)

var (
	minTick     = int32(-887220)
	maxTick     = int32(887220)
	tickSpacing = int32(60)

	printPoints = []int32{1, 5, 10, 100}

	iterationAdjustment = int32(10) // 100 -> 140  10 -> 1400, 1 -> 14000
	iterations          = int32(100)

	incentiveCount         = int32(5)
	TIMESTAMP_90DAYS int64 = 90 * 24 * 60 * 60

	// gov/staker phase
	govDelegateAmount   int64 = 10_000_000
	govUndelegateAmount int64 = 1_000_000

	// gov/governance phase
	voterDelegateAmount int64 = 1_000_000_000

	// launchpad phase
	launchpadDepositAmount int64 = 1_000_000
)

var (
	t *testing.T

	voters      []address
	proposalIds []int64
	depositIds  []string
	projectTier string
)

func main() {
	// ---- Phase A: router / staker stress ----
	initializeRouterPhase()

	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{{"ugnot", 100000000000000}})
	wugnot.Deposit(cross)
	testing.SetOriginSend(chain.Coins{})
	gns.Approve(cross, poolAddr, maxInt64)
	wugnot.Approve(cross, poolAddr, maxInt64)
	gns.Approve(cross, routerAddr, maxInt64)
	wugnot.Approve(cross, routerAddr, maxInt64)

	createPoolsByTokenPaths(wugnotPath, gnsPath, barPath, bazPath, fooPath, oblPath, quxPath, usdcPath)

	incentiveStartTime := createExternalIncentives(incentiveCount)
	testing.SkipHeights((incentiveStartTime-time.Now().Unix())/blockTimeSeconds + 1)

	mintPositionMetric()
	stakePositionMetric()

	for i := int32(0); i < iterations; i++ {
		count := i + int32(1)
		exactInSwapGnsToWugnotMetric(count)
		testing.SkipHeights(1)
		exactOutSwapWugnotToGnsMetric(count)
		testing.SkipHeights(1)
		stakerCollectRewardMetric(count)
		testing.SkipHeights(1)
	}

	// ---- Phase B: gov/staker stress ----
	initializeGovStakerPhase()
	for i := int32(0); i < iterations; i++ {
		count := i + int32(1)
		govDelegateMetric(count)
		testing.SkipHeights(1)
	}

	for i := int32(0); i < iterations; i++ {
		count := i + int32(1)
		govUndelegateMetric(count)
		testing.SkipHeights(1)
	}

	for i := int32(0); i < iterations; i++ {
		count := i + int32(1)
		accumulateProtocolFee()
		govCollectRewardMetric(count)
		testing.SkipHeights(1)
	}

	// ---- Phase C: governance Vote stress ----
	initializeGovernancePhase()
	delegateToVoters()
	createProposals()
	voteMetrics()

	// ---- Phase D: launchpad stress ----
	initializeLaunchpadPhase()
	for i := int32(0); i < iterations; i++ {
		count := i + int32(1)
		depositIds[i] = launchpadDepositGnsMetric(count)
		testing.SkipHeights(1)
	}
	// Allow rewards to accrue.
	testing.SkipHeights((3 * 24 * 60 * 60 / blockTimeSeconds) + 1)
	for i := int32(0); i < iterations; i++ {
		count := i + int32(1)
		launchpadCollectRewardMetric(depositIds[i], count)
		testing.SkipHeights(1)
	}
}

// ----------------------------------------------------------------------
// Phase A — router / staker
// ----------------------------------------------------------------------

func initializeRouterPhase() {
	testing.SetRealm(adminRealm)
	pool.SetPoolCreationFee(cross, 0)

	testing.IssueCoins(chain.PackageAddress("gno.land/r/gnoland/wugnot"), chain.Coins{{"ugnot", 100000000000000}})
	testing.IssueCoins(adminAddr, chain.Coins{{"ugnot", 100000000000000}})

	testing.SetRealm(adminRealm)
	emission.SetDistributionStartTime(cross, time.Now().Unix()+1)
	testing.SkipHeights(1)
}

func createExternalIncentives(creationCount int32) int64 {
	testing.SetRealm(adminRealm)

	common.SafeGRC20Approve(cross, barPath, stakerAddr, maxInt64)
	common.SafeGRC20Approve(cross, gnsPath, stakerAddr, maxInt64)
	common.SafeGRC20Approve(cross, wugnotPath, stakerAddr, maxInt64)
	incentiveStartTime := time.Now().AddDate(0, 0, 1).Truncate(24 * time.Hour).Unix()

	endTime := incentiveStartTime + TIMESTAMP_90DAYS
	poolPath := "gno.land/r/gnoland/wugnot:gno.land/r/gnoswap/gns:3000"
	for i := int32(0); i < creationCount; i++ {
		testing.SetRealm(adminRealm)

		count := i + int32(1)
		iterateMetric("00. Create External Incentive", count, func() {
			staker.CreateExternalIncentive(
				cross,
				poolPath,
				gnsPath,
				1_000_000_000,
				incentiveStartTime,
				endTime,
			)
		})

		testing.SkipHeights(1)
	}

	testing.SkipHeights(1)
	return incentiveStartTime
}

func createPoolsByTokenPaths(tokenPaths ...string) {
	testing.SetRealm(adminRealm)

	feeTiers := []uint32{100, 500, 3000, 10000}
	count := int32(0)

	for i := 0; i < len(tokenPaths); i++ {
		for j := i + 1; j < len(tokenPaths); j++ {
			for _, feeTier := range feeTiers {
				count++
				iterateMetric("01. Create Pool", count, func() {
					pool.CreatePool(
						cross,
						tokenPaths[i],
						tokenPaths[j],
						feeTier,
						common.TickMathGetSqrtRatioAtTick(0).ToString(),
					)
				})
				testing.SkipHeights(1)
			}
		}
	}
}

func mintPositionMetric() {
	for i := int32(0); i < iterations; i++ {
		tickDiff := i * tickSpacing * iterationAdjustment
		min := minTick + tickDiff
		max := tickDiff
		mintPosition(min, max, "10000000", "10000000", i+int32(1))
		testing.SkipHeights(1)
	}
}

func mintPosition(min int32, max int32, amount0 string, amount1 string, count int32) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	iterateMetric("02. Mint Position", count, func() {
		position.Mint(
			cross,
			wugnotPath,
			gnsPath,
			3000,
			min,
			max,
			amount0,
			amount1,
			"0",
			"0",
			9999999999,
			adminAddr,
			adminAddr,
			"",
		)
	})
}

func stakePositionMetric() {
	for i := int32(0); i < iterations; i++ {
		positionID := uint64(i + 1)
		testing.SetRealm(adminRealm)
		gnft.Approve(cross, stakerAddr, grc721.TokenID(strconv.FormatUint(positionID, 10)))

		iterateMetric("03. Stake Position", i+int32(1), func() {
			staker.StakeToken(cross, positionID, "")
		})

		testing.SkipHeights(1)
	}
}

func exactInSwapGnsToWugnotMetric(count int32) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	iterateMetric("04. ExactInSwapRoute", count, func() {
		router.ExactInSwapRoute(
			cross,
			gnsPath,
			wugnotPath,
			"10000000",
			"gno.land/r/gnoswap/gns:gno.land/r/gnoland/wugnot:3000",
			"100",
			"0",
			9999999999,
			"",
		)
	})
}

func exactOutSwapWugnotToGnsMetric(count int32) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	iterateMetric("05. ExactOutSwapRoute", count, func() {
		router.ExactOutSwapRoute(
			cross,
			wugnotPath,
			gnsPath,
			"1000000",
			"gno.land/r/gnoland/wugnot:gno.land/r/gnoswap/gns:3000",
			"100",
			"100000000000",
			9999999999,
			"",
		)
	})
}

func stakerCollectRewardMetric(count int32) {
	testing.SetRealm(adminRealm)
	testing.SetOriginSend(chain.Coins{})

	iterateMetric("06. CollectReward With Swap Count", count, func() {
		staker.CollectReward(cross, uint64(count))
	})
}

// ----------------------------------------------------------------------
// Phase B — gov/staker
// ----------------------------------------------------------------------

func initializeGovStakerPhase() {
	testing.SetRealm(adminRealm)
	gns.Approve(cross, govStakerAddr, maxInt64)
	testing.SkipHeights(1)
}

func govDelegateMetric(count int32) {
	testing.SetRealm(adminRealm)
	iterateMetric("07. GovStaker Delegate", count, func() {
		govstaker.Delegate(cross, govAliceAddr, govDelegateAmount, "")
	})
}

func govUndelegateMetric(count int32) {
	testing.SetRealm(adminRealm)
	iterateMetric("08. GovStaker Undelegate", count, func() {
		govstaker.Undelegate(cross, govAliceAddr, govUndelegateAmount)
	})
}

func accumulateProtocolFee() {
	testing.SetRealm(adminRealm)
	gns.Transfer(cross, protocolFeeAddr, 1_000_000)

	testing.SetRealm(stakerRealm)
	common.SafeGRC20Approve(cross, gnsPath, protocolFeeAddr, maxInt64)
	protocol_fee.AddToProtocolFee(cross, gnsPath, 1_000_000)

	testing.SetRealm(govStakerRealm)
	protocol_fee.DistributeProtocolFee(cross)
}

func govCollectRewardMetric(count int32) {
	testing.SetRealm(adminRealm)
	iterateMetric("09. GovStaker CollectReward", count, func() {
		govstaker.CollectReward(cross)
	})
}

// ----------------------------------------------------------------------
// Phase C — gov/governance Vote
// ----------------------------------------------------------------------

func initializeGovernancePhase() {
	testing.SetRealm(adminRealm)
	// No smoothing, no voting-start delay so each proposal is immediately votable.
	governance.Reconfigure(cross, 0, 604800, 0, 50, 0, 86400, 2592000)
	gns.Approve(cross, govStakerAddr, maxInt64)
	testing.SkipHeights(1)
}

func delegateToVoters() {
	testing.SetRealm(adminRealm)

	voters = make([]address, iterations)
	for i := int32(0); i < iterations; i++ {
		voterAddr := testutils.TestAddress("voter" + strconv.Itoa(int(i)))
		voters[i] = voterAddr
		govstaker.Delegate(cross, voterAddr, voterDelegateAmount, "")
	}

	testing.SkipHeights(5)
}

func createProposals() {
	testing.SetRealm(adminRealm)

	governance.ProposeText(
		cross,
		ufmt.Sprintf("Stress Proposal"),
		"vote stress proposal",
	)
	testing.SkipHeights(1)
}

func voteMetrics() {
	for i := int32(0); i < iterations; i++ {
		count := i + int32(1)

		voterRealm := testing.NewUserRealm(voters[i])
		testing.SetRealm(voterRealm)

		iterateMetric("10. Governance Vote", count, func() {
			governance.Vote(cross, 1, true)
		})

		testing.SkipHeights(1)
	}
}

// ----------------------------------------------------------------------
// Phase D — launchpad
// ----------------------------------------------------------------------

func initializeLaunchpadPhase() {
	testing.SetRealm(adminRealm)
	obl.Approve(cross, launchpadAddr, maxInt64)

	projectId := launchpad.CreateProject(
		cross,
		"OBL Launchpad Project",
		oblPath,
		projectOwnerAddr,
		int64(1_000_000_000),
		"",
		"",
		int64(10),
		int64(20),
		int64(70),
		time.Now().Unix()+604800,
	)
	testing.SkipHeights(604800 / blockTimeSeconds)

	projectTier = projectId + ":30"
	depositIds = make([]string, iterations)
}

func launchpadDepositGnsMetric(count int32) string {
	testing.SetRealm(adminRealm)
	gns.Transfer(cross, launchpadUserAddr, launchpadDepositAmount)

	testing.SetRealm(launchpadUserRlm)
	gns.Approve(cross, launchpadAddr, launchpadDepositAmount)

	var depositId string
	iterateMetric("11. Launchpad DepositGns", count, func() {
		depositId = launchpad.DepositGns(cross, projectTier, launchpadDepositAmount, "")
	})
	return depositId
}

func launchpadCollectRewardMetric(depositId string, count int32) {
	testing.SetRealm(launchpadUserRlm)
	iterateMetric("12. Launchpad CollectRewardByDepositId", count, func() {
		launchpad.CollectRewardByDepositId(cross, depositId)
	})
}

// ----------------------------------------------------------------------
// shared
// ----------------------------------------------------------------------

func iterateMetric(name string, count int32, fn func()) {
	isContains := false
	for _, value := range printPoints {
		if value == count {
			isContains = true
			break
		}
	}

	if isContains {
		integration.PrintMetricsBy(ufmt.Sprintf("%s (iteration: %s)", name, formatIteration(count)), fn)
	} else {
		fn()
	}
}

func formatIteration(count int32) string {
	countStr := strconv.Itoa(int(count))

	if count < 10 {
		return "00" + countStr
	}
	if count < 100 {
		return "0" + countStr
	}

	return countStr
}
