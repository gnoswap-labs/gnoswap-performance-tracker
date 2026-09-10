"""Compare matched attribution outputs; keep queries and independent fixtures separate."""
import argparse
import csv
import json
from collections import defaultdict
from pathlib import Path


def fee(gas, price=1, margin_num=1, margin_den=1):
    wanted = gas * margin_num // margin_den
    return (wanted * price + 999) // 1000


def assess(tracker, baseline, candidate, query_labels):
    raw = tracker / 'reports/poc/raw'
    left = json.loads((raw / baseline / 'manifest.json').read_text())
    right = json.loads((raw / candidate / 'manifest.json').read_text())
    assert not left['errors'] and not right['errors']
    assert left['gno_commit'] == right['gno_commit']
    assert left['fixture_sha256'] == right['fixture_sha256'], 'fixture hash mismatch'
    assert left['fixtures'].keys() == right['fixtures'].keys(), 'fixture set mismatch'
    rows, fixtures = [], {}
    paired_labels = 0
    for fixture in sorted(left['fixtures']):
        a, b = left['fixtures'][fixture], right['fixtures'][fixture]
        assert len(a['rows']) == len(b['rows']), fixture
        assert a['states'] == b['states'], fixture + ': STATE mismatch'
        if fixture.startswith('poc_'):
            assert a['states'], fixture + ': missing semantic assertions'
        paired_labels += len(a['rows'])
        for index, (before, after) in enumerate(zip(a['rows'], b['rows'])):
            assert before['label'] == after['label'], fixture + ': label mismatch'
            if not fixture.startswith('poc_'):
                continue
            for r in (before, after):
                assert sum(r['realms'].values()) == r['storage_bytes'], (fixture, r['label'], 'realm accounting mismatch')
            label = before['label']
            query = any(label.startswith(prefix) for prefix in query_labels)
            gas_delta = after['gas'] - before['gas']
            deltas = {realm: after['realms'].get(realm, 0) - before['realms'].get(realm, 0) for realm in set(before['realms']) | set(after['realms'])}
            # Fresh-state scenario model: uniform 100 ugnot/B deposit ratios in EACH realm.
            deposit_before = sum(max(n, 0) * 100 for n in before['realms'].values())
            refund_before = sum(max(-n, 0) * 100 for n in before['realms'].values())
            deposit_after = sum(max(n, 0) * 100 for n in after['realms'].values())
            refund_after = sum(max(-n, 0) * 100 for n in after['realms'].values())
            storage = deposit_after - refund_after - deposit_before + refund_before
            assert storage == sum(deltas.values()) * 100
            fees = {key: 0 if query else fee(after['gas'], *policy) - fee(before['gas'], *policy) for key, policy in {'fee_ugnot': (1, 1, 1), 'buffered_fee_ugnot': (1, 11, 10), 'historical143_fee_ugnot': (143, 1, 1)}.items()}
            row = {'fixture': fixture, 'sample': index, 'label': label, 'kind': 'query' if query else 'paid', 'base_gas': before['gas'], 'candidate_gas': after['gas'], 'gas_delta': gas_delta, 'gas_pct': gas_delta * 100 / before['gas'] if before['gas'] else None, 'cycles_delta': after['cycles'] - before['cycles'] if after['cycles'] is not None and before['cycles'] is not None else None, 'base_storage_bytes': before['storage_bytes'], 'candidate_storage_bytes': after['storage_bytes'], 'storage_delta_bytes': sum(deltas.values()), 'storage_delta_ugnot': storage, 'deposits_delta_ugnot': deposit_after - deposit_before, 'refunds_delta_ugnot': refund_after - refund_before, **fees, 'net_delta_ugnot': storage + fees['fee_ugnot'], 'buffered_net_delta_ugnot': storage + fees['buffered_fee_ugnot'], 'historical143_net_delta_ugnot': storage + fees['historical143_fee_ugnot']}
            rows.append(row)
        if fixture.startswith('poc_'):
            selection = [r for r in rows if r['fixture'] == fixture]
            paid = [r for r in selection if r['kind'] == 'paid']
            fields = ['gas_delta', 'storage_delta_bytes', 'storage_delta_ugnot', 'fee_ugnot', 'net_delta_ugnot', 'buffered_net_delta_ugnot', 'historical143_net_delta_ugnot']
            fixtures[fixture] = {'state_lines': len(a['states']), 'paid_calls': len(paid), 'query_samples': len(selection) - len(paid), 'paid_totals': {k: sum(r[k] for r in paid) for k in fields}, 'states': a['states']}
    assert rows
    result = {'baseline': baseline, 'candidate': candidate, 'runtime': left['gno_commit'], 'same_inputs': True, 'same_states': True, 'paired_labels_all_fixtures': paired_labels, 'fixtures': fixtures, 'rows': rows, 'model': {'gas': 'ceil(gas/1000) ugnot per measured call; no SDK overhead', 'buffered': 'ceil(floor(gas*1.1)/1000) ugnot', 'storage': 'fresh-state per-realm 100 ugnot/B uniform charge/refund assumption', 'delta': 'candidate minus baseline, negative improvement', 'query': 'metered resources only, zero transaction fee', 'historical143': 'sensitivity only, not current live tariff', 'fixed_fee': 'same valid submitted fee gives zero monetary gas delta', 'limits': 'No deployment, migration, actual bank settlement, arbitrary time-value, or sum of independent fixture lifecycles.'}}
    dest = tracker / 'reports/attribution'
    dest.mkdir(parents=True, exist_ok=True)
    stem = candidate[:8] + '_' + baseline[:8]
    (dest / (stem + '.json')).write_text(json.dumps(result, indent=2) + '\n')
    with (dest / (stem + '.tsv')).open('w') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), delimiter='\t', lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)
    print(json.dumps({'candidate': candidate, 'paired_labels': paired_labels, 'fixtures': {k: v['paid_totals'] for k, v in fixtures.items()}}, indent=2))
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('baseline')
    parser.add_argument('candidate')
    parser.add_argument('--query-prefix', action='append', default=[])
    args = parser.parse_args()
    assess(Path.cwd(), args.baseline, args.candidate, args.query_prefix)
