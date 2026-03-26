package research

import (
	"context"
	"fmt"
	"os"
	"testing"
)

type routerResearchScenario struct {
	Label               string
	RunTag              string
	SetupKind           string
	TickLower           int32
	TickUpper           int32
	PositionCount       int
	ExactOut            bool
	Oscillate           bool
	ExactInAmountIn     string
	ExactOutAmountOut   string
	ExactOutAmountInMax string
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
		{Label: "Router.ExactIn.SingleHop.Pos1", RunTag: "reis1", TickLower: routerSameBoundsTickLower, TickUpper: routerSameBoundsTickUpper, PositionCount: 1, Oscillate: true, ExactInAmountIn: routerExactInSingleHopAmountIn},
		{Label: "Router.ExactIn.SingleHop.Pos6", RunTag: "reis6", SetupKind: "single-hop-staggered", Oscillate: true, ExactInAmountIn: routerExactInSingleHopAmountIn},
		{Label: "Router.ExactIn.TwoHop", RunTag: "reit2", SetupKind: "two-hop-mixed-fee", Oscillate: true, ExactInAmountIn: routerExactInTwoHopAmountIn},
	}
}

func routerExactOutScenarios() []routerResearchScenario {
	return []routerResearchScenario{
		{Label: "Router.ExactOut.SingleHop.Pos1", RunTag: "reos1", TickLower: routerSameBoundsTickLower, TickUpper: routerSameBoundsTickUpper, PositionCount: 1, ExactOut: true, Oscillate: true, ExactOutAmountOut: routerExactOutSingleHopAmountOut, ExactOutAmountInMax: routerExactOutSingleHopAmountInMax},
		{Label: "Router.ExactOut.SingleHop.Pos6", RunTag: "reos6", SetupKind: "single-hop-staggered", ExactOut: true, Oscillate: true, ExactOutAmountOut: routerExactOutSingleHopAmountOut, ExactOutAmountInMax: routerExactOutSingleHopAmountInMax},
		{Label: "Router.ExactOut.TwoHop", RunTag: "reot2", SetupKind: "two-hop-mixed-fee", ExactOut: true, Oscillate: true, ExactOutAmountOut: routerExactOutTwoHopAmountOut, ExactOutAmountInMax: routerExactOutTwoHopAmountInMax},
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
	var state routerScenarioState
	switch scenario.SetupKind {
	case "single-hop-staggered":
		state = mustPrepareRouterSingleHopStaggeredScenario(ctx, t, env, scenario.RunTag)
	case "two-hop-mixed-fee":
		state = mustPrepareRouterTwoHopMixedFeeScenario(ctx, t, env, scenario.RunTag)
	default:
		state = mustPrepareRouterSingleHopScenario(ctx, t, env, scenario.RunTag, scenario.TickLower, scenario.TickUpper, scenario.PositionCount)
	}
	return mustRunCheckpointLoop(t, checkpoints, func(iteration int64) (txMetrics, error) {
		beforeTicks, err := queryPoolTicks(ctx, env, state.poolPaths)
		if err != nil {
			return txMetrics{}, err
		}
		tokenInPath := state.tokenInPath
		tokenOutPath := state.tokenOutPath
		route := state.route
		if scenario.Oscillate && state.reverseRoute != "" && iteration%2 == 0 {
			tokenInPath, tokenOutPath = state.tokenOutPath, state.tokenInPath
			route = state.reverseRoute
		}
		if scenario.ExactOut {
			metrics, err := routerExactOutSwapRouteTxForPairWithAmount(ctx, env, tokenInPath, tokenOutPath, route, scenario.ExactOutAmountOut, scenario.ExactOutAmountInMax)
			if err != nil {
				return txMetrics{}, err
			}
			if scenario.Oscillate {
				afterTicks, tickErr := queryPoolTicks(ctx, env, state.poolPaths)
				if tickErr != nil {
					return txMetrics{}, tickErr
				}
				if !ticksChanged(beforeTicks, afterTicks) {
					return txMetrics{}, fmt.Errorf("expected tick movement but none observed: before=%v after=%v", beforeTicks, afterTicks)
				}
			}
			return metrics, nil
		}
		metrics, err := routerExactInSwapRouteTxForPairWithAmount(ctx, env, tokenInPath, tokenOutPath, route, scenario.ExactInAmountIn, routerExactInAmountOutMin)
		if err != nil {
			return txMetrics{}, err
		}
		if scenario.Oscillate {
			afterTicks, tickErr := queryPoolTicks(ctx, env, state.poolPaths)
			if tickErr != nil {
				return txMetrics{}, tickErr
			}
			if !ticksChanged(beforeTicks, afterTicks) {
				return txMetrics{}, fmt.Errorf("expected tick movement but none observed: before=%v after=%v", beforeTicks, afterTicks)
			}
		}
		return metrics, nil
	})
}

func queryPoolTicks(ctx context.Context, env *researchHarnessEnv, poolPaths []string) ([]int32, error) {
	ticks := make([]int32, 0, len(poolPaths))
	for _, poolPath := range poolPaths {
		tick, err := queryPoolSlot0Tick(ctx, env, poolPath)
		if err != nil {
			return nil, err
		}
		ticks = append(ticks, tick)
	}
	return ticks, nil
}

func ticksChanged(before, after []int32) bool {
	if len(before) != len(after) {
		return true
	}
	for i := range before {
		if before[i] != after[i] {
			return true
		}
	}
	return false
}
