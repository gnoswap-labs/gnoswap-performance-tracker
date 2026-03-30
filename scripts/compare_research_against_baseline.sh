#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <baseline-report.md>" >&2
    exit 1
fi

BASELINE_FILE="$1"
REPORT_DIR="reports/research/commits"

if [[ "$BASELINE_FILE" != *.md ]]; then
    echo "Error: baseline must be a markdown report file" >&2
    exit 1
fi

if [ ! -f "$BASELINE_FILE" ]; then
    echo "Error: baseline file not found: $BASELINE_FILE" >&2
    exit 1
fi

python3 - "$BASELINE_FILE" "$REPORT_DIR" <<'PY' | while IFS= read -r target_file; do
from pathlib import Path
import sys

baseline = Path(sys.argv[1]).resolve()
report_dir = Path(sys.argv[2]).resolve()

if report_dir not in baseline.parents:
    print(f"Error: baseline must be inside {report_dir}", file=sys.stderr)
    sys.exit(1)

targets = sorted(
    path.resolve()
    for path in report_dir.glob("*.md")
    if path.resolve() != baseline
)

for target in targets:
    print(target)
PY
    echo "Comparing: $(basename "$target_file" .md) -> $(basename "$BASELINE_FILE" .md)"
    ./scripts/compare_reports.sh "$target_file" "$BASELINE_FILE"
done

echo "Completed baseline fan-out comparisons into reports/research/compares/"
