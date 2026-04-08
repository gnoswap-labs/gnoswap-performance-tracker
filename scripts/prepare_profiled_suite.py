#!/usr/bin/env python3

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


EXCLUDED_ROOT_NAMES = {"base", "profiles", "manifest.json", "README.md"}


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
    after = rule.get("after")
    before = rule.get("before")

    if after and not is_ancestor(repo, after, commit):
        return False
    if before and is_ancestor(repo, before, commit):
        return False
    return True


def select_profile(repo: str, commit: str, manifest: dict) -> tuple[str, str]:
    profiles = manifest["profiles"]
    default_profile = manifest["default_profile"]

    if default_profile not in profiles:
        raise ValueError(f"Unknown default profile: {default_profile}")

    rules = manifest.get("rules", [])

    for rule in rules:
        if rule.get("type") != "exact":
            continue
        if commit in rule.get("commits", []):
            profile = rule["profile"]
            if profile not in profiles:
                raise ValueError(f"Unknown profile in exact rule: {profile}")
            return profile, f"exact:{rule.get('reason', 'exact match')}"

    range_matches_found: list[tuple[str, str]] = []
    for rule in rules:
        if rule.get("type") != "range":
            continue
        if range_matches(repo, commit, rule):
            profile = rule["profile"]
            if profile not in profiles:
                raise ValueError(f"Unknown profile in range rule: {profile}")
            range_matches_found.append((profile, rule.get("reason", "range match")))

    if len(range_matches_found) > 1:
        raise RuntimeError(
            f"Multiple range rules matched commit {commit}: {range_matches_found}"
        )
    if len(range_matches_found) == 1:
        profile, reason = range_matches_found[0]
        return profile, f"range:{reason}"

    for rule in rules:
        if rule.get("type") != "shape":
            continue
        predicates = rule.get("all", [])
        if predicates and all(
            predicate_matches(repo, commit, predicate) for predicate in predicates
        ):
            profile = rule["profile"]
            if profile not in profiles:
                raise ValueError(f"Unknown profile in shape rule: {profile}")
            return profile, f"shape:{rule.get('reason', 'shape match')}"

    return default_profile, "default"


def copy_tree_contents(source_dir: Path, destination_dir: Path) -> None:
    for source_path in source_dir.rglob("*"):
        if source_path.is_dir():
            continue
        relative_path = source_path.relative_to(source_dir)
        destination = destination_dir / relative_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, destination)


def copy_suite_base(suite_root: Path, destination_dir: Path) -> None:
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


def apply_profile(
    manifest_path: Path, manifest: dict, profile: str, destination_dir: Path
) -> None:
    profile_config = manifest["profiles"].get(profile)
    if profile_config is None:
        raise ValueError(f"Unknown selected profile: {profile}")

    overlay_dir = profile_config.get("overlay_dir")
    if overlay_dir is None:
        return

    profile_root = manifest_path.parent
    source_dir = profile_root / overlay_dir
    if not source_dir.is_dir():
        raise RuntimeError(f"Profile overlay not found: {source_dir}")
    copy_tree_contents(source_dir, destination_dir)


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
    profile, reason = select_profile(repo, commit, manifest)

    copy_suite_base(suite_root, destination_dir)
    apply_profile(manifest_path, manifest, profile, destination_dir)

    print(json.dumps({"profile": profile, "reason": reason}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
