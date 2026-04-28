#!/bin/bash
#
# Compare two gas report files and generate a diff report.
#
# Usage:
#   ./compare_reports.sh <latest.md> <previous.md>
#   ./compare_reports.sh reports/commits/abc123.md reports/commits/def456.md

if [ $# -ne 2 ]; then
    echo "Usage: $0 <latest.md> <previous.md>"
    exit 1
fi

LATEST_FILE="$1"
PREVIOUS_FILE="$2"

if [ ! -f "$LATEST_FILE" ]; then
    echo "Error: Latest file not found: $LATEST_FILE"
    exit 1
fi

if [ ! -f "$PREVIOUS_FILE" ]; then
    echo "Error: Previous file not found: $PREVIOUS_FILE"
    exit 1
fi

# Extract commit hashes from filenames
LATEST_COMMIT=$(basename "$LATEST_FILE" .md)
PREVIOUS_COMMIT=$(basename "$PREVIOUS_FILE" .md)

extract_short_hash() {
    local value="$1"
    if [[ "$value" =~ ^([0-9a-fA-F]{7,40})(-|$) ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
    else
        printf '%s\n' "$value"
    fi
}

# Detect report lane (stress, integration, research, or metric)
if [[ "$LATEST_FILE" == *"/stress/"* ]]; then
    mkdir -p reports/stress/compares
    OUTPUT_FILE="reports/stress/compares/diff_${LATEST_COMMIT}_${PREVIOUS_COMMIT}.md"
elif [[ "$LATEST_FILE" == *"/integration/"* ]]; then
    mkdir -p reports/integration/compares
    OUTPUT_FILE="reports/integration/compares/diff_${LATEST_COMMIT}_${PREVIOUS_COMMIT}.md"
elif [[ "$LATEST_FILE" == *"/research/"* ]]; then
    mkdir -p reports/research/compares
    LATEST_COMMIT=$(extract_short_hash "$LATEST_COMMIT")
    PREVIOUS_COMMIT=$(extract_short_hash "$PREVIOUS_COMMIT")
    OUTPUT_FILE="reports/research/compares/diff_${LATEST_COMMIT}_${PREVIOUS_COMMIT}.md"

    ./scripts/compare_research_reports.py \
        "$LATEST_FILE" \
        "$PREVIOUS_FILE" \
        "$OUTPUT_FILE" \
        "$LATEST_COMMIT" \
        "$PREVIOUS_COMMIT"

    echo "Diff report saved to $OUTPUT_FILE"
    exit 0
else
    mkdir -p reports/metric/compares
    OUTPUT_FILE="reports/metric/compares/diff_${LATEST_COMMIT}_${PREVIOUS_COMMIT}.md"
fi

# Parse markdown table and extract unique entries (first occurrence only)
parse_table() {
    local file="$1"
    if [[ "$file" == *"/research/"* ]]; then
        awk -F'|' '
        NR > 2 && NF > 1 {
            action = $2
            n = $3
            gas = $4
            storage = $9

            gsub(/^[[:space:]]+|[[:space:]]+$/, "", action)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", n)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", gas)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", storage)

            if (action == "" || action == "Action" || n == "" || n == "N" || n !~ /^[0-9]+$/) next

            name = action " (n=" n ")"
            if (seen[name]) next
            seen[name] = 1

            gsub(/[^0-9-]/, "", gas)
            gsub(/[^0-9-]/, "", storage)

            if (gas == "" || gas == "-") gas = 0
            if (storage == "" || storage == "-") storage = 0

            print name "\t" gas "\t" storage "\t0"
        }
        ' "$file"
        return
    fi

    awk -F'|' '
    NR > 2 && NF > 1 {
        # Skip header and separator lines
        name = $2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        
        if (name == "" || name == "Name" || name ~ /^-+$/) next
        
        # Skip if already seen this name
        if (seen[name]) next
        seen[name] = 1
        
        gas = $3; gsub(/[^0-9-]/, "", gas)
        storage = $4; gsub(/[^0-9-]/, "", storage)
        cpu = $5; gsub(/[^0-9-]/, "", cpu)

        if (gas == "" || gas == "-") gas = 0
        if (storage == "" || storage == "-") storage = 0
        if (cpu == "" || cpu == "-") cpu = 0
        
        print name "\t" gas "\t" storage "\t" cpu
    }
    ' "$file"
}

# Create temporary files for parsed data
LATEST_DATA=$(mktemp)
PREVIOUS_DATA=$(mktemp)

parse_table "$LATEST_FILE" | LC_ALL=C sort -t$'\t' -k1,1 > "$LATEST_DATA"
parse_table "$PREVIOUS_FILE" | LC_ALL=C sort -t$'\t' -k1,1 > "$PREVIOUS_DATA"

# Generate diff report
{
    GITHUB_BASE="https://github.com/gnoswap-labs/gnoswap/tree"
    echo "# Gas Report Comparison"
    echo ""
    echo "- **Latest**: [\`$LATEST_COMMIT\`](${GITHUB_BASE}/${LATEST_COMMIT})"
    echo "- **Previous**: [\`$PREVIOUS_COMMIT\`](${GITHUB_BASE}/${PREVIOUS_COMMIT})"
    echo ""
    echo "| Name | Metric | Latest | Previous | Change | % |"
    echo "|------|--------|--------|----------|--------|---|"
    
    # Process each entry from latest
    while IFS=$'\t' read -r name latest_gas latest_storage latest_cpu; do
        # Use exact-key lookup to avoid regex issues in metric names.
        prev_values=$(awk -F'\t' -v key="$name" '$1 == key { print $2 "\t" $3 "\t" $4; exit }' "$PREVIOUS_DATA")
        if [ -n "$prev_values" ]; then
            IFS=$'\t' read -r prev_gas prev_storage prev_cpu <<EOF
$prev_values
EOF
        else
            prev_gas=0
            prev_storage=0
            prev_cpu=0
        fi
        
        # Calculate changes for Gas Used
        gas_diff=$((latest_gas - prev_gas))
        if [ "$prev_gas" -ne 0 ]; then
            gas_pct=$(awk "BEGIN {printf \"%.2f\", ($gas_diff / $prev_gas) * 100}")
        else
            gas_pct="N/A"
        fi
        
        # Format gas change with sign and emoji
        if [ "$gas_diff" -gt 0 ]; then
            gas_change="+$(printf "%'d" $gas_diff)"
            gas_emoji="⚠️"
        elif [ "$gas_diff" -lt 0 ]; then
            gas_change="$(printf "%'d" $gas_diff)"
            gas_emoji="⚡️"
        else
            gas_change="0"
            gas_emoji=""
        fi
        
        # Calculate changes for Storage Diff
        storage_diff=$((latest_storage - prev_storage))

        # For negative storage values (refund), use absolute value comparison
        if [ "$prev_storage" -lt 0 ] && [ "$latest_storage" -lt 0 ]; then
            # Both are negative (storage refund)
            # Calculate percentage based on absolute values
            prev_abs=${prev_storage#-}  # Remove minus sign
            latest_abs=${latest_storage#-}
            abs_diff=$((latest_abs - prev_abs))
            storage_pct=$(awk "BEGIN {printf \"%.2f\", ($abs_diff / $prev_abs) * 100}")

            # More refund (larger absolute value) = improvement
            if [ "$abs_diff" -gt 0 ]; then
                storage_change="$(printf "%'d" $storage_diff)"
                storage_emoji="⚡️"
                # Negate the percentage to show improvement
                storage_pct=$(awk "BEGIN {printf \"%.2f\", -1 * $storage_pct}")
            elif [ "$abs_diff" -lt 0 ]; then
                storage_change="+$(printf "%'d" ${storage_diff#-})"
                storage_emoji="⚠️"
                # Negate the percentage (it's already negative from abs_diff)
                storage_pct=$(awk "BEGIN {printf \"%.2f\", -1 * $storage_pct}")
            else
                storage_change="0"
                storage_emoji=""
            fi
        else
            # Normal calculation for positive values
            if [ "$prev_storage" -ne 0 ]; then
                storage_pct=$(awk "BEGIN {printf \"%.2f\", ($storage_diff / $prev_storage) * 100}")
            else
                if [ "$storage_diff" -ne 0 ]; then
                    storage_pct="N/A"
                else
                    storage_pct="0.00"
                fi
            fi

            if [ "$storage_diff" -gt 0 ]; then
                storage_change="+$(printf "%'d" $storage_diff)"
                storage_emoji="⚠️"
            elif [ "$storage_diff" -lt 0 ]; then
                storage_change="$(printf "%'d" $storage_diff)"
                storage_emoji="⚡️"
            else
                storage_change="0"
                storage_emoji=""
            fi
        fi
        
        # Calculate changes for CPU Cycles
        cpu_diff=$((latest_cpu - prev_cpu))
        if [ "$prev_cpu" -ne 0 ]; then
            cpu_pct=$(awk "BEGIN {printf \"%.2f\", ($cpu_diff / $prev_cpu) * 100}")
        else
            cpu_pct="N/A"
        fi
        
        if [ "$cpu_diff" -gt 0 ]; then
            cpu_change="+$(printf "%'d" $cpu_diff)"
            cpu_emoji="⚠️"
        elif [ "$cpu_diff" -lt 0 ]; then
            cpu_change="$(printf "%'d" $cpu_diff)"
            cpu_emoji="⚡️"
        else
            cpu_change="0"
            cpu_emoji=""
        fi
        
        # Format numbers with commas
        latest_gas_fmt=$(printf "%'d" $latest_gas)
        prev_gas_fmt=$(printf "%'d" $prev_gas)
        latest_storage_fmt=$(printf "%'d" $latest_storage)
        prev_storage_fmt=$(printf "%'d" $prev_storage)
        latest_cpu_fmt=$(printf "%'d" $latest_cpu)
        prev_cpu_fmt=$(printf "%'d" $prev_cpu)
        
        # Output rows for each metric
        echo "| **$name** | Gas Used | $latest_gas_fmt | $prev_gas_fmt | $gas_change | $gas_emoji ${gas_pct}% |"
        echo "| | Storage Diff | $latest_storage_fmt | $prev_storage_fmt | $storage_change | $storage_emoji ${storage_pct}% |"
        echo "| | CPU Cycles | $latest_cpu_fmt | $prev_cpu_fmt | $cpu_change | $cpu_emoji ${cpu_pct}% |"
        
    done < "$LATEST_DATA"
    
} > "$OUTPUT_FILE"

# Cleanup
rm -f "$LATEST_DATA" "$PREVIOUS_DATA"

echo "Diff report saved to $OUTPUT_FILE"
