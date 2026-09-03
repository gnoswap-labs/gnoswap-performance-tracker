# Oracle observation cardinality metrics

This report compares the map-backed oracle surface at GnoSwap PR #1408
(`23182091`) with the sparse `ObservationTree` implementation at PR #1427
(`f6e38d42`). All fixtures ran with tracker Gno `bac78a97`.

Each steady-state metric measures either an in-range `IncreaseLiquidity` that
writes an oracle observation or a direct `GetObservationAt` of the current
observation index. Pool creation, capacity reservation, and index resolution
are outside those metric blocks.

## Steady-state paths

| Operation | Map-backed oracle | Sparse ObservationTree | Change |
| --- | ---: | ---: | ---: |
| Oracle write, cardinality 1 | 24,110,782 gas | 24,392,858 gas | +1.17% |
| Oracle write, cardinality 1,024 | 24,906,946 gas | 24,491,064 gas | -1.67% |
| Cardinality 1 → 1,024 write growth | +796,164 gas | +98,206 gas | 87.66% less growth |
| Current observation read, cardinality 1 | 112,302 gas | 187,441 gas | +66.91% |
| Current observation read, cardinality 1,024 | 112,547 gas | 191,155 gas | +69.84% |
| Oracle write, cardinality 65,535 | 25,741,843 gas | 25,504,475 gas | -0.92% |
| Current observation read, cardinality 65,535 | 258,731 gas | 186,940 gas | -27.75% |

The tree has a fixed traversal cost, so direct reads are more expensive at
small cardinalities. In contrast, the map-backed pool object becomes more
expensive to load as the observation buffer grows; at cardinality 65,535 the
sparse tree is cheaper for the current-observation read.

## Maximum-capacity reservation

The `65,535` fixture reserves `observationCardinalityNext` at the supported
maximum before the metric blocks execute. The completed isolated fixtures show:

| Setup effect | Map-backed oracle | Sparse ObservationTree | Change |
| --- | ---: | ---: | ---: |
| Fixture gas | 17,350,167,796 | 69,126,687 | -99.60% |
| Pool storage delta | +96,314,438 B | +37,246 B | -99.96% |

The map implementation writes 65,534 uninitialized placeholder observations
while reserving capacity. `ObservationTree` represents an uninitialized,
in-range index by an absent key and creates its entry only when
`writeObservation` reaches that index. This removes the reservation-time
storage growth without changing the public zero-observation behavior for an
in-range, unwritten index.

Wall-clock duration is deliberately omitted: it is host-dependent and the map
maximum-capacity setup dominates it. Gas, storage, and the two scoped
steady-state operations are the comparison metrics.
