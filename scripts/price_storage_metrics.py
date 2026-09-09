#!/usr/bin/env python3
"""Verify full paired reports and price declared scopes; negative delta is cheaper.

python3 scripts/price_storage_metrics.py MANIFEST RUN_STATE PRICING
All monetary amounts are estimates, not observed transaction fees.
"""
import csv
from decimal import Decimal, ROUND_HALF_UP
from fractions import Fraction
import json
from pathlib import Path
import re
import sys


def value(number):
    number = Fraction(number)
    return str(Decimal(number.numerator) / Decimal(number.denominator))


def gnot(ugnot):
    result = Decimal(value(ugnot)) / Decimal(1000000)
    result = result.quantize(Decimal('0.000001'), rounding=ROUND_HALF_UP)
    return format(result, '+.6f') if result else '0.000000'


def load_outputs(path):
    rows, states, initial = {}, {}, {}
    for fixture, text in json.loads(path.read_text()).items():
        label, row = None, None
        states[fixture] = []
        initial[fixture] = {}
        for raw in text.splitlines():
            line = re.sub(r'^\s*// ?', '', raw).strip()
            if line.startswith('- State:'):
                states[fixture].append(line)
            elif line.startswith('- Initial Realm Storage: '):
                realm, amount = line.removeprefix('- Initial Realm Storage: ').rsplit(' ', 1)
                initial[fixture][realm] = int(amount)
            elif line.startswith('- Gas Used: '):
                key = (fixture, label)
                if key in rows:
                    raise ValueError('Duplicate metric: ' + str(key))
                row = {'gas': int(line.split(': ', 1)[1]), 'realms': {}}
                rows[key] = row
            elif line.startswith('- Storage Diff: '):
                row['storage'] = int(line.split(': ', 1)[1])
            elif line.startswith('- CPU Cycles: '):
                row['cpu'] = int(line.split(': ', 1)[1])
            elif line.startswith('- Realm Storage: '):
                realm, amount = line.removeprefix('- Realm Storage: ').rsplit(' ', 1)
                row['realms'][realm] = int(amount)
            elif line and not line.startswith('-'):
                label = line
    for key, row in rows.items():
        if sum(row['realms'].values()) != row['storage']:
            raise ValueError('Missing or inconsistent realm deltas: ' + str(key))
    return rows, states, initial


def verify_normalized(path, raw):
    normalized = {}
    for line in path.read_text().splitlines()[2:]:
        cols = [cell.strip() for cell in line.strip('|').split('|')]
        if len(cols) != 4:
            continue
        if cols[0] in normalized:
            raise ValueError('Duplicate normalized label: ' + cols[0])
        normalized[cols[0]] = tuple(int(x.replace(',', '')) for x in cols[1:])
    if len(normalized) != len(raw):
        raise ValueError('Raw/normalized row count mismatch')
    for (_, label), row in raw.items():
        if normalized[label] != (row['gas'], row['storage'], row['cpu']):
            raise ValueError('Raw/normalized value mismatch: ' + label)


def matches(scope, key):
    fixture, label = key
    return fixture == scope['fixture'] and (label in scope.get('labels', []) or any(label.startswith(prefix) for prefix in scope['label_prefixes']))


def main():
    manifest_path, run_path, pricing_path = map(Path, sys.argv[1:])
    manifest = json.loads(manifest_path.read_text())
    run = json.loads(run_path.read_text())
    pricing = json.loads(pricing_path.read_text())
    root = Path(__file__).resolve().parents[1]
    baseline = 'b12f0f8760a3e88e9539b0c8cfd32b38a5297c68'
    gas_tariff = json.loads(pricing['queries']['auth/gasprice']['decoded'])
    gas_price = Fraction(int(gas_tariff['price'].removesuffix('ugnot')), int(gas_tariff['gas']))
    storage_price = int(json.loads(pricing['queries']['params/vm:p:storage_price']['decoded']).removesuffix('ugnot'))
    if 'ugnot' in json.loads(pricing['queries']['params/bank:p:restricted_denoms']['decoded']):
        raise ValueError('This model requires unrestricted refunds')
    ratios = {}
    for realm, query in pricing['realms'].items():
        match = re.fullmatch(r'storage: (\d+), deposit: (\d+)', query['decoded'])
        stored, deposit = map(int, match.groups())
        if not stored or deposit != stored * storage_price:
            raise ValueError('Nonuniform ratio needs a different model: ' + realm)
        ratios[realm] = (stored, deposit)
    assumed = pricing.get('assumed_refund_ratios', {})
    for realm, assumption in assumed.items():
        if realm in ratios or assumption['ugnot_per_byte'] != storage_price or not assumption['reason']:
            raise ValueError('Invalid refund assumption: ' + realm)
        ratios[realm] = (1, assumption['ugnot_per_byte'])
    before, before_states, before_initial = load_outputs(root / f'reports/metric/commits/{baseline[:7]}-output.json')
    verify_normalized(root / f'reports/metric/commits/{baseline[:7]}.md', before)
    report = {'baseline': baseline, 'group': manifest['group'], 'pricing_file': str(pricing_path), 'gas_price_ugnot_per_gas': value(gas_price), 'storage_price_ugnot_per_byte': storage_price, 'variants': []}
    for variant in run['variants']:
        sha = variant['sha']
        after, after_states, after_initial = load_outputs(root / f'reports/metric/commits/{sha[:7]}-output.json')
        verify_normalized(root / f'reports/metric/commits/{sha[:7]}.md', after)
        if before.keys() != after.keys():
            raise ValueError('Baseline/candidate row sets differ')
        if before_states != after_states:
            mismatch = [f for f in before_states.keys() | after_states.keys() if before_states.get(f) != after_states.get(f)]
            raise ValueError('Public state parity failed: ' + repr(mismatch))
        query_keys = {key for scope in manifest['scopes'] if scope['kind'] == 'query' for key in before if matches(scope, key)}
        all_rows = []
        for key, b in before.items():
            c = after[key]
            paid, refunded = [], []
            for row in (b, c):
                deposits = refunds = 0
                for realm, delta in row['realms'].items():
                    if delta > 0:
                        deposits += delta * storage_price
                    elif delta < 0:
                        if realm not in ratios:
                            raise ValueError('Missing refund ratio: ' + realm)
                        denominator, numerator = ratios[realm]
                        refund = numerator * -delta // denominator
                        assert refund == -delta * storage_price
                        refunds += refund
                paid.append(deposits)
                refunded.append(refunds)
            gas_delta = c['gas'] - b['gas']
            storage_delta = (paid[1] - refunded[1]) - (paid[0] - refunded[0])
            assert storage_delta == (c['storage'] - b['storage']) * storage_price
            gas_fee_delta = gas_delta * gas_price if key not in query_keys else Fraction(0)
            monetary = storage_delta + gas_fee_delta
            all_rows.append({'fixture': key[0], 'label': key[1], 'scope': 'query-computation-only' if key in query_keys else 'execution-segment-repricing',
                             'baseline_gas': b['gas'], 'candidate_gas': c['gas'], 'gas_delta': gas_delta,
                             'baseline_net_bytes': b['storage'], 'candidate_net_bytes': c['storage'], 'storage_delta_bytes': c['storage'] - b['storage'],
                             'cpu_delta': c['cpu'] - b['cpu'], 'baseline_deposits_ugnot': paid[0], 'candidate_deposits_ugnot': paid[1],
                             'baseline_refunds_ugnot': refunded[0], 'candidate_refunds_ugnot': refunded[1],
                             'storage_delta_ugnot': storage_delta, 'gas_fee_delta_ugnot': value(gas_fee_delta), 'net_delta_ugnot': value(monetary),
                             'storage_delta_gnot': gnot(storage_delta), 'gas_fee_delta_gnot': gnot(gas_fee_delta), 'net_delta_gnot': gnot(monetary)})
        by_key = {(r['fixture'], r['label']): r for r in all_rows}
        scopes = []
        for scope in manifest['scopes']:
            selected = [by_key[key] for key in before if matches(scope, key)]
            if not selected:
                if scope.get('optional'):
                    scopes.append({**scope, 'calls': 0, 'executed': False, 'note': 'Fixture condition did not call this path; no fabricated zero-cost measurement.'})
                    continue
                raise ValueError('Scope matches no metric: ' + scope['name'])
            sums = {field: sum(Fraction(r[field]) for r in selected) for field in ['baseline_gas', 'candidate_gas', 'gas_delta', 'baseline_net_bytes', 'candidate_net_bytes', 'storage_delta_bytes', 'cpu_delta', 'storage_delta_ugnot', 'gas_fee_delta_ugnot', 'net_delta_ugnot']}
            scopes.append({**scope, 'calls': len(selected), **{key: value(amount) for key, amount in sums.items()},
                           'storage_delta_gnot': gnot(sums['storage_delta_ugnot']), 'gas_fee_delta_gnot': gnot(sums['gas_fee_delta_ugnot']), 'net_delta_gnot': gnot(sums['net_delta_ugnot']),
                           'net_delta_5pct_margin_gnot': gnot(sums['storage_delta_ugnot'] + sums['gas_fee_delta_ugnot'] * Fraction(105, 100)),
                           'fixed_valid_fee_delta_gnot': gnot(sums['storage_delta_ugnot']),
                           'break_even_gas_price_ugnot_per_gas': value(-sums['storage_delta_ugnot'] / sums['gas_delta']) if sums['storage_delta_ugnot'] < 0 < sums['gas_delta'] else None})
        with (root / f'reports/metric/compares/cost_{sha[:7]}_{baseline[:7]}.tsv').open('w') as output:
            writer = csv.DictWriter(output, fieldnames=all_rows[0].keys(), delimiter='\t')
            writer.writeheader()
            writer.writerows(all_rows)
        initial = {fixture: {realm: after_initial.get(fixture, {}).get(realm, 0) - before_initial.get(fixture, {}).get(realm, 0) for realm in before_initial.get(fixture, {}).keys() | after_initial.get(fixture, {}).keys()} for fixture in before_initial.keys() | after_initial.keys() if before_initial.get(fixture) or after_initial.get(fixture)}
        result = {'id': variant['id'], 'field': variant['field'], 'sha': sha, 'branch': variant['branch'], 'row_count': len(all_rows), 'state_parity': True, 'scopes': scopes, 'initial_realm_snapshot_deltas': initial,
                  'row_counts': {field: {'decreased': sum(int(row[field]) < 0 for row in all_rows), 'unchanged': sum(int(row[field]) == 0 for row in all_rows), 'increased': sum(int(row[field]) > 0 for row in all_rows)} for field in ['gas_delta', 'storage_delta_bytes', 'cpu_delta']}}
        report['variants'].append(result)
        print('PASS', variant['id'], len(all_rows), 'paired labels; per-realm cashflow; state parity', flush=True)
        for scope in scopes:
            print('SCOPE', variant['id'], scope['name'], 'storage', scope.get('storage_delta_gnot', 'not-executed'), 'gas', scope.get('gas_fee_delta_gnot', 'not-executed'), 'net', scope.get('net_delta_gnot', 'not-executed'), flush=True)
    report['model'] = {'delta': 'candidate minus baseline; negative improves cost', 'gas': 'Execution-segment same-price repricing, zero margin plus 5% sensitivity. Fractional ugnot retained until GNOT display. Not submitted GasFee or wallet balances; transaction/SDK/deployment overhead omitted. Same valid fixed fee has zero gas cash delta. Query-only rows have zero gas cash fee.', 'storage': 'Fresh-state uniformly funded per-realm model. Observed ratios and explicit assumptions are in pricing. Apply deposit/refund per realm/message before netting; proportional integer ratio is invariant under sequential changes. Initial realm snapshots are separate initialization evidence, not a deployment fee quote.', 'limits': 'Do not sum unrelated scopes or initial observations with overlapping lifecycle results. Repeated costs can outlive allocation savings; capital duration and deployment fees are separate.'}
    (root / 'reports/metric/compares/remaining-economics.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
