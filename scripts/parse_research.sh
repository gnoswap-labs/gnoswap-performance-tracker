#!/bin/bash

set -euo pipefail

input="${1:-/dev/stdin}"

tmp_input=$(mktemp)
trap 'rm -f "$tmp_input"' EXIT
cat "$input" > "$tmp_input"

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

echo "# 컨트랙트 수수료 측정 결과"
echo ""
printf '%s\n' "마일스톤: N = $milestones"
printf '%s\n' "측정: 마일스톤 구간(window) 실행 결과 평균 + Q1/Q3"
printf '%s\n' "수수료: Total Fee (avg) = 각 구간의 평균 total tx cost"
echo ""
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

function domain_order(domain) {
    if (domain == "Pool") return 1
    if (domain == "Router") return 2
    if (domain == "Position") return 3
    if (domain == "Staker") return 4
    return 9
}

function action_domain(action) {
    if (action ~ /^Pool/) return "Pool"
    if (action ~ /^Router/) return "Router"
    if (action ~ /^Position/) return "Position"
    if (action ~ /^Staker/) return "Staker"
    return "Other"
}

/^[[:space:]]*#/ { next }
/^[[:space:]]*$/ { next }

NF >= 18 {
    name = $1
    gas = $2
    storage = $3
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

    domain = action_domain(action)
    row = "| " action " | " n " | " format_number(gas) " | " format_number(gas_q1) " | " format_number(gas_q3) " | " format_number(storage) " | " format_number(storage_q1) " | " format_number(storage_q3) " | " format_number(cost_avg) " |"
    count[domain]++
    rows[domain, count[domain]] = row
    seen[domain] = 1
}

END {
    domains[1] = "Pool"
    domains[2] = "Router"
    domains[3] = "Position"
    domains[4] = "Staker"
    domains[5] = "Other"

    for (d = 1; d <= 5; d++) {
        domain = domains[d]
        if (!seen[domain]) continue
        print "## " domain
        print ""
        print "| Action | N | Gas (avg) | Q1 | Q3 | Storage (avg) | Q1 | Q3 | Total Fee (avg) |"
        print "|--------|---|-----------|----|----|---------------|----|----|------------------|"
        for (i = 1; i <= count[domain]; i++) {
            print rows[domain, i]
        }
        print ""
    }
}
' "$tmp_input"
