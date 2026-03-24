#!/bin/bash

set -euo pipefail

SKIP_EXISTING=false
REPORT_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-exists|-s)
            SKIP_EXISTING=true
            shift
            ;;
        --report-only)
            REPORT_ONLY=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--skip-exists] [--report-only] <ref1> <ref2> [ref3] ..."
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -lt 1 ]; then
    echo "Usage: $0 [--skip-exists] [--report-only] <ref1> <ref2> [ref3] ..." >&2
    exit 1
fi

REFS=("$@")
SHORT_REFS=()
for ref in "${REFS[@]}"; do
    SHORT_REFS+=("${ref:0:7}")
done
REF_COUNT=${#REFS[@]}

echo "=========================================="
echo "Processing $REF_COUNT research ref(s)..."
if [ "$REPORT_ONLY" = true ]; then
    echo "Task: REPORT GENERATION ONLY"
fi
echo "=========================================="
echo ""

echo "Generating research reports"
echo "-------------------------------------------"
for i in "${!REFS[@]}"; do
    ref="${REFS[$i]}"
    short_ref="${SHORT_REFS[$i]}"
    report_file="reports/research/commits/${short_ref}.md"

    if [[ -f "$report_file" && "$SKIP_EXISTING" = true ]]; then
        echo "Skipping $ref: report already exists ($report_file)"
    else
        echo "Generating research report for ref: $ref"
        make research-report "$ref"
    fi
    echo ""
done

if [ "$REPORT_ONLY" = true ]; then
    echo "Research reports generated. Comparisons skipped (--report-only)."
    exit 0
fi

echo "Comparing consecutive research refs"
echo "-------------------------------------------"
for ((i = 0; i < REF_COUNT - 1; i++)); do
    current="${SHORT_REFS[$i]}"
    next="${SHORT_REFS[$((i + 1))]}"
    compare_file="reports/research/compares/diff_${current}_${next}.md"

    if [[ -f "$compare_file" && "$SKIP_EXISTING" = true ]]; then
        echo "Skipping comparison: $current -> $next (already exists: $compare_file)"
    else
        echo "Comparing: $current -> $next"
        ./scripts/compare_reports.sh "reports/research/commits/${current}.md" "reports/research/commits/${next}.md"
    fi
    echo ""
done

base="${SHORT_REFS[$((REF_COUNT - 1))]}"
if [ $REF_COUNT -gt 2 ]; then
    echo "Cumulative research comparisons (each -> base)"
    echo "-------------------------------------------"
    for ((i = 0; i < REF_COUNT - 1; i++)); do
        current="${SHORT_REFS[$i]}"
        if [ $i -eq $((REF_COUNT - 2)) ]; then
            echo "Skipping: $current -> $base (already in consecutive comparisons)"
            continue
        fi

        compare_file="reports/research/compares/diff_${current}_${base}.md"
        if [[ -f "$compare_file" && "$SKIP_EXISTING" = true ]]; then
            echo "Skipping comparison: $current -> $base (already exists: $compare_file)"
        else
            echo "Comparing: $current -> $base"
            ./scripts/compare_reports.sh "reports/research/commits/${current}.md" "reports/research/commits/${base}.md"
        fi
        echo ""
    done
fi

echo "=========================================="
echo "Research comparisons completed!"
echo "=========================================="
echo "Generated reports:"
echo "  - Individual reports: reports/research/commits/"
echo "  - Comparison reports: reports/research/compares/"
