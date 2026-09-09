#!/usr/bin/env python3
"""Price already measured resource deltas under explicit fee policies.

Usage: python3 scripts/price_fee_policies.py EXPERIMENT CANDIDATES PRICING
This does not simulate full transactions or claim observed wallet savings.
"""
import csv
from decimal import Decimal, ROUND_HALF_UP
from fractions import Fraction
import json
from pathlib import Path
import sys


def gnot(value):
    value = Fraction(value)
    amount = Decimal(value.numerator) / Decimal(value.denominator) / Decimal(1000000)
    amount = amount.quantize(Decimal('0.000001'), rounding=ROUND_HALF_UP)
    return format(amount, '+.6f') if amount else '0.000000'


def quoted_fee(gas, price, margin):
    wanted = int(Fraction(gas) * margin)
    amount = wanted * price
    return -(-amount.numerator // amount.denominator)


def main():
    experiment, candidates, pricing_file = map(Path, sys.argv[1:])
    manifest = json.loads(experiment.read_text())
    run = json.loads(candidates.read_text())
    pricing = json.loads(pricing_file.read_text())
    root = Path(__file__).resolve().parents[1]
    baseline = manifest['baseline']
    gas_quote = json.loads(pricing['queries']['auth/gasprice']['decoded'])
    current_price = Fraction(int(gas_quote['price'].removesuffix('ugnot')), int(gas_quote['gas']))
    policies = [
        ('reference-execution-repricing', current_price, Fraction(1)),
        ('client-10pct-floor-ceil-estimate', current_price, Fraction(11, 10)),
        ('historical-143-sensitivity', Fraction(143, 1000), Fraction(11, 10)),
    ]
    report = {'baseline': baseline, 'variants': [], 'limits': [
        'Whole transaction and SDK overhead are omitted; these are execution-segment fee-policy estimates, not wallet debits.',
        'The 10% floor/ceil policy comes from frontend source and live bundle evidence. It must not be assumed for every wallet or bot.',
        'The 143ugnot/1000gas policy is a historical snapshot sensitivity, not a current tariff or price of every sampled transaction.',
        'A measurement window may contain a batch of calls; its rounded fee is an equivalent aggregate quote, not a claim that the batch is one transaction.',
        'Fixed identical valid submitted fees have zero gas cash difference; storage is separately priced.',
    ]}
    for candidate in run['variants']:
        path = root / f"reports/metric/compares/cost_{candidate['sha'][:7]}_{baseline[:7]}.tsv"
        with path.open() as source:
            rows = list(csv.DictReader(source, delimiter='\t'))
        result = {'id': candidate['id'], 'sha': candidate['sha'], 'scopes': []}
        for scope in manifest['scopes']:
            selected = [r for r in rows if r['fixture'] == scope['fixture'] and (r['label'] in scope.get('labels', []) or any(r['label'].startswith(p) for p in scope['label_prefixes']))]
            if not selected:
                if scope.get('optional'):
                    continue
                raise ValueError('Empty scope: ' + scope['name'])
            storage = sum(Fraction(r['storage_delta_ugnot']) for r in selected)
            row = {'name': scope['name'], 'measurement_windows': len(selected), 'operation_count': scope.get('operation_count'), 'storage_delta_gnot': gnot(storage), 'fixed_identical_fee_net_delta_gnot': gnot(storage), 'policies': {}}
            for name, price, margin in policies:
                gas = sum(quoted_fee(int(r['candidate_gas']), price, margin) - quoted_fee(int(r['baseline_gas']), price, margin) for r in selected if r['scope'] != 'query-computation-only')
                row['policies'][name] = {'gas_fee_delta_ugnot': gas, 'gas_fee_delta_gnot': gnot(gas), 'net_delta_gnot': gnot(storage + gas)}
            result['scopes'].append(row)
        report['variants'].append(result)
    output = root / f'reports/metric/compares/fee-policies_{baseline[:7]}.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('PASS', output, len(report['variants']), 'variants')


if __name__ == '__main__':
    main()
