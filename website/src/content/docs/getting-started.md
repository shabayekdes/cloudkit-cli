---
title: Getting started
description: Install CloudKit, its dependencies, and set up your AWS and gcloud credentials.
---

## Quick install

```bash
curl -fsSL https://github.com/shabayekdes/cloudkit-cli/releases/latest/download/install.sh | bash
```

The installer:

1. Asks which clouds you use: AWS, Google Cloud, both, or neither (CloudKit and its common tools only)
2. Installs missing dependencies after one confirmation, using `brew` (macOS) or `apt` / `dnf` / `yum` / `pacman` (Linux)
3. Downloads the **latest release** of CloudKit to `~/.cloudkit` (or switches an existing install to it)
4. Adds a `source …/main.sh` block to `~/.zshrc` / `~/.bashrc` (re-running never duplicates it)
5. Offers to set up your AWS / gcloud credentials
6. Offers to restart your shell so `ck` works right away

### Installer options

Pass options after `bash -s --`, for example:

```bash
curl -fsSL https://github.com/shabayekdes/cloudkit-cli/releases/latest/download/install.sh | bash -s -- --gcp --yes
```

| Option | Effect |
|---|---|
| `--aws` / `--gcp` / `--all` | Install dependencies for one cloud or both (default: ask) |
| `--core` | Install only the common tools (`curl`, `jq`, `python3`), without the AWS CLI or gcloud |
| `--yes` | Don't ask for confirmation |
| `--no-deps` | Skip dependency installation |
| `--no-rc` | Don't edit shell rc files |
| `--no-setup` | Don't offer credential setup |
| `--dir <path>` | Install directory (default: `$CLOUDKIT_HOME` or `~/.cloudkit`) |
| `--deps <tools>` | Install only these tools and exit, e.g. `--deps expect,nc` |
| `--uninstall` | Remove CloudKit (never touches `~/.aws` or gcloud configuration) |

### Upgrade

Re-run the install command: it moves `~/.cloudkit` to the newest release. Check what you have with:

```bash
ck version
```

## Install from a clone

```bash
git clone https://github.com/shabayekdes/cloudkit-cli.git
cd cloudkit-cli
./install.sh
```

Running `./install.sh` from a clone uses that clone in place, so `git pull` or `git checkout <tag>` controls the version.

## Dependencies

The installer handles these for you; install them by hand if you prefer:

| Tool | Needed for |
|---|---|
| `jq`, `python3` | everything |
| [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | AWS commands |
| [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) | `ck ec2 session`, `port-forward`, `upload`, `ck ecs exec` |
| `expect`, `nc` | `ck ec2 upload` (offered on first use) |
| [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (`gcloud`) | Google Cloud commands |

When installing by hand, add this line to your `~/.zshrc` or `~/.bashrc`:

```bash
source /path/to/cloudkit-cli/main.sh
```

## Set up credentials

```bash
ck doctor          # check tools, AWS profiles, gcloud configurations, ADC, rc file
ck setup aws       # AWS SSO (IAM Identity Center), access keys, or a chained role
ck setup gcloud    # create/update a gcloud configuration, log in, optional ADC
```

`ck setup` writes standard files (`~/.aws/config`, gcloud configurations), so profiles you already have keep working. See [Setup and status](/commands/setup/) for details.

## First steps

```bash
ck aws login       # pick a profile and log in
ck ec2 session     # pick a running instance and open a shell
ck help            # list all commands
```

Run `ck help <command>` (for example `ck help gce`) for a command's options.

## Uninstall

```bash
~/.cloudkit/install.sh --uninstall
```

This removes the rc block and `~/.cloudkit`. Your `~/.aws` and gcloud configuration are left untouched.
