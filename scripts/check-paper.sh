#!/data/data/com.termux/files/usr/bin/bash
set -uo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/android-minecraft-server"
SERVER_CONFIG="${SERVER_CONFIG:-$CONFIG_DIR/server.env}"
LOG="${PAPER_UPDATE_LOG:-$HOME/paper-updates.log}"
log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG"; }
if [[ ! -r "$SERVER_CONFIG" ]]; then
    log "ERROR: server config not readable: $SERVER_CONFIG"
    exit 1
fi
# shellcheck source=/dev/null
source "$SERVER_CONFIG"
: "${SERVER_DIR:?Set SERVER_DIR in server.env}"
if [[ -z "${PAPER_MINECRAFT_VERSION:-}" || "$PAPER_MINECRAFT_VERSION" == "CHANGE_ME" ]]; then
    log "ERROR: set PAPER_MINECRAFT_VERSION in $SERVER_CONFIG"
    exit 1
fi
if [[ -z "${PAPER_USER_AGENT:-}" ]]; then
    log "ERROR: set PAPER_USER_AGENT in $SERVER_CONFIG"
    exit 1
fi

API="https://fill.papermc.io/v3/projects/paper/versions/${PAPER_MINECRAFT_VERSION}/builds"
if ! RESPONSE=$(curl -fsSL --connect-timeout 10 --max-time 30 -H "User-Agent: $PAPER_USER_AGENT" "$API"); then
    log "ERROR: could not query PaperMC"
    exit 1
fi
if ! LATEST=$(printf '%s' "$RESPONSE" | jq -er 'if type == "array" then (map(select(.channel == "STABLE")) | .[0].id // empty) else empty end' 2>/dev/null) || [[ ! "$LATEST" =~ ^[0-9]+$ ]]; then
    log "ERROR: PaperMC returned no stable build for version $PAPER_MINECRAFT_VERSION"
    exit 1
fi
BUILD_FILE="${PAPER_BUILD_FILE:-$SERVER_DIR/.paper-build}"
if [[ ! -r "$BUILD_FILE" ]]; then
    log "Latest stable Paper build for Minecraft $PAPER_MINECRAFT_VERSION: $LATEST (installed build unknown; no update installed)"
    exit 0
fi
CURRENT=$(<"$BUILD_FILE")
if [[ ! "$CURRENT" =~ ^[0-9]+$ ]]; then
    log "ERROR: installed build marker is not numeric: $BUILD_FILE"
    exit 1
fi
if (( LATEST > CURRENT )); then
    log "New stable build available: $LATEST (installed: $CURRENT). No update installed."
else
    log "No newer stable build found (installed marker: $CURRENT)."
fi
