# AGENTS.md — GnoSwap Performance Tracker

This repository measures and compares the runtime cost of GnoSwap contract
revisions. It is a **worktree-based benchmark runner and report parser**; it is
not the GnoSwap contract repository.

`CLAUDE.md` is a symlink to this file so every supported coding agent reads the
same instructions.

## Core Model

The checked-out `gnoswap/` and `gno/` directories are Git submodules used as
seed repositories only. For a requested GnoSwap ref, the tracker:

1. resolves the ref to a full commit;
2. creates or reuses an isolated `gnoswap` worktree in `.worktrees/gnoswap/`;
3. creates a temporary isolated `gno` worktree in `.worktrees/runs/`;
4. links/copies the target contract and benchmark scenarios into that runtime;
5. runs `gno test`, parses its output, and writes normalized Markdown reports.

Never run benchmarks by checking out or modifying the shared `gnoswap/` or
`gno/` submodule worktrees. Do not commit submodule pointer changes unless the
task explicitly asks to upgrade a seed revision.

### Metric-enabled Gno revisions

When a benchmark needs a specific upstream `gnolang/gno` revision, first run
`make prepare-gno-gas <gno-ref>`. It creates or reuses
`gnoswap-labs/gno:gas-<8-char-upstream-sha>` from that upstream commit and
applies, in order, the required metric patches:

1. `eb20d3a1074f10dc0c4a4a5815216d18d58aa42b` — testing methods.
2. `9d65db8e09777064d1b69638f9a8e971bd3817c3` — metric gas registration.

The branch creator uses a temporary worktree, never force-pushes, and verifies
an existing branch has precisely that base plus those two patch contents. It
persists the resulting final Gno commit in this checkout's local Git config, so
subsequent `make metric <gnoswap-ref>` and `make stress <gnoswap-ref>` commands
use it automatically. Set `GNO_REF=<ref-or-commit>` only for a one-off override.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `Makefile` | Public benchmark, comparison, research, and cleanup commands. |
| `scripts/prepare_benchmark_workspace.sh` | Resolves refs and creates isolated benchmark worktrees. |
| `scripts/compare_multiple.sh` | Metric/stress report orchestration. |
| `scripts/parse_metrics.sh` | Converts `gno test` metrics to Markdown. |
| `scripts/compare_reports.sh` | Compares two normalized Markdown reports. |
| `tests/metric/` | Canonical filetests for ordinary performance metrics. |
| `tests/stress/` | Canonical stress/performance filetests. |
| `reports/` | Generated metric, stress, and research reports. |
| `research/` | Separate Docker-backed live-chain experimentation lane. |
| `gnoswap/`, `gno/` | Seed submodules; read their local guides only when investigating their code. |

## Commands

```bash
# First-time setup: initialize seed repos and build the Gno binary
make init

# Generate reports for one or more GnoSwap refs
make metric <ref> [<ref> ...]
make stress <ref> [<ref> ...]

# Generate missing reports and comparisons
make compare-metric <ref> <ref> [<ref> ...]
make compare-stress <ref> <ref> [<ref> ...]

# Force regeneration when intentionally replacing generated reports
make metric-force <ref> [<ref> ...]
make stress-force <ref> [<ref> ...]
make compare-metric-force <ref> <ref> [<ref> ...]
make compare-stress-force <ref> <ref> [<ref> ...]

# Research lane (explicit, non-conflicting ports are required for reports)
make research-test
GNO_RPC_PORT=46657 GNO_REST_PORT=48888 make research-report <ref>
make compare-research <ref> <ref> [<ref> ...]

# Remove generated benchmark worktrees only when requested
make clean-worktrees
```

`make metric`/`stress` reuse existing reports; use the `-force` variants only
when regenerating them is intentional. `make research-report` requires both
ports and creates raw artifacts and run logs in addition to the final report.

## Change Rules

- Treat `reports/` as generated output. Commit it only when the task asks for
  a benchmark result or report refresh; do not mix incidental local reports
  into code or documentation changes.
- Preserve users' existing `Makefile`, report, and submodule working-tree
  changes. Stage only files belonging to the requested change.
- Keep the metric/stress lanes deterministic and independent of the research
  lane. Research uses Docker and a live local chain; it is not part of the
  default summary flow.
- When changing parsers or comparison logic, use small representative fixture
  output and verify both the generated report shape and comparison semantics.
- When changing benchmark scenarios, state whether the changed number reflects
  a contract regression/improvement or only a measurement-harness change.
- Consult `gnoswap/AGENTS.md` for GnoSwap contract semantics and
  `gno/AGENTS.md` for Gno runtime conventions, but make contract changes in
  their own repositories rather than in this tracker unless explicitly asked.

## Validation

Choose the narrowest relevant check:

- Makefile wiring: `make help`.
- Shell parser/comparison change: execute it against a focused existing report
  or captured output; inspect the resulting Markdown.
- Go research-lane change: run the focused `go test` package under `research/`.
- Benchmark scenario change: run the corresponding `make metric` or
  `make stress` command for an explicit ref, then review the report diff.

Do not use `make clean-worktrees` as routine cleanup: it removes cached
worktrees and makes subsequent benchmark runs slower.
