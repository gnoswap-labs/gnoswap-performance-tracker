// Pattern: type switch case order (TypeSwitch + 254/clause)
// Bad: rare case declared first; frequent case last
// Good: frequent case first
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

type rareA struct{}
type rareB struct{}
type rareC struct{}
type frequent struct{ v int64 }

var sink int64

func classifyBad(x interface{}) int64 {
	switch v := x.(type) {
	case rareA:
		_ = v
		return 1
	case rareB:
		_ = v
		return 2
	case rareC:
		_ = v
		return 3
	case frequent:
		return v.v
	}
	return 0
}

func classifyGood(x interface{}) int64 {
	switch v := x.(type) {
	case frequent:
		return v.v
	case rareA:
		_ = v
		return 1
	case rareB:
		_ = v
		return 2
	case rareC:
		_ = v
		return 3
	}
	return 0
}

func main() {
	items := make([]interface{}, N)
	for i := range items {
		items[i] = frequent{v: int64(i)}
	}

	gaspatterns.PrintMetricsBy("type switch order (bad)", func() {
		var s int64
		for _, it := range items {
			s += classifyBad(it)
		}
		sink += s
	})
	gaspatterns.PrintMetricsBy("type switch order (good)", func() {
		var s int64
		for _, it := range items {
			s += classifyGood(it)
		}
		sink += s
	})
}
