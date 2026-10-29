#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/android-minecraft-server"
DUCKDNS_CONFIG="${DUCKDNS_CONFIG:-$CONFIG_DIR/duckdns.env}"
if [[ ! -r "$DUCKDNS_CONFIG" ]]; then
    printf 'ERROR: DuckDNS config not readable: %s\n' "$DUCKDNS_CONFIG" >&2
    exit 1
fi
# shellcheck source=/dev/null
source "$DUCKDNS_CONFIG"
if [[ -z "${DUCKDNS_DOMAIN:-}" || -z "${DUCKDNS_TOKEN:-}" || "$DUCKDNS_TOKEN" == "REPLACE_WITH_YOUR_DUCKDNS_TOKEN" ]]; then
    printf 'ERROR: configure DUCKDNS_DOMAIN and DUCKDNS_TOKEN locally.\n' >&2
    exit 1
fi
RESPONSE=$(curl -fsS --connect-timeout 10 --max-time 30 --get \
    --data-urlencode "domains=$DUCKDNS_DOMAIN" \
    --data-urlencode "token=$DUCKDNS_TOKEN" \
    --data-urlencode 'ip=' \
    'https://www.duckdns.org/update')
if [[ "$RESPONSE" != "OK" ]]; then
    printf 'ERROR: DuckDNS did not confirm the update.\n' >&2
    exit 1
fi
printf 'DuckDNS update confirmed.\n'
