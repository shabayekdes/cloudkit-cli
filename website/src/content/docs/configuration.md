---
title: Configuration
description: Environment variables that change how CloudKit behaves.
---

Set these environment variables in your `~/.zshrc` or `~/.bashrc`, before or after sourcing `main.sh`.

| Variable | Effect |
|---|---|
| `CLOUDKIT_PROD_PATTERN` | Extended regex (case-insensitive) for production names. Matching AWS profiles or gcloud configurations/projects get a red **PRODUCTION** banner and a `[PROD]` prompt marker. The default matches `prod`, `production` or `prd` as a separate word. |
| `CLOUDKIT_NO_PROMPT=1` | Don't change the shell prompt (useful with Starship or Powerlevel10k) |
| `CLOUDKIT_NO_CLEAR=1` | Don't clear the terminal before showing the session table |
| `CLOUDKIT_GCLOUD_GLOBAL=1` | New terminals use gcloud's global active configuration instead of starting with no gcloud session |
| `CLOUDKIT_HOME` | Install directory used by the installer (default: `~/.cloudkit`) |

## Example

```bash
# ~/.zshrc
export CLOUDKIT_PROD_PATTERN='(prod|live)'
export CLOUDKIT_NO_PROMPT=1
source ~/.cloudkit/main.sh
```
