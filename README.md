# Android Minecraft Server

A self-hosted Minecraft Paper server running on an Android phone with Termux, remote administration over SSH, DuckDNS updates, and verified backups to a Windows PC.

> **Project status:** The server runs on Android. A manual backup transfer to Windows was tested successfully and the SHA-256 hash of the transferred archive matched the local archive. Automatic startup after a full Android reboot has **not yet been verified**.

## Overview

This project explores hosting a Minecraft Java server on an Android phone using Termux, with a Windows PC as a backup destination.

### Components

- **Android + Termux** — hosts the server and shell scripts.
- **Paper** — Minecraft server software.
- **tmux** — keeps the server console running in a named session.
- **OpenSSH** — remote administration and secure file transfer.
- **DuckDNS** — dynamic DNS updates.
- **cron** — schedules periodic checks, DNS updates, and backups.
- **Windows PowerShell** — verifies archive hashes and manages retained backups.

See [Architecture](docs/architecture.md) and [Backups](docs/backups.md).

## Verified capabilities

- Paper runs in a `tmux` session on Android.
- SSH access to Termux from Windows has been tested.
- The DuckDNS update script returned `OK` during a manual test. Earlier logs also showed intermittent DNS and HTTP 5xx errors.
- The legacy backup script creates a local TAR archive, transfers it to Windows over SSH/SCP, and compares SHA-256 hashes.
- A manual end-to-end backup was tested successfully: an archive of approximately 722 MB was transferred and its SHA-256 hash matched on the Windows PC.
- A cron entry is configured for daily backups at 03:00 local device time.

## Not yet verified / limitations

- Automatic startup of Termux services and Minecraft after a full Android reboot has not been confirmed.
- Historical backup transfers failed while the Windows PC was unreachable. Keep local copies until the scheduled workflow is confirmed reliable.
- Automatic failover to a second Minecraft server is **out of scope**.
- DuckDNS has had intermittent errors in previous logs, despite a later successful manual update.

## Security and privacy

Never commit:
- DuckDNS tokens or other credentials.
- SSH private keys, passwords, or secret environment files.
- Minecraft world data, TAR backups, server logs, or personal network details.
- Machine-specific configuration unless intentionally sanitized.

Review every file for secrets before publishing scripts.

## Repository layout

```text
android-minecraft-server/
├── README.md
├── .gitignore
├── config/
│   ├── server.env.example
│   ├── duckdns.env.example
│   └── backup.env.example
├── docs/
│   ├── architecture.md
│   ├── backups.md
│   └── troubleshooting.md
└── scripts/
    ├── start-services.sh
    ├── check-paper.sh
    ├── update-duckdns.sh
    ├── backup-minecraft.sh
    └── README.md
```

The example scripts are public-facing adaptations, not production-ready defaults. Review `scripts/README.md` before use. Real credentials and machine-specific configuration remain local.

## Documentation

- [Architecture](docs/architecture.md)
- [Backup workflow](docs/backups.md)
- [Troubleshooting notes](docs/troubleshooting.md)

## Disclaimer

This repository documents a personal homelab project. Commands, paths, Android behavior, and network configuration may need adaptation for other devices. Test recovery procedures before relying on the server for important worlds.
