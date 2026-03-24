package research

import (
	"context"
	"fmt"
	"os"
	"strconv"
	"testing"
	"time"
)

const (
	researchReportEnv               = "RESEARCH_REPORT"
	researchReportOutputEnv         = "RESEARCH_REPORT_OUT"
	probeCheckpointsEnv             = "WORKLOAD_NS"
	workloadWrappedUgnotPath        = "gno.land/r/gnoland/wugnot"
	workloadGnsPath                 = "gno.land/r/gnoswap/gns"
	poolPkgPath                     = "gno.land/r/gnoswap/pool"
	workloadFeeTier          uint32 = 3000
	initialSqrtPriceX96             = "79228162514264337593543950337"
	workloadMaxApprove              = "9223372036854775806"
	workloadUserAddress             = "g1z437dpuh5s4p64vtq09dulg6jzxpr2hd4q8r5x"
	workloadWrappedDeposit          = "100000000"
)

type txMetrics struct {
	GasUsed      int64
	StorageDelta int64
	TotalTxCost  int64
}

type researchHarnessEnv struct {
	*TestEnv
	poolAddr string
}

type checkpointPoint struct {
	N            int64
	SampleCount  int
	GasStats     metricStats
	StorageStats metricStats
	CostStats    metricStats
}

func TestResearchReportPoolCreate(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunPoolCreateReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research PoolCreate (n=%d)", point.N),
			GasUsed:        point.GasStats.Avg,
			StorageDiff:    point.StorageStats.Avg,
			CPUCycles:      "-",
			SampleCount:    point.SampleCount,
			GasQ1:          point.GasStats.Q1,
			GasQ3:          point.GasStats.Q3,
			GasMin:         point.GasStats.Min,
			GasMax:         point.GasStats.Max,
			StorageQ1:      point.StorageStats.Q1,
			StorageQ3:      point.StorageStats.Q3,
			StorageMin:     point.StorageStats.Min,
			StorageMax:     point.StorageStats.Max,
			TotalTxCostAvg: point.CostStats.Avg,
			TotalTxCostQ1:  point.CostStats.Q1,
			TotalTxCostQ3:  point.CostStats.Q3,
			TotalTxCostMin: point.CostStats.Min,
			TotalTxCostMax: point.CostStats.Max,
		})
	}
	mustWriteResearchRows(t, outputPath, rows)
}

func mustSetupResearchHarnessEnv(t *testing.T) *researchHarnessEnv {
	t.Helper()
	baseEnv := mustSetupTestEnv(t)
	return &researchHarnessEnv{
		TestEnv:  baseEnv,
		poolAddr: baseEnv.mustQueryAddressByRole(t, "pool"),
	}
}

func mustRunPoolCreateReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	if err := ensurePoolCreateProbePrereqs(ctx, env); err != nil {
		t.Fatalf("pool create report prerequisites: %v", err)
	}
	runTag := strconv.FormatInt(time.Now().UnixNano(), 36)
	if warmupToken0Path, warmupToken1Path, err := createDisposableProbePool(ctx, env, runTag, 0); err != nil {
		t.Fatalf("pool create warm-up package: %v", err)
	} else if _, err := createPoolTx(ctx, env, warmupToken0Path, warmupToken1Path, workloadFeeTier, initialSqrtPriceX96); err != nil {
		t.Fatalf("pool create warm-up tx: %v", err)
	}

	return mustRunCheckpointLoop(t, checkpoints, func(iteration int64) (txMetrics, error) {
		token0Path, token1Path, err := createDisposableProbePool(ctx, env, runTag, iteration)
		if err != nil {
			return txMetrics{}, err
		}
		return createPoolTx(ctx, env, token0Path, token1Path, workloadFeeTier, initialSqrtPriceX96)
	})
}
