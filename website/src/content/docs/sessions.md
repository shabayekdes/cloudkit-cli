---
title: Sessions
description: Log in to AWS profiles and gcloud configurations per terminal with ck aws and ck gcloud.
---

CloudKit keeps one active AWS profile and one active gcloud configuration **per terminal**. Switching in one terminal never affects another.

## ck aws login

Pick an AWS profile from `~/.aws/config`, run an SSO login if the token is missing or expired, and show the session table.

```bash
ck aws login
```

```
Account      1234-5678-9012
Profile      dev-admin
Region       eu-west-1
Identity     SSO AdministratorAccess as jane@example.com
Credentials  SSO · expires 2026-10-21 14:20 UTC (in 7h 12m)
```

Profiles are listed if they use SSO (`sso_session` / `sso_account_id`), access keys, or `credential_process`, including chained roles.

## ck aws switch

Switch this terminal to another AWS profile.

```bash
ck aws switch
```

## ck aws sso

Shortcut for `aws sso login --profile <profile>`.

```bash
ck aws sso my-profile
```

## ck aws logout

Clear the AWS session from this terminal.

```bash
ck aws logout
```

## ck gcloud login

Pick a gcloud configuration, authenticate if needed, and show the session table.

```bash
ck gcloud login
ck gcloud login --reauth     # force re-authentication
```

The selection applies to the current terminal only (via `CLOUDSDK_ACTIVE_CONFIG_NAME`). New terminals start with no gcloud session until you run `ck gcloud login`. Set [`CLOUDKIT_GCLOUD_GLOBAL=1`](/configuration/) to use gcloud's global configuration instead.

## ck gcloud switch

Switch this terminal to another gcloud configuration.

```bash
ck gcloud switch
```

## ck gcloud logout

Clear the gcloud session from this terminal.

```bash
ck gcloud logout
```

## Prompt and production marker

While a session is active, your prompt is prefixed with `[profile:region]` for AWS and `[gcloud:account:project]` for gcloud.

:::caution[Production]
When a profile, configuration or project name matches `prod`, `production` or `prd` as a separate word, CloudKit shows a red **▲ PRODUCTION** banner and a `[PROD]` prompt marker. Change what counts as production with [`CLOUDKIT_PROD_PATTERN`](/configuration/).
:::

Turn the prompt changes off with `CLOUDKIT_NO_PROMPT=1` if you use Starship or Powerlevel10k.

## ck status

Show the active AWS and gcloud sessions in this terminal. It makes no network calls.

```bash
ck status
```
