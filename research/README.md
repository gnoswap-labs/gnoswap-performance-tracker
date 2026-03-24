# Research Lane

This directory is the live-chain research lane for `gnoswap-performance-tracker`.

## Purpose

- run exploratory live-chain measurements separately from `tests/metric` and `tests/stress`
- keep Docker/`gnodev`/`gnokey` runtime assets isolated from the canonical filetest benchmark lanes
- emit raw artifacts under `research/`, then normalize them into `reports/research/**`

## Current Scope

This initial version is scaffolding only.

- `Makefile` exposes the runtime command surface
- `docker-compose.yml` and `gno/` contain placeholder runtime files
- `artifacts/` and `.runlogs/` hold raw outputs
- normalized markdown reports are produced by the root tracker via `scripts/parse_research.sh`

The actual live-chain harness logic should be promoted into this lane incrementally.

## Commands

From the tracker root:

```bash
make research-up
make research-down
make research-test
make research-report main
make compare-research main develop
```

Or directly inside `research/`:

```bash
make up
make down
make test
make report REF=main
```

## Boundaries

- Do not move live-chain runtime files into `tests/metric` or `tests/stress`.
- Do not write raw outputs into `reports/metric` or `reports/stress`.
- Do not mutate the tracker `.worktrees/` flow from this lane.
- Treat research results as exploratory until manually promoted into canonical benchmark lanes.
