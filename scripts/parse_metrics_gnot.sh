#!/bin/bash
#
# Parse gno test metric output and convert to markdown table.
#
# Usage:
#   gno test . -v -run . 2>&1 | ./parse_metrics.sh
#   ./parse_metrics.sh < output.txt
#   ./parse_metrics.sh output.txt

input="${1:-/dev/stdin}"

# Print table header
echo "| Name | Gas Used (GNOT) | Storage Diff (GNOT) | CPU Cycles |"
echo "|------|----------|--------------|------------|"

awk '
function format_number(num) {
    # Add comma separators; support floats after scaling (e.g. / 1_000_000).
    result = ""
    sign = ""
    if (num < 0) {
        sign = "-"
        num = -num
    }

    if (num == int(num)) {
        str = sprintf("%d", int(num))
        len = length(str)
        for (i = 1; i <= len; i++) {
            if (i > 1 && (len - i + 1) % 3 == 0) {
                result = result ","
            }
            result = result substr(str, i, 1)
        }
        return sign result
    }

    # Keep 6 decimals (since we divide by 1_000_000), trim trailing zeros.
    s = sprintf("%.6f", num)
    split(s, parts, ".")
    intp = parts[1]
    decp = parts[2]

    while (decp ~ /0$/) {
        decp = substr(decp, 1, length(decp) - 1)
        if (decp == "") break
    }

    # Add commas to integer part
    str = intp
    len = length(str)
    for (i = 1; i <= len; i++) {
        if (i > 1 && (len - i + 1) % 3 == 0) {
            result = result ","
        }
        result = result substr(str, i, 1)
    }

    if (decp != "") return sign result "." decp
    return sign result
}

# Skip lines after "unexpected output:" until next test
/unexpected output:/ {
    skip_duplicate = 1
    next
}

# Reset skip flag on new test run
/^=== RUN/ {
    skip_duplicate = 0
    next
}

# Skip if in duplicate section
skip_duplicate { next }

!/^[[:space:]]*$/ {
    if (/^- Gas Used:/) {
        # First scale is integer (truncation), final /1_000_000 keeps decimals.
        gas = (int($NF / 1000)) / 1000000
    } else if (/^- Storage Diff:/) {
        storage = (int($NF * 100)) / 1000000
    } else if (/^- CPU Cycles:/) {
        cpu = $NF
        # Print entry only if not already printed
        if (name != "" && !printed[name]) {
            printf "| %s | %s | %s | %s |\n", name, format_number(gas), format_number(storage), format_number(cpu)
            printed[name] = 1
        }
    } else if (!/^-/) {
        # This is a name line
        name = $0
    }
}
' "$input"

