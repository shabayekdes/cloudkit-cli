<p align="center">
  <img src="assets/logo.svg" alt="CloudKit CLI" width="128" height="128">
</p>

<h1 align="center">CloudKit CLI</h1>

<p align="center">
  <b>One <code>ck</code> command for AWS and GCloud.</b><br>
  Interactive sessions, service wrappers, and a color-coded prompt -- across both clouds.
</p>

<p align="center">
  <a href="https://github.com/shabayekdes/cloudkit-cli/actions/workflows/ci.yml"><img src="https://github.com/shabayekdes/cloudkit-cli/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/shell-bash%20%7C%20zsh-4EAA25" alt="Shell: bash | zsh">
  <img src="https://img.shields.io/badge/clouds-AWS%20%7C%20GCloud-FF8A00" alt="Clouds: AWS | GCloud">
</p>

## User Guide

Shell helpers for AWS and GCloud. Source one file, get a single `ck` command with interactive session management, service wrappers, and a color-coded prompt -- across both clouds.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1) Prerequisites

**Common**

- Install `jq` for JSON parsing (macOS: `brew install jq`)
- Install `python3` (3.6+) for cross-platform credential expiry parsing

**AWS**

- Install AWS CLI v2 (`aws --version`)
- Configure AWS profiles in `~/.aws/config` (SSO, static keys, or credential_process -- all supported)
- Install `expect` for file upload functionality (macOS: `brew install expect`)
- Install `nc` (netcat) for file transfers (usually pre-installed on macOS/Linux)

**GCloud**

- Install Google Cloud SDK / `gcloud` CLI (`gcloud --version`)
- Create at least one gcloud configuration (see examples below)

**AWS configuration** (`~/.aws/config`):

```ini
[sso-session my-session]
sso_start_url = https://example.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[profile my-sso-profile]
sso_session = my-session
sso_account_id = 123456789012
sso_role_name = ReadOnly
region = us-east-1
output = json
```

Chained profiles (role assumption via `source_profile`) are also supported:

```ini
[profile dev-admin]
source_profile = my-sso-profile
role_arn = arn:aws:iam::098765432109:role/AdminRole
region = eu-west-1

[profile prod-readonly]
role_arn = arn:aws:iam::111222333444:role/ReadOnly
source_profile = my-sso-profile
region = us-west-2
```

**GCloud configuration** (`~/.config/gcloud/configurations/`):

Each gcloud configuration is stored as a separate file. Create and manage them with the `gcloud` CLI:

```bash
# Create a configuration for a project
gcloud config configurations create my-project
gcloud config set core/account user@example.com
gcloud config set core/project my-gcp-project
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# Create another configuration for a different project
gcloud config configurations create staging
gcloud config set core/account user@example.com
gcloud config set core/project my-staging-project
gcloud config set compute/region europe-west1
gcloud config set compute/zone europe-west1-b
```

The resulting config files look like this (`~/.config/gcloud/configurations/config_my-project`):

```ini
[core]
account = user@example.com
project = my-gcp-project

[compute]
region = us-central1
zone = us-central1-a
```

`ck gcloud login` discovers these configurations via `gcloud config configurations list` and presents them for selection.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2) Setup

Source `main.sh` to load all helpers into your shell.

- **One-time (current shell only):**

```bash
source /path/cloudkit-cli/main.sh
```

- **Permanent (every new shell):**
  Add the line above to `~/.zshrc`, `~/.bashrc`, or `~/.bash_profile`.

Notes:
- `main.sh` exports `CLOUDKIT_DIR` and loads everything behind a single `ck` command.
- Run `ck help` for the command list, or `ck help <command>` (e.g. `ck help gce`) for its options.

**Quick reference**

```
ck aws login | switch | logout | sso <profile>
ck gcloud login [--reauth] | switch | logout
ck status                          # active AWS + gcloud sessions
ck ec2 <command>                   # ls, session, run, stop, port-forward, upload
ck ecs <command>                   # clusters, services, tasks, exec, logs, stop, describe
ck gce <command>                   # ls, start, stop, ssh, scp, port-forward
ck mig <command>                   # list, describe, recreate, restart
ck help [command]
```

**Configuration** (environment variables, set before or after sourcing)

| Variable | Effect |
|---|---|
| `CLOUDKIT_PROD_PATTERN` | Extended regex (case-insensitive) for production names; matching AWS profiles or gcloud configs/projects get a red **PRODUCTION** banner and a `[PROD]` prompt marker. Default matches `prod`, `production`, `prd` as a separate word (`my-prod-account`, not `products-api`) |
| `CLOUDKIT_NO_PROMPT=1` | Don't change the shell prompt (useful with Starship/Powerlevel10k, which already show the cloud context) |
| `CLOUDKIT_NO_CLEAR=1` | Don't clear the terminal before showing the session table |
| `CLOUDKIT_GCLOUD_GLOBAL=1` | New terminals use gcloud's global active configuration instead of starting with no gcloud session |

**Upgrading from the old command names**

The separate commands were replaced by `ck`. Open a new shell after upgrading (re-sourcing `main.sh` does not remove functions an existing shell already has).

| Old | New |
|---|---|
| `aws_session` / `aws_switch` / `aws_logout` | `ck aws login` / `ck aws switch` / `ck aws logout` |
| `sso_login <profile>` | `ck aws sso <profile>` |
| `gcloud_session` / `gcloud_switch` / `gcloud_logout` | `ck gcloud login` / `ck gcloud switch` / `ck gcloud logout` |
| `ec2 …` / `ecs …` / `gce …` | `ck ec2 …` / `ck ecs …` / `ck gce …` |
| `gce-ig …` | `ck mig …` |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 3) Commands -- AWS

- `ck aws login`
  - Lists all configured AWS profiles from `~/.aws/config` -- SSO, static keys, and credential_process
  - If only one profile exists, it is auto-selected (no prompt)
  - Performs SSO login if not already authenticated (SSO profiles only)
  - After authentication, detects **chained profiles** (profiles with `source_profile`):
    - **One chained profile**: auto-selects it
    - **Multiple chained profiles**: displays a selection table
    - **No chained profiles**: continues with the base profile
  - Clears the terminal and displays a session table:
    - **Account**, **Profile**, **Region**
    - **Identity** -- readable caller identity: `IAM user jane`, `SSO AdministratorAccess as jane@example.com`, `Role Deploy as ci` (root is shown in red)
    - **Credentials** -- type and expiry: `SSO · expires 2026-10-21 14:20 UTC (in 7h 12m)`, `Static keys · no expiry`
  - Shows a red **PRODUCTION** banner when the profile matches `CLOUDKIT_PROD_PATTERN`
  - Updates the shell prompt with `[profile:region]` (bash and zsh), prefixed with a red `[PROD]` for production profiles
  - Warns if credentials will expire in ≤ 15 minutes (yellow) or ≤ 5 minutes (red)

- `ck aws logout`
  - Unsets all AWS session environment variables (`AWS_PROFILE`, `AWS_REGION`, etc.)
  - Restores the original shell prompt
  - Does not delete any files from `~/.aws/`

- `ck aws switch`
  - Switches to a different profile without re-running the full `ck aws login` flow
  - Triggers SSO login automatically if the selected profile needs it
  - Clears the terminal, shows the session table at the top, updates the prompt, and checks for upcoming expiry

- `ck aws sso <profile>`
  - Shortcut for `aws sso login --profile <profile>`

- `ck ec2` with subcommands:
  - `ck ec2 ls` -- list all EC2 instances (id, name, state)
  - `ck ec2 ls-running` -- list only running EC2 instances
  - `ck ec2 ls-stopped` -- list only stopped EC2 instances
  - `ck ec2 session [instance-id]` -- start an SSM shell session (omit the ID to pick from running instances)
  - `ck ec2 run <instance-id>` -- start (run) an EC2 instance
  - `ck ec2 stop <instance-id>` -- stop an EC2 instance
  - `ck ec2 port-forward <remote-port> <local-port> <instance-id> [host]` -- start SSM port forwarding
    - **Without host:** forwards from the EC2 instance itself (e.g., web server on the instance)
    - **With host:** forwards from a remote service through the EC2 instance (e.g., RDS, ElastiCache)
  - `ck ec2 upload <instance-id> <local-file> [remote-path] [port]` -- upload a file to an EC2 instance via SSM port forwarding

- `ck ecs` with subcommands:
  - `ck ecs clusters` -- list all ECS clusters
  - `ck ecs services <cluster>` -- list services in a cluster
  - `ck ecs tasks <cluster> [--running]` -- list tasks in a cluster (optionally only running)
  - `ck ecs service-tasks <cluster> <service> [--running]` -- list tasks for a specific service
  - `ck ecs task-info <cluster> <task-id>` -- get detailed task information (status, container, image, uptime)
  - `ck ecs exec <cluster> <task-id> <container> [command]` -- execute command in a container (default: /bin/bash)
  - `ck ecs logs <cluster> <task-id> [--tail N]` -- get task information and container logs
  - `ck ecs stop <cluster> <task-id> [reason]` -- stop a running task
  - `ck ecs describe <cluster> <service>` -- describe a service (status, running/desired count, task definition)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4) Commands -- GCloud

- `ck gcloud login [--reauth]`
  - Lists all gcloud configurations and lets you select one
  - The selection applies to **this terminal only**, like `AWS_PROFILE`: it sets `CLOUDSDK_ACTIVE_CONFIG_NAME`, which gcloud (and tools that run it) and prompt themes like Spaceship honour
  - **New terminals start with no gcloud session**, like a shell without `AWS_PROFILE`: sourcing `main.sh` sets an empty `CLOUDSDK_CORE_ACCOUNT`, so gcloud commands report "no active account selected" until you run `ck gcloud login` or `ck gcloud switch`. No extra gcloud configuration is created. Spaceship's gcloud prompt section is hidden until you pick one (your own `SPACESHIP_GCLOUD_SHOW` setting is restored afterwards); other prompt themes that read gcloud's config files directly may still show the global configuration, so check `ck status` for the real state. Set `CLOUDKIT_GCLOUD_GLOBAL=1` to keep gcloud's global active configuration in new terminals instead
  - If only one configuration exists, it is auto-selected (no prompt)
  - Validates existing credentials or initiates `gcloud auth login`
  - Pass `--reauth` to force re-authentication
  - Clears the terminal and displays account/config/project/region and token expiry in a styled table
  - **ADC** row -- what SDKs, Terraform, and client libraries use (Application Default Credentials):
    - `same as gcloud account` (green), `user login (account not recorded)`, `service account …`, `impersonating …`
    - ⚠ `not set` or `different account` (yellow), with the `gcloud auth application-default login` fix
    - Read from the local ADC file or `GOOGLE_APPLICATION_CREDENTIALS`; no network calls
  - Shows a red **PRODUCTION** banner when the configuration or project matches `CLOUDKIT_PROD_PATTERN`
  - Updates the shell prompt with `[gcloud:account:project]` (bash and zsh), prefixed with a red `[PROD]` for production. With an AWS session active too, both show: `[profile:region] [gcloud:account:project]`; logging out of one keeps the other
  - Warns if credentials will expire in ≤ 15 minutes (yellow) or ≤ 5 minutes (red) **and cannot auto-refresh** (no refresh token); normal user logins and service accounts refresh silently, so no warning is shown for them

- `ck gcloud logout`
  - Unsets gcloud session environment variables (`GCLOUD_ACTIVE_CONFIG`, `GCLOUD_ACCOUNT`, `GCLOUD_PROJECT`, `GCLOUD_REGION`) and leaves this terminal without a gcloud account again (or on gcloud's global default with `CLOUDKIT_GCLOUD_GLOBAL=1`)
  - Restores the original shell prompt

- `ck gcloud switch`
  - Switches this terminal to a different gcloud configuration without re-running full authentication
  - Clears the terminal, shows the session table at the top, and updates the prompt

- `ck status`
  - Shows the active AWS profile/account/region and gcloud configuration/account/project in one table
  - Reads the session variables set by `ck aws login` / `ck gcloud login`; makes no network calls
  - When `ck gcloud login` hasn't run in this shell, shows gcloud's active configuration from its local config files instead

- `ck gce` with subcommands:
  - `ck gce ls [--filter <pattern>]` -- list GCE instances (optional name filter)
  - `ck gce ls-running` -- list only running instances
  - `ck gce ls-stopped` -- list only stopped (`TERMINATED`) instances
  - `ck gce start <instance>` / `ck gce stop <instance>` / `ck gce reset <instance>` -- start, stop, or hard-reset a VM
  - `ck gce ssh [instance] [options] [command]` -- SSH to a GCE VM (optional remote command)
    - Omit the instance to pick from running VMs (filtered by `--zone`/`--project` if given); a single running VM is auto-selected
    - `--tunnel-iap` / `--no-iap` -- force or disable connecting through IAP (IAP is used automatically when `--forward` is given)
    - `--forward <local:host:remote>` -- local port forward; repeatable
    - `--tunnel-only` -- with `--forward`, hold the tunnel(s) open without a shell
  - `ck gce scp <source>... <destination> [--tunnel-iap] [-r]` -- copy files to/from a GCE VM
  - `ck gce port-forward <remote-port> <local-port> <instance> [host]` -- forward a port via IAP
    - **Without host:** forwards from the VM itself (`gcloud compute start-iap-tunnel`)
    - **With host:** forwards from a remote service through the VM (e.g., Cloud SQL private IP, Memorystore)
  - All instance commands accept `--zone <zone>` and `--project <project>`. When `--zone` is omitted, it is looked up from the instance name.

- `ck mig` (managed instance groups) with subcommands:
  - `ck mig list [--region <region>]` -- list managed instance groups
  - `ck mig describe <group> --region <region>` -- describe a managed instance group
  - `ck mig recreate <group> --region <region>` -- replace instances (rolling replace)
  - `ck mig restart <group> --region <region>` -- restart instances (rolling restart)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5) Typical Workflow

**AWS**

```
source /path/cloudkit-cli/main.sh
ck aws login           # select profile, SSO login, view session table
ck ec2 ls-running      # list running instances
ck ec2 session         # pick a running instance and SSM into it
ck aws switch          # switch to another profile mid-session
ck status              # see what is active
ck aws logout          # clear session
```

**GCloud**

```
source /path/cloudkit-cli/main.sh
ck gcloud login        # select config, authenticate, view session table
ck gce ls              # list GCE instances
ck gce ssh             # pick a running VM and SSH into it
ck gce ssh my-vm       # zone is auto-detected
ck gce ssh my-vm --forward 3308:127.0.0.1:3306 --tunnel-only
ck gce port-forward 3306 3308 my-vm 10.20.0.5
ck mig list            # list managed instance groups
ck gcloud switch       # switch to another config
ck gcloud logout       # clear session
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 6) Verification Steps

**AWS**

- `ck aws login` shows a table with correct Account (formatted `XXXX-XXXX-XXXX`), Profile, Region, Identity, and Credentials
- Single-profile auto-selection works without prompting
- Chained profiles (via `source_profile`) are detected and offered after authentication
- Shell prompt updates to `[profile:region]`
- `ck ec2 ls` outputs instance data without errors
- `ck ecs clusters` lists available ECS clusters

**GCloud**

- `ck gcloud login` shows a table with Account, Configuration, Project, Region, Token Expiry, and ADC
- Single-config auto-selection works without prompting
- Shell prompt updates to `[gcloud:account:project]`
- `ck gce ls` lists GCE instances
- `ck mig list` lists managed instance groups

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 7) Troubleshooting

**Common**

- `jq: command not found` -- install `jq` (macOS: `brew install jq`)

**AWS**

- `aws: command not found` or AWS CLI v1 detected -- install `awscli` (macOS: `brew install awscli`)
- No profiles listed in `ck aws login` -- ensure `~/.aws/config` profiles include `sso_account_id`, `aws_access_key_id`, or `credential_process`
- Chained profile not detected -- ensure it has `source_profile = <base-profile-name>` matching exactly
- Chained profile fails to assume role -- verify the `role_arn` is correct and permissions allow it
- SSM session errors -- ensure the instance has SSM agent installed and proper IAM role
- ECS exec fails -- ensure ECS Exec is enabled (`enableExecuteCommand: true`) and the task role has SSM permissions
- File upload fails -- ensure `expect` and `nc` are installed, SSM agent is running, and the port is available

**GCloud**

- `gcloud: command not found` -- install the Google Cloud SDK
- No configurations listed -- create one with `gcloud config configurations create <name>` and set account/project
- Authentication fails -- try `ck gcloud login --reauth` to force re-login
- `You do not currently have an active account selected` in a new terminal -- expected: run `ck gcloud login` or `ck gcloud switch` first (or set `CLOUDKIT_GCLOUD_GLOBAL=1`)
- `ck gce ssh` permission denied -- ensure your account has `compute.instances.osLogin` or OS Login is configured
- `ck gce` reports an instance in multiple zones -- pass `--zone` explicitly
- IAP tunnel fails -- ensure a firewall rule allows ingress from `35.235.240.0/20` and your account has `iap.tunnelInstances.accessViaIAP`
- `ck mig` region required -- most instance group commands require `--region <region>`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 8) Repository Structure

- `assets/logo.svg` -- project logo
- `main.sh` -- entrypoint; exports `CLOUDKIT_DIR`, loads session and service helpers and `ck`
- `ck.sh` -- the `ck` command: dispatches to session and service helpers, `ck status`, `ck help`
- `session.sh` -- session management for both AWS and GCloud: profile/config picker, SSO/auth login, session table, prompt updates
- `services/_picker.sh` -- shared interactive instance picker used by `ck ec2 session` and `ck gce ssh`
- `services/ec2.sh` -- `ck ec2`: list instances, SSM session, port forwarding, file upload
- `services/_ec2_upload.sh` -- file upload script using Expect for SSM port forwarding transfers
- `services/ecs.sh` -- `ck ecs`: clusters, services, tasks, exec, logs, stop, describe
- `services/gce.sh` -- `ck gce`: list, start/stop/reset, SSH, SCP, IAP port forwarding
- `services/gce_ig.sh` -- `ck mig`: list, describe, recreate, restart managed instance groups

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 9) Development / Testing

- **Lint (Shellcheck)**
  Install [Shellcheck](https://github.com/koalaman/shellcheck) (e.g. `brew install shellcheck` on macOS), then run:
  ```bash
  make shellcheck
  ```

- **Smoke tests** (no AWS/GCloud credentials required):
  ```bash
  make test
  ```

- **CI**
  On push or pull request to `main`, GitHub Actions runs Shellcheck and the smoke tests. See `.github/workflows/ci.yml`.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 10) Uninstall / Disable

- Remove or comment out the `source /path/cloudkit-cli/main.sh` line from:
  - `~/.zshrc` (Zsh) or
  - `~/.bashrc` / `~/.bash_profile` (Bash)
- Restart your terminal (or re-source the rc file)
