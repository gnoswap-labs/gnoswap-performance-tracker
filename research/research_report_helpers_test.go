package research

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"testing"
	"time"
)

var (
	gasUsedRE      = regexp.MustCompile(`GAS USED:\s*([0-9]+)`)
	storageDeltaRE = regexp.MustCompile(`STORAGE DELTA:\s*(-?[0-9]+)\s+bytes`)
	totalTxCostRE  = regexp.MustCompile(`TOTAL TX COST:\s*([0-9]+)ugnot`)
)

type researchRow struct {
	Name           string
	GasUsed        int64
	StorageDiff    int64
	CPUCycles      string
	SampleCount    int
	GasQ1          int64
	GasQ3          int64
	GasMin         int64
	GasMax         int64
	StorageQ1      int64
	StorageQ3      int64
	StorageMin     int64
	StorageMax     int64
	TotalTxCostAvg int64
	TotalTxCostQ1  int64
	TotalTxCostQ3  int64
	TotalTxCostMin int64
	TotalTxCostMax int64
}

type metricStats struct {
	Avg int64
	Q1  int64
	Q3  int64
	Min int64
	Max int64
}

func mustProbeCheckpoints(t *testing.T) []int64 {
	t.Helper()
	raw := getenvOrDefault(probeCheckpointsEnv, "1,100,10000")
	checkpoints := parseCheckpoints(raw)
	if len(checkpoints) == 0 {
		t.Fatalf("no valid %s checkpoints", probeCheckpointsEnv)
	}
	return checkpoints
}

func getenvOrDefault(key, fallback string) string {
	v := strings.TrimSpace(os.Getenv(key))
	if v == "" {
		return fallback
	}
	return v
}

func parseCheckpoints(raw string) []int64 {
	parts := strings.Split(raw, ",")
	out := make([]int64, 0, len(parts))
	seen := make(map[int64]struct{}, len(parts))
	for _, part := range parts {
		v := strings.TrimSpace(part)
		if v == "" {
			continue
		}
		n, err := strconv.ParseInt(v, 10, 64)
		if err != nil || n <= 0 {
			continue
		}
		if _, ok := seen[n]; ok {
			continue
		}
		seen[n] = struct{}{}
		out = append(out, n)
	}
	sort.Slice(out, func(i, j int) bool { return out[i] < out[j] })
	return out
}

func parseSingleTxMetrics(output string) (txMetrics, error) {
	gasMatch := gasUsedRE.FindStringSubmatch(output)
	storageMatch := storageDeltaRE.FindStringSubmatch(output)
	totalMatch := totalTxCostRE.FindStringSubmatch(output)

	if len(gasMatch) != 2 || len(storageMatch) != 2 || len(totalMatch) != 2 {
		return txMetrics{}, fmt.Errorf("missing tx metric fields")
	}

	gas, err := strconv.ParseInt(gasMatch[1], 10, 64)
	if err != nil {
		return txMetrics{}, err
	}
	storage, err := strconv.ParseInt(storageMatch[1], 10, 64)
	if err != nil {
		return txMetrics{}, err
	}
	total, err := strconv.ParseInt(totalMatch[1], 10, 64)
	if err != nil {
		return txMetrics{}, err
	}

	return txMetrics{GasUsed: gas, StorageDelta: storage, TotalTxCost: total}, nil
}

func mustRunCheckpointLoop(t *testing.T, checkpoints []int64, fn func(iteration int64) (txMetrics, error)) []checkpointPoint {
	t.Helper()
	checkpointSet := make(map[int64]struct{}, len(checkpoints))
	maxN := int64(0)
	for _, n := range checkpoints {
		checkpointSet[n] = struct{}{}
		if n > maxN {
			maxN = n
		}
	}

	points := make([]checkpointPoint, 0, len(checkpoints))
	windowGas := make([]int64, 0)
	windowStorage := make([]int64, 0)
	windowCost := make([]int64, 0)

	for i := int64(1); i <= maxN; i++ {
		m, err := fn(i)
		if err != nil {
			t.Fatalf("probe iteration %d: %v", i, err)
		}
		windowGas = append(windowGas, m.GasUsed)
		windowStorage = append(windowStorage, m.StorageDelta)
		windowCost = append(windowCost, m.TotalTxCost)

		if _, ok := checkpointSet[i]; !ok {
			continue
		}

		points = append(points, checkpointPoint{
			N:            i,
			SampleCount:  len(windowGas),
			GasStats:     summarizeMetric(windowGas),
			StorageStats: summarizeMetric(windowStorage),
			CostStats:    summarizeMetric(windowCost),
		})
		windowGas = windowGas[:0]
		windowStorage = windowStorage[:0]
		windowCost = windowCost[:0]
	}

	return points
}

func summarizeMetric(values []int64) metricStats {
	if len(values) == 0 {
		return metricStats{}
	}
	sorted := append([]int64(nil), values...)
	sort.Slice(sorted, func(i, j int) bool { return sorted[i] < sorted[j] })
	var sum int64
	for _, v := range sorted {
		sum += v
	}
	return metricStats{
		Avg: sum / int64(len(sorted)),
		Q1:  percentileValue(sorted, 0.25),
		Q3:  percentileValue(sorted, 0.75),
		Min: sorted[0],
		Max: sorted[len(sorted)-1],
	}
}

func percentileValue(sorted []int64, percentile float64) int64 {
	if len(sorted) == 1 {
		return sorted[0]
	}
	idx := int(float64(len(sorted)-1) * percentile)
	if idx < 0 {
		idx = 0
	}
	if idx >= len(sorted) {
		idx = len(sorted) - 1
	}
	return sorted[idx]
}

func ensurePoolCreateProbePrereqs(ctx context.Context, env *researchHarnessEnv) error {
	if err := ensureWrappedUgnotReady(ctx, env); err != nil {
		return err
	}
	if err := approveToken(ctx, env, workloadGnsPath, env.poolAddr, workloadMaxApprove); err != nil {
		return fmt.Errorf("approve gns to pool for create probe: %w", err)
	}
	return nil
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

func mustWriteResearchRows(t *testing.T, outputPath string, rows []researchRow) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(outputPath), 0o755); err != nil {
		t.Fatalf("create report output dir: %v", err)
	}
	file, err := os.Create(outputPath)
	if err != nil {
		t.Fatalf("create report output file: %v", err)
	}
	defer file.Close()
	for _, row := range rows {
		if _, err := fmt.Fprintf(file, "%s\t%d\t%d\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n",
			row.Name,
			row.GasUsed,
			row.StorageDiff,
			row.CPUCycles,
			row.SampleCount,
			row.GasQ1,
			row.GasQ3,
			row.GasMin,
			row.GasMax,
			row.StorageQ1,
			row.StorageQ3,
			row.StorageMin,
			row.StorageMax,
			row.TotalTxCostAvg,
			row.TotalTxCostQ1,
			row.TotalTxCostQ3,
			row.TotalTxCostMin,
			row.TotalTxCostMax,
		); err != nil {
			t.Fatalf("write report row: %v", err)
		}
	}
}
