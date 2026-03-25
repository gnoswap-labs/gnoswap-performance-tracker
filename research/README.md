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
- raw TSV output under `artifacts/`, normalized into tracker reports via `scripts/parse_research.sh`

The broader probe matrix should still be expanded incrementally.

## Commands

From the tracker root:

```bash
make research-up
make research-down
make research-test
make research-report 3f2642b8898ae02d14a14c4050d80919f18f3f21
make compare-research main develop
```

Or directly inside `research/`:

```bash
make up
make down
make test
make report REF=3f2642b8898ae02d14a14c4050d80919f18f3f21
```

For local runs, copy `.env.example` to `.env` and provide a valid `TEST_MNEMONIC`.

The default milestone set is `1,100,10000`. Override it per run when needed.

```bash
WORKLOAD_NS=1,10 make report REF=3f2642b8898ae02d14a14c4050d80919f18f3f21
WORKLOAD_NS=1,10 make research-report 3f2642b8898ae02d14a14c4050d80919f18f3f21
```

## Boundaries

- Do not move live-chain runtime files into `tests/metric` or `tests/stress`.
- Do not write raw outputs into `reports/metric` or `reports/stress`.
- Do not mutate the tracker `.worktrees/` flow from this lane.
- Treat research results as exploratory until manually promoted into canonical benchmark lanes.
