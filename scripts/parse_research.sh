#!/bin/bash

set -euo pipefail

input="${1:-/dev/stdin}"

echo "| Name | Gas Used | Storage Diff | CPU Cycles |"
echo "|------|----------|--------------|------------|"

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

NF >= 3 {
    name = $1
    gas = $2
    storage = $3
    cpu = (NF >= 4 && $4 != "") ? $4 : "-"

    gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", gas)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", storage)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", cpu)

    printf "| %s | %s | %s | %s |\n", name, format_number(gas), format_number(storage), format_number(cpu)
}
' "$input"
