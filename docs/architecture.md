# Architecture

## High-level design

```text
Players
   |
   | Minecraft connection (configured separately)
   v
Android phone
  - Termux
  - Paper server
  - tmux session
  - cron jobs
  - DuckDNS update script
   |
   | SSH / SCP
   v
Windows PC
  - OpenSSH server
  - PowerShell hash verification
  - C:\\MinecraftBackups\\received
```

## Roles

### Android phone

The phone hosts Paper in a `tmux` session named `mcserver`. Termux also provides OpenSSH, cron, and shell scripts for DNS updates and backup creation.

### Windows PC

The PC receives backup archives over SSH/SCP. PowerShell calculates SHA-256 hashes and manages retained backup files.

### Dynamic DNS

A DuckDNS update script is configured for the hostname. It returned `OK` in a manual test, although previous logs recorded intermittent DNS lookup and HTTP 500/502 failures.

## Startup behavior

A Termux:Boot script exists at `~/.termux/boot/start-services.sh`. Its syntax was checked and it ran manually. However, a full reboot test did not confirm that Termux:Boot executed it automatically. Treat automatic startup as unverified until tested after an Android reboot.

## Failover

Automatic failover to Windows is out of scope. Windows is currently a backup destination, not a verified active/standby Minecraft host.
