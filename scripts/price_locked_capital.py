#!/usr/bin/env python3
"""Integrate avoided storage capital using retained per-call clocks and costs.

Usage: python3 scripts/price_locked_capital.py BASE_SHA CANDIDATE_SHA
No investment return is assumed; report the simple annualized break-even rate.
"""
import csv
from decimal import Decimal, ROUND_HALF_UP
from fractions import Fraction
import json
from pathlib import Path
import re
import sys


def decimal(value):
    value = Fraction(value)
    return str(Decimal(value.numerator) / Decimal(value.denominator))


def main():
    baseline, candidate = sys.argv[1:]
    root = Path(__file__).resolve().parents[1]
    outputs = json.loads((root / f'reports/metric/commits/{baseline[:7]}-output.json').read_text())
    with (root / f'reports/metric/compares/cost_{candidate[:7]}_{baseline[:7]}.tsv').open() as source:
        costs = {(row['fixture'], row['label']): row for row in csv.DictReader(source, delimiter='\t')}
    records = []
    for fixture, text in outputs.items():
        if not fixture.startswith('launchpad_reward_state_debt_'):
            continue
        label = None
        pending = []
        cumulative_delta = Fraction(0)
        gnot_seconds = Fraction(0)
        previous_time = None
        first_time = None
        last_deposit_time = None
        final_time = None
        all_keys = []
        peak_saved_gnot = Fraction(0)
        for raw in text.splitlines():
            line = re.sub(r'^\s*// ?', '', raw).strip()
            if line.startswith('- Gas Used: '):
                key = (fixture, label)
                pending.append(key)
                all_keys.append(key)
            elif line.startswith('- State: clock '):
                stage, timestamp = line.removeprefix('- State: clock ').split()
                now = int(timestamp)
                if previous_time is not None:
                    if now < previous_time:
                        raise ValueError('Non-monotonic fixture clock')
                    gnot_seconds += -cumulative_delta * (now - previous_time) / 1000000
                for key in pending:
                    cumulative_delta += Fraction(costs[key]['storage_delta_ugnot'])
                pending.clear()
                previous_time = now
                peak_saved_gnot = max(peak_saved_gnot, -cumulative_delta / 1000000)
                if stage == 'first-deposit':
                    first_time = now
                if stage == 'after-all-deposits':
                    last_deposit_time = now
                if stage == 'after-withdrawals':
                    final_time = now
            elif line and not line.startswith('-'):
                label = line
        if pending or first_time is None or final_time is None:
            raise ValueError('Incomplete measured-call clock coverage: ' + fixture)
        expected_keys = {key for key in costs if key[0] == fixture}
        if set(all_keys) != expected_keys or len(all_keys) != len(expected_keys):
            raise ValueError('Missing/duplicated lifecycle calls')
        net_gnot = sum(Fraction(costs[key]['net_delta_ugnot']) for key in all_keys) / 1000000
        days = gnot_seconds / 86400
        annual_rate = net_gnot * 365 / days if days > 0 and net_gnot > 0 else Fraction(0)
        records.append({'fixture': fixture, 'measured_calls': len(all_keys), 'first_deposit_timestamp': first_time,
                        'last_deposit_stage_timestamp': last_deposit_time, 'withdrawals_complete_timestamp': final_time,
                        'retention_days_first_deposit': decimal(Fraction(final_time - first_time, 86400)),
                        'peak_avoided_capital_gnot': decimal(peak_saved_gnot), 'avoided_capital_gnot_days': decimal(days),
                        'full_lifecycle_net_delta_gnot': decimal(net_gnot), 'simple_annual_break_even_rate': decimal(annual_rate),
                        'simple_annual_break_even_percent': decimal(annual_rate * 100)})
    result = {'baseline': baseline, 'candidate': candidate, 'records': records,
              'method': 'Integrate negative cumulative per-call storage cashflow delta over identical baseline/candidate fixture clocks. Test time changes are outside metric windows. Event-time step model; do not extrapolate beyond measured end.',
              'interpretation': 'Positive lifecycle cost premium may be offset by capital availability. Break-even is a hypothetical constant simple annual opportunity-cost rate, not an observed yield or investment recommendation. No compounding, deployment cost, price changes, or post-exit residual time value.'}
    (root / 'reports/metric/compares/locked-capital.json').write_text(json.dumps(result, indent=2) + '\n')
    for row in records:
        print(row['fixture'], 'capital-days', row['avoided_capital_gnot_days'], 'net-GNOT', row['full_lifecycle_net_delta_gnot'], 'break-even annual %', row['simple_annual_break_even_percent'])


if __name__ == '__main__':
    main()
