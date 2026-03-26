package research

import (
	"context"
	"fmt"
	"os"
	"testing"
)

func TestResearchReportStakerCreateExternalIncentive(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunStakerCreateExternalIncentiveReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research StakerCreateExternalIncentive (n=%d)", point.N),
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

func TestResearchReportStakerStakeToken(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunStakerStakeTokenReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research StakerStakeToken (n=%d)", point.N),
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

func TestResearchReportStakerCollectReward(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunStakerCollectRewardReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research StakerCollectReward (n=%d)", point.N),
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

func TestResearchReportStakerUnStakeToken(t *testing.T) {
	if os.Getenv(researchReportEnv) != "1" {
		t.Skip("set RESEARCH_REPORT=1 to run research report probes")
	}

	outputPath := os.Getenv(researchReportOutputEnv)
	if outputPath == "" {
		t.Fatalf("%s is required", researchReportOutputEnv)
	}

	env := mustSetupResearchHarnessEnv(t)
	points := mustRunStakerUnStakeTokenReportProbe(t.Context(), t, env, mustProbeCheckpoints(t))
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research StakerUnStakeToken (n=%d)", point.N),
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

func mustRunStakerCreateExternalIncentiveReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	maxIteration := reportMaxIteration(checkpoints)
	rewardAmount, err := queryMinimumRewardAmount(ctx, env)
	if err != nil {
		t.Fatalf("query minimum reward amount: %v", err)
	}
	mustEnsureStakerCreateExternalIncentivePrereqs(ctx, t, env, tokenBudget{
		GNS:          scaledAmountBudget(rewardAmount, maxIteration),
		WrappedUgnot: parseDecimalInt64OrPanic(workloadWrappedDeposit),
	})
	return mustRunCheckpointLoop(t, checkpoints, func(iteration int64) (txMetrics, error) {
		return createExternalIncentiveTx(ctx, env, checkpointRunID()+iteration)
	})
}

func mustRunStakerStakeTokenReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	maxIteration := reportMaxIteration(checkpoints)
	mustEnsureStakerPoolIncentives(ctx, t, env, tokenBudget{
		GNS:          scaledAmountBudget(workloadMintAmount0, maxIteration),
		WrappedUgnot: scaledAmountBudget(workloadMintAmount1, maxIteration),
	})
	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		positionID, err := prepareApprovedStakeablePosition(ctx, env)
		if err != nil {
			return txMetrics{}, err
		}
		return stakeTokenTx(ctx, env, positionID)
	})
}

func mustRunStakerCollectRewardReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	mustEnsureStakerPoolIncentives(ctx, t, env, tokenBudget{
		GNS:          parseDecimalInt64OrPanic(workloadMintAmount0),
		WrappedUgnot: parseDecimalInt64OrPanic(workloadMintAmount1),
	})
	positionID, err := prepareStakedPosition(ctx, env)
	if err != nil {
		t.Fatalf("prepare staked position for collect: %v", err)
	}
	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		waitForRewardAccrual()
		return collectRewardTx(ctx, env, positionID)
	})
}

func mustRunStakerUnStakeTokenReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64) []checkpointPoint {
	t.Helper()
	maxIteration := reportMaxIteration(checkpoints)
	mustEnsureStakerPoolIncentives(ctx, t, env, tokenBudget{
		GNS:          scaledAmountBudget(workloadMintAmount0, maxIteration),
		WrappedUgnot: scaledAmountBudget(workloadMintAmount1, maxIteration),
	})
	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		positionID, err := prepareStakedPosition(ctx, env)
		if err != nil {
			return txMetrics{}, err
		}
		return unstakeTokenTx(ctx, env, positionID)
	})
}
