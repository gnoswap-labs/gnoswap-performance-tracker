package research

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"testing"
)

var (
	gasUsedRE      = regexp.MustCompile(`GAS USED:\s*([0-9]+)`)
	storageDeltaRE = regexp.MustCompile(`STORAGE DELTA:\s*(-?[0-9]+)\s+bytes`)
	totalTxCostRE  = regexp.MustCompile(`TOTAL TX COST:\s*(-?[0-9]+)ugnot`)
)

type researchRow struct {
	Name           string
	GasUsed        int64
	StorageDiff    int64
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

	return txMetrics{GasUsed: gas, StorageDelta: storage, TotalTxCost: total, HasTotalCost: true}, nil
}

func parseSingleTxMetricsAllowMissing(output string) (txMetrics, error) {
	gasMatch := gasUsedRE.FindStringSubmatch(output)
	if len(gasMatch) != 2 {
		return txMetrics{}, fmt.Errorf("missing GAS USED field")
	}
	gas, err := strconv.ParseInt(gasMatch[1], 10, 64)
	if err != nil {
		return txMetrics{}, err
	}
	m := txMetrics{GasUsed: gas, TotalTxCost: -1}
	if storageMatch := storageDeltaRE.FindStringSubmatch(output); len(storageMatch) == 2 {
		storage, parseErr := strconv.ParseInt(storageMatch[1], 10, 64)
		if parseErr != nil {
			return txMetrics{}, parseErr
		}
		m.StorageDelta = storage
	}
	if totalMatch := totalTxCostRE.FindStringSubmatch(output); len(totalMatch) == 2 {
		total, parseErr := strconv.ParseInt(totalMatch[1], 10, 64)
		if parseErr != nil {
			return txMetrics{}, parseErr
		}
		m.TotalTxCost = total
		m.HasTotalCost = true
	}
	return m, nil
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
	windowCostComplete := true

	for i := int64(1); i <= maxN; i++ {
		m, err := fn(i)
		if err != nil {
			t.Fatalf("probe iteration %d: %v", i, err)
		}
		windowGas = append(windowGas, m.GasUsed)
		windowStorage = append(windowStorage, m.StorageDelta)
		windowCost = append(windowCost, m.TotalTxCost)
		if !m.HasTotalCost {
			windowCostComplete = false
		}

		if _, ok := checkpointSet[i]; !ok {
			continue
		}

		points = append(points, checkpointPoint{
			N:            i,
			SampleCount:  len(windowGas),
			GasStats:     summarizeMetric(windowGas),
			StorageStats: summarizeMetric(windowStorage),
			CostStats:    summarizeMetricOrMissing(windowCost, windowCostComplete),
		})
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

func summarizeMetricOrMissing(values []int64, complete bool) metricStats {
	if !complete || len(values) == 0 {
		return metricStats{Avg: -1, Q1: -1, Q3: -1, Min: -1, Max: -1}
	}
	return summarizeMetric(values)
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

func mustWriteResearchRows(t *testing.T, outputPath string, rows []researchRow) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(outputPath), 0o755); err != nil {
		t.Fatalf("create report output dir: %v", err)
	}
	flags := os.O_CREATE | os.O_WRONLY | os.O_APPEND
	if _, err := os.Stat(outputPath); err == nil {
		flags = os.O_WRONLY | os.O_APPEND
	}
	file, err := os.OpenFile(outputPath, flags, 0o644)
	if err != nil {
		t.Fatalf("create report output file: %v", err)
	}
	defer file.Close()
	if info, err := file.Stat(); err == nil && info.Size() > 0 {
		if _, err := file.WriteString("\n"); err != nil {
			t.Fatalf("separate report rows: %v", err)
		}
	}
	for _, row := range rows {
		if _, err := fmt.Fprintf(file, "%s\t%d\t%d\t-\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n",
			row.Name,
			row.GasUsed,
			row.StorageDiff,
			0,
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

func appendMetricOutputLog(label, output string) error {
	if err := os.MkdirAll(".runlogs", 0o755); err != nil {
		return err
	}
	file, err := os.OpenFile(filepath.Join(".runlogs", "metric-output.log"), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
	if err != nil {
		return err
	}
	defer file.Close()
	if _, err := fmt.Fprintf(file, "===== %s =====\n%s\n\n", label, output); err != nil {
		return err
	}
	return nil
}

func appendMetricAttemptLog(label, command, stdout, stderr string, err error) error {
	status := "ok"
	if err != nil {
		status = err.Error()
	}
	body := fmt.Sprintf("command: %s\nstatus: %s\n\nstdout:\n%s\n\nstderr:\n%s\n", command, status, stdout, stderr)
	return appendMetricOutputLog(label, body)
}
