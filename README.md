<p align="center">
  <img src="assets/logo.svg" alt="CloudKit — CLI toolkit for AWS & Google Cloud" width="580">
</p>

<p align="center">
  <a href="https://github.com/shabayekdes/cloudkit-cli/actions/workflows/ci.yml"><img src="https://github.com/shabayekdes/cloudkit-cli/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/shell-bash%20%7C%20zsh-4EAA25" alt="Shell: bash | zsh">
  <img src="https://img.shields.io/badge/clouds-AWS%20%7C%20Google%20Cloud-FF8A00" alt="Clouds: AWS | Google Cloud">
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey" alt="Platform: macOS | Linux">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT"></a>
</p>

<p align="center">
  <b>One <code>ck</code> command for AWS and Google Cloud.</b><br>
  Pick a profile, log in, and jump into your instances — without remembering a single long CLI flag.
</p>

---

## What is CloudKit?

CloudKit is a set of shell helpers that wraps the AWS CLI and `gcloud` behind a single `ck` command:

- **Session management** — pick an AWS profile (SSO, access keys, chained roles) or a gcloud configuration from a list, log in if needed, and see account, region, identity and credential expiry in one table.
- **Per-terminal sessions** — each terminal has its own active profile/configuration, like `AWS_PROFILE`. Your prompt shows `[profile:region]` and `[gcloud:account:project]`, with a red `[PROD]` marker and banner for production.
- **Service shortcuts** — list, start, stop and connect to EC2 and GCE instances, exec into ECS tasks, forward ports through SSM or IAP, and manage instance groups. Most commands offer an interactive picker when you leave out the instance.
- **Guided setup** — `ck setup` walks you through creating AWS profiles and gcloud configurations; `ck doctor` checks that everything is installed and configured.

Works in **bash** and **zsh** on **macOS** and **Linux**.

## Installation

### Quick install

```bash
curl -fsSL https://github.com/shabayekdes/cloudkit-cli/releases/latest/download/install.sh | bash
```

The installer:

1. Asks which clouds you use — AWS, Google Cloud, or both
2. Installs missing dependencies after one confirmation, using `brew` (macOS) or `apt` / `dnf` / `yum` / `pacman` (Linux)
3. Downloads the **latest release** of CloudKit to `~/.cloudkit` (or switches an existing install to it)
4. Adds a `source …/main.sh` block to `~/.zshrc` / `~/.bashrc` (re-running never duplicates it)
5. Offers to set up your AWS / gcloud credentials
6. Offers to restart your shell so `ck` works right away

Pass options after `bash -s --`, for example `curl … | bash -s -- --gcp --yes`:

| Option | Effect |
|---|---|
| `--aws` / `--gcp` / `--all` | Install dependencies for one cloud or both (default: ask) |
| `--yes` | Don't ask for confirmation |
| `--no-deps` | Skip dependency installation |
| `--no-rc` | Don't edit shell rc files |
| `--no-setup` | Don't offer credential setup |
| `--dir <path>` | Install directory (default: `$CLOUDKIT_HOME` or `~/.cloudkit`) |
| `--uninstall` | Remove CloudKit (never touches `~/.aws` or gcloud configuration) |

To upgrade, re-run the same command: it moves `~/.cloudkit` to the newest release. Check what you have with `ck version`.

### From a clone

```bash
git clone https://github.com/shabayekdes/cloudkit-cli.git
cd cloudkit-cli
./install.sh
```

Running `./install.sh` from a clone uses that clone in place, so `git pull` or `git checkout <tag>` controls the version.

### Dependencies

The installer handles these for you; install them by hand if you prefer:

| Tool | Needed for |
|---|---|
| `jq`, `python3` | everything |
| [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | AWS commands |
| [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) | `ck ec2 session`, `port-forward`, `upload`, `ck ecs exec` |
| `expect`, `nc` | `ck ec2 upload` |
| [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (`gcloud`) | Google Cloud commands |

Then add `source /path/to/cloudkit-cli/main.sh` to your `~/.zshrc` or `~/.bashrc`.

### Set up credentials

```bash
ck doctor          # check tools, AWS profiles, gcloud configurations, ADC, rc file
ck setup aws       # AWS SSO (IAM Identity Center), access keys, or a chained role
ck setup gcloud    # create/update a gcloud configuration, log in, optional ADC
```

`ck setup` writes standard files (`~/.aws/config`, gcloud configurations), so profiles you already have keep working.

### Uninstall

```bash
~/.cloudkit/install.sh --uninstall
```

Removes the rc block and `~/.cloudkit`. Your `~/.aws` and gcloud configuration are left untouched.

## Usage

Run `ck help` for all commands, or `ck help <command>` (e.g. `ck help gce`) for a command's options.

### AWS

```bash
ck aws login                 # pick a profile, SSO login if needed, show the session table
ck aws switch                # switch to another profile in this terminal
ck aws sso my-profile        # shortcut for: aws sso login --profile my-profile
ck aws logout                # clear the AWS session from this terminal
```

After login you get a session table like:

```
Account      1234-5678-9012
Profile      dev-admin
Region       eu-west-1
Identity     SSO AdministratorAccess as jane@example.com
Credentials  SSO · expires 2026-10-21 14:20 UTC (in 7h 12m)
```

**EC2**

```bash
ck ec2 ls                    # all instances (id, name, state)
ck ec2 ls-running            # running instances only
ck ec2 session               # pick a running instance and open an SSM shell
ck ec2 session i-0abc123     # SSM shell on a specific instance
ck ec2 run i-0abc123         # start an instance
ck ec2 stop i-0abc123        # stop an instance

# forward localhost:8080 to port 80 on the instance
ck ec2 port-forward 80 8080 i-0abc123
# reach a private RDS database through the instance
ck ec2 port-forward 5432 5433 i-0abc123 mydb.xxxx.eu-west-1.rds.amazonaws.com

ck ec2 upload i-0abc123 ./build.tar.gz /tmp/build.tar.gz
```

**ECS**

```bash
ck ecs clusters                              # list clusters
ck ecs services my-cluster                   # list services
ck ecs service-tasks my-cluster api --running
ck ecs exec my-cluster <task-id> app         # shell into a container (default /bin/bash)
ck ecs exec my-cluster <task-id> app "php artisan migrate:status"
ck ecs logs my-cluster <task-id> --tail 100
ck ecs describe my-cluster api               # status, running/desired, task definition
ck ecs stop my-cluster <task-id> "stuck task"
```

### Google Cloud

```bash
ck gcloud login              # pick a configuration, authenticate, show the session table
ck gcloud login --reauth     # force re-authentication
ck gcloud switch             # switch configuration in this terminal only
ck gcloud logout             # clear the gcloud session from this terminal
```

The gcloud selection applies to the current terminal only (via `CLOUDSDK_ACTIVE_CONFIG_NAME`). New terminals start with no gcloud session until you run `ck gcloud login` — set `CLOUDKIT_GCLOUD_GLOBAL=1` to use gcloud's global configuration instead.

**Compute Engine**

```bash
ck gce ls                            # list VMs
ck gce ls --filter web               # filter by name
ck gce start my-vm                   # start / stop / reset; zone is detected automatically
ck gce ssh                           # pick a running VM and SSH into it
ck gce ssh my-vm                     # SSH to a VM
ck gce ssh my-vm --tunnel-iap        # SSH through IAP (no public IP needed)
ck gce ssh my-vm "df -h"             # run a remote command

# MySQL on the VM at localhost:3308, tunnel only (no shell)
ck gce ssh my-vm --forward 3308:127.0.0.1:3306 --tunnel-only
# Cloud SQL private IP through the VM
ck gce port-forward 3306 3308 my-vm 10.20.0.5

ck gce scp ./app.env my-vm:/tmp/     # copy files to/from a VM
```

All instance commands accept `--zone <zone>` and `--project <project>`.

**Managed instance groups**

```bash
ck mig list --region us-central1
ck mig describe web-mig --region us-central1
ck mig restart web-mig --region us-central1     # rolling restart
ck mig recreate web-mig --region us-central1    # rolling replace
```

### Both clouds

```bash
ck status        # active AWS and gcloud sessions in this terminal (no network calls)
ck doctor        # dependency and configuration check
ck version       # installed CloudKit version
```

### Configuration

Set these environment variables in your rc file, before or after sourcing `main.sh`:

| Variable | Effect |
|---|---|
| `CLOUDKIT_PROD_PATTERN` | Extended regex (case-insensitive) for production names. Matching AWS profiles or gcloud configs/projects get a red **PRODUCTION** banner and a `[PROD]` prompt marker. Default matches `prod`, `production`, `prd` as a separate word |
| `CLOUDKIT_NO_PROMPT=1` | Don't change the shell prompt (useful with Starship / Powerlevel10k) |
| `CLOUDKIT_NO_CLEAR=1` | Don't clear the terminal before showing the session table |
| `CLOUDKIT_GCLOUD_GLOBAL=1` | New terminals use gcloud's global active configuration |

### Troubleshooting

Start with `ck doctor` — it lists missing tools with the command that installs them.

- **`ck: command not found` right after installing** — open a new terminal or run `exec zsh` (`exec bash`)
- **No profiles in `ck aws login`** — run `ck setup aws`, or make sure profiles in `~/.aws/config` have `sso_session`/`sso_account_id`, access keys, or `credential_process`
- **SSM session fails** — the instance needs the SSM agent and an instance role with SSM permissions; your machine needs the Session Manager plugin
- **ECS exec fails** — enable ECS Exec on the service (`enableExecuteCommand: true`) and give the task role SSM permissions
- **"You do not currently have an active account selected"** in a new terminal — expected; run `ck gcloud login` (or set `CLOUDKIT_GCLOUD_GLOBAL=1`)
- **IAP tunnel fails** — allow ingress from `35.235.240.0/20` and grant `iap.tunnelInstances.accessViaIAP`

## Contributing

Contributions are welcome! Please follow these rules so changes stay easy to review:

1. **Open an issue first** for new features or behaviour changes, so we can agree on the approach.
2. **Branch from `main`** and open the pull request against `main`. Keep each PR focused on one change.
3. **Use [Conventional Commits](https://www.conventionalcommits.org/)** — e.g. `feat(gce): add scp picker`, `fix(session): handle expired SSO token`, `docs(readme): …`.
4. **Support bash and zsh.** Everything sourced by `main.sh` runs in both shells: avoid bash-only syntax there (arrays, `read -p`, `${var,,}`), and guard globs that may not match.
5. **Pass the checks** before pushing:
   ```bash
   make ci          # shellcheck + all tests
   ```
   CI runs the same on every pull request.
6. **Add tests** in `test/` for new behaviour. Tests must not need real cloud credentials or network access — stub `aws` / `gcloud` on `PATH` (see `test/test_install.sh`).
7. **Keep the docs in sync** — update `ck help` output and this README when you add or change a command.
8. **Never commit secrets** — no account IDs, keys, tokens or real hostnames in code, tests or examples.

Project layout:

```
install.sh              installer (dependencies, rc block, uninstall)
main.sh                 entry point; loads everything behind `ck`
ck.sh                   `ck` dispatcher, `ck status`, `ck help`
session.sh              AWS and gcloud login/switch/logout, session table, prompt
services/ec2.sh         ck ec2        services/ecs.sh       ck ecs
services/gce.sh         ck gce        services/gce_ig.sh    ck mig
services/setup.sh       ck setup, ck doctor
services/_picker.sh     shared interactive instance picker
test/                   smoke, auth, and install tests (`make test`)
```

## License

Released under the [MIT License](LICENSE).
