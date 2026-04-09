#!/usr/bin/env python3

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


EXCLUDED_ROOT_NAMES = {"base", "latest", "profiles", "manifest.json", "README.md"}


def run_git(repo: str, args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", repo, *args],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def is_ancestor(repo: str, ancestor: str, descendant: str) -> bool:
    result = run_git(repo, ["merge-base", "--is-ancestor", ancestor, descendant])
    if result.returncode == 0:
        return True
    if result.returncode == 1:
        return False
    raise RuntimeError(
        result.stderr.strip() or f"git merge-base failed for {ancestor} -> {descendant}"
    )


def grep_matches(repo: str, commit: str, predicate: dict) -> bool:
    if "path" in predicate:
        paths = [predicate["path"]]
    elif "any_path" in predicate:
        paths = predicate["any_path"]
    else:
        raise ValueError(f"Predicate missing path selector: {predicate}")

    for path in paths:
        result = run_git(repo, ["grep", "-q", predicate["pattern"], commit, "--", path])
        if result.returncode == 0:
            return True
        if result.returncode != 1:
            raise RuntimeError(result.stderr.strip() or f"git grep failed for {path}")
    return False


def predicate_matches(repo: str, commit: str, predicate: dict) -> bool:
    matched = grep_matches(repo, commit, predicate)
    expect = predicate["expect"]
    if expect == "present":
        return matched
    if expect == "absent":
        return not matched
    raise ValueError(f"Unsupported predicate expectation: {expect}")


def range_matches(repo: str, commit: str, rule: dict) -> bool:
    after = rule.get("after") or rule.get("since")
    before = rule.get("before") or rule.get("until")

    if after and not is_ancestor(repo, after, commit):
        return False
    if before and is_ancestor(repo, before, commit):
        return False
    return True


def choose_most_recent_rule(repo: str, matches: list[dict]) -> dict:
    if len(matches) == 1:
        return matches[0]

    best = matches[0]
    for candidate in matches[1:]:
        best_since = best.get("after") or best.get("since")
        candidate_since = candidate.get("after") or candidate.get("since")

        if not best_since or not candidate_since:
            raise RuntimeError(
                f"Cannot disambiguate range rules without since/after: {matches}"
            )

        if is_ancestor(repo, best_since, candidate_since):
            best = candidate
            continue
        if is_ancestor(repo, candidate_since, best_since):
            continue

        raise RuntimeError(f"Ambiguous range rules are not linearly ordered: {matches}")

    return best


def match_rules(
    repo: str, commit: str, rules: list[dict]
) -> tuple[bool, str | None, str | None]:
    exact_matches: list[tuple[str | None, str]] = []
    for rule in rules:
        if rule.get("type") != "exact":
            continue
        if commit in rule.get("commits", []):
            exact_matches.append(
                (rule.get("overlay"), rule.get("reason", "exact match"))
            )

    if len(exact_matches) > 1:
        raise RuntimeError(
            f"Multiple exact rules matched commit {commit}: {exact_matches}"
        )
    if len(exact_matches) == 1:
        overlay, reason = exact_matches[0]
        return True, overlay, f"exact:{reason}"

    range_rule_matches: list[dict] = []
    for rule in rules:
        if rule.get("type") != "range":
            continue
        if range_matches(repo, commit, rule):
            range_rule_matches.append(rule)

    if len(range_rule_matches) >= 1:
        selected_rule = choose_most_recent_rule(repo, range_rule_matches)
        overlay = selected_rule.get("overlay")
        reason = selected_rule.get("reason", "range match")
        return True, overlay, f"range:{reason}"

    shape_matches_found: list[tuple[str | None, str]] = []
    for rule in rules:
        if rule.get("type") != "shape":
            continue
        predicates = rule.get("all", [])
        if predicates and all(
            predicate_matches(repo, commit, predicate) for predicate in predicates
        ):
            shape_matches_found.append(
                (rule.get("overlay"), rule.get("reason", "shape match"))
            )

    if len(shape_matches_found) > 1:
        raise RuntimeError(
            f"Multiple shape rules matched commit {commit}: {shape_matches_found}"
        )
    if len(shape_matches_found) == 1:
        overlay, reason = shape_matches_found[0]
        return True, overlay, f"shape:{reason}"

    return False, None, None


def apply_file_overrides(
    manifest_path: Path, manifest: dict, repo: str, commit: str, destination_dir: Path
) -> dict[str, dict[str, str]]:
    overlays = manifest.get("overlays", {})
    file_rules = manifest.get("files", {})
    applied: dict[str, dict[str, str]] = {}

    for relative_path, config in file_rules.items():
        matched, overlay, reason = match_rules(repo, commit, config.get("rules", []))
        if not matched:
            continue
        if reason is None:
            raise RuntimeError(f"Matched overlay without reason for {relative_path}")

        if overlay is None:
            applied[relative_path] = {"overlay": "latest", "reason": reason}
            continue

        overlay_config = overlays.get(overlay)
        if overlay_config is None:
            raise ValueError(f"Unknown overlay in file rule: {overlay}")

        source_path = manifest_path.parent / overlay_config["root"] / relative_path
        if not source_path.is_file():
            raise RuntimeError(f"Overlay file not found: {source_path}")

        destination = destination_dir / relative_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, destination)
        applied[relative_path] = {"overlay": overlay, "reason": reason}

    return applied


def copy_tree_contents(source_dir: Path, destination_dir: Path) -> None:
    for source_path in source_dir.rglob("*"):
        if source_path.is_dir():
            continue
        relative_path = source_path.relative_to(source_dir)
        destination = destination_dir / relative_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, destination)


def copy_suite_base(suite_root: Path, destination_dir: Path) -> None:
    latest_dir = suite_root / "latest"
    if latest_dir.is_dir():
        copy_tree_contents(latest_dir, destination_dir)
        return

    base_dir = suite_root / "base"
    if base_dir.is_dir():
        copy_tree_contents(base_dir, destination_dir)
        return

    for entry in suite_root.iterdir():
        if entry.name in EXCLUDED_ROOT_NAMES:
            continue
        if entry.is_dir():
            copy_tree_contents(entry, destination_dir / entry.name)
            continue
        destination = destination_dir / entry.name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(entry, destination)


def main() -> int:
    if len(sys.argv) != 6:
        print(
            "Usage: prepare_profiled_suite.py <gnoswap_repo> <full_commit> <suite_root> <manifest_path> <destination_dir>",
            file=sys.stderr,
        )
        return 1

    repo = sys.argv[1]
    commit = sys.argv[2]
    suite_root = Path(sys.argv[3])
    manifest_path = Path(sys.argv[4])
    destination_dir = Path(sys.argv[5])

    destination_dir.mkdir(parents=True, exist_ok=True)

    manifest = json.loads(manifest_path.read_text())

    copy_suite_base(suite_root, destination_dir)
    overrides = apply_file_overrides(
        manifest_path, manifest, repo, commit, destination_dir
    )
    override_count = sum(
        1 for info in overrides.values() if info.get("overlay") != "latest"
    )
    print(
        json.dumps(
            {
                "profile": "per-file",
                "reason": (
                    f"{len(overrides)} file decisions, {override_count} overrides"
                    if overrides
                    else "default canonical suite"
                ),
                "overrides": overrides,
            }
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
