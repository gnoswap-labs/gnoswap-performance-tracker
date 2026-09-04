#!/usr/bin/env bash
#
# Regression test for scripts/compare_reports.sh: the parser that turns two
# worktree-generated metric reports (e.g. main vs. a PR ref) into a
# before/after gas comparison. Feeds small fixture reports through the real
# script and checks the computed deltas.
#
# Usage: bash tests/scripts/test_compare_reports.sh

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# "main" report: state before the PR.
cat > "$WORKDIR/main.md" <<'EOF'
| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| StakeToken | 1,000,000 | 100 | 900,000 |
| CollectReward | 2,000,000 | 200 | 1,800,000 |
EOF

# "pr" report: state after the PR (StakeToken improved, CollectReward regressed).
cat > "$WORKDIR/pr.md" <<'EOF'
| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| StakeToken | 900,000 | 100 | 800,000 |
| CollectReward | 2,200,000 | 200 | 2,000,000 |
EOF

(cd "$WORKDIR" && "$REPO_ROOT/scripts/compare_reports.sh" pr.md main.md >/dev/null)

DIFF_FILE="$WORKDIR/reports/metric/compares/diff_pr_main.md"

fail() {
    echo "FAIL: $1" >&2
    echo "--- diff report ---" >&2
    cat "$DIFF_FILE" >&2 2>/dev/null || echo "(not generated)" >&2
    exit 1
}

[ -f "$DIFF_FILE" ] || fail "diff report was not generated at $DIFF_FILE"

assert_contains() {
    grep -qF -- "$1" "$DIFF_FILE" || fail "expected line not found: $1"
}

# StakeToken improved: gas -100,000 (-10.00%), cpu -100,000 (-11.11%).
assert_contains "| **StakeToken** | Gas Used | 900,000 | 1,000,000 | -100,000 | ⚡️ -10.00% |"
assert_contains "| | CPU Cycles | 800,000 | 900,000 | -100,000 | ⚡️ -11.11% |"

# CollectReward regressed: gas +200,000 (10.00%), cpu +200,000 (11.11%).
assert_contains "| **CollectReward** | Gas Used | 2,200,000 | 2,000,000 | +200,000 | ⚠️ 10.00% |"
assert_contains "| | CPU Cycles | 2,000,000 | 1,800,000 | +200,000 | ⚠️ 11.11% |"

echo "PASS: compare_reports.sh produced the expected main-vs-PR diff"
