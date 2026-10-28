---
title: ck gce
description: List, start, stop and SSH into Compute Engine VMs, copy files, and forward ports through IAP.
sidebar:
  order: 3
---

Commands for Compute Engine VMs in the active gcloud configuration. Log in first with [`ck gcloud login`](/sessions/).

| Command | What it does |
|---|---|
| [`ls`](#ck-gce-ls) | List VMs |
| [`ls-running`](#ck-gce-ls-running) | List running VMs |
| [`ls-stopped`](#ck-gce-ls-stopped) | List stopped VMs |
| [`start` / `stop` / `reset`](#ck-gce-start--stop--reset) | Change a VM's power state |
| [`ssh`](#ck-gce-ssh) | SSH to a VM, run a command, or hold tunnels open |
| [`scp`](#ck-gce-scp) | Copy files to or from a VM |
| [`port-forward`](#ck-gce-port-forward) | Forward a port through IAP |

## Common options

All instance commands accept:

| Option | Meaning |
|---|---|
| `--zone <zone>` | VM zone. When left out, it's looked up from the VM name; if the name exists in more than one zone, you must pass it. |
| `--project <project>` | Project to use instead of the configuration's default |

Flags can go anywhere on the line. Everything after a bare `--` is passed through as-is.

## ck gce ls

```
ck gce ls [--filter <pattern>]
```

List VMs. `--filter` matches the name against a pattern.

```bash
ck gce ls
ck gce ls --filter web
```

## ck gce ls-running

```
ck gce ls-running
```

List VMs with status `RUNNING`.

## ck gce ls-stopped

```
ck gce ls-stopped
```

List VMs with status `TERMINATED` (stopped).

## ck gce start / stop / reset

```
ck gce start <instance-name> [--zone <zone>] [--project <project>]
ck gce stop  <instance-name> [--zone <zone>] [--project <project>]
ck gce reset <instance-name> [--zone <zone>] [--project <project>]
```

Start, stop, or hard-reset a VM.

```bash
ck gce start my-vm
ck gce stop my-vm --zone us-central1-a
```

## ck gce ssh

```
ck gce ssh [instance-name] [--zone <zone>] [--project <project>]
           [--tunnel-iap | --no-iap] [--forward <local:host:remote>]...
           [--tunnel-only] [--] [command]
```

SSH to a VM. Leave out the name to pick from running VMs.

| Option | Meaning |
|---|---|
| `--tunnel-iap` | Connect through IAP, so the VM needs no public IP. On by default when `--forward` is used. |
| `--no-iap` | Never connect through IAP |
| `--forward <local:host:remote>` | Forward a local port to `host:remote` as seen from the VM. Repeatable. |
| `--tunnel-only` | With `--forward`: hold the tunnels open without a shell |
| `command` | Run this command instead of opening a shell |

```bash
ck gce ssh                                   # pick a running VM
ck gce ssh my-vm --tunnel-iap
ck gce ssh my-vm "df -h"                     # run a remote command

# MySQL on the VM at localhost:3308, tunnel only (no shell)
ck gce ssh my-vm --forward 3308:127.0.0.1:3306 --tunnel-only

# two forwards at once
ck gce ssh my-vm --forward 3308:127.0.0.1:3306 --forward 6380:127.0.0.1:6379
```

## ck gce scp

```
ck gce scp <source>... <destination> [--zone <zone>] [--project <project>] [--tunnel-iap] [-r]
```

Copy files to or from a VM. Write remote paths as `instance:path`; the zone is looked up from the first remote path.

| Option | Meaning |
|---|---|
| `--tunnel-iap` | Copy through IAP |
| `-r`, `--recurse` | Copy directories |

```bash
ck gce scp ./app.env my-vm:/tmp/
ck gce scp my-vm:/var/log/syslog ./syslog --zone us-central1-a
ck gce scp -r ./dist my-vm:/srv/app --tunnel-iap
```

## ck gce port-forward

```
ck gce port-forward <remote-port> <local-port> <instance-name> [host] [--zone <zone>] [--project <project>]
```

Forward a port to `localhost` through IAP. Arguments are in the same order as [`ck ec2 port-forward`](/commands/ec2/#ck-ec2-port-forward).

- Without `host`: opens an IAP TCP tunnel to the VM's own port.
- With `host`: tunnels through the VM over SSH to a host it can reach, such as a Cloud SQL private IP.

```bash
ck gce port-forward 8080 8080 my-vm
ck gce port-forward 3306 3308 my-vm 10.20.0.5     # Cloud SQL private IP through the VM
```

:::note[IAP requirements]
Allow ingress from `35.235.240.0/20` to the VM and grant your account `iap.tunnelInstances.accessViaIAP`.
:::
