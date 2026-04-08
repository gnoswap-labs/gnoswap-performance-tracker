# Research Lane

This directory is the live-chain research lane for `gnoswap-performance-tracker`.

## Purpose

- run exploratory live-chain measurements separately from `tests/metric` and `tests/stress`
- keep Docker/`gnodev`/`gnokey` runtime assets isolated from the canonical filetest benchmark lanes
- emit raw artifacts under `research/`, then normalize them into `reports/research/**`

## Current Scope

This lane now includes:

- a Dockerized local `gnodev` runtime with integrated contract deployment during bootstrap
- a minimal Go smoke harness for readiness and deployment checks
- a first report-capable probe path for `PoolCreate`
- raw TSV output under `artifacts/`, normalized into tracker reports via `scripts/parse_research.sh`; tracker reports use hash-only filenames while raw artifacts/runlogs keep run-scoped filenames with the resolved short hash and UTC timestamp

The broader probe matrix should still be expanded incrementally.

## Commands

From the tracker root:

```bash
make research-up
make research-down
make research-test
GNO_RPC_PORT=46657 GNO_REST_PORT=48888 make research-report 3f2642b8898ae02d14a14c4050d80919f18f3f21
make compare-research main develop
```

Or directly inside `research/`:

```bash
make up
make down
make test
COMPOSE_PROJECT_NAME=gnoswap_performance_research_abcd123-20260327-120000-000001 GNO_RPC_PORT=46657 GNO_REST_PORT=48888 GNO_GNOKEY_REMOTE=localhost:46657 GNO_REST=http://localhost:48888 RESEARCH_REPORT_OUT=$PWD/artifacts/research-report-abcd123-20260327-120000-000001.tsv RESEARCH_REPORT_LOG_OUT=$PWD/.runlogs/research-report-abcd123-20260327-120000-000001.log RESEARCH_METRIC_LOG_OUT=$PWD/.runlogs/metric-output-abcd123-20260327-120000-000001.log make report REF=3f2642b8898ae02d14a14c4050d80919f18f3f21
```

For local runs, copy `.env.example` to `.env` and provide a valid `TEST_MNEMONIC`.

The default sample bucket set is `1,10,100`. Override it per run when needed.

These are not interval buckets. The workload runs through the largest requested `N`, and each reported `N` summarizes the first `N` measured executions for that probe. For example, `N=10` means the summary is computed from the first 10 samples, and `N=100` means the summary is computed from the first 100 samples.

There is no hidden warm-up run. `N=1` is the true first measured execution for each probe.

```bash
COMPOSE_PROJECT_NAME=gnoswap_performance_research_abcd123-20260327-120000-000001 GNO_RPC_PORT=46657 GNO_REST_PORT=48888 GNO_GNOKEY_REMOTE=localhost:46657 GNO_REST=http://localhost:48888 RESEARCH_REPORT_OUT=$PWD/artifacts/research-report-abcd123-20260327-120000-000001.tsv RESEARCH_REPORT_LOG_OUT=$PWD/.runlogs/research-report-abcd123-20260327-120000-000001.log RESEARCH_METRIC_LOG_OUT=$PWD/.runlogs/metric-output-abcd123-20260327-120000-000001.log WORKLOAD_NS=1,10,100 make report REF=3f2642b8898ae02d14a14c4050d80919f18f3f21
GNO_RPC_PORT=46657 GNO_REST_PORT=48888 WORKLOAD_NS=1,10,100 make research-report 3f2642b8898ae02d14a14c4050d80919f18f3f21
GNO_RPC_PORT=47657 GNO_REST_PORT=49888 WORKLOAD_NS=1,10,100 make research-report main
```

## Probe Setup Summary

The research lane mixes two setup styles:

- **Shared protocol state** probes reuse the canonical `wugnot:gns:3000` pool and the standard protocol contracts deployed during bootstrap.
- **Disposable scenario state** probes create isolated probe-token pools per scenario so router state can be measured without polluting the shared `wugnot:gns` pool.

### Shared protocol state probes

| Test | Tokens | Pool | Reuse across iterations | Setup before the measured loop |
|---|---|---|---|---|
| `PoolCreate` | fresh disposable probe tokens per iteration | fresh disposable pool per iteration | none | ensure wrapped `wugnot` is available, approve `gns` to the pool package, then create a new token pair and pool each iteration |
| `PositionMint` | `gns` + `wugnot` | shared `wugnot:gns:3000` pool | reuses the pool only; each iteration mints a new position | ensure the shared pool exists, provision `gns` / wrapped `wugnot` budget for the full workload, approve tokens to pool/position |
| `PositionIncreaseLiquidity` | `gns` + `wugnot` | shared `wugnot:gns:3000` pool | reuses one position | same as `PositionMint`, then mint one wide-range position before entering the measured loop |
| `PositionDecreaseLiquidity` | `gns` + `wugnot` | shared `wugnot:gns:3000` pool | reuses one position | same as `PositionMint`, then mint one narrow-range position with enough liquidity to split across the full workload |
| `StakerCreateExternalIncentive` | `gns` + `wugnot` | shared `wugnot:gns:3000` pool | pool reused; each iteration creates a fresh incentive schedule | ensure mint prerequisites, approve `gns` to staker, set the pool tier |
| `StakerStakeToken` | `gns` + `wugnot` | shared `wugnot:gns:3000` pool | pool reused; each iteration mints and stakes a fresh LP position | ensure mint prerequisites, set the pool tier, start emission if needed, then call `MintAndDistributeGns()` once before the measured loop |
| `StakerCollectReward` | `gns` + `wugnot` | shared `wugnot:gns:3000` pool | reuses one staked position | same staker setup as above, then mint and stake a single position before the loop; each iteration waits for reward accrual and collects from the same position |
| `StakerUnStakeToken` | `gns` + `wugnot` | shared `wugnot:gns:3000` pool | pool reused; each iteration mints, stakes, and unstakes a fresh LP position | same staker setup as above |

### Disposable router scenario probes

| Test | Tokens | Pools | Reuse across iterations | Setup before the measured loop |
|---|---|---|---|---|
| `Router.ExactIn.SingleHop.Pos1` | 2 disposable probe tokens | 1 disposable single-hop pool | reuses the scenario pool and one position | create a fresh token pair, create one single-hop pool, mint one same-bounds position, then run oscillating swaps |
| `Router.ExactIn.SingleHop.Pos6` | 2 disposable probe tokens | 1 disposable single-hop pool | reuses the scenario pool and six positions | create a fresh token pair, create one single-hop pool, mint six staggered positions, then run oscillating swaps |
| `Router.ExactIn.TwoHop` | 3 disposable probe tokens | 2 disposable pools (`fee=100`, then `fee=3000`) | reuses both pools and one position per hop | create three fresh tokens, create both pools, mint one wide position in each hop, then run oscillating swaps |
| `Router.ExactOut.SingleHop.Pos1` | 2 disposable probe tokens | 1 disposable single-hop pool | reuses the scenario pool and one position | same setup as `Router.ExactIn.SingleHop.Pos1`, but measured with `ExactOutSwapRoute` |
| `Router.ExactOut.SingleHop.Pos6` | 2 disposable probe tokens | 1 disposable single-hop pool | reuses the scenario pool and six positions | same setup as `Router.ExactIn.SingleHop.Pos6`, but measured with `ExactOutSwapRoute` |
| `Router.ExactOut.TwoHop` | 3 disposable probe tokens | 2 disposable pools (`fee=100`, then `fee=3000`) | reuses both pools and one position per hop | same setup as `Router.ExactIn.TwoHop`, but measured with `ExactOutSwapRoute` |

Router scenarios marked `Pos6` use a six-position staggered layout intended to keep oscillating swaps crossing initialized tick boundaries during repeated measurements. Current router loops also assert that at least one pool `slot0` tick changes on every measured iteration.

## Boundaries

- Do not move live-chain runtime files into `tests/metric` or `tests/stress`.
- Do not write raw outputs into `reports/metric` or `reports/stress`.
- Do not mutate the tracker `.worktrees/` flow from this lane.
- Treat research results as exploratory until manually promoted into canonical benchmark lanes.
