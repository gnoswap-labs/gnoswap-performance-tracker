# Value-storage attribution: staker

Four independent numeric-field changes plus their original combination. Each run stakes all 33 positions, exercises signed crossings, makes 111 repeated paid external claims, ends the incentive, and unstakes every position. Final assertions require zero addressable deposits, zero active reward entitlements, zero tick objects and zero staked liquidity. Retired history and incentive records remain.

Baseline: `b12f0f8760a3e88e9539b0c8cfd32b38a5297c68`. Runtime: `bac78a97b20e12ba471bdd73a41af31bd94bdc12`.

Delta = candidate minus baseline. Negative GNOT is lower modeled net outflow. Each row is a separate candidate on the same workload; **do not add rows**.

| Candidate | Baseline gas | Candidate gas | Gas delta | Gas % | Net storage delta B | CPU cycles delta | Storage delta GNOT | Fee delta GNOT | Total delta GNOT | 10% buffered total GNOT |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Deposit liquidity | 4,254,569,896 | 4,257,315,821 | +2,745,925 | +0.0645% | +0 | +2,423,764 | +0.000000 | +0.002759 | **+0.002759** | +0.003028 |
| Tick gross liquidity | 4,254,569,896 | 4,256,312,181 | +1,742,285 | +0.0410% | +0 | +1,607,986 | +0.000000 | +0.001745 | **+0.001745** | +0.001921 |
| Tick signed liquidity delta | 4,254,569,896 | 4,255,544,593 | +974,697 | +0.0229% | +0 | +1,222,166 | +0.000000 | +0.000976 | **+0.000976** | +0.001080 |
| External incentive rate | 4,254,569,896 | 4,255,444,273 | +874,377 | +0.0206% | -364 | +765,878 | -0.036400 | +0.000884 | **-0.035516** | -0.035432 |
| Combined value candidate | 4,254,569,896 | 4,260,907,785 | +6,337,889 | +0.1490% | -364 | +6,019,794 | -0.036400 | +0.006344 | **-0.030056** | -0.029426 |

## Decision guidance
- For total-cost reduction, select the incentive-rate change alone. Its end-of-lifecycle saving is **0.035516 GNOT**, versus only **0.030056 GNOT** for all four fields.
- Deposit, gross and signed-delta value storage each finish with **zero net storage advantage** after every position exits. Their extra fees are the cost of reducing locked capital while stakes exist, not permanent storage savings.
- The repeat sample has 111 paid external claims. At the same per-call shape and 1 ugnot/1000 gas, the incentive-only saving tolerates **5,919 additional claims** using the observed worst-case 6 ugnot increment. This is a modeled extension before incentive closure, not another 5,919-call benchmark.
- The incentive-only linear fee-price crossover for this complete workload is approximately **41.629640 ugnot/1000 gas**, before integer rounding. At the separate 143 ugnot/1000 sensitivity tariff it costs **0.088641 GNOT more**. The observed 1 ugnot tariff is not a permanent guarantee.
- Whole-Deposit object value storage and numeric-field value storage change different layers. They may compose semantically, but no savings may be added across those PoCs. Binary encoding and inline numeric values for the same field are mutually exclusive alternatives. History codecs target other fields.

## Locked-capital tradeoff

| Candidate | Peak less locked GNOT | Observed capital saving GNOT-days | Extra end cost GNOT | Break-even simple annual opportunity cost |
|---|---:|---:|---:|---:|
| Deposit liquidity | 1.183800 | 107.749298 | +0.002759 | 0.934609% |
| Tick gross liquidity | 1.277800 | 116.305229 | +0.001745 | 0.547632% |
| Tick signed liquidity delta | 1.290000 | 117.415613 | +0.000976 | 0.303401% |

The annual rate is a calculated threshold, **not an assumed investment return**. It integrates actual fixture timestamps and modeled deposit cashflow; no time after the fixture is extrapolated. Different actors/realms are aggregated explicitly. Favorable upfront capital alone does not prove lower lifetime fees.

## Verification and reproduction

```sh
make init
make compare-metric-force cc1dacdb86b6cbfcc6ea215626a336ff83bb3b0d 27df6c6f44785a645c594cf263d8a4471d1013f1 97e45b8578003de3a2f190599d3b7fa5655c3b85 e0c5473c2907c9fb4436c5a66601fbe730045939 0bee3ad1b436a2d858f69d730d79b0cfc6be9558 b12f0f8760a3e88e9539b0c8cfd32b38a5297c68
```

The full standard suite was regenerated for all candidates and baseline, then replayed without golden updates. All fixture hashes and emitted STATE values match; raw per-realm deltas sum to the measured net bytes. New isolated Staker candidates passed both Staker packages; new isolated Launchpad candidates passed Launchpad, v1 and the changed upgrade-v3 package. Existing immutable candidates were exercised in this fresh paired suite without unnecessarily repeating their previously reported unit checks.

### Immutable candidates
- Deposit liquidity: [`27df6c6f44785a645c594cf263d8a4471d1013f1`](https://github.com/gnoswap-labs/gnoswap/commit/27df6c6f44785a645c594cf263d8a4471d1013f1); [per-window evidence](27df6c6f_b12f0f87.tsv).
- Tick gross liquidity: [`97e45b8578003de3a2f190599d3b7fa5655c3b85`](https://github.com/gnoswap-labs/gnoswap/commit/97e45b8578003de3a2f190599d3b7fa5655c3b85); [per-window evidence](97e45b85_b12f0f87.tsv).
- Tick signed liquidity delta: [`e0c5473c2907c9fb4436c5a66601fbe730045939`](https://github.com/gnoswap-labs/gnoswap/commit/e0c5473c2907c9fb4436c5a66601fbe730045939); [per-window evidence](e0c5473c_b12f0f87.tsv).
- External incentive rate: [`0bee3ad1b436a2d858f69d730d79b0cfc6be9558`](https://github.com/gnoswap-labs/gnoswap/commit/0bee3ad1b436a2d858f69d730d79b0cfc6be9558); [per-window evidence](0bee3ad1_b12f0f87.tsv).
- Combined value candidate: [`cc1dacdb86b6cbfcc6ea215626a336ff83bb3b0d`](https://github.com/gnoswap-labs/gnoswap/commit/cc1dacdb86b6cbfcc6ea215626a336ff83bb3b0d); [per-window evidence](cc1dacdb_b12f0f87.tsv).

## Accounting, compatibility and scope

- [Pricing provenance](pricing.json): Pearl height 334227, observed 1 ugnot/1000 gas and 100 ugnot/byte; restricted-denom list empty.
- Local fresh-state storage is priced **per realm** at a uniform assumed charge/refund ratio of 100 ugnot/byte. These are net realm storage measurements, not observed bank transfers or peak runtime allocation.
- Fee model: `ceil(gas/1000)` per measured public-call window. Buffered model: `ceil(floor(gas*1.1)/1000)`. SDK/transaction estimation overhead is excluded. Keeping the same valid fixed submitted GasFee makes monetary gas delta zero.
- Standalone queries pay no transaction fee; their metered resource regressions remain disclosed.
- Values preserve numeric/API results in tested fresh-state workflows but change persistent representation. Existing typed objects require migration; no compatibility bridge or deployment was attempted. No Contract PR, merge or deployment was performed.
- Original selected-window results are historical evidence at tracker commit `0a9af0ed054701a0e676b2a70d38b9fcb0237384`; they are not the full exit lifecycle reported here.
