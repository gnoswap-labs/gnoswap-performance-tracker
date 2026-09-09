"""Retain raw filetest outputs and accounting states before tracker cleanup."""
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    source, output, fixture_root = map(Path, sys.argv[1:4])
    contract_commit, gno_commit = sys.argv[4:6]
    output.mkdir(parents=True, exist_ok=True)
    manifest = {
        'contract_commit': contract_commit,
        'gno_commit': gno_commit,
        'fixture_sha256': {str(p.relative_to(fixture_root)): digest(p) for p in sorted(fixture_root.rglob('*')) if p.is_file() and p.suffix in ('.gno', '.gnoa', '.toml')},
        'fixtures': {},
        'errors': [],
    }
    for path in sorted(source.glob('*_filetest.gno')):
        shutil.copy2(path, output / path.name)
        text = path.read_text()
        if '// Error:' in text:
            manifest['errors'].append(path.name + ': ' + text.split('// Error:', 1)[1])
        if '// Output:' not in text:
            manifest['errors'].append(path.name + ': no output section')
            continue
        content = '\n'.join(line.removeprefix('// ') for line in text.split('// Output:', 1)[1].splitlines())
        states = [line for line in content.splitlines() if line.startswith('STATE ')]
        rows = []
        for chunk in re.split(r'\n(?=[^-\n])', content):
            gas = re.search(r'- Gas Used: (\d+)', chunk)
            storage = re.search(r'- Storage Diff: (-?\d+)', chunk)
            if not gas or not storage:
                continue
            cycles = re.search(r'- CPU Cycles: (\d+)', chunk)
            realms = {name: int(size) for name, size in re.findall(r'- Realm ([^:]+): (-?\d+)', chunk)}
            rows.append({'label': chunk.splitlines()[0].strip(), 'gas': int(gas[1]), 'storage_bytes': int(storage[1]), 'cycles': int(cycles[1]) if cycles else None, 'realms': realms})
        manifest['fixtures'][path.name] = {'states': states, 'rows': rows, 'output_sha256': digest(path)}
        if path.name.startswith('poc_') and (not rows or not states):
            manifest['errors'].append(path.name + ': PoC fixture needs measured rows and STATE snapshots')
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps({'captured': str(output), 'fixtures': len(manifest['fixtures']), 'errors': len(manifest['errors'])}))
    if manifest['errors']:
        raise SystemExit('\n'.join(manifest['errors']))


if __name__ == '__main__':
    main()
