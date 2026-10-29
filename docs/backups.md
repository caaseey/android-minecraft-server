# Backup workflow

## Historical legacy workflow

The existing `backup-minecraft.sh` script is scheduled by cron for 03:00 daily. It:

1. Creates a local TAR archive of the Minecraft server directory.
2. Sends `save-all flush` to Paper and temporarily issues `save-off` while archiving.
3. Checks that the TAR archive can be read.
4. Transfers the archive to Windows over SCP.
5. Calculates SHA-256 on Android and compares it with the hash calculated on Windows.
6. Runs a Windows cleanup script and retains recent local copies.

The script has an `EXIT` trap intended to send `save-on` if it exits after disabling automatic saving. This behavior should still be reviewed and monitored in real use.

## Public example script

The public `scripts/backup-minecraft.sh` is a sanitized adaptation of the legacy workflow. It verifies the local TAR and compares SHA-256 after SCP, but it does not run the private Windows cleanup script or manage remote retention. It also cannot confirm that Paper acknowledged its console commands. Review the script and test restoration before relying on it.

## Verification performed

A manual run on 2026-10-21 created and transferred an archive of approximately 722 MB. The script reported `BACKUP_VERIFICADO_SHA256`, indicating that local and remote SHA-256 hashes matched.

The hash comparison was verified for that manual run. Earlier scheduled runs failed to transfer when the Windows PC was unreachable, so scheduled reliability still needs monitoring.

## Operational notes

- Keep local copies until remote transfer and hash verification succeed.
- Do not delete the last known-good backup to make room without first verifying another copy.
- A successful SCP transfer alone is not sufficient; verify the hash.
- Avoid running concurrent backup jobs.
- Do not publish world archives, backup logs, credentials, or private key material.

## Future improvements

- Confirm that Paper acknowledged `save-all flush`, `save-off`, and `save-on`.
- Use an append-only console log or another reliable mechanism to confirm fresh console responses.
- Add retry/queue handling for periods when Windows is offline.
- Test restoring a backup, not only creating and hashing an archive.
