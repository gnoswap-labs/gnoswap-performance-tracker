# Delegation/reward value-record refresh

## Provenance

- Tracker PR [#65](https://github.com/gnoswap-labs/gnoswap-performance-tracker/pull/65), rebased onto main `babaa9e328c4fbb2cc5f7d3fbba0ac80509fa18b`.
- Contract PR [#1462](https://github.com/gnoswap-labs/gnoswap/pull/1462), candidate `f53f16f55c7007d77c60834d17a9038eeb8c59aa`.
- PR merge base: `23c906bd4cc684ef1e39037e0b7aabb04ce0a89e`.
- Live contract main at measurement: `42691b2d593272f86b0638d31bacf5a6b7813e6a`.
- Metric runtime: `a021c9ee3ccfc0ec74350614d0dca9c3e1ade504`, based on mainnet Gno `9c8eb132e483d6fd324d92c193e629ad65a98a37` plus metric patches.
- All three refs used the same tracked scenario source. The conditional `common/v1` initializer follows the selected contract layout. Pointer/value observation adapters run outside measured intervals; reward assertions read scalar snapshots without converting external values to an interface.
- Contract source was not changed by this refresh. Older `cb4c0f4`/`b12f0f8` reports and their inconsistent 11-row comparison were replaced.

## Matched PoC results

The complete lifecycle contains 13 measured intervals, with delegation/reward records and Launchpad deposits growing from 32 to 128. All 10 emitted state snapshots match exactly across all three refs. This establishes the scenario's sampled state parity, not historical-payload migration compatibility.

| Metric | PR merge base | Candidate | Delta | Delta % |
|---|---:|---:|---:|---:|
| Gas | 2,531,747,504 | 2,488,874,283 | -42,873,221 | -1.6934% |
| Net storage bytes | 2,983,121 | 2,762,405 | -220,716 | -7.3988% |
| CPU cycles | 2,129,206,110 | 2,169,135,429 | +39,929,319 | +1.8753% |

**PR-only tradeoff: lower gas/storage, higher CPU.** Model-only combined delta is **-22.114473221 GNOT**, using 1 ugnot per 1,000 gas and 100 ugnot per byte. It is not an observed transaction bill.

| Metric | Current main | Candidate | Delta | Delta % |
|---|---:|---:|---:|---:|
| Gas | 2,648,798,500 | 2,488,874,283 | -159,924,217 | -6.0376% |
| Net storage bytes | 2,934,525 | 2,762,405 | -172,120 | -5.8653% |
| CPU cycles | 2,243,715,534 | 2,169,135,429 | -74,580,105 | -3.3240% |

Current-main model delta: **-17.371924217 GNOT**. This comparison includes intervening main-branch changes; do not attribute its larger improvement solely to the PR.

Per-workload baseline/candidate values and absolute/percentage changes:
- [PR-only comparison](../../metric/compares/diff_f53f16f_23c906b.md)
- [Current-main comparison](../../metric/compares/diff_f53f16f_42691b2.md)

## Entire tracker execution

For each of the three full contract refs above, executed without fixture filters:

```sh
KEEP_BENCHMARK_WORKTREES=1 make gas-report <full-contract-ref>
KEEP_BENCHMARK_WORKTREES=1 make stress-report <full-contract-ref>
```

| Lane | Scope attempted | Actual outcome |
|---|---|---|
| Metric | All 86 active filetests on each ref | 74 complete; 12 record errors on each ref; identical error inventory |
| Stress | All 58 active fixtures on each ref; 15 existing `.gnoa` fixtures remain disabled | Package setup fails before case bodies: missing `gno.land/p/demo/tokens/grc721` |
| Research | `make research-test f53f16f55c7007d77c60834d17a9038eeb8c59aa` | Blocked before tests; details below |

**Not an all-green run.** The metric command exits zero because `-update-golden-tests` accepts newly recorded panics. Every generated `Error` section was inspected. The 132 rows in each normalized commit report come only from the 74 completed scenarios; partial output from erroring scenarios is excluded. The PoC itself completes all 13 intervals without an error.

The same 12 metric scenarios fail on the merge base, candidate, and current main:

- `launchpad_collect_protocol_fee_filetest.gno`: `should only be called for Realms`.
- `staker_collect_reward_filetest.gno`, `staker_collect_reward_position_growth_filetest.gno`, `staker_collect_reward_with_warmup_range_filetest.gno`, and `staker_collect_reward_with_external_rewards_{1,5}_filetest.gno`: required initial wugnot/GNS pool missing.
- `staker_create_external_incentive_filetest.gno`: start time exceeds maximum policy.
- `staker_collect_reward_incentive_token_count_filetest.gno`, `staker_end_external_incentive_filetest.gno`, and `staker_end_external_incentive_unclaimable{10,50,100}_filetest.gno`: start time is not at least 24 hours later.

Research initially failed because its Go 1.24 Docker builder is older than the contract's Go 1.25.9 minimum. An environment-only Go 1.25 retry built successfully, then deployment exited because the contract no longer provides `deploy-bar`. The readiness wait was cancelled after the container exited. The isolated container/network and temporary `.env` were removed; no research pass or tracked Dockerfile change is claimed.

The final parallel candidate stress attempt also hit workspace initialization failure. A serial full retry reached and reproduced the missing-package blocker. No stress metric report is published as a successful run.

## Complete contract verification

Candidate `f53f16f55c7007d77c60834d17a9038eeb8c59aa`, separate contract-test runtime `1bf7282dd85ec089a2e9079132b1505a6d80a159`:

```sh
make test WORKDIR=tmp/runtime-current PKG='gno.land/p/gnoswap/... ./gno.land/r/gnoswap/... ./gno.land/r/onbloc/... ./gno.land/r/try_register_pool_initializer'
python3 setup.py --exclude-tests -w tmp/integration-current
GOFLAGS=-count=1 bash scripts/all-integration-tests.sh tmp/integration-current/gno/gno.land/pkg/integration .
```

- 50 passing package entries, 90 no-test package entries, 399/399 filetests, and 8,898 passing named-test/subtest records. The grouped command still exits 2: router/v1 reports `initializer already registered`. The whole router/v1 package passes in isolation.
- All 68 integration cases attempted without `--skip`: 67 pass; `gov_governance_execute_text_proposal_should_fail.txtar:78` fails an event regex.
- Auxiliary Go tests: deploy generator fails `TestPackageDiscovery` (`test_usdc` vs `usdc`); integration/bless passes.
- All three repository-skipped bodies were also executed in temporary generated test copies: `TestCanonicalTickCross_7` passes; `TestEndExternalIncentive` fails caller-frame lookup; `TestCanonicalSimulation_0` expects reward 3,876,666,664 but observes 3,969,999,999. Tracked source and setup links were restored.
- These contract failures are recorded, not established as regressions introduced by this PR. Do not describe the whole contract suite as passing.

## Compatibility and disposition

Continue review conditionally: gas/storage improvements are reproducible, but CPU increases in the PR-only comparison and the full verification is not green. Existing pointer-payload migration and overlapping debt/price-debt work remain unresolved.

The tracker PR is measurement-only and has no production deployment dependency. The contract PR requires coordinated updated value-signature callers and a reviewed migration/compatibility plan before deployment. Passing this fixture or updated upgrade tests does not prove historical pointer-payload compatibility. Rolling back only the implementation version may not be safe after value records are persisted. Both PRs remain drafts; no deployment was performed.

## Evidence

- [Full manifest](verification.json): exact refs, fixture hash, all per-ref metric outcomes, lane blockers, contract results, raw-log hashes.
- PoC output/state snapshots: [merge base](23c906b.output.txt), [candidate](f53f16f.output.txt), [current main](42691b2.output.txt).
- Machine-readable metrics: [merge base](23c906b.metrics.json), [candidate](f53f16f.metrics.json), [current main](42691b2.metrics.json).
- Completed-scenario tables: [merge base](../../metric/commits/23c906b.md), [candidate](../../metric/commits/f53f16f.md), [current main](../../metric/commits/42691b2.md).

Raw logs remain local because they include workstation paths and deployment test credentials; only sanitized evidence and hashes are published.
