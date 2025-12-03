# GnoSwap Performance Tracker

A tool for measuring and comparing Gas usage, Storage Diff, and CPU Cycles of GnoSwap smart contracts.

## Installation

```bash
# Initialize submodules and install gno
make init
```

## Usage

### 1. Generate Gas Report

Measure performance of a specific commit or branch and generate a report.

```bash
# Based on main branch (default)
make gas-report

# Specific branch
make gas-report feature-branch

# Specific commit
make gas-report abc1234
```

Reports are saved to `reports/commits/{commit_hash}.md`.

**Report Example:**

| Name                        | Gas Used   | Storage Diff | CPU Cycles |
| --------------------------- | ---------- | ------------ | ---------- |
| TickMathGetSqrtRatioAtTick  | 652,368    | 0            | 641,936    |
| Position Mint               | 32,077,387 | 42,822       | 22,212,424 |
| Router Exact Out Swap Route | 30,809,715 | 5,012        | 13,929,413 |

### 2. Compare Reports

Compare performance differences between two commits.

```bash
make compare <latest_commit> <previous_commit>

# Example
make compare abc1234 def5678
```

Comparison reports are saved to `reports/diff_{latest}_{previous}.md`.

**Comparison Report Example:**

| Name              | Metric       | Latest     | Previous   | Change     | %      |
| ----------------- | ------------ | ---------- | ---------- | ---------- | ------ |
| **Position Mint** | Gas Used     | 30,000,000 | 32,077,387 | -2,077,387 | -6.47% |
|                   | Storage Diff | 42,822     | 42,822     | 0          | 0.00%  |
|                   | CPU Cycles   | 20,000,000 | 22,212,424 | -2,212,424 | -9.96% |

## Workflow Example

```bash
# 1. Initial setup
make init

# 2. Measure main branch performance
make gas-report
# → reports/commits/abc1234.md generated

# 3. Measure optimized branch performance
make gas-report optimize-gas
# → reports/commits/def5678.md generated

# 4. Compare two versions
make compare def5678 abc1234
# → reports/diff_def5678_abc1234.md generated
```

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

## Submodules

| Submodule | Branch     | Description                           |
| --------- | ---------- | ------------------------------------- |
| gno       | metric-gas | gno fork with gas measurement feature |
| gnoswap   | main       | GnoSwap smart contracts               |
