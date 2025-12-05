#!/bin/bash
#
# Compare multiple commits by generating gas reports and comparing them.
#
# Usage:
#   ./compare_multiple.sh [--skip-exists] <commit1> <commit2> [commit3] ...
#
# Options:
#   --skip-exists-, -s    Skip generating gas report if file already exists
#
# This script will:
#   1. Generate gas reports for each commit
#   2. Compare consecutive commits (commit1~commit2, commit2~commit3, ...)
#   3. Compare first commit to each subsequent commit (cumulative comparison)

set -e

# Parse options
SKIP_EXISTING=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-exists|-s)
            SKIP_EXISTING=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--skip-exists] <commit1> <commit2> [commit3] ..."
            echo ""
            echo "Options:"
            echo "  --skip-exists, -s    Skip generating gas report if file already exists"
            echo "  --help, -h    Show this help message"
            echo ""
            echo "Example: $0 --skip-exists abc12345 def45678 ghi78901"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -lt 2 ]; then
    echo "Usage: $0 [--skip-exists] <commit1> <commit2> [commit3] ..."
    echo "Example: $0 --skip-exists abc12345 def45678 ghi78901"
    exit 1
fi

# Truncate all commit hashes to 8 characters
COMMITS=()
for arg in "$@"; do
    COMMITS+=("${arg:0:8}")
done
COMMIT_COUNT=${#COMMITS[@]}

echo "=========================================="
echo "Processing $COMMIT_COUNT commits..."
echo "=========================================="
echo ""

# Generate gas reports for each commit
echo "Generating gas reports for all commits"
echo "-------------------------------------------"
for commit in "${COMMITS[@]}"; do
    REPORT_FILE="reports/commits/${commit}.md"
    if [[ -f "$REPORT_FILE" && "$SKIP_EXISTING" = true ]]; then
        echo "Skipping $commit: report already exists ($REPORT_FILE)"
    else
        echo "Generating gas report for commit: $commit"
        make gas-report "$commit"
    fi
    echo ""
done

# Compare consecutive commits
echo ""
echo "Comparing consecutive commits"
echo "-------------------------------------------"
for ((i = 0; i < COMMIT_COUNT - 1; i++)); do
    current="${COMMITS[$i]}"
    next="${COMMITS[$((i + 1))]}"
    echo "Comparing: $current -> $next"
    make compare "$current" "$next"
    echo ""
done

# Compare each commit to the base (oldest) commit
# COMMITS array is ordered newest-first, so base is the last element
base="${COMMITS[$((COMMIT_COUNT - 1))]}"
if [ $COMMIT_COUNT -gt 2 ]; then
    echo ""
    echo "Cumulative comparisons (each -> base)"
    echo "-------------------------------------------"
    for ((i = 0; i < COMMIT_COUNT - 1; i++)); do
        current="${COMMITS[$i]}"
        # Skip if it's the commit just before base (consecutive already covers it)
        if [ $i -eq $((COMMIT_COUNT - 2)) ]; then
            echo "Skipping: $current -> $base (already in consecutive comparisons)"
            continue
        fi
        echo "Comparing: $current -> $base"
        make compare "$current" "$base"
        echo ""
    done
fi

echo ""
echo "=========================================="
echo "All comparisons completed!"
echo "=========================================="
echo ""
echo "Generated reports:"
echo "  - Individual reports: reports/commits/"
echo "  - Comparison reports: reports/compares/"

