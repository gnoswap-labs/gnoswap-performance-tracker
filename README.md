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

## Usage

The tool provides simplified commands for generating and comparing reports.

### 1. Basic Commands

| Command | Description | Existing Reports |
| :--- | :--- | :--- |
| **`make metric`** | Generate metric reports | **Skip** (Reuse) |
| **`make metric-force`** | Generate metric reports | **Force Regenerate** |
| **`make stress`** | Generate stress reports | **Skip** (Reuse) |
| **`make stress-force`** | Generate stress reports | **Force Regenerate** |
| **`make compare`** | Generate and compare reports | **Skip** (Reuse) |
| **`make compare-force`** | Generate and compare reports | **Force Regenerate** |

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
# Compare commit1 -> commit2 (skip existing)
make compare abc1234 def5678

# Force regenerate all
make compare-force abc1234 def5678

# Stress Test Comparison
make stress-compare abc1234 def5678
```

#### Compare Multiple Commits
Generate reports and compare multiple commits in sequence.
(commit1 → commit2, commit2 → commit3, and commit1 → commit3)

```bash
# Skip existing reports and comparisons
make compare abc1234 def5678 ghi9012

# Force regenerate everything
make compare-force abc1234 def5678 ghi9012
```

### 3. Generate Summary Report

Track performance changes across multiple commits defined in `commit-history.txt`.

```bash
# Generate summary (skip existing reports and comparisons)
make summary

# Force regenerate all reports, comparisons, and summary
make summary-force
```

### 4. Output Locations

- **Metric Reports:**
  - Individual: `reports/metric/commits/{commit_hash}.md`
  - Comparison: `reports/metric/compares/diff_{new}_{old}.md`
- **Stress Reports:**
  - Individual: `reports/stress/commits/{commit_hash}.md`
  - Comparison: `reports/stress/compares/diff_{new}_{old}.md`
- **Summary Report:** `SUMMARY.md`

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

## Submodules

| Submodule | Branch     | Description                           |
| --------- | ---------- | ------------------------------------- |
| gno       | metric-gas | gno fork with gas measurement feature |
| gnoswap   | main       | GnoSwap smart contracts               |
