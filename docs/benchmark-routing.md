# Benchmark Routing Guide

This document explains how the benchmark lane chooses:

1. which **metric test files** to use for a target `gnoswap` commit, and
2. which **`gno` runtime ref** to use for that same run.

The goal is to keep the tracker stable as contract APIs and `gno` behavior evolve.

## Mental Model

There are two separate routing layers.

### 1. Test routing

Location:

- `tests/metric/latest/`
- `tests/metric/profiles/*`
- `tests/metric/manifest.json`

Default behavior:

- `tests/metric/latest/` is the canonical latest metric suite.
- Older commits can override only the files that need historical behavior.

### 2. Runtime routing

Location:

- `tests/runtime/manifest.json`
- `scripts/select_gno_runtime.py`

Default behavior:

- use the tracker repo's current local `gno` checkout (`local-head`)
- if rules are added later, a target `gnoswap` commit can select a different `gno` ref

These layers are intentionally separate:

- test routing is about **which scenario files** are copied into the temp worktree
- runtime routing is about **which `gno` commit** gets its own temp worktree and binary

## Current Execution Flow

For `make gas-report <ref>`:

1. `scripts/prepare_benchmark_workspace.sh` resolves the target `gnoswap` commit.
2. The same script resolves a `gno_ref` from `tests/runtime/manifest.json`.
3. A detached `gnoswap` worktree is prepared for the target commit.
4. A detached `gno` worktree is prepared for the selected `gno_ref`.
5. `Makefile` builds `gnovm/build/gno` inside that selected `gno` worktree.
6. `scripts/prepare_profiled_suite.py` copies `tests/metric/latest/` into the temp `gno` examples tree.
7. The metric manifest applies per-file historical overlays if needed.
8. The selected `gno` binary runs the metric suite.

## Metric Manifest Format

File:

- `tests/metric/manifest.json`

Current structure:

```json
{
  "version": 1,
  "overlays": {
    "example-overlay": {
      "root": "profiles/example-overlay",
      "description": "Why this historical override exists"
    }
  },
  "files": {
    "some_metric_file.gno": {
      "rules": [
        {
          "type": "range",
          "overlay": "example-overlay",
          "until": "full_commit_hash",
          "reason": "Why older commits need this file"
        }
      ]
    }
  }
}
```

### Rule meaning

Each entry under `files` controls one file from `tests/metric/latest/`.

- no matching rule → keep the file from `latest/`
- matching rule with `overlay` → replace that one file with the overlay version

Supported rule types in the selector:

- `exact`
- `range`
- `shape`

Current metric routing uses `range` rules.

The stress lane uses the same manifest shape. If no historical stress overrides are needed yet, it can stay as:

```json
{
  "version": 1,
  "overlays": {},
  "files": {}
}
```

## Runtime Manifest Format

File:

- `tests/runtime/manifest.json`

Current structure:

```json
{
  "version": 1,
  "default_gno_ref": "local-head",
  "rules": []
}
```

### Rule meaning

- `local-head` means: use the tracker repo's current local `gno` checkout `HEAD`
- later, you can add rules to route older `gnoswap` commits to a pinned older `gno` ref

Example future config:

```json
{
  "version": 1,
  "default_gno_ref": "local-head",
  "rules": [
    {
      "type": "range",
      "until": "0174f34a51e8181430c59989e423b04a31a1aff5",
      "gno_ref": "ea8914bcf1234567890deadbeef1234567890abc",
      "reason": "Older contract line requires an older gno runtime"
    }
  ]
}
```

## When to Change `latest/`

Update `tests/metric/latest/` when the tracker's intended default target line changes.

Use `profiles/` only for commits that need file-level historical compatibility.

In short:

- **latest/** = default modern truth
- **profiles/** = exceptions for older lines

## When to Add a Metric Overlay

Add an overlay when:

- one metric file no longer compiles or behaves correctly on an older `gnoswap` commit
- the rest of the latest suite is still valid

Steps:

1. Create a focused overlay directory under `tests/metric/profiles/`.
2. Put only the historical replacement file there.
3. Add a rule under `tests/metric/manifest.json` for that filename.
4. Re-run `make gas-report <target-commit>`.

Keep overlays narrow. Do not copy the entire suite unless absolutely necessary.

## When to Add a GNO Runtime Rule

Add a runtime rule when:

- the selected `gnoswap` commit requires a different `gno` runtime behavior
- test-file overlays alone are not enough

Steps:

1. Identify the correct `gno` commit or ref.
2. Add a rule to `tests/runtime/manifest.json`.
3. Re-run `make gas-report <target-commit>`.
4. Confirm the selected `gno` worktree and binary are from the intended ref.

## Practical Editing Guidelines

### Good changes

- change one file overlay for one historical incompatibility
- add one runtime rule for one clearly bounded old contract line
- keep `latest/` clean and representative of the intended default target

### Avoid

- putting unrelated historical files in one overlay directory
- encoding test routing and runtime routing in the same manifest
- treating generated reports as source of truth

## Current Defaults

At the time of writing:

- `tests/metric/latest/` is the default metric suite
- `tests/runtime/manifest.json` defaults to `local-head`
- metric runs build the `gno` binary from the selected `GNO_WORKTREE`

If you change these defaults later, update this guide and the README link.
