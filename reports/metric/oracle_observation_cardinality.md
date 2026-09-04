# Oracle observation cardinality metrics

This report compares the map-backed oracle buffer at GnoSwap PR #1408
(`23182091`) with the store-backed `ObservationTree` implementation at PR
#1427 (`9600b2f`). Both fixtures ran with tracker Gno `bac78a97`.

The earlier sparse-tree result is intentionally superseded. PR #1427 now
preserves the Uniswap `Oracle.grow` cost boundary: increasing
`observationCardinalityNext` writes uninitialized placeholders immediately,
so the caller that reserves capacity pays the allocation cost rather than a
later swapper.

## Steady-state paths

Each metric below measures an in-range `IncreaseLiquidity` that writes an
oracle observation or a direct `GetObservationAt` of the resolved current
index. Pool creation, capacity reservation, and index resolution are outside
these blocks.

| Operation | Map-backed oracle | ObservationTree | Change |
| --- | ---: | ---: | ---: |
| Oracle write, cardinality 1 | 24,128,659 gas | 24,386,975 gas | +1.07% |
| Oracle write, cardinality 1,024 | 24,924,823 gas | 24,529,487 gas | -1.59% |
| Current observation read, cardinality 1 | 112,302 gas | 189,602 gas | +68.83% |
| Current observation read, cardinality 1,024 | 112,547 gas | 237,207 gas | +110.76% |

`ObservationTree` adds B+tree traversal to a current-observation read, so it
is not a small-cardinality read optimization. Its purpose is to keep the
oracle buffer out of ordinary `Pool` state; the write path is comparable and
is slightly cheaper at cardinality 1,024 in this fixture.

## Initialized tick-cross swap

This fixture measures the swap path that matters for oracle tick crossing,
rather than an isolated getter or position update. It compares main after
PR #1408 (`268fe17f6a2d3766a41b85818c2c2a0ecdb1a13a`) with PR #1427
(`4f2d650c2f184d16a09624efcd55acbba8687833`) using tracker Gno
`bac78a97`.

Each case creates a fee-tier `500` pool at tick `0`, adds full-range liquidity
and an initialized `[-100, 100]` position, then performs the same exact-input
swap of `100,000,000`. The fixture asserts that the resulting tick is above
`100`, so `tickCross` and its oracle read execute. Capacity reservation,
pool creation, and minting are outside the metric block. Cardinality `1` and
`1,024` use separate token pairs with otherwise identical parameters.

| Operation | Map-backed oracle | ObservationTree | Change |
| --- | ---: | ---: | ---: |
| Swap crossing initialized tick, cardinality 1 | 54,517,302 gas | 54,732,539 gas | +0.39% |
| Swap crossing initialized tick, cardinality 1,024 | 53,720,735 gas | 53,281,812 gas | -0.82% |

The tree refactor therefore leaves the direct tick-cross swap path effectively
flat: a small-cardinality overhead is offset by a small improvement once the
larger observation capacity is active. This is a full swap result, not a
claim about `IncreaseObservationCardinalityNext` reservation cost.

## Maximum-cardinality check

The `65,535` fixture is retained as a functional scale check, not as the
headline performance metric. With physical placeholder allocation restored,
PR #1427 records:

| Operation | ObservationTree |
| --- | ---: |
| Oracle write, cardinality 65,535 | 25,660,864 gas |
| Current observation read, cardinality 65,535 | 260,892 gas |

The cost of `IncreaseObservationCardinalityNext(1, 65,535)` is deliberately
not treated as a steady-state metric. It is an upfront reservation cost by
design and belongs to the permissionless caller that requests the capacity.
