#!/usr/bin/env bash
# Compare GnoSwap integration txtar GAS USED across multiple gnolang/gno refs.
#
# The script keeps the GnoSwap repo fixed at one ref, swaps the Gno toolchain
# worktree for each supplied Gno ref, runs one or more integration txtars through
# gnoland/gnokey, and emits per-command GAS USED rows.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TRACKER_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

GNO_REPO="$TRACKER_ROOT/gno"
GNOSWAP_REPO="$TRACKER_ROOT/gnoswap"
GNOSWAP_REF="main"
WORKDIR="$TRACKER_ROOT/.worktrees/txtar-gas"
OUTPUT=""
FORMAT="tsv"
KEEP_WORKTREES=0
SKIP_FETCH=0

REFS=()
TESTS=()
TARGETS=()

usage() {
    cat <<'EOF'
Usage:
  scripts/compare_gno_txtar_gas.sh [options]

Required:
  --ref <label:ref>       Gno ref to test. Repeat for multiple refs.
  --test <name>           Integration txtar test name without .txtar. Repeatable.

Optional:
  --target <func|pkg:func>
                          Only emit GAS USED rows for matching gnokey call funcs.
                          Repeatable. If omitted, all gnokey maketx GAS USED rows
                          are emitted.
  --gno-repo <path>       Local gnolang/gno repo. Default: ./gno
  --gnoswap-repo <path>   Local gnoswap repo. Default: ./gnoswap
  --gnoswap-ref <ref>     GnoSwap ref to hold fixed. Default: main
  --workdir <path>        Scratch/worktree directory. Default: .worktrees/txtar-gas
  --output <path>         Write final table to path. Default: stdout
  --format <tsv|markdown> Output format. Default: tsv
  --keep-worktrees        Keep per-ref Gno worktrees for inspection.
  --skip-fetch            Do not fetch origin before resolving refs.
  -h, --help              Show this help.

Examples:
  scripts/compare_gno_txtar_gas.sh \
    --gnoswap-ref main \
    --ref master:origin/master \
    --ref pr5937:refs/pull/5937/head \
    --ref pr5938:refs/pull/5938/head \
    --test pool_swap_wugnot_gns_tokens \
    --target WrappedSwap \
    --format markdown

  scripts/compare_gno_txtar_gas.sh \
    --ref master:origin/master \
    --ref pr5938:refs/pull/5938/head \
    --test router_exact_in_swap_route \
    --target gno.land/r/gnoswap/router:ExactInSwapRoute \
    --output reports/txtar-gas/router.tsv
EOF
}

fail() {
    echo "Error: $*" >&2
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --gno-repo)
            GNO_REPO="${2:-}"; shift 2 ;;
        --gnoswap-repo)
            GNOSWAP_REPO="${2:-}"; shift 2 ;;
        --gnoswap-ref)
            GNOSWAP_REF="${2:-}"; shift 2 ;;
        --workdir)
            WORKDIR="${2:-}"; shift 2 ;;
        --output)
            OUTPUT="${2:-}"; shift 2 ;;
        --format)
            FORMAT="${2:-}"; shift 2 ;;
        --ref)
            REFS+=("${2:-}"); shift 2 ;;
        --test)
            TESTS+=("${2:-}"); shift 2 ;;
        --target)
            TARGETS+=("${2:-}"); shift 2 ;;
        --keep-worktrees)
            KEEP_WORKTREES=1; shift ;;
        --skip-fetch)
            SKIP_FETCH=1; shift ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            fail "unknown argument: $1" ;;
    esac
done

[ "${#REFS[@]}" -gt 0 ] || fail "at least one --ref <label:ref> is required"
[ "${#TESTS[@]}" -gt 0 ] || fail "at least one --test <name> is required"
case "$FORMAT" in
    tsv|markdown) ;;
    *) fail "--format must be 'tsv' or 'markdown'" ;;
esac

git -C "$GNO_REPO" rev-parse --git-dir >/dev/null 2>&1 || fail "not a git repo: $GNO_REPO"
git -C "$GNOSWAP_REPO" rev-parse --git-dir >/dev/null 2>&1 || fail "not a git repo: $GNOSWAP_REPO"
[ -f "$GNOSWAP_REPO/setup.py" ] || fail "setup.py not found in gnoswap repo: $GNOSWAP_REPO"

mkdir -p "$WORKDIR/logs" "$WORKDIR/runs" "$WORKDIR/gnoswap"

if [ "$SKIP_FETCH" -eq 0 ]; then
    git -C "$GNO_REPO" fetch origin >/dev/null 2>&1 || true
    git -C "$GNOSWAP_REPO" fetch origin >/dev/null 2>&1 || true
fi

git -C "$GNO_REPO" worktree prune >/dev/null 2>&1 || true
git -C "$GNOSWAP_REPO" worktree prune >/dev/null 2>&1 || true

resolve_commit() {
    local repo="$1"
    local ref="$2"

    if git -C "$repo" rev-parse -q --verify "${ref}^{commit}" >/dev/null 2>&1; then
        git -C "$repo" rev-parse "${ref}^{commit}"
        return
    fi

    if git -C "$repo" rev-parse -q --verify "origin/${ref}^{commit}" >/dev/null 2>&1; then
        git -C "$repo" rev-parse "origin/${ref}^{commit}"
        return
    fi

    # Pull request refs are not always fetched by default.
    if [[ "$ref" =~ ^refs/pull/[0-9]+/head$ ]]; then
        local pr_num
        pr_num=$(printf '%s\n' "$ref" | cut -d/ -f3)
        git -C "$repo" fetch origin "$ref:refs/remotes/pr/${pr_num}" >/dev/null
        git -C "$repo" rev-parse "refs/remotes/pr/${pr_num}^{commit}"
        return
    fi

    fail "could not resolve ref '$ref' in $repo"
}

add_or_reset_worktree() {
    local repo="$1"
    local path="$2"
    local commit="$3"

    if [ -d "$path/.git" ] || git -C "$path" rev-parse --git-dir >/dev/null 2>&1; then
        local current
        current=$(git -C "$path" rev-parse HEAD)
        if [ "$current" = "$commit" ]; then
            return
        fi
        git -C "$repo" worktree remove --force "$path" >/dev/null 2>&1 || rm -rf "$path"
    elif [ -e "$path" ]; then
        rm -rf "$path"
    fi

    mkdir -p "$(dirname "$path")"
    git -C "$repo" worktree add --detach "$path" "$commit" >/dev/null
}

sanitize_label() {
    printf '%s\n' "$1" | tr -c 'A-Za-z0-9_.-' '_'
}

GNOSWAP_COMMIT=$(resolve_commit "$GNOSWAP_REPO" "$GNOSWAP_REF")
GNOSWAP_SHORT=$(git -C "$GNOSWAP_REPO" rev-parse --short=12 "$GNOSWAP_COMMIT")
GNOSWAP_WORKTREE="$WORKDIR/gnoswap/$GNOSWAP_COMMIT"
add_or_reset_worktree "$GNOSWAP_REPO" "$GNOSWAP_WORKTREE" "$GNOSWAP_COMMIT"

RUN_ID=$(python3 -c 'from datetime import datetime, timezone; print(datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S-%f"))')
RAW_TSV="$WORKDIR/txtar-gas-raw-$RUN_ID.tsv"
SUMMARY_TSV="$WORKDIR/txtar-gas-summary-$RUN_ID.tsv"

printf 'label\tgno_sha\tgnoswap_sha\ttest\tpkg\tfunc\toccurrence\tgas_used\tlog_path\n' > "$RAW_TSV"

for spec in "${REFS[@]}"; do
    [[ "$spec" == *:* ]] || fail "--ref must be label:ref, got: $spec"
    label=${spec%%:*}
    ref=${spec#*:}
    safe_label=$(sanitize_label "$label")
    gno_commit=$(resolve_commit "$GNO_REPO" "$ref")
    gno_short=$(git -C "$GNO_REPO" rev-parse --short=12 "$gno_commit")
    run_root="$WORKDIR/runs/$safe_label"
    gno_worktree="$run_root/gno"

    echo "==> Preparing $label ($gno_short)" >&2
    rm -rf "$run_root"
    mkdir -p "$run_root"
    add_or_reset_worktree "$GNO_REPO" "$gno_worktree" "$gno_commit"

    echo "==> Linking GnoSwap $GNOSWAP_SHORT into $label" >&2
    (cd "$GNOSWAP_WORKTREE" && python3 setup.py --exclude-tests -w "$run_root" >/dev/null)

    for test_name in "${TESTS[@]}"; do
        log_path="$WORKDIR/logs/${safe_label}__${test_name}.log"
        echo "==> Running $label $test_name" >&2
        (
            cd "$gno_worktree/gno.land/pkg/integration"
            SEQ_TS=1 go test -v . -run "TestTestdata/${test_name}$" -count=1
        ) >"$log_path" 2>&1 || {
            echo "WARN: test failed for $label $test_name (see $log_path)" >&2
        }

        python3 - "$log_path" "$label" "$gno_short" "$GNOSWAP_SHORT" "$test_name" "$RAW_TSV" "${TARGETS[@]}" <<'PY'
import re
import sys
from collections import defaultdict

log_path, label, gno_sha, gnoswap_sha, test_name, out_path, *targets = sys.argv[1:]

def match_target(pkg, func):
    if not targets:
        return True
    for target in targets:
        if ':' in target:
            target_pkg, target_func = target.rsplit(':', 1)
            if pkg == target_pkg and func == target_func:
                return True
        elif func == target:
            return True
    return False

lines = open(log_path, errors='replace').read().splitlines()
last_cmd = ''
seen = defaultdict(int)
rows = []

for line in lines:
    stripped = line.strip()
    if stripped.startswith('> gnokey maketx'):
        last_cmd = stripped[2:]
        continue
    if stripped.startswith('#'):
        continue

    match = re.fullmatch(r'GAS USED:\s+([0-9]+)', stripped)
    if not match or not last_cmd:
        continue

    func_match = re.search(r' -func ([^ ]+)', last_cmd)
    pkg_match = re.search(r' -pkgpath (("[^"]+")|([^ ]+))', last_cmd)
    func = func_match.group(1) if func_match else ''
    pkg = pkg_match.group(1).strip('"') if pkg_match else ''
    gas = int(match.group(1))

    if not match_target(pkg, func):
        continue

    seen[(pkg, func)] += 1
    rows.append((label, gno_sha, gnoswap_sha, test_name, pkg, func, seen[(pkg, func)], gas, log_path))

with open(out_path, 'a', encoding='utf-8') as out:
    for row in rows:
        out.write('\t'.join(str(value) for value in row) + '\n')
PY
    done

    if [ "$KEEP_WORKTREES" -eq 0 ]; then
        git -C "$GNO_REPO" worktree remove --force "$gno_worktree" >/dev/null 2>&1 || true
        rm -rf "$run_root"
    fi
done

python3 - "$RAW_TSV" "$SUMMARY_TSV" "$FORMAT" <<'PY'
import csv
import sys
from collections import defaultdict

raw_path, summary_path, fmt = sys.argv[1:]
with open(raw_path, encoding='utf-8') as f:
    rows = list(csv.DictReader(f, delimiter='\t'))

labels = []
for row in rows:
    label = row['label']
    if label not in labels:
        labels.append(label)

keys = []
values = defaultdict(dict)
for row in rows:
    key = (row['test'], row['pkg'], row['func'], row['occurrence'])
    if key not in keys:
        keys.append(key)
    values[key][row['label']] = int(row['gas_used'])

with open(summary_path, 'w', encoding='utf-8') as out:
    if fmt == 'tsv':
        out.write('\t'.join(['test', 'pkg', 'func', 'occurrence'] + labels + ['latest_vs_first_pct', 'latest_vs_previous_pct']) + '\n')
        for key in keys:
            row_values = [values[key].get(label) for label in labels]
            first = row_values[0] if row_values else None
            latest = row_values[-1] if row_values else None
            previous = row_values[-2] if len(row_values) >= 2 else None
            def pct(a, b):
                if a is None or b in (None, 0):
                    return ''
                return f'{((a - b) / b) * 100:.2f}'
            out.write('\t'.join([
                *key,
                *('' if value is None else str(value) for value in row_values),
                pct(latest, first),
                pct(latest, previous),
            ]) + '\n')
    else:
        out.write('| Test | Package | Function | # | ' + ' | '.join(labels) + ' | latest vs first | latest vs previous |\n')
        out.write('|---|---|---|---:|' + '|'.join(['---:'] * (len(labels) + 2)) + '|\n')
        for key in keys:
            row_values = [values[key].get(label) for label in labels]
            first = row_values[0] if row_values else None
            latest = row_values[-1] if row_values else None
            previous = row_values[-2] if len(row_values) >= 2 else None
            def fmt_int(value):
                return '-' if value is None else f'{value:,}'
            def fmt_pct(a, b):
                if a is None or b in (None, 0):
                    return '-'
                return f'{((a - b) / b) * 100:+.2f}%'
            out.write('| ' + ' | '.join([
                key[0], key[1], key[2], key[3],
                *(fmt_int(value) for value in row_values),
                fmt_pct(latest, first),
                fmt_pct(latest, previous),
            ]) + ' |\n')
PY

if [ -n "$OUTPUT" ]; then
    mkdir -p "$(dirname "$OUTPUT")"
    cp "$SUMMARY_TSV" "$OUTPUT"
    echo "Report saved to $OUTPUT" >&2
else
    cat "$SUMMARY_TSV"
fi

echo "Raw rows: $RAW_TSV" >&2
