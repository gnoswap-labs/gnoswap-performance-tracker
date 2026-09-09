#!/usr/bin/env python3
"""Price paired metric outputs using a captured tariff and uniform realm ratios.

Usage: python3 scripts/price_liquidity_metrics.py BASE CANDIDATE PRICING_JSON
Gas amounts are same-price execution-segment repricing estimates, not paid fees.
"""
import csv
from decimal import Decimal
from fractions import Fraction
import json
from pathlib import Path
import re
import sys


def decimal(value):
    value = Fraction(value)
    return str(Decimal(value.numerator) / Decimal(value.denominator))


def outputs(path):
    result = {}
    for fixture, text in json.loads(path.read_text()).items():
        current = None
        label = None
        for raw in text.splitlines():
            line = re.sub(r"^\s*// ?", "", raw).strip()
            if line.startswith("- Gas Used: "):
                key = (fixture, label)
                if key in result:
                    raise ValueError(f"Duplicate metric: {key}")
                current = {"gas": int(line.split(": ", 1)[1]), "realms": {}}
                result[key] = current
            elif line.startswith("- Storage Diff: "):
                current["storage"] = int(line.split(": ", 1)[1])
            elif line.startswith("- CPU Cycles: "):
                current["cpu"] = int(line.split(": ", 1)[1])
            elif line.startswith("- Realm Storage: "):
                realm, amount = line.removeprefix("- Realm Storage: ").rsplit(" ", 1)
                current["realms"][realm] = int(amount)
            elif line and not line.startswith("-"):
                label = line
    for key, row in result.items():
        if row["realms"] and sum(row["realms"].values()) != row["storage"]:
            raise ValueError(f"Realm total mismatch: {key}")
    return result


def main():
    base, candidate, pricing_path = sys.argv[1:]
    root = Path(__file__).resolve().parents[1]
    pricing = json.loads(Path(pricing_path).read_text())
    gas_tariff = json.loads(pricing["queries"]["auth/gasprice"]["decoded"])
    gas_price = Fraction(int(gas_tariff["price"].removesuffix("ugnot")), int(gas_tariff["gas"]))
    storage_price = int(json.loads(pricing["queries"]["params/vm:p:storage_price"]["decoded"]).removesuffix("ugnot"))
    if "ugnot" in json.loads(pricing["queries"]["params/bank:p:restricted_denoms"]["decoded"]):
        raise ValueError("This uniform-refund model requires unrestricted ugnot refunds")
    ratios = {}
    for realm, query in pricing["realms"].items():
        stored, deposit = map(int, re.fullmatch(r"storage: (\d+), deposit: (\d+)", query["decoded"]).groups())
        if not stored or deposit != stored * storage_price:
            raise ValueError(f"Nonuniform deposit ratio: {realm}")
        ratios[realm] = (stored, deposit)
    assumed = pricing.get("assumed_refund_ratios", {})
    for realm, assumption in assumed.items():
        if realm in ratios or assumption["ugnot_per_byte"] != storage_price or not assumption["reason"]:
            raise ValueError(f"Invalid or conflicting refund assumption: {realm}")
        # Unit-ratio representation, not an observed realm storage/deposit ledger.
        ratios[realm] = (1, assumption["ugnot_per_byte"])
    before = outputs(root / f"reports/metric/commits/{base[:7]}-output.json")
    after = outputs(root / f"reports/metric/commits/{candidate[:7]}-output.json")
    if before.keys() != after.keys():
        raise ValueError("Metric row sets differ")
    rows = []
    for (fixture, label), b in before.items():
        c = after[(fixture, label)]
        # Zero-storage numerical microbenchmarks may use MetricsBy rather than PrintMetricsBy.
        for r in (b, c):
            if not r["realms"] and r["storage"]:
                raise ValueError(f"Missing per-realm data: {fixture}/{label}")
        paid = []
        refunded = []
        for r in (b, c):
            deposits = refunds = 0
            for realm, delta in r["realms"].items():
                if delta > 0:
                    deposits += delta * storage_price
                elif delta < 0:
                    if realm not in ratios:
                        raise ValueError(f"Missing refund ratio: {realm}")
                    stored, deposit = ratios[realm]
                    # At the declared uniform integer ratio, this equality remains
                    # true after each message's positive or negative delta.
                    refund = deposit * (-delta) // stored
                    assert refund == -delta * storage_price
                    refunds += refund
            paid.append(deposits)
            refunded.append(refunds)
        storage_gain = paid[0] - refunded[0] - paid[1] + refunded[1]
        gas_gain = (b["gas"] - c["gas"]) * gas_price
        assert storage_gain == (b["storage"] - c["storage"]) * storage_price
        rows.append({"fixture": fixture, "workload": label,
                     "assumed_refund_realms": ",".join(sorted(realm for realm in assumed if b["realms"].get(realm, 0) < 0 or c["realms"].get(realm, 0) < 0)),
                     "baseline_gas": b["gas"], "candidate_gas": c["gas"],
                     "gas_delta": c["gas"] - b["gas"],
                     "baseline_net_bytes": b["storage"], "candidate_net_bytes": c["storage"],
                     "storage_delta_bytes": c["storage"] - b["storage"],
                     "cpu_delta": c["cpu"] - b["cpu"],
                     "deposit_gain_ugnot": paid[0] - paid[1],
                     "refund_gain_ugnot": refunded[1] - refunded[0],
                     "storage_gain_ugnot": storage_gain,
                     "gas_repricing_gain_ugnot": decimal(gas_gain),
                     "net_gain_ugnot": decimal(storage_gain + gas_gain),
                     "net_5pct_gas_margin_ugnot": decimal(storage_gain + gas_gain * Fraction(105, 100)),
                     "net_fixed_fee_ugnot": storage_gain})
    destination = root / f"reports/metric/compares/ugnot_{candidate[:7]}_{base[:7]}.tsv"
    with destination.open("w") as output:
        writer = csv.DictWriter(output, fieldnames=rows[0].keys(), delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)
    print(f"PASS: {len(rows)} matching workloads; per-realm deposit/refund identity; {destination}")


if __name__ == "__main__":
    main()
