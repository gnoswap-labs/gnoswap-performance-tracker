# Delegation/reward value records rebased onto current main

## Provenance

- Contract PR [#1462](https://github.com/gnoswap-labs/gnoswap/pull/1462): **`0df50727c2c5f391a1a26ee9d3509858d2b69789`**, rebased and pushed from previous head `f53f16f55c7007d77c60834d17a9038eeb8c59aa`.
- Current main and PR merge base are both **`42691b2d593272f86b0638d31bacf5a6b7813e6a`**. This measures the PR applied to current main, not the older candidate compared with a newer main.
- Tracker PR [#65](https://github.com/gnoswap-labs/gnoswap-performance-tracker/pull/65) includes tracker main `babaa9e328c4fbb2cc5f7d3fbba0ac80509fa18b`.
- Metric runtime: `a021c9ee3ccfc0ec74350614d0dca9c3e1ade504` (mainnet `9c8eb132` plus metric patches). Contract-test runtime: `1bf7282dd85ec089a2e9079132b1505a6d80a159`.
- Rebase conflicts preserve main's value-typed Launchpad Deposit and this PR's value-typed RewardState storage. An obsolete pointer-based GetDeposit test was not reintroduced over main's cutover.
- The same metric fixture is used on both refs. Observation adapters are outside measured intervals. Contract source was updated by the rebase; diagnostic test copies do not change tracked source.

## Matched performance

Complete 32→128 record lifecycle: **13 measurement intervals**, **10 emitted state snapshots identical**.

| Metric | Current main / merge base | Rebased candidate | Delta | Delta % |
|---|---:|---:|---:|---:|
| Gas | 2,648,798,500 | 2,605,738,823 | -43,059,677 | -1.6256% |
| Net storage bytes | 2,934,525 | 2,713,830 | -220,695 | -7.5206% |
| CPU cycles | 2,243,715,534 | 2,283,644,853 | +39,929,319 | +1.7796% |

**Lower gas/storage, higher CPU.** Model-only combined delta: **-22.112559677 GNOT**, using 1 ugnot/1,000 gas and 100 ugnot/B. Not an observed transaction bill. Sampled state parity does not establish historical-payload migration compatibility.

[All per-workload values and deltas](../../metric/compares/diff_0df5072_42691b2.md).

## Complete contract verification

```sh
make test WORKDIR=tmp/runtime-current PKG='gno.land/p/gnoswap/... ./gno.land/r/gnoswap/... ./gno.land/r/onbloc/... ./gno.land/r/try_register_pool_initializer'
python3 setup.py --exclude-tests -w tmp/integration-current
GOFLAGS=-count=1 bash scripts/all-integration-tests.sh tmp/integration-current/gno/gno.land/pkg/integration .
go test -count=1 ./...
```

- **Unit/filetest command PASS, exit 0**: 52 passing package entries, 90 no-test entries, **410/410 filetests**, 9,909 passing named-test/subtest records. Eight repository skips remain in the normal run. The old grouped router initializer failure did not recur.
- **Integration: 77 attempted, 75 pass, 2 fail**, without `--skip`:
  - `gov_governance_create_parameter_change_proposal.txtar:113`: unable to vote outside the voting period.
  - `gov_governance_execute_text_proposal_should_fail.txtar:79`: event regex mismatch.
- **Auxiliary Go suites**: deploy generator `TestPackageDiscovery` fails (`test_usdc` vs `usdc`); integration/bless passes.
- **All eight unconditional skipped bodies also executed individually**, in a separate same-revision runtime with only the skip lines removed from detached generated copies: **2 pass, 6 fail**.
  - Pass: `TestProcessRoute_MultiHops`, `TestCanonicalTickCross_7`.
  - `TestExactOutSwapBoundary`: route first-token mismatch.
  - Three `TestCompareExactInAndDrySwap...` bodies: payer balance is zero.
  - `TestEndExternalIncentive`: caller-frame lookup failure.
  - `TestCanonicalSimulation_0`: expected reward 3,876,666,664; observed 3,969,999,999.
- Diagnostic source links were restored. These failures are recorded, not proven to be regressions introduced by this PR. **Overall verification is not all green.**

## Entire tracker execution

For both exact contract refs, without fixture filters:

```sh
KEEP_BENCHMARK_WORKTREES=1 make gas-report <full-contract-ref>
KEEP_BENCHMARK_WORKTREES=1 make stress-report <full-contract-ref>
```

- **Metric: 86 executed, 74 complete, 12 recorded errors on each ref**, with identical error inventories. All 13 PoC intervals complete. Each normalized report has 132 rows from completed scenarios only.
- `-update-golden-tests` accepts recorded panics and can print PASS / exit zero. Every generated `Error` section was inspected; the command's zero exit is not an all-pass result.
- The 12 failures concern missing initial wugnot/GNS pool setup, incentive start-time policies, and Launchpad realm context. Exact file names and errors are in the manifest.
- **Stress: all 58 active fixtures attempted; package setup blocked by missing `gno.land/p/demo/tokens/grc721`, before any case body.** Fifteen existing disabled `.gnoa` fixtures remain disabled. No successful stress metrics are claimed.
- **Research:** `make research-test 0df50727c2c5f391a1a26ee9d3509858d2b69789` was retried with an environment-only Go 1.25 Docker builder, isolated ports/network, and a 60-second readiness deadline. Build succeeds, then deployment exits after five attempts at missing `deploy-bar`; no research test body executes. Temporary container/network and `.env` were cleaned up.
- Disk-exhausted/interrupted attempts were not counted as final verification. Full unit/integration runs were repeated to completion with logs under the contract worktree's `tmp/pr1462-rebased-verification/`.

## Compatibility and disposition

Continue conditionally: improvements are reproduced on current main, but CPU increases and integration/auxiliary/supplemental checks are not all green. Debt/price-debt overlap and existing pointer-payload migration remain unresolved.

Tracker PR #65 is measurement-only and may merge independently; it has no production deployment dependency. Before deploying contract PR #1462, coordinate updated value-signature callers and review legacy storage migration/compatibility. Updated upgrade tests and this PoC do not prove historical pointer-payload compatibility. Rolling back only the implementation version may be unsafe after value records persist. Both PRs remain drafts; no production deployment was performed.

## Evidence

- [Full verification manifest](verification.json): refs, fixture hash, all metric outcomes, commands, contract results, supplemental failures, and local-log hashes.
- PoC output/state snapshots: [main](42691b2.output.txt), [rebased candidate](0df5072.output.txt).
- Machine-readable metrics: [main](42691b2.metrics.json), [rebased candidate](0df5072.metrics.json).
- Completed-scenario tables: [main](../../metric/commits/42691b2.md), [rebased candidate](../../metric/commits/0df5072.md).
- Older `23c906b` / `f53f16f` artifacts are historical pre-rebase measurements, not this PR head's current results. The [previous report](https://github.com/gnoswap-labs/gnoswap-performance-tracker/blob/806566ccb54646f3e8088f7f7a0d14f03f06e9fe/reports/poc/pr1462-main-refresh/summary.md) is retained in Git history.

Raw logs remain local because they include workstation paths and deployment test credentials. Only sanitized evidence is published.
