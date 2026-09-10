# Value-storage attribution: proposal

The identical expanded workload is run against original pointers, value roots only and value roots plus inline metadata. It creates/votes 128 text proposals individually, then exercises 8KiB text/spend and parameter-change paths (131 proposals total). Root/nested/list query resource samples are kept separate from 263 paid-call windows. Passed/executed/canceled proposal history remains stored.

Baseline: `b12f0f8760a3e88e9539b0c8cfd32b38a5297c68`. Runtime: `bac78a97b20e12ba471bdd73a41af31bd94bdc12`.

Delta = candidate minus baseline. Negative GNOT is lower modeled net outflow. Each row is a separate candidate on the same workload; **do not add rows**.

| Candidate | Baseline gas | Candidate gas | Gas delta | Gas % | Net storage delta B | CPU cycles delta | Storage delta GNOT | Fee delta GNOT | Total delta GNOT | 10% buffered total GNOT |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Proposal value root only | 463,066,301 | 503,933,013 | +40,866,712 | +8.8252% | -58,186 | +35,306,126 | -5.818600 | +0.040880 | **-5.777720** | -5.773650 |
| Combined value candidate | 463,066,301 | 504,178,073 | +41,111,772 | +8.8782% | -108,363 | +35,549,539 | -10.836300 | +0.041112 | **-10.795188** | -10.791075 |

## Decision guidance
- Root-only saves **5.777720 GNOT**; root+inline metadata saves **10.795188 GNOT**, excluding free-query gas from paid fees.
- The direct inline-metadata increment saves another **5.017468 GNOT**. Nested query gas is **1.618780% lower** than root-only, not higher. It is incorrect to blame the combined candidate's query regression on metadata inlining alone.
- Relative to original pointers, the 128-proposal nested-read sample still grows **38.407858%** in gas (root-only: **40.685242%**). Root/list reads improve with the combined candidate. Query gas is a resource cost, not a transaction payment for standalone qeval.
- If the storage benefit is accepted together with this nested-query resource regression, prefer the combined candidate over root-only. If preserving nested-query resource usage is a hard requirement, choose neither; root-only does not fix it.
- The 143 ugnot/1000 sensitivity tariff leaves combined improving by **4.957319 GNOT**, while root-only becomes **0.025330 GNOT more expensive**. No deployment or RPC capacity change was performed.

## Verification and reproduction

```sh
make init
make compare-metric-force c9e134dd90fc8f50b2ed9b8e311a6d86df5b088a 602716defb8bdc21c8c226477b9f3b06cc6dbd81 b12f0f8760a3e88e9539b0c8cfd32b38a5297c68
```

The full standard suite was regenerated for all candidates and baseline, then replayed without golden updates. All fixture hashes and emitted STATE values match; raw per-realm deltas sum to the measured net bytes. New isolated Staker candidates passed both Staker packages; new isolated Launchpad candidates passed Launchpad, v1 and the changed upgrade-v3 package. Existing immutable candidates were exercised in this fresh paired suite without unnecessarily repeating their previously reported unit checks.

### Immutable candidates
- Proposal value root only: [`602716defb8bdc21c8c226477b9f3b06cc6dbd81`](https://github.com/gnoswap-labs/gnoswap/commit/602716defb8bdc21c8c226477b9f3b06cc6dbd81); [per-window evidence](602716de_b12f0f87.tsv).
- Combined value candidate: [`c9e134dd90fc8f50b2ed9b8e311a6d86df5b088a`](https://github.com/gnoswap-labs/gnoswap/commit/c9e134dd90fc8f50b2ed9b8e311a6d86df5b088a); [per-window evidence](c9e134dd_b12f0f87.tsv).
- [Direct metadata increment](c9e134dd_602716de.tsv).

## Accounting, compatibility and scope

- [Pricing provenance](pricing.json): Pearl height 334227, observed 1 ugnot/1000 gas and 100 ugnot/byte; restricted-denom list empty.
- Local fresh-state storage is priced **per realm** at a uniform assumed charge/refund ratio of 100 ugnot/byte. These are net realm storage measurements, not observed bank transfers or peak runtime allocation.
- Fee model: `ceil(gas/1000)` per measured public-call window. Buffered model: `ceil(floor(gas*1.1)/1000)`. SDK/transaction estimation overhead is excluded. Keeping the same valid fixed submitted GasFee makes monetary gas delta zero.
- Standalone queries pay no transaction fee; their metered resource regressions remain disclosed.
- Values preserve numeric/API results in tested fresh-state workflows but change persistent representation. Existing typed objects require migration; no compatibility bridge or deployment was attempted. No Contract PR, merge or deployment was performed.
- Original selected-window results are historical evidence at tracker commit `20a6fc08516e1d5c157299d68cb629b7cf3ef4cb`; they are not the full exit lifecycle reported here.
