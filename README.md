<p align="center">
  <img src="assets/logo.svg" alt="CloudKit — CLI toolkit for AWS & Google Cloud" width="580">
</p>

<p align="center">
  <a href="https://github.com/shabayekdes/cloudkit-cli/actions/workflows/ci.yml"><img src="https://github.com/shabayekdes/cloudkit-cli/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/shabayekdes/cloudkit-cli/releases/latest"><img src="https://img.shields.io/github/v/release/shabayekdes/cloudkit-cli?label=release&color=2EA44F" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/shell-bash%20%7C%20zsh-4EAA25" alt="Shell: bash | zsh">
  <img src="https://img.shields.io/badge/clouds-AWS%20%7C%20Google%20Cloud-FF8A00" alt="Clouds: AWS | Google Cloud">
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey" alt="Platform: macOS | Linux">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT"></a>
  <a href="https://cloudkit.pages.dev"><img src="https://img.shields.io/badge/docs-cloudkit.pages.dev-F38020" alt="Docs"></a>
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

1. Asks which clouds you use — AWS, Google Cloud, both, or neither (CloudKit and its common tools only)
2. Installs missing dependencies after one confirmation, using `brew` (macOS) or `apt` / `dnf` / `yum` / `pacman` (Linux)
3. Downloads the **latest release** of CloudKit to `~/.cloudkit` (or switches an existing install to it)
4. Adds a `source …/main.sh` block to `~/.zshrc` / `~/.bashrc` (re-running never duplicates it)
5. Offers to set up your AWS / gcloud credentials
6. Offers to restart your shell so `ck` works right away

Pass options after `bash -s --`, for example `curl … | bash -s -- --gcp --yes`:

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
| `expect`, `nc` | `ck ec2 upload` (not installed up front; `ck ec2 upload` offers to install them the first time) |
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

📖 **Full documentation: [cloudkit.pages.dev](https://cloudkit.pages.dev)**: every command, its options, configuration and troubleshooting.

```bash
ck aws login                 # pick an AWS profile, SSO login if needed, show the session table
ck ec2 session               # pick a running instance and open an SSM shell
ck ecs exec-running my-cluster app --service api
ck gcloud login              # pick a gcloud configuration and authenticate
ck gce ssh my-vm --forward 3308:127.0.0.1:3306 --tunnel-only
ck status                    # active sessions in this terminal
```

Run `ck help` for all commands, or `ck help <command>` (e.g. `ck help gce`) for a command's options.

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
   CI runs the same on every pull request. If you change `install.sh`, also run `make docker-shell SOURCE=local` to try a fresh install of your changes in Docker (see [docker/README.md](docker/README.md)).
6. **Add tests** in `test/` for new behaviour. Tests must not need real cloud credentials or network access — stub `aws` / `gcloud` on `PATH` (see `test/test_install.sh`).
7. **Keep the docs in sync** — update `ck help` output and the command's page in [`website/src/content/docs/`](website/src/content/docs/) when you add or change a command. `make test` fails if a subcommand is missing from either; preview with `make docs-serve`.
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
test/                   smoke, auth, install, and docs tests (`make test`)
docker/                 fresh-install testing in Docker (`make docker-shell`)
scripts/release.sh      tag and publish a release (`make release`)
website/                docs site (Starlight → Cloudflare Pages; `make docs-serve`)
```

### Releasing (maintainers)

```bash
make release VERSION=v3 DRY_RUN=1    # check everything, publish nothing
make release VERSION=v3              # tag main, push, publish the GitHub release
```

The release is marked latest and carries `install.sh`, so the quick-install URL serves it right away. Needs an authenticated [`gh`](https://cli.github.com) and a clean, up-to-date `main`.

## License

Released under the [MIT License](LICENSE).
