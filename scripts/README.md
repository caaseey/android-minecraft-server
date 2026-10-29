# Termux scripts

These scripts are public examples adapted from a personal Termux setup. They are not a drop-in production package. Review the configuration examples and adapt paths and versions before use.

## Configuration

Copy the example files from `config/` to `~/.config/android-minecraft-server/`, remove the `.example` suffix, and edit them locally. Keep real configuration files out of source control. Never commit the DuckDNS token, SSH private key, Minecraft worlds, logs, or backups.

The scripts expect `server.env` for Minecraft settings, `duckdns.env` for the DuckDNS domain and token, and `backup.env` for local backup paths and the Windows SSH destination. All configuration files are sourced as Bash; only put trusted values in them.

## Script behavior

- `start-services.sh` is intended for `~/.termux/boot/`. It requests a wake lock, starts SSH and cron if needed, attempts a DuckDNS update, and starts Paper in tmux if the session is absent.
- `check-paper.sh` reports the newest stable build for the configured Minecraft version. It does not download or install updates.
- `update-duckdns.sh` sends the configured domain and token to DuckDNS over HTTPS and requires an `OK` response.
- `backup-minecraft.sh` asks Paper to flush saves, pauses saving while making a TAR, checks the archive, sends it over SSH, compares SHA-256 hashes, and rotates old local archives after successful verification.

The backup script does not prove that Paper acknowledged its console commands. Test a restore separately and monitor the server after backups. Remote backup retention is not automated by this script.

## Install location

Put `check-paper.sh` and `backup-minecraft.sh` in `$HOME`. Put `update-duckdns.sh` at `~/duckdns/update.sh` to match the boot script's default path, and put `start-services.sh` in `~/.termux/boot/`. Install the required Termux packages and make the scripts executable with `chmod 700`. Copy the three example configs to `~/.config/android-minecraft-server/`, remove `.example` from each filename, fill in local values, and restrict them with `chmod 600`. Before the first automated backup, connect to the Windows SSH host once interactively and verify its host key; the backup script uses non-interactive SSH.

Do not run these examples against an important world until you have reviewed the configuration and tested recovery.
