#!/data/data/com.termux/files/usr/bin/bash
set -uo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/android-minecraft-server"
SERVER_CONFIG="${SERVER_CONFIG:-$CONFIG_DIR/server.env}"
BOOT_LOG="${BOOT_LOG:-$HOME/termux-boot.log}"
mkdir -p "$(dirname "$BOOT_LOG")"
exec >>"$BOOT_LOG" 2>&1
log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

if [[ ! -r "$SERVER_CONFIG" ]]; then
    log "ERROR: server config not readable: $SERVER_CONFIG"
    exit 1
fi
# shellcheck source=/dev/null
source "$SERVER_CONFIG"
: "${SERVER_DIR:?Set SERVER_DIR in server.env}"
: "${SERVER_JAR:?Set SERVER_JAR in server.env}"
: "${TMUX_SESSION:?Set TMUX_SESSION in server.env}"
: "${JAVA_BIN:?Set JAVA_BIN in server.env}"

log "Startup script started"
termux-wake-lock || log "WARNING: could not acquire wake lock"
sleep 30
if ! pgrep -x sshd >/dev/null 2>&1; then
    sshd || log "WARNING: could not start sshd"
fi
if ! pgrep -f '(^|/)crond($| )' >/dev/null 2>&1; then
    crond || log "WARNING: could not start crond"
fi

DUCKDNS_SCRIPT="${DUCKDNS_SCRIPT:-$HOME/duckdns/update.sh}"
if [[ -x "$DUCKDNS_SCRIPT" ]]; then
    "$DUCKDNS_SCRIPT" || log "WARNING: DuckDNS update failed"
elif [[ -f "$DUCKDNS_SCRIPT" ]]; then
    bash "$DUCKDNS_SCRIPT" || log "WARNING: DuckDNS update failed"
else
    log "WARNING: DuckDNS script is missing: $DUCKDNS_SCRIPT"
fi

if ! command -v tmux >/dev/null 2>&1 || ! command -v "$JAVA_BIN" >/dev/null 2>&1; then
    log "ERROR: tmux or Java is unavailable"
    exit 1
fi
if [[ ! -d "$SERVER_DIR" || ! -f "$SERVER_DIR/$SERVER_JAR" ]]; then
    log "ERROR: server directory or JAR is missing"
    exit 1
fi
if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
    read -r -a JAVA_ARGS <<<"${JAVA_OPTS:-}"
    SERVER_COMMAND=$(printf '%q ' "$JAVA_BIN" "${JAVA_ARGS[@]}" -jar "$SERVER_JAR" --nogui)
    tmux new-session -d -s "$TMUX_SESSION" -c "$SERVER_DIR" "$SERVER_COMMAND"
    log "Started Paper in tmux session $TMUX_SESSION"
else
    log "Paper tmux session already exists"
fi
log "Startup script finished"
