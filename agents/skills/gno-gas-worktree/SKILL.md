---
name: gno-gas-worktree
description: Prepare and use a metric-enabled Gno worktree for this performance tracker. Use when a user supplies a gnolang/gno commit or ref and wants GnoSwap gas, metric, or stress benchmarks against it; creates or verifies the corresponding gnoswap-labs/gno gas branch with the required metric patches before running the tracker.
---

# Gno Gas Worktree

This repository creates isolated Gno worktrees for benchmark runs. Do not
checkout, cherry-pick, or build against the shared `gno/` submodule.

## Workflow

1. Run `make prepare-gno-gas <upstream-ref>`.
2. Record the printed `GNO_SOURCE_COMMIT`, `GNO_GAS_BRANCH`, and
   `GNO_GAS_COMMIT` in the work summary.
3. Run the requested benchmark. It automatically uses the prepared Gno commit:

   ```bash
   make metric <gnoswap-ref>
   make stress <gnoswap-ref>
   ```

Use `GNO_REF=<ref-or-commit>` only for a one-off benchmark override.

The preparation command makes `gnoswap-labs/gno:gas-<8-char-upstream-sha>`
from the exact upstream commit and cherry-picks these patches in order:

1. `eb20d3a1074f10dc0c4a4a5815216d18d58aa42b`
2. `9d65db8e09777064d1b69638f9a8e971bd3817c3`

It uses a temporary worktree and refuses to overwrite an existing branch. If a
branch already exists, it verifies its base and the patch contents before
reusing it. Stop on cherry-pick conflicts or verification failures; do not
force-push or manually repair a gas branch without explicit user direction.
