# GnoSwap Performance Tracker

A tool for measuring and comparing Gas usage, Storage Diff, and CPU Cycles of GnoSwap smart contracts.

> **📊 [View Latest Performance Summary →](SUMMARY.md)**

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

### 3. Generate Summary Report

Track performance changes across multiple commits and generate a comprehensive summary.

#### Step 1: Add commit to history file

Edit `commit-history.txt` and add your commit with a description:

```
{commit_hash}:{description}
```

**Format:**

- Each line: `{full_commit_hash}:{description}`
- Order: Oldest commit first, newest last
- Comments: Lines starting with `#` are ignored

**Example `commit-history.txt`:**

```
e5d1e160b0e3302bd00355ef9705f0e5a28c9a68:Base
9dbd89273d8dca332e9b033e77ef0ee1f39f70c9:Optimize Uint256
31d883d42b428ecf3d5c735d83f28d2ab734a8b7:Optimize Int256
94d467283a562e0ac319440777f5269a447d3a72:Optimize Common
f468996ce38e1387392278643af0d83e7219c6cc:Optimize Pool
```

#### Step 2: Generate gas report for each commit

```bash
make gas-report {commit_hash}

# Example
make gas-report f468996ce38e1387392278643af0d83e7219c6cc
```

#### Step 3: Generate summary report

```bash
# Generate summary from existing reports only
make summary

# Generate reports for all commits and create summary
make summary-with-run
```

The summary report (`SUMMARY.md`) includes:

- Overview of all tracked commits
- Links to individual commit reports
- Diff links between consecutive commits
- Diff links from baseline (first commit)
- Overall comparison (first → latest)

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

### Workflow Example: Summary Report

```bash
# 1. Edit commit-history.txt (oldest to newest order)
cat commit-history.txt
# e5d1e160b0e3302bd00355ef9705f0e5a28c9a68:Base
# 9dbd89273d8dca332e9b033e77ef0ee1f39f70c9:Optimize Uint256
# f468996ce38e1387392278643af0d83e7219c6cc:Optimize Pool

# 2. Generate gas report for new commit
make gas-report f468996ce38e1387392278643af0d83e7219c6cc
# → reports/commits/f468996c.md generated

# 3. Generate summary report with all comparisons
make summary-with-run
# → SUMMARY.md generated with:
#   - Individual commit reports
#   - Consecutive commit diffs
#   - Overall comparison (first → latest)
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
