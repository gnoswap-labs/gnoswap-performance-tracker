"""Integrate observed modeled deposit savings over fixture clocks, not assumed APR."""
import argparse
import json
from pathlib import Path
import re


def clocks(path):
    text = path.read_text().split('// Output:', 1)[1]
    now, samples = None, []
    for raw in text.splitlines():
        line = raw.removeprefix('// ')
        match = re.match(r'STATE CLOCK .+ (\d+)$', line)
        if match:
            now = int(match[1])
        if line.startswith('- Gas Used: '):
            if now is None:
                raise ValueError('Missing clock before measured call: ' + str(path))
            samples.append(now)
    return samples, now


def calculate(tracker, assessment):
    a = json.loads(assessment.read_text())
    out = {}
    for fixture, info in a['fixtures'].items():
        rows = [r for r in a['rows'] if r['fixture'] == fixture]
        src = tracker / 'reports/poc/raw'
        t, end = clocks(src / a['baseline'] / fixture)
        tc, ec = clocks(src / a['candidate'] / fixture)
        assert t == tc and end == ec and len(t) == len(rows)
        cumulative = 0
        peak = 0
        integral = 0
        previous = t[0]
        for stamp, row in zip(t, rows):
            assert stamp >= previous
            integral += max(-cumulative, 0) * (stamp - previous)
            if row['kind'] == 'paid':
                cumulative += row['storage_delta_ugnot']
            peak = max(peak, -cumulative)
            previous = stamp
        integral += max(-cumulative, 0) * (end - previous)
        extra = info['paid_totals']['net_delta_ugnot']
        out[fixture] = {'observed_duration_seconds': end - t[0], 'peak_reduced_locked_gnot': peak / 1e6, 'reduced_capital_gnot_days': integral / 1e6 / 86400, 'ending_storage_delta_gnot': cumulative / 1e6, 'total_paid_delta_gnot': extra / 1e6, 'break_even_simple_apr_percent': extra * 365 * 86400 * 100 / integral if extra > 0 and integral > 0 else None, 'limits': 'Fresh-state 100 ugnot/B ledger; aggregates actors/realms. Only observed interval, no assumed yield and no extrapolated time after fixture end. Peak is not itself a lifetime saving.'}
    dest = assessment.with_name('capital_' + assessment.name)
    dest.write_text(json.dumps(out, indent=2) + '\n')
    print(json.dumps(out, indent=2))


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('assessment', type=Path)
    args = p.parse_args()
    calculate(Path.cwd(), args.assessment)
