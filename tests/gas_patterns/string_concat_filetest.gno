// Pattern: string concatenation in loop (AddString 18 -> 186)
// Bad: out += s each iteration (O(n^2))
// Good: collect slice, join once
package main

import (
	"strings"

	"gno.land/r/gnoswap/scenario/gaspatterns"
)

const N = 200

var sinkStr string

func main() {
	parts := make([]string, N)
	for i := range parts {
		parts[i] = "abc"
	}

	gaspatterns.PrintMetricsBy("string concat loop (bad)", func() {
		var out string
		for _, p := range parts {
			out += p
		}
		sinkStr = out
	})
	gaspatterns.PrintMetricsBy("string concat loop (good)", func() {
		sinkStr = strings.Join(parts, "")
	})
}
