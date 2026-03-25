# GnoSwap Performance Tracker

A tool for measuring and comparing Gas usage, Storage Diff, and CPU Cycles of GnoSwap smart contracts.

> **📊 [View Latest Performance Summary →](SUMMARY.md)**

## Installation

```bash
# Initialize submodules and install gno
make init
# View available commands
make
```

Benchmarks now run in isolated git worktrees under `.worktrees/`.
The shared `gnoswap/` and `gno/` submodules are used as seed repositories and are no longer checked out in place during report generation.

## Usage

The tool provides simplified commands for generating and comparing reports.

There are now three lanes in the tracker:

- `tests/metric` for canonical `gno test` metric benchmarks
- `tests/stress` for canonical `gno test` stress benchmarks
- `research/` for isolated live-chain runtime and exploratory measurements

The report layer is shared, but the runtime layer is intentionally separated.

### 1. Basic Commands

| Command | Description | Existing Reports |
| :--- | :--- | :--- |
| **`make metric`** | Generate metric reports | **Skip** (Reuse) |
| **`make metric-force`** | Generate metric reports | **Force Regenerate** |
| **`make stress`** | Generate stress reports | **Skip** (Reuse) |
| **`make stress-force`** | Generate stress reports | **Force Regenerate** |
| **`make compare-metric`** | Compare metric reports | **Skip** (Reuse) |
| **`make compare-metric-force`** | Compare metric reports | **Force Regenerate** |
| **`make compare-stress`** | Compare stress reports | **Skip** (Reuse) |
| **`make compare-stress-force`** | Compare stress reports | **Force Regenerate** |
| **`make research-up`** | Start research runtime | N/A |
| **`make research-down`** | Stop research runtime scaffold | N/A |
| **`make research-test`** | Run research smoke harness | N/A |
| **`make research-report <ref>`** | Run integrated deploy + probes + report | N/A |
| **`make compare-research <refs>`** | Compare research reports | N/A |
| **`make clean-worktrees`** | Remove cached benchmark worktrees | N/A |

### 2. Examples

#### Single Commit Report
Generate a report for a specific commit without comparison.

```bash
# Standard Metric (skip if exists)
make metric abc1234

# Force regenerate
make metric-force abc1234

# Stress Test
make stress abc1234
```

#### Compare Two Commits
Generate reports (if needed) and compare two commits.

```bash
# Compare metric reports: commit1 -> commit2 (skip existing)
make compare-metric abc1234 def5678

# Force regenerate all metric comparisons
make compare-metric-force abc1234 def5678

# Compare stress reports
make compare-stress abc1234 def5678
```

#### Compare Multiple Commits
Generate reports and compare multiple commits in sequence.
(commit1 → commit2, commit2 → commit3, and commit1 → commit3)

```bash
# Skip existing reports and comparisons
make compare-metric abc1234 def5678 ghi9012

# Force regenerate everything
make compare-metric-force abc1234 def5678 ghi9012
```

### 3. Generate Summary Report

Track performance changes across multiple commits defined in `commit-history.txt`.

```bash
# Generate summary (skip existing reports and comparisons)
make summary

# Force regenerate all reports, comparisons, and summary
make summary-force
```

### 4. Research Lane

The research lane is an integrated live-chain runtime namespace under `research/`.

```bash
make research-up
make research-test
make research-report 3f2642b8898ae02d14a14c4050d80919f18f3f21
make compare-research main develop
make research-down
```

This lane does **not** participate in the default `summary` flow yet.

`make research-report <ref>` is the one-shot path: it boots the local chain, deploys contracts inside the container, executes the probes, and emits normalized markdown through the shared compare pipeline. The `<ref>` argument now drives both the cloned `GNOSWAP_REF` and the output label.

The default research milestones are `1,100,10000`. Override them per run when you want a smaller or denser checkpoint set.

```bash
WORKLOAD_NS=1,10 make research-report 3f2642b8898ae02d14a14c4050d80919f18f3f21
```

### 5. Output Locations

- **Metric Reports:**
  - Individual: `reports/metric/commits/{commit_hash}.md`
  - Comparison: `reports/metric/compares/diff_{new}_{old}.md`
- **Stress Reports:**
  - Individual: `reports/stress/commits/{commit_hash}.md`
  - Comparison: `reports/stress/compares/diff_{new}_{old}.md`
- **Research Reports:**
  - Individual: `reports/research/commits/{ref_hash}.md`
  - Comparison: `reports/research/compares/diff_{new}_{old}.md`
- **Summary Report:** `SUMMARY.md`

Raw research artifacts stay under `research/artifacts/` and `research/.runlogs/`.

### 6. Benchmark Workspace Behavior

- `gnoswap/` stays as the source repository for commit resolution.
- Each benchmark resolves the requested ref to a full commit and reuses a cached detached `gnoswap` worktree under `.worktrees/gnoswap/{full_commit}`.
- Each run also creates a temporary isolated `gno` worktree under `.worktrees/runs/` so copied scenario files and linked contracts do not mutate the shared `gno/` checkout.
- Temporary run worktrees are removed automatically after each benchmark.
- To remove cached worktrees manually, run:

```bash
make clean-worktrees
```

#### Report Example

| Name                        | Gas Used   | Storage Diff | CPU Cycles |
| --------------------------- | ---------- | ------------ | ---------- |
| TickMathGetSqrtRatioAtTick  | 652,368    | 0            | 641,936    |
| Position Mint               | 32,077,387 | 42,822       | 22,212,424 |

#### Comparison Example

| Name              | Metric       | Latest     | Previous   | Change     | %      |
| ----------------- | ------------ | ---------- | ---------- | ---------- | ------ |
| **Position Mint** | Gas Used     | 30,000,000 | 32,077,387 | -2,077,387 | -6.47% |

## Using Scripts Directly

### parse_metrics.sh

Convert gno test results to markdown table.

```bash
# Use with pipe
gno test . -v -run . 2>&1 | ./scripts/parse_metrics.sh

# Read from file
./scripts/parse_metrics.sh output.txt
```

### compare_reports.sh

Compare two report files.

```bash
./scripts/compare_reports.sh <latest.md> <previous.md>
```

### parse_research.sh

Convert live-chain research TSV rows into a markdown table compatible with the compare pipeline.

```bash
./scripts/parse_research.sh < research/artifacts/latest-report.tsv
```

## Submodules

| Submodule | Branch     | Description                           |
| --------- | ---------- | ------------------------------------- |
| gno       | new-metric-gas | gno metric branch used by the tracker |
| gnoswap   | main       | GnoSwap smart contracts               |
