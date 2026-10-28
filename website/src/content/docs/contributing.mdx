---
title: Contributing
description: How to contribute to CloudKit, the project layout, and releasing.
---

Contributions are welcome! Please follow these rules so changes stay easy to review:

1. **Open an issue first** for new features or behaviour changes, so we can agree on the approach.
2. **Branch from `main`** and open the pull request against `main`. Keep each PR focused on one change.
3. **Use [Conventional Commits](https://www.conventionalcommits.org/)**, e.g. `feat(gce): add scp picker`, `fix(session): handle expired SSO token`, `docs(website): …`.
4. **Support bash and zsh.** Everything sourced by `main.sh` runs in both shells: avoid bash-only syntax there (arrays, `read -p`, `${var,,}`), and guard globs that may not match.
5. **Pass the checks** before pushing:
   ```bash
   make ci          # shellcheck + all tests
   ```
   CI runs the same on every pull request. If you change `install.sh`, also run `make docker-shell SOURCE=local` to try a fresh install of your changes in Docker.
6. **Add tests** in `test/` for new behaviour. Tests must not need real cloud credentials or network access: stub `aws` / `gcloud` on `PATH` (see `test/test_install.sh`).
7. **Keep the docs in sync.** When you add or change a command, update its `ck help` output and its page in `website/src/content/docs/`. `make test` fails if a subcommand is missing from either.
8. **Never commit secrets**: no account IDs, keys, tokens or real hostnames in code, tests or examples.

## Docs site

The site uses [Starlight](https://starlight.astro.build) and lives in `website/`.

```bash
make docs-serve      # live preview at http://localhost:4321
make docs-build      # production build into website/dist (fails on broken links)
```

Merges to `main` that touch `website/` deploy to Cloudflare Pages automatically.

## Project layout

```
install.sh              installer (dependencies, rc block, uninstall)
main.sh                 entry point; loads everything behind `ck`
ck.sh                   `ck` dispatcher, `ck status`, `ck help`
session.sh              AWS and gcloud login/switch/logout, session table, prompt
services/ec2.sh         ck ec2        services/ecs.sh       ck ecs
services/gce.sh         ck gce        services/gce_ig.sh    ck mig
services/setup.sh       ck setup, ck doctor
services/_picker.sh     shared interactive instance picker
test/                   smoke, auth, install and docs tests (`make test`)
docker/                 fresh-install testing in Docker (`make docker-shell`)
scripts/release.sh      tag and publish a release (`make release`)
website/                this docs site (Starlight)
```

## Releasing (maintainers)

```bash
make release VERSION=v3 DRY_RUN=1    # check everything, publish nothing
make release VERSION=v3              # tag main, push, publish the GitHub release
```

The release is marked latest and carries `install.sh`, so the quick-install URL serves it right away. Needs an authenticated [`gh`](https://cli.github.com) and a clean, up-to-date `main`.
