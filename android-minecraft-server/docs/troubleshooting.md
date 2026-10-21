# Troubleshooting notes

## SSH connection to Windows times out

Historical backup logs recorded `Connection timed out` and `No route to host` for the Windows SSH endpoint. Later, SSH succeeded and a manual backup transfer completed.

Check that the Windows PC is powered on, connected to the network, and running its SSH server. Confirm the current LAN address before relying on a hard-coded address.

## DuckDNS update errors

The update script returned `OK` in a manual test. Earlier logs contained intermittent DNS resolution errors and HTTP 500/502 responses. A successful manual update does not prove every scheduled update will succeed.

Do not put the DuckDNS token in source control or public issue reports.

## Termux:Boot

The startup script exists and passes `bash -n`. Manual execution completed, but automatic execution after a full reboot remains unverified. Test after reboot by checking the boot log, the `mcserver` tmux session, `crond`, and SSH.

## Paper async-profiler warning

The console showed a Spark async-profiler warning about missing `libdl.so.2`. The server continued starting and saving the world. The warning was non-fatal in the observed session; do not assume it is the cause of unrelated connectivity issues.
