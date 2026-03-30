package research

import (
	"context"
	"fmt"
	"os"
	"testing"
)

func TestResearchReportPositionMint(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunPositionMintReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research PositionMint (n=%d)", point.N),
			GasUsed:        point.GasStats.Avg,
			StorageDiff:    point.StorageStats.Avg,
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

func TestResearchReportPositionIncreaseLiquidity(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunPositionIncreaseReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research PositionIncreaseLiquidity (n=%d)", point.N),
			GasUsed:        point.GasStats.Avg,
			StorageDiff:    point.StorageStats.Avg,
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

func TestResearchReportPositionDecreaseLiquidity(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunPositionDecreaseReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research PositionDecreaseLiquidity (n=%d)", point.N),
			GasUsed:        point.GasStats.Avg,
			StorageDiff:    point.StorageStats.Avg,
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

func mustRunPositionMintReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	maxIteration := reportMaxIteration(checkpoints)
	mustEnsureMintPrereqs(ctx, t, env, tokenBudget{
		GNS:          scaledAmountBudget(workloadMintAmount0, maxIteration),
		WrappedUgnot: scaledAmountBudget(workloadMintAmount1, maxIteration),
	})

	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		return mintPositionTx(ctx, env, workloadWideTickLower, workloadWideTickUpper, workloadMintAmount0, workloadMintAmount1)
	})
}

func mustRunPositionIncreaseReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	maxIteration := reportMaxIteration(checkpoints)
	mustEnsureMintPrereqs(ctx, t, env, tokenBudget{
		GNS:          parseDecimalInt64OrPanic(workloadMintAmount0) + scaledAmountBudget(workloadIncreaseAmount0, maxIteration),
		WrappedUgnot: parseDecimalInt64OrPanic(workloadMintAmount1) + scaledAmountBudget(workloadIncreaseAmount1, maxIteration),
	})
	positionID, err := preparePositionForIncrease(ctx, env)
	if err != nil {
		t.Fatalf("prepare position for increase: %v", err)
	}

	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		return increaseLiquidityTx(ctx, env, positionID)
	})
}

func mustRunPositionDecreaseReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	mustEnsureMintPrereqs(ctx, t, env, tokenBudget{
		GNS:          parseDecimalInt64OrPanic(workloadDecreaseMintAmount0),
		WrappedUgnot: parseDecimalInt64OrPanic(workloadDecreaseMintAmount1),
	})
	maxIteration := checkpoints[len(checkpoints)-1]
	positionID, liquidity, err := preparePositionForDecrease(ctx, env, maxIteration)
	if err != nil {
		t.Fatalf("prepare position for decrease: %v", err)
	}

	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		return decreaseLiquidityTx(ctx, env, positionID, liquidity)
	})
}

func reportMaxIteration(checkpoints []int64) int64 {
	var maxIteration int64
	for _, checkpoint := range checkpoints {
		if checkpoint > maxIteration {
			maxIteration = checkpoint
		}
	}
	return maxIteration
}
