#!/bin/bash
set -eu

READY_FILE="/tmp/gnoswap-ready"

rm -f "$READY_FILE"

KEY_OUTPUT=$(printf "%s\n\n" "$TEST_MNEMONIC" | gnokey add gnoswap_admin --recover --insecure-password-stdin --force)
TEST_ADDR=$(printf "%s" "$KEY_OUTPUT" | grep -o 'g1[0-9a-z]\+' | head -n 1)

if [ -z "$TEST_ADDR" ]; then
    echo "failed to recover gnoswap_admin address"
    exit 1
fi

gnodev local \
    -node-rpc-listener 0.0.0.0:26657 \
    -web-listener 0.0.0.0:8888 \
    -empty-blocks \
    -no-watch \
    -add-account "${TEST_ADDR}=1000000000000000ugnot" &

GNODEV_PID=$!
cleanup() {
    kill "$GNODEV_PID" >/dev/null 2>&1 || true
    wait "$GNODEV_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

until curl -sf http://localhost:26657/status >/dev/null; do
    sleep 1
done

cd /opt/gnoswap/tests

sed -i 's/gdate -ud/date -ud/g' scripts/config/default.mk

make patch-admin-address ENV=default ADDR_ADMIN="$TEST_ADDR"
find ../contract -type f \( -name "*_test.gno" -o -name "*_filetest.gno" \) -delete

sed -i -E 's/-gas-fee [0-9]+ugnot/-gas-fee 1000000ugnot/g' scripts/deploy.mk
sed -i -E 's/-gas-wanted [0-9]+/-gas-wanted 120000000/g' scripts/deploy.mk

run_make_target() {
    local target=$1
    local attempt=0

    attempt=0
    while true; do
        set +e
        deploy_output=$(make "$target" ENV=default GNOLAND_RPC_URL=localhost:26657 CHAINID=dev ADDR_ADMIN="$TEST_ADDR" TOMORROW_MIDNIGHT=0 INCENTIVE_END=0 2>&1)
        deploy_status=$?
        set -e
        echo "$deploy_output"
        if [ $deploy_status -eq 0 ] || printf "%s" "$deploy_output" | grep -q "package already exists"; then
            return 0
        fi
        attempt=$((attempt + 1))
        if [ $attempt -ge 5 ]; then
            echo "failed target $target after retries"
            return $deploy_status
        fi
        sleep 2
    done
}

set +e
initial_output=$(make deploy ENV=default GNOLAND_RPC_URL=localhost:26657 CHAINID=dev ADDR_ADMIN="$TEST_ADDR" TOMORROW_MIDNIGHT=0 INCENTIVE_END=0 2>&1)
initial_status=$?
set -e
echo "$initial_output"

if [ $initial_status -ne 0 ]; then
    echo "full deploy failed, resuming with staged targets"
    for target in deploy-tokens deploy-libs deploy-base deploy-realms deploy-v1; do
        run_make_target "$target"
    done
fi

touch "$READY_FILE"

wait "$GNODEV_PID"
