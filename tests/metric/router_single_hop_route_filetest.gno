// Gas and performance metrics for r/gnoswap/router package
package main

import (
	"testing"

	router "gno.land/r/gnoswap/router/v1"
	"gno.land/r/gnoswap/scenario/metric"
)

var t *testing.T

func main() {
	BuildSingleHopRoutePath()
}

// Router Package Functions

func BuildSingleHopRoutePath() {
	metric.PrintMetricsBy("BuildSingleHopRoutePath", func() {
		router.BuildSingleHopRoutePath(
			"gno.land/r/demo/wugnot",
			"gno.land/r/demo/usdc",
			500,
		)
	})
}
