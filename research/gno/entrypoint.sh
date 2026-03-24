#!/bin/bash

set -euo pipefail

echo "research runtime scaffold"
echo "GNOSWAP_REF=${GNOSWAP_REF:-main}"
echo "GNO_CHAIN_ID=${GNO_CHAIN_ID:-dev}"
echo "GNO_GNOKEY_REMOTE=${GNO_GNOKEY_REMOTE:-localhost:26657}"
echo "GNO_REST=${GNO_REST:-http://localhost:48888}"

sleep infinity
