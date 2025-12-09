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
| **`make run`** | Run standard metric tests | **Skip** (Reuse) |
| **`make run-all`** | Run standard metric tests | **Regenerate** |
| **`make stress`** | Run stress tests | **Skip** (Reuse) |
| **`make stress-all`** | Run stress tests | **Regenerate** |

### 2. Examples

#### Single Commit Report
Generate a report for a specific commit without comparison.

```bash
# Standard Metric
make run abc1234

# Stress Test
make stress abc1234
```

#### Compare Two Commits
Generate reports (if needed) and compare two commits.

```bash
# Compare commit1 -> commit2
make run abc1234 def5678

# Stress Test Comparison
make stress abc1234 def5678
```

#### Compare Multiple Commits
Generate reports and compare multiple commits in sequence.
(commit1 → commit2, commit2 → commit3, and commit1 → commit3)

```bash
make run abc1234 def5678 ghi9012
```

### 3. Generate Summary Report

Track performance changes across multiple commits defined in `commit-history.txt`.

```bash
# Generate summary from existing reports
make summary

# Generate reports for all commits in history and create summary
make summary-with-run
```

### 4. Output Locations

- **Individual Reports:** `reports/commits/{commit_hash}.md`
- **Comparison Reports:** `reports/compares/diff_{new}_{old}.md`
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
