#!/usr/bin/env python3

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path


STAT_FIELDS = [
    "Gas (avg)",
    "Gas Q1",
    "Gas Q3",
    "Gas Min",
    "Gas Max",
    "Storage (avg)",
    "Storage Q1",
    "Storage Q3",
    "Storage Min",
    "Storage Max",
]


def parse_int(value: str) -> int:
    cleaned = value.replace(",", "").strip()
    if cleaned in {"", "-"}:
        return 0
    return int(cleaned)


def fmt_int(value: int) -> str:
    return f"{value:,}"


def fmt_change(value: int) -> str:
    if value > 0:
        return f"+{fmt_int(value)}"
    return fmt_int(value)


def fmt_pct(latest: int, previous: int) -> str:
    if previous == 0:
        if latest == 0:
            return "0.00%"
        return "N/A"
    pct = ((latest - previous) / previous) * 100
    return f"{pct:.2f}%"


def parse_research_report(
    path: Path,
) -> tuple[
    dict[tuple[str, str, int], dict[str, int]],
    list[str],
    dict[str, list[tuple[str, int]]],
]:
    records: dict[tuple[str, str, int], dict[str, int]] = {}
    domain_order: list[str] = []
    action_order: dict[str, list[tuple[str, int]]] = defaultdict(list)
    seen_actions: dict[str, set[tuple[str, int]]] = defaultdict(set)

    current_domain: str | None = None

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()

        if line.startswith("## "):
            current_domain = line[3:].strip()
            if current_domain and current_domain not in domain_order:
                domain_order.append(current_domain)
            continue

        if not current_domain or not line.startswith("|"):
            continue

        parts = [part.strip() for part in line.split("|")[1:-1]]
        if len(parts) != 12:
            continue
        if parts[0] == "Action" or parts[0].startswith("--------"):
            continue

        action = parts[0]
        try:
            n_value = int(parts[1])
        except ValueError:
            continue

        key = (current_domain, action, n_value)
        records[key] = {
            "Gas (avg)": parse_int(parts[2]),
            "Gas Q1": parse_int(parts[3]),
            "Gas Q3": parse_int(parts[4]),
            "Gas Min": parse_int(parts[5]),
            "Gas Max": parse_int(parts[6]),
            "Storage (avg)": parse_int(parts[7]),
            "Storage Q1": parse_int(parts[8]),
            "Storage Q3": parse_int(parts[9]),
            "Storage Min": parse_int(parts[10]),
            "Storage Max": parse_int(parts[11]),
        }

        action_key = (action, n_value)
        if action_key not in seen_actions[current_domain]:
            seen_actions[current_domain].add(action_key)
            action_order[current_domain].append(action_key)

    return records, domain_order, action_order


def merged_domain_order(
    latest_domains: list[str], previous_domains: list[str]
) -> list[str]:
    merged = list(latest_domains)
    for domain in previous_domains:
        if domain not in merged:
            merged.append(domain)
    return merged


def merged_action_order(
    domain: str,
    latest_actions: dict[str, list[tuple[str, int]]],
    previous_actions: dict[str, list[tuple[str, int]]],
) -> list[tuple[str, int]]:
    merged = list(latest_actions.get(domain, []))
    seen = set(merged)
    for action_key in previous_actions.get(domain, []):
        if action_key not in seen:
            merged.append(action_key)
            seen.add(action_key)
    return merged


def build_markdown(
    latest_report: Path,
    previous_report: Path,
    output_file: Path,
    latest_commit: str,
    previous_commit: str,
) -> None:
    latest_records, latest_domains, latest_actions = parse_research_report(
        latest_report
    )
    previous_records, previous_domains, previous_actions = parse_research_report(
        previous_report
    )

    latest_keys = set(latest_records.keys())
    previous_keys = set(previous_records.keys())
    only_latest = sorted(latest_keys - previous_keys)
    only_previous = sorted(previous_keys - latest_keys)

    github_base = "https://github.com/gnoswap-labs/gnoswap/tree"
    lines: list[str] = []
    lines.append("# Research Report Comparison")
    lines.append("")
    lines.append(f"- **Latest**: [`{latest_commit}`]({github_base}/{latest_commit})")
    lines.append(
        f"- **Previous**: [`{previous_commit}`]({github_base}/{previous_commit})"
    )
    lines.append("")

    lines.append("## Coverage")
    lines.append("")
    lines.append(
        f"- Matched rows (domain + action + N): **{len(latest_keys & previous_keys)}**"
    )
    lines.append(f"- Latest-only rows: **{len(only_latest)}**")
    lines.append(f"- Previous-only rows: **{len(only_previous)}**")

    if only_latest:
        lines.append("")
        lines.append("### Latest-only rows")
        lines.append("")
        for domain, action, n_value in only_latest:
            lines.append(f"- `{domain} / {action} / N={n_value}`")

    if only_previous:
        lines.append("")
        lines.append("### Previous-only rows")
        lines.append("")
        for domain, action, n_value in only_previous:
            lines.append(f"- `{domain} / {action} / N={n_value}`")

    domains = merged_domain_order(latest_domains, previous_domains)

    for domain in domains:
        lines.append("")
        lines.append(f"## {domain}")
        lines.append("")

        actions = merged_action_order(domain, latest_actions, previous_actions)
        for action, n_value in actions:
            key = (domain, action, n_value)
            latest_values = latest_records.get(key)
            previous_values = previous_records.get(key)

            lines.append(f"### {action} (N={n_value})")
            lines.append("")
            lines.append("| Statistic | Latest | Previous | Change | % |")
            lines.append("|-----------|--------|----------|--------|---|")

            for field in STAT_FIELDS:
                latest_number = latest_values[field] if latest_values else 0
                previous_number = previous_values[field] if previous_values else 0
                change = latest_number - previous_number
                pct = fmt_pct(latest_number, previous_number)

                lines.append(
                    "| "
                    + field
                    + " | "
                    + fmt_int(latest_number)
                    + " | "
                    + fmt_int(previous_number)
                    + " | "
                    + fmt_change(change)
                    + " | "
                    + pct
                    + " |"
                )

            lines.append("")

    output_file.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    if len(sys.argv) != 6:
        print(
            "Usage: compare_research_reports.py <latest.md> <previous.md> <output.md> <latest_commit> <previous_commit>",
            file=sys.stderr,
        )
        return 1

    latest_report = Path(sys.argv[1])
    previous_report = Path(sys.argv[2])
    output_file = Path(sys.argv[3])
    latest_commit = sys.argv[4]
    previous_commit = sys.argv[5]

    build_markdown(
        latest_report, previous_report, output_file, latest_commit, previous_commit
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
