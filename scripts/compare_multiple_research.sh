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
DEFAULT_GNO_RPC_PORT="${GNO_RPC_PORT:-46657}"
DEFAULT_GNO_REST_PORT="${GNO_REST_PORT:-48888}"

resolve_ref() {
    local ref="$1"
    git -C gnoswap fetch origin >/dev/null 2>&1 || true
    if git -C gnoswap rev-parse -q --verify "${ref}^{commit}" >/dev/null 2>&1; then
        git -C gnoswap rev-parse "${ref}^{commit}"
        return
    fi
    if git -C gnoswap rev-parse -q --verify "origin/${ref}^{commit}" >/dev/null 2>&1; then
        git -C gnoswap rev-parse "origin/${ref}^{commit}"
        return
    fi
    echo "Could not resolve ref '$ref'" >&2
    exit 1
}

SHORT_REFS=()
for ref in "${REFS[@]}"; do
    full_ref="$(resolve_ref "$ref")"
    SHORT_REFS+=("$(git -C gnoswap rev-parse --short=7 "$full_ref")")
done
REF_COUNT=${#REFS[@]}

resolve_report_file() {
    local short_ref="$1"
    python3 - "$short_ref" <<'PY'
from pathlib import Path
import sys

short_ref = sys.argv[1]
paths = sorted(Path("reports/research/commits").glob(f"{short_ref}-*.md"), key=lambda p: p.stat().st_mtime, reverse=True)
if paths:
    print(paths[0])
PY
}

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
    report_file="$(resolve_report_file "$short_ref")"

    if [[ -n "$report_file" && -f "$report_file" && "$SKIP_EXISTING" = true ]]; then
        echo "Skipping $ref: report already exists ($report_file)"
    else
        echo "Generating research report for ref: $ref"
        GNO_RPC_PORT="$DEFAULT_GNO_RPC_PORT" GNO_REST_PORT="$DEFAULT_GNO_REST_PORT" make research-report "$ref"
        report_file="$(resolve_report_file "$short_ref")"
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
    current_report="$(resolve_report_file "$current")"
    next_report="$(resolve_report_file "$next")"
    compare_file="reports/research/compares/diff_${current}_${next}.md"

    if [[ -f "$compare_file" && "$SKIP_EXISTING" = true ]]; then
        echo "Skipping comparison: $current -> $next (already exists: $compare_file)"
    else
        echo "Comparing: $current -> $next"
        ./scripts/compare_reports.sh "$current_report" "$next_report"
    fi
    echo ""
done

base="${SHORT_REFS[$((REF_COUNT - 1))]}"
if [ $REF_COUNT -gt 2 ]; then
    echo "Cumulative research comparisons (each -> base)"
    echo "-------------------------------------------"
    for ((i = 0; i < REF_COUNT - 1; i++)); do
        current="${SHORT_REFS[$i]}"
        current_report="$(resolve_report_file "$current")"
        base_report="$(resolve_report_file "$base")"
        if [ $i -eq $((REF_COUNT - 2)) ]; then
            echo "Skipping: $current -> $base (already in consecutive comparisons)"
            continue
        fi

        compare_file="reports/research/compares/diff_${current}_${base}.md"
        if [[ -f "$compare_file" && "$SKIP_EXISTING" = true ]]; then
            echo "Skipping comparison: $current -> $base (already exists: $compare_file)"
        else
            echo "Comparing: $current -> $base"
            ./scripts/compare_reports.sh "$current_report" "$base_report"
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
