#!/bin/bash

set -euo pipefail

input="${1:-/dev/stdin}"

tmp_input=$(mktemp)
trap 'rm -f "$tmp_input"' EXIT
cat "$input" > "$tmp_input"

echo "# Research Report"
echo ""
milestones=$(awk -F'\t' '
/^[[:space:]]*#/ { next }
/^[[:space:]]*$/ { next }
NF >= 1 {
    name = $1
    n = name
    sub(/^.*\(n=/, "", n)
    sub(/\).*$/, "", n)
    if (n ~ /^[0-9]+$/) {
        if (!seen[n]++) {
            values[++count] = n
        }
    }
}
END {
    for (i = 1; i <= count; i++) {
        printf "%s%s", values[i], (i < count ? ", " : "")
    }
}
' "$tmp_input")

printf '%s\n' '- Milestones: `'"$milestones"'`'
printf '%s\n' "- Measurement: average and quartiles over samples collected within each checkpoint window"
echo ""
echo "## PoolCreate"
echo ""
echo "| Action | N | Samples | Gas (avg) | Q1 | Q3 | Storage (avg) | Q1 | Q3 | GNO (avg) |"
echo "|--------|---|---------|-----------|----|----|---------------|----|----|-----------|"

awk -F'\t' '
function format_number(num,    result, sign, str, len, i) {
    result = ""
    sign = ""
    if (num == "-" || num == "") {
        return "-"
    }
    if (num < 0) {
        sign = "-"
        num = -num
    }
    str = sprintf("%d", num)
    len = length(str)
    for (i = 1; i <= len; i++) {
        if (i > 1 && (len - i + 1) % 3 == 0) {
            result = result ","
        }
        result = result substr(str, i, 1)
    }
    return sign result
}

/^[[:space:]]*#/ { next }
/^[[:space:]]*$/ { next }

NF >= 18 {
    name = $1
    gas = $2
    storage = $3
    samples = $5
    gas_q1 = $6
    gas_q3 = $7
    storage_q1 = $10
    storage_q3 = $11
    cost_avg = $14

    gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", gas)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", storage)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", samples)

    if (name == "" || name == "ok") {
        next
    }

    action = name
    sub(/^research /, "", action)
    n = action
    sub(/^.*\(n=/, "", n)
    sub(/\).*$/, "", n)
    sub(/ \(n=[0-9]+\)$/, "", action)

    printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n", action, n, samples, format_number(gas), format_number(gas_q1), format_number(gas_q3), format_number(storage), format_number(storage_q1), format_number(storage_q3), format_number(cost_avg)
}
' "$tmp_input"

awk -F'\t' '
function format_number(num,    result, sign, str, len, i) {
    result = ""
    sign = ""
    if (num == "-" || num == "") {
        return "-"
    }
    if (num < 0) {
        sign = "-"
        num = -num
    }
    str = sprintf("%d", num)
    len = length(str)
    for (i = 1; i <= len; i++) {
        if (i > 1 && (len - i + 1) % 3 == 0) {
            result = result ","
        }
        result = result substr(str, i, 1)
    }
    return sign result
}

/^[[:space:]]*#/ { next }
/^[[:space:]]*$/ { next }

NF >= 18 {
    name = $1
    if (name == "" || name == "ok") {
        next
    }
    sample = $5
    gas_q1 = $6
    gas_q3 = $7
    gas_min = $8
    gas_max = $9
    storage_q1 = $10
    storage_q3 = $11
    storage_min = $12
    storage_max = $13
    cost_avg = $14
    cost_q1 = $15
    cost_q3 = $16
    cost_min = $17
    cost_max = $18

    print ""
    print "> " name " measured over " sample " sample(s)."
    print ""
    print "- Gas min/max: `" format_number(gas_min) "` / `" format_number(gas_max) "`"
    print "- Storage min/max: `" format_number(storage_min) "` / `" format_number(storage_max) "`"
    print "- GNO min/max: `" format_number(cost_min) "` / `" format_number(cost_max) "` ugnot"
}
' "$tmp_input"
