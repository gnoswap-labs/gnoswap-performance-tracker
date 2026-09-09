"""Compare one real contract PoC's matched tracker raw manifests."""
import argparse
import csv
import json
import math
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('tracker', type=Path)
    parser.add_argument('baseline')
    parser.add_argument('candidate')
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    raw = args.tracker / 'reports/poc/raw'
    baseline = json.loads((raw / args.baseline / 'manifest.json').read_text())
    candidate = json.loads((raw / args.candidate / 'manifest.json').read_text())
    assert not baseline['errors'] and not candidate['errors']
    assert baseline['gno_commit'] == candidate['gno_commit']
    assert baseline['fixture_sha256'] == candidate['fixture_sha256'], 'different fixture inputs'
    names = sorted(name for name in baseline['fixtures'] if name.startswith('poc_'))
    assert names and names == sorted(name for name in candidate['fixtures'] if name.startswith('poc_'))
    rows, states = [], {}
    for name in names:
        left, right = baseline['fixtures'][name], candidate['fixtures'][name]
        assert left['states'] and left['states'] == right['states'], name + ': STATE mismatch'
        states[name] = len(left['states'])
        assert len(left['rows']) == len(right['rows']) and left['rows']
        for index, (before, after) in enumerate(zip(left['rows'], right['rows'])):
            assert before['label'] == after['label'], name + ': label mismatch'
            gas_delta = after['gas'] - before['gas']
            byte_delta = after['storage_bytes'] - before['storage_bytes']
            fee_delta = math.ceil(after['gas']/1000) - math.ceil(before['gas']/1000)
            deposit_delta = byte_delta * 100
            rows.append({'fixture': name, 'sample': index, 'label': before['label'], 'baseline_gas': before['gas'], 'candidate_gas': after['gas'], 'gas_delta': gas_delta, 'baseline_net_realm_bytes': before['storage_bytes'], 'candidate_net_realm_bytes': after['storage_bytes'], 'storage_delta_bytes': byte_delta, 'storage_delta_ugnot': deposit_delta, 'gas_delta_ugnot': fee_delta, 'total_delta_ugnot': deposit_delta+fee_delta})
    total = {field: sum(row[field] for row in rows) for field in ['baseline_gas','candidate_gas','gas_delta','baseline_net_realm_bytes','candidate_net_realm_bytes','storage_delta_bytes','storage_delta_ugnot','gas_delta_ugnot','total_delta_ugnot']}
    result = {'name': args.name, 'baseline': args.baseline, 'candidate': args.candidate, 'gno_commit': baseline['gno_commit'], 'same_inputs': True, 'same_states': True, 'state_lines': states, 'rows': rows, 'total': total, 'decision': 'cost_improved_for_measured_workload' if total['total_delta_ugnot'] < 0 else 'cost_regressed_for_measured_workload' if total['total_delta_ugnot'] > 0 else 'no_measured_cost_change', 'cost_model': {'gas_price': '1 ugnot / 1000 gas; per-call rounding', 'storage_price': '100 ugnot/byte', 'delta_sign': 'candidate minus baseline', 'limits': 'Net realm deposit delta at equal ratios, not lifetime profit or actual submitted fees. Setup excluded. Same fixed GasFee means zero cash gas delta. Migration/deployment/time value excluded; no cross-PoC sum.'}}
    out = args.tracker / 'reports/poc'
    out.mkdir(parents=True, exist_ok=True)
    stem = args.candidate[:8] + '_' + args.baseline[:8]
    (out / ('assessment_' + stem + '.json')).write_text(json.dumps(result, indent=2) + '\n')
    with (out / ('assessment_' + stem + '.tsv')).open('w') as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]), delimiter='\t', lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)
    print(json.dumps({'name': args.name, 'decision': result['decision'], 'fixtures': len(names), 'rows': len(rows), 'total': total}, indent=2))


if __name__ == '__main__':
    main()
