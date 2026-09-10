# Value-storage attribution: launch

Four retained Tier/Manager numeric fields are isolated from the per-user price debt. Each run measures one project creation, all 256 deposits, 111 paid claims, all 256 withdrawals and the final project refund. The active reward tree, active debt and staked GNS end at zero; archived Deposit metadata and project state remain. The selected tier lasts 30 days; project settlement is observed through its 180-day end.

Baseline: `b12f0f8760a3e88e9539b0c8cfd32b38a5297c68`. Runtime: `bac78a97b20e12ba471bdd73a41af31bd94bdc12`.

Delta = candidate minus baseline. Negative GNOT is lower modeled net outflow. Each row is a separate candidate on the same workload; **do not add rows**.

| Candidate | Baseline gas | Candidate gas | Gas delta | Gas % | Net storage delta B | CPU cycles delta | Storage delta GNOT | Fee delta GNOT | Total delta GNOT | 10% buffered total GNOT |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Tier + Manager (four retained numeric fields) | 3,860,442,640 | 3,885,647,527 | +25,204,887 | +0.6529% | -4,465 | +24,096,520 | -0.446500 | +0.025223 | **-0.421277** | -0.418774 |
| User reward debt | 3,860,442,640 | 3,867,752,193 | +7,309,553 | +0.1893% | -38 | +6,708,189 | -0.003800 | +0.007304 | **+0.003504** | +0.004252 |
| Combined value candidate | 3,860,442,640 | 3,892,958,181 | +32,515,541 | +0.8423% | -4,505 | +30,804,709 | -0.450500 | +0.032521 | **-0.417979** | -0.414736 |

## Decision guidance
- For total-cost reduction at the stated tariff, prefer **the four retained fields only**: **0.421277 GNOT** saving. Adding user debt makes the identical combined lifecycle **0.003298 GNOT more expensive** than retained-only (direct combined-versus-retained comparison).
- Debt-only costs **0.003504 GNOT** after all exits, but reduces peak locked capital by **9.312100 GNOT**. Decide this separately as an upfront-capital policy, not a fee optimization.
- The retained-only saving tolerates **14,526 additional claims** of the measured shape, at the worst observed 29 ugnot extra per claim. This is a same-tariff extrapolation, not a benchmark at that count.
- At this workload, the retained-only linear fee-price crossover is about **17.714819 ugnot/1000 gas** (before per-window integer rounding). Under a 143 ugnot/1000 sensitivity tariff, it is not a cost improvement. Do not assume today's low tariff forever.
- Five combined inline values and binary encodings of those same fields are alternative representations, not additive savings. Project/Deposit root conversions are a distinct layer and are not included here. The four retained fields are still a chosen group, not a claim of four independent field savings.

## Locked-capital tradeoff

| Candidate | Peak less locked GNOT | Observed capital saving GNOT-days | Extra end cost GNOT | Break-even simple annual opportunity cost |
|---|---:|---:|---:|---:|
| User reward debt | 9.312100 | 279.932989 | +0.003504 | 0.456881% |

The annual rate is a calculated threshold, **not an assumed investment return**. It integrates actual fixture timestamps and modeled deposit cashflow; no time after the fixture is extrapolated. Different actors/realms are aggregated explicitly. Favorable upfront capital alone does not prove lower lifetime fees.

## Verification and reproduction

```sh
make init
make compare-metric-force 5e03b62bc5c4bd983ab3b17396655427b1a9b616 0d20572f0275665ede9f97e574e1cd4f6317c66f 3b5bc592bec2164f4bc1331eb7406e9e47db7056 b12f0f8760a3e88e9539b0c8cfd32b38a5297c68
```

The full standard suite was regenerated for all candidates and baseline, then replayed without golden updates. All fixture hashes and emitted STATE values match; raw per-realm deltas sum to the measured net bytes. New isolated Staker candidates passed both Staker packages; new isolated Launchpad candidates passed Launchpad, v1 and the changed upgrade-v3 package. Existing immutable candidates were exercised in this fresh paired suite without unnecessarily repeating their previously reported unit checks.

### Immutable candidates
- Tier + Manager (four retained numeric fields): [`0d20572f0275665ede9f97e574e1cd4f6317c66f`](https://github.com/gnoswap-labs/gnoswap/commit/0d20572f0275665ede9f97e574e1cd4f6317c66f); [per-window evidence](0d20572f_b12f0f87.tsv).
- User reward debt: [`3b5bc592bec2164f4bc1331eb7406e9e47db7056`](https://github.com/gnoswap-labs/gnoswap/commit/3b5bc592bec2164f4bc1331eb7406e9e47db7056); [per-window evidence](3b5bc592_b12f0f87.tsv).
- Combined value candidate: [`5e03b62bc5c4bd983ab3b17396655427b1a9b616`](https://github.com/gnoswap-labs/gnoswap/commit/5e03b62bc5c4bd983ab3b17396655427b1a9b616); [per-window evidence](5e03b62b_b12f0f87.tsv).
- [Direct debt increment on retained-only](5e03b62b_0d20572f.tsv).

## Accounting, compatibility and scope

- [Pricing provenance](pricing.json): Pearl height 334227, observed 1 ugnot/1000 gas and 100 ugnot/byte; restricted-denom list empty.
- Local fresh-state storage is priced **per realm** at a uniform assumed charge/refund ratio of 100 ugnot/byte. These are net realm storage measurements, not observed bank transfers or peak runtime allocation.
- Fee model: `ceil(gas/1000)` per measured public-call window. Buffered model: `ceil(floor(gas*1.1)/1000)`. SDK/transaction estimation overhead is excluded. Keeping the same valid fixed submitted GasFee makes monetary gas delta zero.
- Standalone queries pay no transaction fee; their metered resource regressions remain disclosed.
- Values preserve numeric/API results in tested fresh-state workflows but change persistent representation. Existing typed objects require migration; no compatibility bridge or deployment was attempted. No Contract PR, merge or deployment was performed.
- Original selected-window results are historical evidence at tracker commit `0448e902419dd07b742b36a1827367fa464c05d2`; they are not the full exit lifecycle reported here.
