#!/usr/bin/env python3

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


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


def select_runtime(repo: str, commit: str, manifest: dict) -> tuple[str, str]:
    default_ref = manifest["default_gno_ref"]
    rules = manifest.get("rules", [])

    exact_matches = [
        rule
        for rule in rules
        if rule.get("type") == "exact" and commit in rule.get("commits", [])
    ]
    if len(exact_matches) > 1:
        raise RuntimeError(
            f"Multiple exact rules matched commit {commit}: {exact_matches}"
        )
    if len(exact_matches) == 1:
        rule = exact_matches[0]
        return rule["gno_ref"], f"exact:{rule.get('reason', 'exact match')}"

    range_matches_found = [
        rule
        for rule in rules
        if rule.get("type") == "range" and range_matches(repo, commit, rule)
    ]
    if range_matches_found:
        rule = choose_most_recent_rule(repo, range_matches_found)
        return rule["gno_ref"], f"range:{rule.get('reason', 'range match')}"

    shape_matches_found = []
    for rule in rules:
        if rule.get("type") != "shape":
            continue
        predicates = rule.get("all", [])
        if predicates and all(
            predicate_matches(repo, commit, predicate) for predicate in predicates
        ):
            shape_matches_found.append(rule)

    if len(shape_matches_found) > 1:
        raise RuntimeError(
            f"Multiple shape rules matched commit {commit}: {shape_matches_found}"
        )
    if len(shape_matches_found) == 1:
        rule = shape_matches_found[0]
        return rule["gno_ref"], f"shape:{rule.get('reason', 'shape match')}"

    return default_ref, "default"


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "Usage: select_gno_runtime.py <gnoswap_repo> <full_commit> <manifest_path>",
            file=sys.stderr,
        )
        return 1

    repo = sys.argv[1]
    commit = sys.argv[2]
    manifest_path = Path(sys.argv[3])
    manifest = json.loads(manifest_path.read_text())
    gno_ref, reason = select_runtime(repo, commit, manifest)
    print(json.dumps({"gno_ref": gno_ref, "reason": reason}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
