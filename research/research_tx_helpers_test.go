package research

import (
	"context"
	"fmt"
	"math/big"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"
)

func queryPoolSlot0Tick(ctx context.Context, env *researchHarnessEnv, poolPath string) (int32, error) {
	out, err := gnoQEvalRawWithContext(ctx, env.gnoContainer, env.cfg.GnoGnokeyRemote,
		fmt.Sprintf(`%s.GetSlot0Tick(%q)`, poolPkgPath, poolPath),
	)
	if err != nil {
		return 0, err
	}
	const prefix = "data: "
	idx := strings.Index(out, prefix)
	if idx < 0 {
		return 0, fmt.Errorf("unexpected gnokey output (no 'data: ' prefix): %s", out)
	}
	value := strings.TrimSpace(out[idx+len(prefix):])
	match := regexp.MustCompile(`-?[0-9]+`).FindString(value)
	if match == "" {
		return 0, fmt.Errorf("no tick value in qeval output: %s", out)
	}
	parsed, err := strconv.ParseInt(match, 10, 32)
	if err != nil {
		return 0, err
	}
	return int32(parsed), nil
}

func ensurePoolCreateProbePrereqs(ctx context.Context, env *researchHarnessEnv) error {
	if err := ensureWrappedUgnotReady(ctx, env, parseDecimalInt64OrPanic(workloadWrappedDeposit)); err != nil {
		return err
	}
	if err := approveToken(ctx, env, workloadGnsPath, env.poolAddr, workloadMaxApprove); err != nil {
		return fmt.Errorf("approve gns to pool for create probe: %w", err)
	}
	return nil
}

func mustEnsureMintPrereqs(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv, budget tokenBudget) {
	t.Helper()
	if err := ensureFundingBudget(ctx, env, budget); err != nil {
		t.Fatalf("ensure wrapped ugnot ready: %v", err)
	}
	if err := ensurePoolExists(ctx, env); err != nil {
		t.Fatalf("ensure pool exists: %v", err)
	}
	if err := approveToken(ctx, env, workloadWrappedUgnotPath, env.poolAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve wugnot to pool: %v", err)
	}
	if err := approveToken(ctx, env, workloadWrappedUgnotPath, env.positionAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve wugnot to position: %v", err)
	}
	if err := approveToken(ctx, env, workloadGnsPath, env.positionAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve gns to position: %v", err)
	}
}

func mustEnsureSwapPrereqs(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv, budget tokenBudget) {
	t.Helper()
	if err := ensureFundingBudget(ctx, env, budget); err != nil {
		t.Fatalf("ensure wrapped ugnot ready: %v", err)
	}
	if err := ensureRouterPoolExists(ctx, env); err != nil {
		t.Fatalf("ensure router pool exists: %v", err)
	}
	if err := approveToken(ctx, env, workloadGnsPath, env.routerAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve gns to router: %v", err)
	}
	if err := approveToken(ctx, env, workloadWrappedUgnotPath, env.poolAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve wugnot to pool: %v", err)
	}
	if _, err := mintPositionTxAtFee(ctx, env, routerWorkloadFeeTier, workloadWideTickLower, workloadWideTickUpper, routerMintAmount0, routerMintAmount1); err != nil {
		t.Fatalf("mint router swap liquidity: %v", err)
	}
	if err := approveToken(ctx, env, workloadWrappedUgnotPath, env.routerAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve wugnot to router: %v", err)
	}
}

func mustPrepareRouterSingleHopScenario(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv, runTag string, tickLower, tickUpper int32, positionCount int) routerScenarioState {
	return mustPrepareRouterSingleHopScenarioWithPositionSpecs(ctx, t, env, runTag, repeatRouterPositionSpecs(positionCount, tickLower, tickUpper))
}

func mustPrepareRouterSingleHopStaggeredScenario(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv, runTag string) routerScenarioState {
	return mustPrepareRouterSingleHopScenarioWithPositionSpecs(ctx, t, env, runTag, staggeredRouterPositionSpecs())
}

func mustPrepareRouterSingleHopScenarioWithPositionSpecs(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv, runTag string, specs []routerPositionSpec) routerScenarioState {
	t.Helper()
	tokenInPath, tokenOutPath, err := createDisposableProbePool(ctx, env, runTag, checkpointRunID())
	if err != nil {
		t.Fatalf("create disposable router probe pool: %v", err)
	}
	if err := approveToken(ctx, env, workloadGnsPath, env.poolAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve gns to pool for router scenario: %v", err)
	}
	for _, spender := range []string{env.poolAddr, env.positionAddr, env.routerAddr} {
		if err := approveToken(ctx, env, tokenInPath, spender, workloadMaxApprove); err != nil {
			t.Fatalf("approve tokenIn to %s: %v", spender, err)
		}
		if err := approveToken(ctx, env, tokenOutPath, spender, workloadMaxApprove); err != nil {
			t.Fatalf("approve tokenOut to %s: %v", spender, err)
		}
	}
	if _, err := createPoolTx(ctx, env, tokenInPath, tokenOutPath, routerWorkloadFeeTier, initialSqrtPriceX96); err != nil {
		t.Fatalf("create router scenario pool: %v", err)
	}
	for i, spec := range specs {
		if _, err := mintPositionTxForPairAtFee(ctx, env, tokenInPath, tokenOutPath, routerWorkloadFeeTier, spec.TickLower, spec.TickUpper, spec.Amount0Desired, spec.Amount1Desired); err != nil {
			t.Fatalf("mint router scenario position %d/%d: %v", i+1, len(specs), err)
		}
	}
	return routerScenarioState{
		tokenInPath:  tokenInPath,
		tokenOutPath: tokenOutPath,
		route:        singleHopRoute(tokenInPath, tokenOutPath, routerWorkloadFeeTier),
		reverseRoute: singleHopRoute(tokenOutPath, tokenInPath, routerWorkloadFeeTier),
		poolPaths:    []string{tokenInPath + ":" + tokenOutPath + ":" + strconv.FormatUint(uint64(routerWorkloadFeeTier), 10)},
	}
}

func mustPrepareRouterTwoHopMixedFeeScenario(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv, runTag string) routerScenarioState {
	t.Helper()
	tokenPaths, err := createDisposableProbeTokens(ctx, env, runTag, checkpointRunID(), 3)
	if err != nil {
		t.Fatalf("create disposable two-hop router tokens: %v", err)
	}
	if err := approveToken(ctx, env, workloadGnsPath, env.poolAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve gns to pool for two-hop router scenario: %v", err)
	}
	for _, spender := range []string{env.poolAddr, env.positionAddr, env.routerAddr} {
		for _, tokenPath := range tokenPaths {
			if err := approveToken(ctx, env, tokenPath, spender, workloadMaxApprove); err != nil {
				t.Fatalf("approve %s to %s: %v", tokenPath, spender, err)
			}
		}
	}
	if _, err := createPoolTx(ctx, env, tokenPaths[0], tokenPaths[1], routerMixedFeeTier, initialSqrtPriceX96); err != nil {
		t.Fatalf("create first two-hop pool: %v", err)
	}
	if _, err := createPoolTx(ctx, env, tokenPaths[1], tokenPaths[2], workloadFeeTier, initialSqrtPriceX96); err != nil {
		t.Fatalf("create second two-hop pool: %v", err)
	}
	if _, err := mintPositionTxForPairAtFee(ctx, env, tokenPaths[0], tokenPaths[1], routerMixedFeeTier, routerContractWideTickLower, routerContractWideTickUpper, routerMintAmount0, routerMintAmount1); err != nil {
		t.Fatalf("mint first two-hop position: %v", err)
	}
	if _, err := mintPositionTxForPairAtFee(ctx, env, tokenPaths[1], tokenPaths[2], workloadFeeTier, routerContractWideTickLower, routerContractWideTickUpper, routerMintAmount0, routerMintAmount1); err != nil {
		t.Fatalf("mint second two-hop position: %v", err)
	}
	return routerScenarioState{
		tokenInPath:  tokenPaths[0],
		tokenOutPath: tokenPaths[2],
		route: multiHopRoute(
			singleHopRoute(tokenPaths[0], tokenPaths[1], routerMixedFeeTier),
			singleHopRoute(tokenPaths[1], tokenPaths[2], workloadFeeTier),
		),
		reverseRoute: multiHopRoute(
			singleHopRoute(tokenPaths[2], tokenPaths[1], workloadFeeTier),
			singleHopRoute(tokenPaths[1], tokenPaths[0], routerMixedFeeTier),
		),
		poolPaths: []string{
			tokenPaths[0] + ":" + tokenPaths[1] + ":" + strconv.FormatUint(uint64(routerMixedFeeTier), 10),
			tokenPaths[1] + ":" + tokenPaths[2] + ":" + strconv.FormatUint(uint64(workloadFeeTier), 10),
		},
	}
}

func repeatRouterPositionSpecs(count int, tickLower, tickUpper int32) []routerPositionSpec {
	specs := make([]routerPositionSpec, 0, count)
	for i := 0; i < count; i++ {
		specs = append(specs, routerPositionSpec{
			TickLower:      tickLower,
			TickUpper:      tickUpper,
			Amount0Desired: routerMintAmount0,
			Amount1Desired: routerMintAmount1,
		})
	}
	return specs
}

func staggeredRouterPositionSpecs() []routerPositionSpec {
	ranges := [][2]int32{{-60, 60}, {-120, 120}, {-240, 240}, {-480, 480}, {-960, 960}, {-1920, 1920}}
	specs := make([]routerPositionSpec, 0, len(ranges))
	for _, r := range ranges {
		specs = append(specs, routerPositionSpec{
			TickLower:      r[0],
			TickUpper:      r[1],
			Amount0Desired: routerMintAmount0,
			Amount1Desired: routerMintAmount1,
		})
	}
	return specs
}

func mustEnsureStakerCreateExternalIncentivePrereqs(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv, budget tokenBudget) {
	t.Helper()
	mustEnsureMintPrereqs(ctx, t, env, budget)
	if err := approveToken(ctx, env, workloadGnsPath, env.stakerAddr, workloadMaxApprove); err != nil {
		t.Fatalf("approve gns to staker: %v", err)
	}
	if err := ensurePoolTierSet(ctx, env); err != nil {
		t.Fatalf("ensure staker pool tier: %v", err)
	}
}

func mustEnsureStakerPoolIncentives(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv, budget tokenBudget) {
	t.Helper()
	mustEnsureMintPrereqs(ctx, t, env, budget)
	if err := ensurePoolTierSet(ctx, env); err != nil {
		t.Fatalf("ensure staker pool tier: %v", err)
	}
	if err := ensureEmissionStartedAndDistributed(ctx, env); err != nil {
		t.Fatalf("ensure emission started and distributed: %v", err)
	}
}

func ensurePoolExists(ctx context.Context, env *researchHarnessEnv) error {
	exists, err := queryPoolExistsWithContext(ctx, env)
	if err == nil && exists {
		return nil
	}
	if err := ensureWrappedUgnotReady(ctx, env, parseDecimalInt64OrPanic(workloadWrappedDeposit)); err != nil {
		return err
	}
	if err := approveToken(ctx, env, workloadGnsPath, env.poolAddr, workloadMaxApprove); err != nil {
		return fmt.Errorf("approve gns to pool before create: %w", err)
	}
	_, err = broadcastCallOutput(ctx, env, "gnoswap_admin", poolPkgPath, "CreatePool", "",
		workloadWrappedUgnotPath,
		workloadGnsPath,
		strconv.FormatUint(uint64(workloadFeeTier), 10),
		initialSqrtPriceX96,
	)
	if err != nil {
		lower := strings.ToLower(err.Error())
		if strings.Contains(lower, "already") || strings.Contains(lower, "exists") {
			return nil
		}
		return err
	}
	return nil
}

func ensureRouterPoolExists(ctx context.Context, env *researchHarnessEnv) error {
	exists, err := queryPoolExistsForFee(ctx, env, routerWorkloadFeeTier)
	if err == nil && exists {
		return nil
	}
	if err := ensureWrappedUgnotReady(ctx, env, parseDecimalInt64OrPanic(workloadWrappedDeposit)); err != nil {
		return err
	}
	if err := approveToken(ctx, env, workloadGnsPath, env.poolAddr, workloadMaxApprove); err != nil {
		return fmt.Errorf("approve gns to pool before router create: %w", err)
	}
	if err := approveToken(ctx, env, workloadWrappedUgnotPath, env.poolAddr, workloadMaxApprove); err != nil {
		return fmt.Errorf("approve wugnot to pool before router create: %w", err)
	}
	_, err = createPoolTx(ctx, env, workloadWrappedUgnotPath, workloadGnsPath, routerWorkloadFeeTier, initialSqrtPriceX96)
	if err != nil {
		lower := strings.ToLower(err.Error())
		if strings.Contains(lower, "already") || strings.Contains(lower, "exists") {
			return nil
		}
		return err
	}
	return nil
}

func ensurePoolTierSet(ctx context.Context, env *researchHarnessEnv) error {
	out, err := gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, fmt.Sprintf(`%s.GetPoolTier(%q)`, stakerPkgPath, poolPath()))
	if err == nil && strings.Contains(out, stakerPoolTier) {
		return nil
	}
	_, err = broadcastCallOutput(ctx, env, "gnoswap_admin", stakerPkgPath, "SetPoolTier", "", poolPath(), stakerPoolTier)
	return err
}

func ensureEmissionStartedAndDistributed(ctx context.Context, env *researchHarnessEnv) error {
	startTimestamp, err := queryEmissionDistributionStartTimestamp(ctx, env)
	if err != nil {
		return err
	}
	if startTimestamp == 0 {
		startTimestamp = time.Now().Unix() + 1
		if _, err := broadcastCallOutput(ctx, env, "gnoswap_admin", emissionPkgPath, "SetDistributionStartTime", "", strconv.FormatInt(startTimestamp, 10)); err != nil {
			return err
		}
	}
	if now := time.Now().Unix(); startTimestamp > now {
		time.Sleep(time.Duration(startTimestamp-now+1) * time.Second)
	}
	_, err = broadcastCallOutput(ctx, env, "gnoswap_admin", emissionPkgPath, "MintAndDistributeGns", "")
	return err
}

func queryEmissionDistributionStartTimestamp(ctx context.Context, env *researchHarnessEnv) (int64, error) {
	out, err := gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, emissionPkgPath+`.GetDistributionStartTimestamp()`)
	if err != nil {
		return 0, err
	}
	return parseFirstInt64(out)
}

func poolPath() string {
	return workloadWrappedUgnotPath + ":" + workloadGnsPath + ":" + strconv.FormatUint(uint64(workloadFeeTier), 10)
}

func queryPoolExistsWithContext(_ context.Context, env *researchHarnessEnv) (bool, error) {
	poolPath := workloadWrappedUgnotPath + ":" + workloadGnsPath + ":" + strconv.FormatUint(uint64(workloadFeeTier), 10)
	out, err := gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, fmt.Sprintf(`gno.land/r/gnoswap/pool.ExistsPoolPath(%q)`, poolPath))
	if err != nil {
		return false, err
	}
	return strings.Contains(out, "true"), nil
}

func queryPoolExistsForFee(_ context.Context, env *researchHarnessEnv, fee uint32) (bool, error) {
	poolPath := workloadWrappedUgnotPath + ":" + workloadGnsPath + ":" + strconv.FormatUint(uint64(fee), 10)
	out, err := gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, fmt.Sprintf(`gno.land/r/gnoswap/pool.ExistsPoolPath(%q)`, poolPath))
	if err != nil {
		return false, err
	}
	return strings.Contains(out, "true"), nil
}

func ensureWrappedUgnotReady(ctx context.Context, env *researchHarnessEnv, minBalance int64) error {
	out, err := gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, fmt.Sprintf(`%s.IsRegistered(%q)`, commonPkgPath, workloadWrappedUgnotPath))
	if err != nil {
		return err
	}
	currentBalance, balanceErr := queryTokenBalance(ctx, env, workloadWrappedUgnotPath)
	if balanceErr != nil {
		currentBalance = 0
	}
	neededBalance := maxInt64(minBalance, parseDecimalInt64OrPanic(workloadWrappedDeposit))
	if currentBalance < neededBalance {
		if err := depositWrappedUgnot(ctx, env, strconv.FormatInt(neededBalance-currentBalance, 10)); err != nil {
			return err
		}
		out, err = gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, fmt.Sprintf(`%s.IsRegistered(%q)`, commonPkgPath, workloadWrappedUgnotPath))
		if err != nil {
			return err
		}
	}
	if strings.Contains(out, "not registered") {
		return fmt.Errorf("wrapped ugnot is still not registered: %s", out)
	}
	return nil
}

func ensureFundingBudget(ctx context.Context, env *researchHarnessEnv, budget tokenBudget) error {
	if err := ensureWrappedUgnotReady(ctx, env, budget.WrappedUgnot); err != nil {
		return err
	}
	if budget.GNS <= 0 {
		return nil
	}
	currentGNS, err := queryTokenBalance(ctx, env, workloadGnsPath)
	if err != nil {
		return err
	}
	if currentGNS < budget.GNS {
		return fmt.Errorf("insufficient GNS funding for workload: need >= %d have %d", budget.GNS, currentGNS)
	}
	return nil
}

func queryTokenBalance(ctx context.Context, env *researchHarnessEnv, tokenPath string) (int64, error) {
	out, err := gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, fmt.Sprintf(`%s.BalanceOf(%q, address(%q))`, commonPkgPath, tokenPath, env.adminAddr))
	if err != nil {
		return 0, err
	}
	return parseFirstInt64(out)
}

func parseDecimalInt64OrPanic(value string) int64 {
	parsed, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		panic(err)
	}
	return parsed
}

func maxInt64(a, b int64) int64 {
	if a > b {
		return a
	}
	return b
}

func scaledAmountBudget(amount string, iterations int64) int64 {
	perOp := big.NewInt(parseDecimalInt64OrPanic(amount))
	total := new(big.Int).Mul(perOp, big.NewInt(iterations))
	if !total.IsInt64() {
		panic(fmt.Sprintf("budget overflow for amount %s x %d", amount, iterations))
	}
	return total.Int64()
}

func depositWrappedUgnot(ctx context.Context, env *researchHarnessEnv, amount string) error {
	command := strings.Join([]string{
		"printf '\\n' |",
		"gnokey maketx call",
		"-pkgpath", workloadWrappedUgnotPath,
		"-func Deposit",
		"-send", amount + "ugnot",
		"-insecure-password-stdin=true",
		"-remote", env.cfg.GnoGnokeyRemote,
		"-broadcast=true",
		"-chainid", env.cfg.GnoChainID,
		"-gas-fee 1000000ugnot",
		"-gas-wanted 1000000000",
		"-memo ''",
		"gnoswap_admin",
	}, " ")
	var lastErr error
	for attempt := 0; attempt < 5; attempt++ {
		stdout, stderr, err := dockerExec(ctx, env.gnoContainer, "sh", "-lc", command)
		if err == nil {
			return nil
		}
		lastErr = fmt.Errorf("gnokey maketx call %s.Deposit: %w: stdout=%s stderr=%s", workloadWrappedUgnotPath, err, stdout, stderr)
		if !isRetryableTxError(lastErr) {
			return lastErr
		}
		time.Sleep(time.Duration(attempt+1) * time.Second)
	}
	return lastErr
}

func createPoolTx(ctx context.Context, env *researchHarnessEnv, token0Path, token1Path string, fee uint32, sqrtPriceX96 string) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", poolPkgPath, "CreatePool", "",
		token0Path,
		token1Path,
		strconv.FormatUint(uint64(fee), 10),
		sqrtPriceX96,
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetrics(out)
}

func routerExactInSwapRouteTx(ctx context.Context, env *researchHarnessEnv) (txMetrics, error) {
	return routerExactInSwapRouteTxForPair(ctx, env, workloadWrappedUgnotPath, workloadGnsPath, singleHopRoute(workloadWrappedUgnotPath, workloadGnsPath, routerWorkloadFeeTier))
}

func routerExactInSwapRouteTxForPair(ctx context.Context, env *researchHarnessEnv, tokenInPath, tokenOutPath, route string) (txMetrics, error) {
	return routerExactInSwapRouteTxForPairWithAmount(ctx, env, tokenInPath, tokenOutPath, route, routerExactInSingleHopAmountIn, routerExactInAmountOutMin)
}

func routerExactInSwapRouteTxForPairWithAmount(ctx context.Context, env *researchHarnessEnv, tokenInPath, tokenOutPath, route, amountIn, amountOutMin string) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", routerPkgPath, "ExactInSwapRoute", "",
		tokenInPath,
		tokenOutPath,
		amountIn,
		route,
		routerExactInQuoteRatios,
		amountOutMin,
		strconv.FormatInt(workloadDefaultDeadline, 10),
		"",
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetricsAllowMissing(out)
}

func routerExactOutSwapRouteTx(ctx context.Context, env *researchHarnessEnv) (txMetrics, error) {
	return routerExactOutSwapRouteTxForPair(ctx, env, workloadWrappedUgnotPath, workloadGnsPath, singleHopRoute(workloadWrappedUgnotPath, workloadGnsPath, routerWorkloadFeeTier))
}

func routerExactOutSwapRouteTxForPair(ctx context.Context, env *researchHarnessEnv, tokenInPath, tokenOutPath, route string) (txMetrics, error) {
	return routerExactOutSwapRouteTxForPairWithAmount(ctx, env, tokenInPath, tokenOutPath, route, routerExactOutSingleHopAmountOut, routerExactOutSingleHopAmountInMax)
}

func routerExactOutSwapRouteTxForPairWithAmount(ctx context.Context, env *researchHarnessEnv, tokenInPath, tokenOutPath, route, amountOut, amountInMax string) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", routerPkgPath, "ExactOutSwapRoute", "",
		tokenInPath,
		tokenOutPath,
		amountOut,
		route,
		routerExactOutQuoteRatios,
		amountInMax,
		strconv.FormatInt(workloadDefaultDeadline, 10),
		"",
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetricsAllowMissing(out)
}

func singleHopRoute(tokenIn, tokenOut string, fee uint32) string {
	return tokenIn + ":" + tokenOut + ":" + strconv.FormatUint(uint64(fee), 10)
}

func multiHopRoute(hops ...string) string {
	return strings.Join(hops, "*POOL*")
}

func createExternalIncentiveTx(ctx context.Context, env *researchHarnessEnv, runID int64) (txMetrics, error) {
	rewardAmount, err := queryMinimumRewardAmount(ctx, env)
	if err != nil {
		return txMetrics{}, err
	}
	startTimestamp, endTimestamp := incentiveSchedule(runID)
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", stakerPkgPath, "CreateExternalIncentive", "",
		poolPath(),
		workloadGnsPath,
		rewardAmount,
		strconv.FormatInt(startTimestamp, 10),
		strconv.FormatInt(endTimestamp, 10),
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetrics(out)
}

func stakeTokenTx(ctx context.Context, env *researchHarnessEnv, positionID uint64) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", stakerPkgPath, "StakeToken", "",
		strconv.FormatUint(positionID, 10),
		"",
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetrics(out)
}

func collectRewardTx(ctx context.Context, env *researchHarnessEnv, positionID uint64) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", stakerPkgPath, "CollectReward", "",
		strconv.FormatUint(positionID, 10),
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetrics(out)
}

func unstakeTokenTx(ctx context.Context, env *researchHarnessEnv, positionID uint64) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", stakerPkgPath, "UnStakeToken", "",
		strconv.FormatUint(positionID, 10),
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetricsAllowMissing(out)
}

func queryMinimumRewardAmount(_ context.Context, env *researchHarnessEnv) (string, error) {
	out, err := gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, stakerPkgPath+`.GetMinimumRewardAmount()`)
	if err != nil {
		return "", err
	}
	return firstDecimalString(out), nil
}

func prepareApprovedStakeablePosition(ctx context.Context, env *researchHarnessEnv) (uint64, error) {
	positionID, err := mintFreshPosition(ctx, env, workloadWideTickLower, workloadWideTickUpper)
	if err != nil {
		return 0, err
	}
	if _, err := approveTokenTx(ctx, env, gnftPkgPath, env.stakerAddr, positionID); err != nil {
		return 0, err
	}
	return positionID, nil
}

func prepareStakedPosition(ctx context.Context, env *researchHarnessEnv) (uint64, error) {
	positionID, err := prepareApprovedStakeablePosition(ctx, env)
	if err != nil {
		return 0, err
	}
	if _, err := stakeTokenTx(ctx, env, positionID); err != nil {
		return 0, err
	}
	return positionID, nil
}

func preparePositionForIncrease(ctx context.Context, env *researchHarnessEnv) (uint64, error) {
	return mintFreshPosition(ctx, env, workloadWideTickLower, workloadWideTickUpper)
}

func preparePositionForDecrease(ctx context.Context, env *researchHarnessEnv, repeatCount int64) (uint64, string, error) {
	details, err := mintFreshPositionWithLiquidityForAmounts(
		ctx,
		env,
		workloadNarrowTickLower,
		workloadNarrowTickUpper,
		workloadDecreaseMintAmount0,
		workloadDecreaseMintAmount1,
	)
	if err != nil {
		return 0, "", err
	}
	if details.Liquidity == "" || details.Liquidity == "0" {
		return 0, "", fmt.Errorf("minted liquidity missing for position %d", details.PositionID)
	}
	stepLiquidity, err := splitLiquidityForRepeats(details.Liquidity, repeatCount)
	if err != nil {
		return 0, "", err
	}
	return details.PositionID, stepLiquidity, nil
}

func splitLiquidityForRepeats(totalLiquidity string, repeatCount int64) (string, error) {
	if repeatCount <= 0 {
		return "", fmt.Errorf("repeat count must be positive")
	}
	total := new(big.Int)
	if _, ok := total.SetString(totalLiquidity, 10); !ok {
		return "", fmt.Errorf("invalid liquidity %q", totalLiquidity)
	}
	chunk := new(big.Int).Quo(total, big.NewInt(repeatCount))
	if chunk.Sign() <= 0 {
		return "", fmt.Errorf("liquidity %s too small for %d repeats", totalLiquidity, repeatCount)
	}
	return chunk.String(), nil
}

func createDisposableProbePool(ctx context.Context, env *researchHarnessEnv, runTag string, iteration int64) (string, string, error) {
	tokenPackages, err := createDisposableProbeTokens(ctx, env, runTag, iteration, 2)
	if err != nil {
		return "", "", err
	}
	return tokenPackages[0], tokenPackages[1], nil
}

func createDisposableProbeTokens(ctx context.Context, env *researchHarnessEnv, runTag string, iteration int64, count int) ([]string, error) {
	baseName := fmt.Sprintf("ptr%s%d", runTag, iteration)
	tokenPackages := make([]string, 0, count)
	for i := 0; i < count; i++ {
		suffix := string(rune('a' + i))
		pkgPath := "gno.land/r/gnoswap_probe_token_" + baseName + suffix
		pkgName := "p" + baseName + suffix
		symbol := "PT" + string(rune('A'+i))
		if err := addProbeTokenPackage(ctx, env, pkgPath, pkgName, symbol); err != nil {
			return nil, err
		}
		tokenPackages = append(tokenPackages, pkgPath)
	}
	return tokenPackages, nil
}

func mintPositionRawOutput(ctx context.Context, env *researchHarnessEnv, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (string, error) {
	return mintPositionRawOutputAtFee(ctx, env, workloadFeeTier, tickLower, tickUpper, amount0Desired, amount1Desired)
}

func mintPositionRawOutputAtFee(ctx context.Context, env *researchHarnessEnv, fee uint32, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (string, error) {
	return mintPositionRawOutputForPairAtFee(ctx, env, workloadGnsPath, workloadWrappedUgnotPath, fee, tickLower, tickUpper, amount0Desired, amount1Desired)
}

func mintPositionRawOutputForPairAtFee(ctx context.Context, env *researchHarnessEnv, token0Path, token1Path string, fee uint32, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (string, error) {
	return broadcastCallOutput(ctx, env, "gnoswap_admin", positionPkgPath, "Mint", "",
		token0Path,
		token1Path,
		strconv.FormatUint(uint64(fee), 10),
		strconv.FormatInt(int64(tickLower), 10),
		strconv.FormatInt(int64(tickUpper), 10),
		amount0Desired,
		amount1Desired,
		"1",
		"1",
		strconv.FormatInt(workloadDefaultDeadline, 10),
		env.adminAddr,
		env.adminAddr,
		"",
	)
}

func mintPositionTx(ctx context.Context, env *researchHarnessEnv, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (txMetrics, error) {
	return mintPositionTxAtFee(ctx, env, workloadFeeTier, tickLower, tickUpper, amount0Desired, amount1Desired)
}

func mintPositionTxAtFee(ctx context.Context, env *researchHarnessEnv, fee uint32, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (txMetrics, error) {
	return mintPositionTxForPairAtFee(ctx, env, workloadGnsPath, workloadWrappedUgnotPath, fee, tickLower, tickUpper, amount0Desired, amount1Desired)
}

func mintPositionTxForPairAtFee(ctx context.Context, env *researchHarnessEnv, token0Path, token1Path string, fee uint32, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (txMetrics, error) {
	out, err := mintPositionRawOutputForPairAtFee(ctx, env, token0Path, token1Path, fee, tickLower, tickUpper, amount0Desired, amount1Desired)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetrics(out)
}

func increaseLiquidityTx(ctx context.Context, env *researchHarnessEnv, positionID uint64) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", positionPkgPath, "IncreaseLiquidity", "",
		strconv.FormatUint(positionID, 10),
		workloadIncreaseAmount0,
		workloadIncreaseAmount1,
		"1",
		"1",
		strconv.FormatInt(workloadDefaultDeadline, 10),
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetricsAllowMissing(out)
}

func decreaseLiquidityTx(ctx context.Context, env *researchHarnessEnv, positionID uint64, liquidity string) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", positionPkgPath, "DecreaseLiquidity", "",
		strconv.FormatUint(positionID, 10),
		liquidity,
		"1",
		"1",
		strconv.FormatInt(workloadDefaultDeadline, 10),
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetricsAllowMissing(out)
}

type mintedPositionDetails struct {
	PositionID uint64
	Liquidity  string
}

func mintFreshPosition(ctx context.Context, env *researchHarnessEnv, tickLower, tickUpper int32) (uint64, error) {
	details, err := mintFreshPositionWithLiquidity(ctx, env, tickLower, tickUpper)
	if err != nil {
		return 0, err
	}
	return details.PositionID, nil
}

func mintFreshPositionWithLiquidity(ctx context.Context, env *researchHarnessEnv, tickLower, tickUpper int32) (mintedPositionDetails, error) {
	return mintFreshPositionWithLiquidityForAmounts(ctx, env, tickLower, tickUpper, workloadMintAmount0, workloadMintAmount1)
}

func mintFreshPositionWithLiquidityForAmounts(ctx context.Context, env *researchHarnessEnv, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (mintedPositionDetails, error) {
	out, err := mintPositionRawOutput(ctx, env, tickLower, tickUpper, amount0Desired, amount1Desired)
	if err != nil {
		return mintedPositionDetails{}, err
	}
	return parseMintPositionDetails(out)
}

func parseMintPositionDetails(output string) (mintedPositionDetails, error) {
	positionIDMatch := regexp.MustCompile(`"lpPositionId","value":"([0-9]+)"`).FindStringSubmatch(output)
	liquidityMatch := regexp.MustCompile(`"positionLiquidity","value":"([0-9]+)"`).FindStringSubmatch(output)
	if len(positionIDMatch) != 2 || len(liquidityMatch) != 2 {
		return mintedPositionDetails{}, fmt.Errorf("missing minted position details in output: %s", output)
	}
	positionID, err := strconv.ParseUint(positionIDMatch[1], 10, 64)
	if err != nil {
		return mintedPositionDetails{}, err
	}
	return mintedPositionDetails{PositionID: positionID, Liquidity: liquidityMatch[1]}, nil
}

func parseFirstInt64(output string) (int64, error) {
	match := regexp.MustCompile(`[-]?[0-9]+`).FindString(output)
	if match == "" {
		return 0, fmt.Errorf("no integer found in output: %s", output)
	}
	return strconv.ParseInt(match, 10, 64)
}

func firstDecimalString(output string) string {
	return regexp.MustCompile(`[0-9]+`).FindString(output)
}

func checkpointRunID() int64 {
	return time.Now().Unix()
}

func waitForRewardAccrual() {
	time.Sleep(2 * time.Second)
}

func incentiveSchedule(seed int64) (int64, int64) {
	_ = seed
	now := time.Now().UTC()
	nextMidnight := time.Date(now.Year(), now.Month(), now.Day()+1, 0, 0, 0, 0, time.UTC).Unix()
	start := nextMidnight
	end := start + (stakerEmissionEnd - stakerEmissionStart)
	return start, end
}

func addProbeTokenPackage(ctx context.Context, env *researchHarnessEnv, pkgPath, packageName, symbol string) error {
	pkgDir := "/tmp/" + packageName
	writeCmd := fmt.Sprintf(`mkdir -p %s && cat > %s <<'EOF'
module = "%s"
gno = "0.9"
EOF
cat > %s <<'EOF'
package %s

import (
	"gno.land/p/demo/tokens/grc20"
	"gno.land/r/demo/defi/grc20reg"
)

var (
	token, privateLedger = grc20.NewToken("%s", "%s", 6)
)

func init() {
	privateLedger.Mint(address("%s"), 1000000000000)
	grc20reg.Register(cross, token, "")
}

func Transfer(cur realm, to address, amount int64) {
	checkErr(token.CallerTeller().Transfer(to, amount))
}

func Approve(cur realm, spender address, amount int64) {
	checkErr(token.CallerTeller().Approve(spender, amount))
}

func TransferFrom(cur realm, from, to address, amount int64) {
	checkErr(token.CallerTeller().TransferFrom(from, to, amount))
}

func checkErr(err error) {
	if err != nil {
		panic(err)
	}
}
EOF`,
		shellQuote(pkgDir),
		shellQuote(filepath.Join(pkgDir, "gnomod.toml")),
		pkgPath,
		shellQuote(filepath.Join(pkgDir, packageName+".gno")),
		packageName,
		symbol,
		symbol,
		env.adminAddr,
	)
	stdout, stderr, err := dockerExec(ctx, env.gnoContainer, "sh", "-lc", writeCmd)
	if err != nil {
		return fmt.Errorf("write probe token package %s: %w: stdout=%s stderr=%s", pkgPath, err, stdout, stderr)
	}

	addCmd := "printf '\\n' | gnokey maketx addpkg -pkgdir " + shellQuote(pkgDir) + " -pkgpath " + shellQuote(pkgPath) + " -gas-fee 2000000ugnot -gas-wanted 1500000000 -broadcast=true -chainid " + shellQuote(env.cfg.GnoChainID) + " -remote " + shellQuote(env.cfg.GnoGnokeyRemote) + " -insecure-password-stdin=true gnoswap_admin"
	stdout, stderr, err = dockerExec(ctx, env.gnoContainer, "sh", "-lc", addCmd)
	if err != nil {
		return fmt.Errorf("add probe token package %s: %w: stdout=%s stderr=%s", pkgPath, err, stdout, stderr)
	}
	return nil
}

func approveToken(ctx context.Context, env *researchHarnessEnv, pkgPath, spender, amount string) error {
	_, err := broadcastCallOutput(ctx, env, "gnoswap_admin", pkgPath, "Approve", "", spender, amount)
	return err
}

func approveTokenTx(ctx context.Context, env *researchHarnessEnv, pkgPath, spender string, tokenID uint64) (txMetrics, error) {
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", pkgPath, "Approve", "", spender, strconv.FormatUint(tokenID, 10))
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetrics(out)
}

func broadcastCallOutput(ctx context.Context, env *researchHarnessEnv, keyName, pkgPath, funcName, sendCoins string, args ...string) (string, error) {
	parts := []string{
		"printf '\\n' |",
		"gnokey", "maketx", "call",
		"-pkgpath", shellQuote(pkgPath),
		"-func", shellQuote(funcName),
	}
	if sendCoins != "" {
		parts = append(parts, "-send", shellQuote(sendCoins))
	}
	for _, arg := range args {
		parts = append(parts, "-args", shellQuote(arg))
	}
	parts = append(parts,
		"-insecure-password-stdin=true",
		"-remote", shellQuote(env.cfg.GnoGnokeyRemote),
		"-broadcast=true",
		"-chainid", shellQuote(env.cfg.GnoChainID),
		"-gas-fee", "1000000ugnot",
		"-gas-wanted", "1000000000",
		"-memo", shellQuote(""),
	)
	parts = append(parts, shellQuote(keyName))
	command := strings.Join(parts, " ")
	var lastErr error
	for attempt := 0; attempt < 5; attempt++ {
		stdout, stderr, err := dockerExec(ctx, env.gnoContainer, "sh", "-lc", command)
		_ = appendMetricAttemptLog(fmt.Sprintf("%s.%s attempt=%d", pkgPath, funcName, attempt+1), command, stdout, stderr, err)
		if err == nil {
			return stdout, nil
		}
		lastErr = fmt.Errorf("gnokey maketx call %s.%s: %w: stdout=%s stderr=%s", pkgPath, funcName, err, stdout, stderr)
		if !isRetryableTxError(lastErr) {
			return "", lastErr
		}
		time.Sleep(time.Duration(attempt+1) * time.Second)
	}
	return "", lastErr
}

func shellQuote(s string) string {
	return "'" + strings.ReplaceAll(s, "'", `"'"'`) + "'"
}

func isRetryableTxError(err error) bool {
	if err == nil {
		return false
	}
	msg := strings.ToLower(err.Error())
	return strings.Contains(msg, "signature verification failed") || strings.Contains(msg, "incorrect account sequence") || strings.Contains(msg, "sequence") || strings.Contains(msg, "tx already exists in cache")
}
