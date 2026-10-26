# CloudKit CLI — development targets
# Requires: shellcheck (brew install shellcheck), bash

SHELL := /bin/bash
SCRIPTS := main.sh session.sh services/_picker.sh services/ec2.sh services/ecs.sh services/gce.sh services/gce_ig.sh services/setup.sh ck.sh install.sh docker/run.sh docker/test-install.sh scripts/release.sh

.PHONY: shellcheck test ci release help docker-shell docker-fresh

help:
	@echo "Targets: shellcheck, test, ci, release, docker-shell, docker-fresh"

shellcheck: ## Run Shellcheck on Bash scripts (excludes Expect)
	shellcheck -x $(SCRIPTS)

test: ## Run all tests (smoke + auth + install; no AWS credentials required)
	@bash "$(CURDIR)/test/run.sh"
	@bash "$(CURDIR)/test/test_auth.sh"
	@bash "$(CURDIR)/test/test_install.sh"

ci: shellcheck test ## Run all CI checks

# make release VERSION=v3 [YES=1] [DRY_RUN=1] — see scripts/release.sh
release: ## Tag main, push, and publish a GitHub release (updates the latest install.sh URL)
	@bash scripts/release.sh "$(VERSION)" $(if $(YES),--yes) $(if $(DRY_RUN),--dry-run)

# Fresh-install testing in Docker (see docker/README.md). Installs the latest
# GitHub release; SOURCE=local installs this working tree instead.
# DEPS=aws|gcp|core bakes fewer tools into the docker-shell image; BASE_IMAGE / USER_SHELL override the machine.
export SOURCE DEPS BASE_IMAGE USER_SHELL

docker-shell: ## Shell on a fresh machine with CloudKit installed (ck ready to use)
	@bash docker/run.sh shell

docker-fresh: ## Empty fresh machine to walk through the installer by hand
	@bash docker/run.sh fresh
