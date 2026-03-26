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

func ensurePoolCreateProbePrereqs(ctx context.Context, env *researchHarnessEnv) error {
	if err := ensureWrappedUgnotReady(ctx, env); err != nil {
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
}, env *researchHarnessEnv) {
	t.Helper()
	if err := ensureWrappedUgnotReady(ctx, env); err != nil {
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
}, env *researchHarnessEnv) {
	t.Helper()
	if err := ensureWrappedUgnotReady(ctx, env); err != nil {
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

func mustEnsureStakerCreateExternalIncentivePrereqs(ctx context.Context, t interface {
	Helper()
	Fatalf(string, ...any)
}, env *researchHarnessEnv) {
	t.Helper()
	mustEnsureMintPrereqs(ctx, t, env)
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
}, env *researchHarnessEnv) {
	t.Helper()
	mustEnsureMintPrereqs(ctx, t, env)
	if err := ensurePoolTierSet(ctx, env); err != nil {
		t.Fatalf("ensure staker pool tier: %v", err)
	}
}

func ensurePoolExists(ctx context.Context, env *researchHarnessEnv) error {
	exists, err := queryPoolExistsWithContext(ctx, env)
	if err == nil && exists {
		return nil
	}
	if err := ensureWrappedUgnotReady(ctx, env); err != nil {
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
	if err := ensureWrappedUgnotReady(ctx, env); err != nil {
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

func ensureWrappedUgnotReady(ctx context.Context, env *researchHarnessEnv) error {
	if err := depositWrappedUgnot(ctx, env, workloadWrappedDeposit); err != nil {
		return err
	}
	out, err := gnoQEval(env.gnoContainer, env.cfg.GnoGnokeyRemote, fmt.Sprintf(`gno.land/r/gnoswap/common.IsRegistered(%q)`, workloadWrappedUgnotPath))
	if err != nil {
		return err
	}
	if strings.Contains(out, "not registered") {
		return fmt.Errorf("wrapped ugnot is still not registered: %s", out)
	}
	return nil
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
	route := singleHopRoute(workloadWrappedUgnotPath, workloadGnsPath, routerWorkloadFeeTier)
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", routerPkgPath, "ExactInSwapRoute", "",
		workloadWrappedUgnotPath,
		workloadGnsPath,
		routerExactInAmountIn,
		route,
		routerExactInQuoteRatios,
		routerExactInAmountOutMin,
		strconv.FormatInt(workloadDefaultDeadline, 10),
		"",
	)
	if err != nil {
		return txMetrics{}, err
	}
	return parseSingleTxMetricsAllowMissing(out)
}

func routerExactOutSwapRouteTx(ctx context.Context, env *researchHarnessEnv) (txMetrics, error) {
	route := singleHopRoute(workloadWrappedUgnotPath, workloadGnsPath, routerWorkloadFeeTier)
	out, err := broadcastCallOutput(ctx, env, "gnoswap_admin", routerPkgPath, "ExactOutSwapRoute", "",
		workloadWrappedUgnotPath,
		workloadGnsPath,
		routerExactOutAmountOut,
		route,
		routerExactOutQuoteRatios,
		routerExactOutAmountInMax,
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
	baseName := fmt.Sprintf("ptr%s%d", runTag, iteration)
	token0Package := "gno.land/r/gnoswap_probe_token_" + baseName + "a"
	token1Package := "gno.land/r/gnoswap_probe_token_" + baseName + "b"
	token0Name := "p" + baseName + "a"
	token1Name := "p" + baseName + "b"

	if err := addProbeTokenPackage(ctx, env, token0Package, token0Name, "PTA"); err != nil {
		return "", "", err
	}
	if err := addProbeTokenPackage(ctx, env, token1Package, token1Name, "PTB"); err != nil {
		return "", "", err
	}
	return token0Package, token1Package, nil
}

func mintPositionRawOutput(ctx context.Context, env *researchHarnessEnv, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (string, error) {
	return mintPositionRawOutputAtFee(ctx, env, workloadFeeTier, tickLower, tickUpper, amount0Desired, amount1Desired)
}

func mintPositionRawOutputAtFee(ctx context.Context, env *researchHarnessEnv, fee uint32, tickLower, tickUpper int32, amount0Desired, amount1Desired string) (string, error) {
	return broadcastCallOutput(ctx, env, "gnoswap_admin", positionPkgPath, "Mint", "",
		workloadGnsPath,
		workloadWrappedUgnotPath,
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
	out, err := mintPositionRawOutputAtFee(ctx, env, fee, tickLower, tickUpper, amount0Desired, amount1Desired)
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
		workloadUserAddress,
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
