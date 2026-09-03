# Oracle observation maximum-cardinality metric

Measured with tracker Gno `bac78a97` using the same isolated filetest fixture
against the map-backed oracle surface and the sparse `ObservationTree` update.
The fixture reserves `observationCardinalityNext = 65535`, then measures an
in-range position update and a direct current-observation lookup. Reservation
is intentionally outside the two metric blocks.

| Operation | Map-backed oracle | Sparse ObservationTree | Change |
| --- | ---: | ---: | ---: |
| Max reservation fixture runtime | 22.73s | 0.05s | -99.8% |
| Max reservation setup gas | 17,350,167,796 | 69,126,483 | -99.60% |
| Max reservation pool storage | +96,314,438 B | +37,246 B | -99.96% |
| Oracle write at cardinality 65,535 | 25,741,843 | 25,504,475 | -0.92% |
| Current observation read at cardinality 65,535 | 258,731 | 186,940 | -27.75% |

The map implementation writes 65,534 uninitialized placeholders during
reservation. The sparse tree does not: absent in-range keys represent
uninitialized observations, and an entry is created only by an oracle write.
