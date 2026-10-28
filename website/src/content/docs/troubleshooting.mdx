---
title: Troubleshooting
description: Fixes for common CloudKit problems.
---

Start with `ck doctor`. It lists missing tools along with the command that installs each one.

## `ck: command not found` right after installing

The rc file hasn't been reloaded yet. Open a new terminal, or run `exec zsh` (or `exec bash`).

## No profiles in `ck aws login`

Run `ck setup aws`, or check that the profiles in `~/.aws/config` have `sso_session` / `sso_account_id`, access keys, or `credential_process`.

## SSM session fails

`ck ec2 session`, `port-forward` and `upload` need:

- the SSM agent running on the instance
- an instance role with SSM permissions
- the [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) on your machine

## ECS exec fails

Enable ECS Exec on the service (`enableExecuteCommand: true`) and give the task role SSM permissions.

## "You do not currently have an active account selected" in a new terminal

This is expected: gcloud sessions are per terminal. Run `ck gcloud login`, or set [`CLOUDKIT_GCLOUD_GLOBAL=1`](/configuration/).

## IAP tunnel fails

Allow ingress from `35.235.240.0/20` to the VM and grant your account `iap.tunnelInstances.accessViaIAP`.

## `ck gce` says the instance exists in multiple zones

Two VMs share the name. Pass `--zone` explicitly.
