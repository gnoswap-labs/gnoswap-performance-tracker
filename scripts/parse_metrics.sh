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
echo "| Name | Gas Used | Storage Diff | CPU Cycles |"
echo "|------|----------|--------------|------------|"

awk '
function normalize(line) {
    sub(/\r$/, "", line)
    if (line ~ /^[[:space:]]*\/\/[[:space:]]?/) {
        sub(/^[[:space:]]*\/\/[[:space:]]?/, "", line)
        from_comment = 1
    } else {
        from_comment = 0
    }
    return line
}

function format_number(num) {
    # Add comma separators
    result = ""
    sign = ""
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
    line = normalize($0)

    if (from_comment && line == "Output:") {
        in_output = 1
        next
    }

    if (from_comment && !in_output) {
        next
    }

    if (line ~ /^- Gas Used:/) {
        split(line, parts, " ")
        gas = parts[length(parts)]
    } else if (line ~ /^- Storage Diff:/) {
        split(line, parts, " ")
        storage = parts[length(parts)]
    } else if (line ~ /^- CPU Cycles:/) {
        split(line, parts, " ")
        cpu = parts[length(parts)]
        # Print entry only if not already printed
        if (name != "" && !printed[name]) {
            printf "| %s | %s | %s | %s |\n", name, format_number(gas), format_number(storage), format_number(cpu)
            printed[name] = 1
        }
    } else if (line !~ /^-/) {
        # This is a name line
        name = line
    }
}
' "$input"
