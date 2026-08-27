#!/bin/bash

# Prepare a metric-enabled Gno branch without mutating the shared gno checkout.
# Usage: ./scripts/prepare_gno_gas_branch.sh <gnolang/gno commit-or-ref>

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TRACKER_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
GNO_REPO="$TRACKER_ROOT/gno"
UPSTREAM_URL="${GNO_UPSTREAM_URL:-https://github.com/gnolang/gno.git}"
CUSTOM_COMMITS=(
    eb20d3a1074f10dc0c4a4a5815216d18d58aa42b
    9d65db8e09777064d1b69638f9a8e971bd3817c3
)

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <gnolang/gno commit-or-ref>" >&2
    exit 1
fi

if ! git -C "$GNO_REPO" rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: gno submodule is not initialized at $GNO_REPO. Run 'make init' first." >&2
    exit 1
fi

SOURCE_REF=$1
git -C "$GNO_REPO" fetch origin --prune >/dev/null

for custom_commit in "${CUSTOM_COMMITS[@]}"; do
    if ! git -C "$GNO_REPO" rev-parse -q --verify "${custom_commit}^{commit}" >/dev/null; then
        git -C "$GNO_REPO" fetch --no-tags origin "$custom_commit" >/dev/null
    fi
done

git -C "$GNO_REPO" fetch --no-tags "$UPSTREAM_URL" "$SOURCE_REF" >/dev/null
SOURCE_COMMIT=$(git -C "$GNO_REPO" rev-parse FETCH_HEAD^{commit})

SHORT_SOURCE_COMMIT=$(git -C "$GNO_REPO" rev-parse --short=8 "$SOURCE_COMMIT")
BRANCH="gas-$SHORT_SOURCE_COMMIT"

patch_id() {
    git -C "$GNO_REPO" show --pretty=format: "$1" | git patch-id --stable | awk '{print $1}'
}

verify_branch() {
    local tip=$1 base first_custom second_custom
    if ! base=$(git -C "$GNO_REPO" rev-parse "${tip}~2" 2>/dev/null); then
        echo "Error: $BRANCH does not contain both required metric commits." >&2
        return 1
    fi
    first_custom=$(git -C "$GNO_REPO" rev-parse "${tip}~1")
    second_custom=$(git -C "$GNO_REPO" rev-parse "$tip")
    if [ "$base" != "$SOURCE_COMMIT" ] \
        || [ "$(patch_id "$first_custom")" != "$(patch_id "${CUSTOM_COMMITS[0]}")" ] \
        || [ "$(patch_id "$second_custom")" != "$(patch_id "${CUSTOM_COMMITS[1]}")" ]; then
        echo "Error: existing $BRANCH is not $SOURCE_COMMIT plus the required metric patches." >&2
        return 1
    fi
}

if git -C "$GNO_REPO" show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
    GNO_GAS_COMMIT=$(git -C "$GNO_REPO" rev-parse "origin/$BRANCH^{commit}")
    verify_branch "$GNO_GAS_COMMIT"
else
    mkdir -p "$TRACKER_ROOT/.worktrees"
    TEMP_WORKTREE=$(mktemp -d "$TRACKER_ROOT/.worktrees/gno-gas.XXXXXX")
    rmdir "$TEMP_WORKTREE"
    cleanup() {
        git -C "$GNO_REPO" worktree remove --force "$TEMP_WORKTREE" >/dev/null 2>&1 || true
        git -C "$GNO_REPO" worktree prune >/dev/null 2>&1 || true
    }
    trap cleanup EXIT

    git -C "$GNO_REPO" worktree add --detach "$TEMP_WORKTREE" "$SOURCE_COMMIT" >/dev/null
    git -C "$TEMP_WORKTREE" cherry-pick "${CUSTOM_COMMITS[@]}" >/dev/null
    GNO_GAS_COMMIT=$(git -C "$TEMP_WORKTREE" rev-parse HEAD)

    if ! git -C "$TEMP_WORKTREE" push origin "HEAD:refs/heads/$BRANCH" >/dev/null; then
        git -C "$GNO_REPO" fetch origin "refs/heads/$BRANCH:refs/remotes/origin/$BRANCH" >/dev/null
        GNO_GAS_COMMIT=$(git -C "$GNO_REPO" rev-parse "origin/$BRANCH^{commit}")
        verify_branch "$GNO_GAS_COMMIT"
    fi
fi

git -C "$TRACKER_ROOT" config --local gnoswap-performance.gnoRef "$GNO_GAS_COMMIT"

printf 'GNO_SOURCE_COMMIT=%s\n' "$SOURCE_COMMIT"
printf 'GNO_GAS_BRANCH=%s\n' "$BRANCH"
printf 'GNO_GAS_COMMIT=%s\n' "$GNO_GAS_COMMIT"
printf 'GNO_REF is now the default for benchmark commands.\n'
