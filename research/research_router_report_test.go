package research

import (
	"context"
	"fmt"
	"os"
	"testing"
)

type routerResearchScenario struct {
	Label         string
	RunTag        string
	TickLower     int32
	TickUpper     int32
	PositionCount int
	ExactOut      bool
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
	rows := make([]researchRow, 0)
	for _, scenario := range routerExactInScenarios() {
		rows = append(rows, routerScenarioRows(t.Context(), t, env, mustProbeCheckpoints(t), scenario)...)
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
	rows := make([]researchRow, 0)
	for _, scenario := range routerExactOutScenarios() {
		rows = append(rows, routerScenarioRows(t.Context(), t, env, mustProbeCheckpoints(t), scenario)...)
	}
	mustWriteResearchRows(t, outputPath, rows)
}

func routerExactInScenarios() []routerResearchScenario {
	return []routerResearchScenario{
		{Label: "Router.ExactIn.SingleHop.Wide.Pos1", RunTag: "reiw1", TickLower: workloadWideTickLower, TickUpper: workloadWideTickUpper, PositionCount: 1},
		{Label: "Router.ExactIn.SingleHop.Wide.Pos3", RunTag: "reiw3", TickLower: workloadWideTickLower, TickUpper: workloadWideTickUpper, PositionCount: 3},
		{Label: "Router.ExactIn.SingleHop.Wide.Pos6", RunTag: "reiw6", TickLower: workloadWideTickLower, TickUpper: workloadWideTickUpper, PositionCount: 6},
		{Label: "Router.ExactIn.SingleHop.Narrow.Pos1", RunTag: "rein1", TickLower: workloadNarrowTickLower, TickUpper: workloadNarrowTickUpper, PositionCount: 1},
		{Label: "Router.ExactIn.SingleHop.Narrow.Pos3", RunTag: "rein3", TickLower: workloadNarrowTickLower, TickUpper: workloadNarrowTickUpper, PositionCount: 3},
		{Label: "Router.ExactIn.SingleHop.Narrow.Pos6", RunTag: "rein6", TickLower: workloadNarrowTickLower, TickUpper: workloadNarrowTickUpper, PositionCount: 6},
	}
}

func routerExactOutScenarios() []routerResearchScenario {
	return []routerResearchScenario{
		{Label: "Router.ExactOut.SingleHop.Wide.Pos1", RunTag: "reow1", TickLower: workloadWideTickLower, TickUpper: workloadWideTickUpper, PositionCount: 1, ExactOut: true},
		{Label: "Router.ExactOut.SingleHop.Wide.Pos3", RunTag: "reow3", TickLower: workloadWideTickLower, TickUpper: workloadWideTickUpper, PositionCount: 3, ExactOut: true},
		{Label: "Router.ExactOut.SingleHop.Wide.Pos6", RunTag: "reow6", TickLower: workloadWideTickLower, TickUpper: workloadWideTickUpper, PositionCount: 6, ExactOut: true},
		{Label: "Router.ExactOut.SingleHop.Narrow.Pos1", RunTag: "reon1", TickLower: workloadNarrowTickLower, TickUpper: workloadNarrowTickUpper, PositionCount: 1, ExactOut: true},
		{Label: "Router.ExactOut.SingleHop.Narrow.Pos3", RunTag: "reon3", TickLower: workloadNarrowTickLower, TickUpper: workloadNarrowTickUpper, PositionCount: 3, ExactOut: true},
		{Label: "Router.ExactOut.SingleHop.Narrow.Pos6", RunTag: "reon6", TickLower: workloadNarrowTickLower, TickUpper: workloadNarrowTickUpper, PositionCount: 6, ExactOut: true},
	}
}

func routerScenarioRows(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64, scenario routerResearchScenario) []researchRow {
	t.Helper()
	points := mustRunRouterScenarioReportProbe(ctx, t, env, checkpoints, scenario)
	rows := make([]researchRow, 0, len(points))
	for _, point := range points {
		rows = append(rows, researchRow{
			Name:           fmt.Sprintf("research %s (n=%d)", scenario.Label, point.N),
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
	return rows
}

func mustRunRouterScenarioReportProbe(ctx context.Context, t *testing.T, env *researchHarnessEnv, checkpoints []int64, scenario routerResearchScenario) []checkpointPoint {
	t.Helper()
	state := mustPrepareRouterSingleHopScenario(ctx, t, env, scenario.RunTag, scenario.TickLower, scenario.TickUpper, scenario.PositionCount)
	return mustRunCheckpointLoop(t, checkpoints, func(_ int64) (txMetrics, error) {
		if scenario.ExactOut {
			return routerExactOutSwapRouteTxForPair(ctx, env, state.tokenInPath, state.tokenOutPath, state.route)
		}
		return routerExactInSwapRouteTxForPair(ctx, env, state.tokenInPath, state.tokenOutPath, state.route)
	})
}
