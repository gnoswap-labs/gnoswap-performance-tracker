// Pattern: many-parameter function call (Call + 53/param)
// Bad: f(a, b, c, d, e, f, g, h)
// Good: bundle related args into a struct and pass the struct
package main

import "gno.land/r/gnoswap/scenario/gaspatterns"

const N = 1000

type args struct {
	a, b, c, d, e, f, g, h int64
}

func sumMany(a, b, c, d, e, f, g, h int64) int64 {
	return a + b + c + d + e + f + g + h
}

func sumStruct(x args) int64 {
	return x.a + x.b + x.c + x.d + x.e + x.f + x.g + x.h
}

var sink int64

func main() {
	gaspatterns.PrintMetricsBy("many params (bad)", func() {
		var s int64
		for i := int64(0); i < int64(N); i++ {
			s += sumMany(i, i+1, i+2, i+3, i+4, i+5, i+6, i+7)
		}
		sink += s
	})
	gaspatterns.PrintMetricsBy("struct param (good)", func() {
		var s int64
		for i := int64(0); i < int64(N); i++ {
			s += sumStruct(args{a: i, b: i + 1, c: i + 2, d: i + 3, e: i + 4, f: i + 5, g: i + 6, h: i + 7})
		}
		sink += s
	})
}
