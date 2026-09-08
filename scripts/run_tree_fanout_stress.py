import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys

root = Path(sys.argv[1]).resolve()
refs = sys.argv[2:]
selected = [
    'staker_collect_reward_batch_claim_pos500_tick500_cliam1_filetest.gno',
    'staker_collect_reward_batch_claim_pos500_tick500_cliam5_filetest.gno',
    *[f'staker_collect_reward_batch_claim_pos500_tick500_tier{tier}_claim{claim}_filetest.gno' for tier in (1, 5, 10) for claim in (1, 5)],
    *[f'staker_collect_reward_stress_position_{n}_filetest.gno' for n in (10, 100, 500, 1000)],
    *[f'staker_collect_reward_stress_tick_cross_{n}_filetest.gno' for n in (20, 50)],
]
pattern = './(' + '|'.join(re.escape(name) for name in selected) + ')$'
for ref in refs:
    prepared = subprocess.run([str(root/'scripts/prepare_benchmark_workspace.sh'), ref], cwd=root, text=True, capture_output=True, check=True)
    config = {line.split('=', 1)[0]: shlex.split(line.split('=', 1)[1])[0] for line in prepared.stdout.splitlines()}
    gno = Path(config['GNO_WORKTREE'])
    run_root = Path(config['RUN_ROOT'])
    short = config['SHORT_COMMIT']
    print('FOCUSED STRESS', short, config['GNO_COMMIT'], flush=True)
    try:
        subprocess.run(['python3', 'setup.py', '--exclude-tests', '-w', str(run_root)], cwd=config['GNOSWAP_WORKTREE'], check=True)
        scenario = gno/'examples/gno.land/r/gnoswap/scenario'
        metric = scenario/'metric'
        stress = scenario/'stress'
        shutil.copytree(root/'tests/metric', metric)
        shutil.copytree(root/'tests/stress', stress)
        (stress/'filetests').mkdir(exist_ok=True)
        for name in selected:
            shutil.move(str(stress/name), str(stress/'filetests'/name))
        subprocess.run(['make', '--no-print-directory', 'build'], cwd=gno/'gnovm', check=True)
        env = dict(os.environ, GNOROOT=str(gno))
        subprocess.run([str(gno/'gnovm/build/gno'), 'test', '.', '-v', '-run', pattern, '-update-golden-tests'], cwd=stress, env=env, check=True)
        raw = ''
        for name in sorted(selected):
            content = (stress/'filetests'/name).read_text()
            if '// Error:' in content or '// - Gas Used:' not in content:
                raise RuntimeError(f'{short}: benchmark did not complete: {name}\n{content[-1200:]}')
            raw += content + '\n'
        parsed = subprocess.run([str(root/'scripts/parse_metrics.sh')], input=raw, text=True, capture_output=True, check=True).stdout
        rows = parsed.splitlines()[2:]
        if len(rows) != 14:
            raise RuntimeError(f'{short}: expected 14 metrics, got {len(rows)}')
        output = root/'reports/stress/commits'/f'{short}.md'
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(parsed)
        print('VERIFIED', output, '14 completed metrics; no Error directives', flush=True)
    finally:
        subprocess.run(['git', '-C', str(root/'gno'), 'worktree', 'remove', '--force', str(gno)], check=True)
        shutil.rmtree(run_root)
for candidate, baseline in ((refs[0], refs[1]), (refs[1], refs[2]), (refs[0], refs[2])):
    subprocess.run([str(root/'scripts/compare_reports.sh'), str(root/'reports/stress/commits'/f'{candidate}.md'), str(root/'reports/stress/commits'/f'{baseline}.md')], cwd=root, check=True)
