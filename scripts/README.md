# Scripts

Operational scripts are intentionally not included in this initial bundle.

Before committing a script from the live Termux installation:

1. Copy it to a staging folder, not directly from the live server.
2. Replace private IP addresses, usernames, tokens, keys, and personal paths with configuration variables or examples.
3. Remove hard-coded secrets and source them from a local ignored environment file.
4. Review cleanup and error-handling paths, especially restoration of Paper automatic saving (`save-on`).
5. Run syntax checks and test with a disposable copy before publishing.

Never commit the live `.termux` directory, private keys, tokens, world files, or backup archives.
