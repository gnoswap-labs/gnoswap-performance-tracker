#!/usr/bin/env bash

# Convert performance reports to GitHub issue format
# Usage: ./scripts/convert_to_issue_format.sh [base_commit] [latest_commit]
#
# Output format:
# | Pkg Path | Name | Gas Used (Before) | Storage Fee (Before) | Gas Used (After) | Storage Fee (After) | Commit |

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORTS_DIR="$PROJECT_ROOT/reports"
COMMITS_DIR="$REPORTS_DIR/metric/commits"
COMMIT_HISTORY="$PROJECT_ROOT/commit-history.txt"
METRIC_TEST_DIR="$PROJECT_ROOT/metric_test"
GNOSWAP_DIR="$PROJECT_ROOT/gnoswap"
OUTPUT_FILE="$REPORTS_DIR/issue_format.md"

# GitHub repo URL for test files
GITHUB_REPO="https://github.com/gnoswap-labs/gnoswap-performance-tracker"
BRANCH="main"

# Get base and latest commit from arguments or commit-history.txt
if [ -n "$1" ] && [ -n "$2" ]; then
    BASE_COMMIT="${1:0:7}"
    LATEST_COMMIT="${2:0:7}"
else
    # Read from commit-history.txt
    BASE_COMMIT=$(head -1 "$COMMIT_HISTORY" | cut -d':' -f1 | cut -c1-7)
    LATEST_COMMIT=$(tail -1 "$COMMIT_HISTORY" | cut -d':' -f1 | cut -c1-7)
fi

BASE_REPORT="$COMMITS_DIR/${BASE_COMMIT}.md"

# Verify file exists
if [ ! -f "$BASE_REPORT" ]; then
    echo "Error: Base report not found: $BASE_REPORT" >&2
    exit 1
fi

# Function to format number with commas using awk
format_number() {
    local num="$1"
    if [ -z "$num" ]; then
        echo ""
        return
    fi
    echo "$num" | awk '{printf "%\047d", $1}' 2>/dev/null || echo "$num"
}

# Function to get value from report file by line matching
get_value_by_name() {
    local file="$1"
    local name="$2"
    local column="$3"  # 2=Gas Used, 3=Storage Diff, 4=CPU Cycles

    # Escape special characters for grep
    local escaped_name=$(printf '%s\n' "$name" | sed 's/[][().*+?^${}|\\]/\\&/g')

    grep -E "^\| ${escaped_name} \|" "$file" 2>/dev/null | head -1 | awk -F'|' -v col="$column" '{
        gsub(/^[ \t]+|[ \t]+$/, "", $col)
        gsub(/,/, "", $col)
        print $col
    }'
}

# Function to find test file and line number for a test name
find_test_info() {
    local name="$1"

    # Search for PrintMetricsBy("$name" in metric_test files
    local result=$(grep -rn "PrintMetricsBy(\"${name}\"" "$METRIC_TEST_DIR" 2>/dev/null | head -1)

    if [ -n "$result" ]; then
        local file=$(echo "$result" | cut -d':' -f1)
        local line=$(echo "$result" | cut -d':' -f2)
        local relative_path=$(echo "$file" | sed "s|${PROJECT_ROOT}/||")

        # Return file:line:relative_path
        echo "${file}:${line}:${relative_path}"
    else
        echo ""
    fi
}

# Function to find package path from test file
find_pkg_path() {
    local name="$1"
    local test_info="$2"

    if [ -z "$test_info" ]; then
        echo ""
        return
    fi

    local file=$(echo "$test_info" | cut -d':' -f1)
    local line=$(echo "$test_info" | cut -d':' -f2)

    # Get next few lines after PrintMetricsBy to find function call (package.Function pattern)
    # Exclude lines with := (variable assignments) and testing.* calls to find the actual function call
    local func_call=$(sed -n "$((line+1)),$((line+15))p" "$file" | grep -v ':=' | grep -v 'testing\.' | grep -oE '[a-z][a-zA-Z0-9_]*\.[A-Za-z][a-zA-Z0-9_]*\(' | head -1 | sed 's/($//')

    if [ -z "$func_call" ]; then
        echo ""
        return
    fi

    local alias=$(echo "$func_call" | cut -d'.' -f1)

    # Find import for this alias - check both /r/ and /p/ paths
    # Pattern 1: "gno.land/r/gnoswap/pool" (alias is last segment, no version)
    # Pattern 2: "gno.land/r/gnoswap/router/v1" (alias before version)
    # Pattern 3: router "gno.land/r/gnoswap/router/v1" (explicit alias)
    local import_line=$(grep -E "(\"gno\.land/[rp]/[^\"]*/${alias}(/v[0-9]+)?\")|(\s${alias}\s+\"gno\.land/[rp]/)" "$file" | head -1)

    if [ -n "$import_line" ]; then
        # Extract the path from import and simplify (remove gnoswap prefix and version suffix)
        local pkg_path=$(echo "$import_line" | grep -oE 'gno\.land/[rp]/[^"]+' | sed 's|gno.land||' | sed 's|/gnoswap/|/|' | sed 's|/v[0-9]*$||')
        echo "$pkg_path"
    else
        echo ""
    fi
}

# Function to calculate percentage change
calc_percent() {
    local before="$1"
    local after="$2"

    if [ -z "$before" ] || [ -z "$after" ] || [ "$before" = "0" ]; then
        echo ""
        return
    fi

    awk -v b="$before" -v a="$after" 'BEGIN {
        diff = a - b
        pct = (diff / b) * 100
        if (diff < 0) {
            printf "%.2f%%", pct
        } else if (diff > 0) {
            printf "+%.2f%%", pct
        } else {
            printf "0.00%%"
        }
    }'
}

# Function to get commit date from gnoswap repo (format: YY.MM.DD)
get_commit_date() {
    local commit="$1"
    if [ -z "$commit" ]; then
        echo ""
        return
    fi
    local date=$(cd "$GNOSWAP_DIR" && git log -1 --format='%cs' "$commit" 2>/dev/null)
    if [ -n "$date" ]; then
        # Convert YYYY-MM-DD to YY.MM.DD
        echo "$date" | sed 's/^20\([0-9][0-9]\)-\([0-9][0-9]\)-\([0-9][0-9]\)$/\1.\2.\3/'
    else
        echo ""
    fi
}

# Read commit history into array
COMMITS=()
while IFS=: read -r hash desc; do
    COMMITS+=("${hash:0:7}")
done < "$COMMIT_HISTORY"

# Generate output
{
    echo "## Performance Report (Base: \`$BASE_COMMIT\`)"
    echo ""
    echo "| Pkg Path | Name | Gas Used (Before) | Storage Fee (Before) | Gas Used (After) | Storage Fee (After) | Date | Commit |"
    echo "|----------|------|-------------------|----------------------|------------------|---------------------|------|--------|"

    # Process each test from base report - extract all rows
    grep "^|" "$BASE_REPORT" | grep -v "^| Name" | grep -v "^|---" | while IFS= read -r line; do
        # Parse the line directly using awk
        parsed=$(echo "$line" | awk -F'|' '{
            gsub(/^[ \t]+|[ \t]+$/, "", $2)
            gsub(/^[ \t]+|[ \t]+$/, "", $3)
            gsub(/^[ \t]+|[ \t]+$/, "", $4)
            gsub(/,/, "", $3)
            gsub(/,/, "", $4)
            print $2 "\t" $3 "\t" $4
        }')

        name=$(echo "$parsed" | cut -f1)
        base_gas=$(echo "$parsed" | cut -f2)
        base_storage=$(echo "$parsed" | cut -f3)

        if [ -z "$name" ]; then
            continue
        fi

        # Initialize best values with base
        best_gas="$base_gas"
        best_gas_commit="$BASE_COMMIT"
        best_storage="$base_storage"
        best_storage_commit="$BASE_COMMIT"

        # Check each commit after base to find best values
        for i in "${!COMMITS[@]}"; do
            if [ "$i" -eq 0 ]; then
                continue  # Skip base commit
            fi

            commit="${COMMITS[$i]}"
            report="$COMMITS_DIR/${commit}.md"

            if [ -f "$report" ]; then
                current_gas=$(get_value_by_name "$report" "$name" 3)
                current_storage=$(get_value_by_name "$report" "$name" 4)

                # Check if gas is better (lower)
                if [ -n "$current_gas" ] && [ -n "$best_gas" ] && [ "$current_gas" -lt "$best_gas" ] 2>/dev/null; then
                    best_gas="$current_gas"
                    best_gas_commit="$commit"
                fi

                # Check if storage is better (lower)
                if [ -n "$current_storage" ] && [ -n "$best_storage" ] && [ "$current_storage" -lt "$best_storage" ] 2>/dev/null; then
                    best_storage="$current_storage"
                    best_storage_commit="$commit"
                fi
            fi
        done

        # Format numbers with commas
        base_gas_fmt=$(format_number "$base_gas")
        base_storage_fmt=$(format_number "$base_storage")

        # Only show After values if improved, otherwise leave empty
        if [ "$best_gas_commit" != "$BASE_COMMIT" ] && [ -n "$base_gas" ] && [ "$base_gas" != "0" ]; then
            best_gas_fmt=$(format_number "$best_gas")
            pct=$(calc_percent "$base_gas" "$best_gas")
            best_gas_fmt="$best_gas_fmt ($pct)"
        else
            best_gas_fmt=""
        fi

        if [ "$best_storage_commit" != "$BASE_COMMIT" ] && [ -n "$base_storage" ] && [ "$base_storage" != "0" ]; then
            best_storage_fmt=$(format_number "$best_storage")
            pct=$(calc_percent "$base_storage" "$best_storage")
            best_storage_fmt="$best_storage_fmt ($pct)"
        else
            best_storage_fmt=""
        fi

        # Determine which commit to show (prefer gas improvement, fallback to base)
        if [ "$best_gas_commit" != "$BASE_COMMIT" ]; then
            best_commit="$best_gas_commit"
        elif [ "$best_storage_commit" != "$BASE_COMMIT" ]; then
            best_commit="$best_storage_commit"
        else
            best_commit="$BASE_COMMIT"
        fi
        commit_link="[\`$best_commit\`](https://github.com/gnoswap-labs/gnoswap/commit/$best_commit)"

        # Get commit date
        commit_date=$(get_commit_date "$best_commit")

        # Get test file info and package path
        test_info=$(find_test_info "$name")
        pkg_path=$(find_pkg_path "$name" "$test_info")

        if [ -n "$test_info" ]; then
            relative_path=$(echo "$test_info" | cut -d':' -f3)
            test_line=$(echo "$test_info" | cut -d':' -f2)
            test_link="${GITHUB_REPO}/blob/${BRANCH}/${relative_path}#L${test_line}"
            name_with_link="[$name]($test_link)"
        else
            name_with_link="$name"
        fi

        echo "| $pkg_path | $name_with_link | $base_gas_fmt | $base_storage_fmt | $best_gas_fmt | $best_storage_fmt | $commit_date | $commit_link |"
    done
} | tee "$OUTPUT_FILE"

echo ""
echo "Report saved to: $OUTPUT_FILE" >&2
