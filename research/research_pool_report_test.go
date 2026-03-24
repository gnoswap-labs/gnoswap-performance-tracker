package research

import (
	"context"
	"fmt"
	"os"
	"strconv"
	"testing"
	"time"
)

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

func TestResearchReportRouterExactInSwapRoute(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunRouterExactInSwapRouteReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research RouterExactInSwapRoute (n=%d)", point.N),
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

func TestResearchReportRouterExactOutSwapRoute(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunRouterExactOutSwapRouteReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research RouterExactOutSwapRoute (n=%d)", point.N),
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

func mustRunRouterExactInSwapRouteReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	mustEnsureSwapPrereqs(ctx, t, env)
	if _, err := routerExactInSwapRouteTx(ctx, env); err != nil {
		t.Fatalf("router exact-in warm-up: %v", err)
	}

	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		return routerExactInSwapRouteTx(ctx, env)
	})
}

func mustRunRouterExactOutSwapRouteReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	mustEnsureSwapPrereqs(ctx, t, env)
	if _, err := routerExactOutSwapRouteTx(ctx, env); err != nil {
		t.Fatalf("router exact-out warm-up: %v", err)
	}

	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		return routerExactOutSwapRouteTx(ctx, env)
	})
}
