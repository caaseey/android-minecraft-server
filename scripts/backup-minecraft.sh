#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/android-minecraft-server"
BACKUP_CONFIG="${BACKUP_CONFIG:-$CONFIG_DIR/backup.env}"
if [[ ! -r "$BACKUP_CONFIG" ]]; then
    printf 'ERROR: backup config not readable: %s\n' "$BACKUP_CONFIG" >&2
    exit 1
fi
# shellcheck source=/dev/null
source "$BACKUP_CONFIG"
: "${BACKUP_SOURCE_DIR:?Set BACKUP_SOURCE_DIR in backup.env}"
: "${BACKUP_DIR:?Set BACKUP_DIR in backup.env}"
: "${SSH_TARGET:?Set SSH_TARGET in backup.env}"
: "${SSH_KEY:?Set SSH_KEY in backup.env}"
: "${REMOTE_SCP_DIR:?Set REMOTE_SCP_DIR in backup.env}"
: "${REMOTE_HASH_DIR:?Set REMOTE_HASH_DIR in backup.env}"
TMUX_SESSION="${TMUX_SESSION:-mcserver}"
SAVE_SETTLE_SECONDS="${SAVE_SETTLE_SECONDS:-5}"
KEEP_LOCAL_BACKUPS="${KEEP_LOCAL_BACKUPS:-2}"

[[ -d "$BACKUP_SOURCE_DIR" ]] || { printf 'ERROR: backup source directory is missing.\n' >&2; exit 1; }
[[ -r "$SSH_KEY" ]] || { printf 'ERROR: SSH key is not readable.\n' >&2; exit 1; }
[[ "$SAVE_SETTLE_SECONDS" =~ ^[0-9]+$ ]] || { printf 'ERROR: SAVE_SETTLE_SECONDS must be an integer.\n' >&2; exit 1; }
[[ "$KEEP_LOCAL_BACKUPS" =~ ^[1-9][0-9]*$ ]] || { printf 'ERROR: KEEP_LOCAL_BACKUPS must be a positive integer.\n' >&2; exit 1; }
for command_name in tmux tar scp ssh sha256sum; do
    command -v "$command_name" >/dev/null 2>&1 || { printf 'ERROR: required command missing: %s\n' "$command_name" >&2; exit 1; }
done

mkdir -p "$BACKUP_DIR"
LOCK_DIR="$BACKUP_DIR/.backup-lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    printf 'ERROR: another backup appears to be running.\n' >&2
    exit 1
fi
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP="$BACKUP_DIR/minecraft-$DATE.tar"
SAVE_OFF=0
cleanup() {
    if (( SAVE_OFF )) && tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux send-keys -t "$TMUX_SESSION" 'save-on' Enter || true
    fi
    rmdir "$LOCK_DIR" 2>/dev/null || true
}
trap cleanup EXIT

if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
    tmux send-keys -t "$TMUX_SESSION" 'save-all flush' Enter
    sleep "$SAVE_SETTLE_SECONDS"
    SAVE_OFF=1
    tmux send-keys -t "$TMUX_SESSION" 'save-off' Enter
    sleep 2
fi
if tar -cf "$BACKUP" -C "$(dirname "$BACKUP_SOURCE_DIR")" "$(basename "$BACKUP_SOURCE_DIR")" && tar -tf "$BACKUP" >/dev/null; then
    printf 'Local archive created and readable.\n'
else
    printf 'ERROR: local archive creation or validation failed.\n' >&2
    rm -f "$BACKUP"
    exit 1
fi

SSH_OPTS=(-o BatchMode=yes -o IdentitiesOnly=yes -o ConnectTimeout=15 -i "$SSH_KEY")
scp "${SSH_OPTS[@]}" "$BACKUP" "$SSH_TARGET:$REMOTE_SCP_DIR/"
HASH_LOCAL=$(sha256sum "$BACKUP" | awk '{print $1}')
REMOTE_FILE="$REMOTE_HASH_DIR\\$(basename "$BACKUP")"
PS_COMMAND="(Get-FileHash -LiteralPath '$REMOTE_FILE' -Algorithm SHA256).Hash.ToLowerInvariant()"
HASH_REMOTE=$(ssh "${SSH_OPTS[@]}" "$SSH_TARGET" "powershell.exe -NoProfile -NonInteractive -Command \"$PS_COMMAND\"" | tr -d '\r' | tr '[:upper:]' '[:lower:]')
if [[ ! "$HASH_REMOTE" =~ ^[[:xdigit:]]{64}$ || "$HASH_LOCAL" != "$HASH_REMOTE" ]]; then
    printf 'ERROR: backup hash verification failed. Local archive kept.\n' >&2
    exit 1
fi
printf 'Remote archive verified against local SHA-256.\n'
mapfile -t OLD_BACKUPS < <(ls -1t "$BACKUP_DIR"/minecraft-*.tar 2>/dev/null | tail -n "+$((KEEP_LOCAL_BACKUPS + 1))")
if ((${#OLD_BACKUPS[@]})); then rm -f -- "${OLD_BACKUPS[@]}"; fi
printf 'Backup workflow completed. Remote retention is not managed by this script.\n'
