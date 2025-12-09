#!/bin/bash
#
# Compare multiple commits by generating gas reports and comparing them.
#
# Usage:
#   ./compare_multiple.sh [--skip-exists] [--stress] <commit1> <commit2> [commit3] ...
#
# Options:
#   --skip-exists, -s    Skip generating gas report if file already exists
#   --stress             Run stress tests instead of standard metric tests
#
# This script will:
#   1. Generate gas reports for each commit
#   2. Compare consecutive commits (commit1~commit2, commit2~commit3, ...)
#   3. Compare first commit to each subsequent commit (cumulative comparison)

set -e

# Parse options
SKIP_EXISTING=false
STRESS_MODE=false
REPORT_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-exists|-s)
            SKIP_EXISTING=true
            shift
            ;;
        --stress)
            STRESS_MODE=true
            shift
            ;;
        --report-only)
            REPORT_ONLY=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--skip-exists] [--stress] [--report-only] <commit1> <commit2> [commit3] ..."
            echo ""
            echo "Options:"
            echo "  --skip-exists, -s    Skip generating gas report if file already exists"
            echo "  --stress             Run stress tests instead of standard metric tests"
            echo "  --report-only        Only generate reports, skip comparisons"
            echo "  --help, -h           Show this help message"
            echo ""
            echo "Example: $0 --skip-exists abc12345"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -lt 1 ]; then
    echo "Usage: $0 [--skip-exists] [--stress] [--report-only] <commit1> <commit2> [commit3] ..."
    echo "Example: $0 --skip-exists abc12345"
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
if [ "$STRESS_MODE" = true ]; then
    echo "Mode: STRESS TEST"
else
    echo "Mode: STANDARD METRIC"
fi
if [ "$REPORT_ONLY" = true ]; then
    echo "Task: REPORT GENERATION ONLY"
fi
echo "=========================================="
echo ""

# Generate gas reports for each commit
echo "Generating gas reports for all commits"
echo "-------------------------------------------"
for commit in "${COMMITS[@]}"; do
    if [ "$STRESS_MODE" = true ]; then
        REPORT_FILE="reports/commits/stress_${commit}.md"
        TARGET="stress-report"
    else
        REPORT_FILE="reports/commits/${commit}.md"
        TARGET="gas-report"
    fi

    if [[ -f "$REPORT_FILE" && "$SKIP_EXISTING" = true ]]; then
        echo "Skipping $commit: report already exists ($REPORT_FILE)"
    else
        echo "Generating gas report for commit: $commit"
        make "$TARGET" "$commit"
    fi
    echo ""
done

if [ "$REPORT_ONLY" = true ]; then
    echo "Reports generated. Comparisons skipped (--report-only)."
    exit 0
fi

# Compare consecutive commits
echo ""
echo "Comparing consecutive commits"
echo "-------------------------------------------"
for ((i = 0; i < COMMIT_COUNT - 1; i++)); do
    current="${COMMITS[$i]}"
    next="${COMMITS[$((i + 1))]}"
    echo "Comparing: $current -> $next"
    
    if [ "$STRESS_MODE" = true ]; then
        PREFIX="stress_"
    else
        PREFIX=""
    fi
    
    REPORT_CURRENT="reports/commits/${PREFIX}${current}.md"
    REPORT_NEXT="reports/commits/${PREFIX}${next}.md"
    
    ./scripts/compare_reports.sh "$REPORT_CURRENT" "$REPORT_NEXT"
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
        
        if [ "$STRESS_MODE" = true ]; then
            PREFIX="stress_"
        else
            PREFIX=""
        fi

        REPORT_CURRENT="reports/commits/${PREFIX}${current}.md"
        REPORT_BASE="reports/commits/${PREFIX}${base}.md"

        ./scripts/compare_reports.sh "$REPORT_CURRENT" "$REPORT_BASE"
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

