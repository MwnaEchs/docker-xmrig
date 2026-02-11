#!/bin/bash
cd /xmrig
exec /xmrig/xmrig -o "${POOL}" -u "${WALLET}" -p x ${RIG_ID:+--rig-id "${RIG_ID}"} "$@"
