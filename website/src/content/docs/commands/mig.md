---
title: ck mig
description: List, describe, restart and recreate Compute Engine managed instance groups.
sidebar:
  order: 4
---

Commands for regional managed instance groups (MIGs) in the active gcloud configuration.

| Command | What it does |
|---|---|
| [`list`](#ck-mig-list) | List groups |
| [`describe`](#ck-mig-describe) | Describe a group |
| [`restart`](#ck-mig-restart) | Rolling restart of a group's VMs |
| [`recreate`](#ck-mig-recreate) | Rolling replace of a group's VMs |

## ck mig list

```
ck mig list [--region <region>]
```

List managed instance groups, optionally in one region.

```bash
ck mig list --region us-central1
```

## ck mig describe

```
ck mig describe <group> --region <region>
```

Show a group's full configuration.

```bash
ck mig describe web-mig --region us-central1
```

## ck mig restart

```
ck mig restart <group> --region <region>
```

Restart the group's VMs in a rolling fashion. VMs keep their disks.

```bash
ck mig restart web-mig --region us-central1
```

## ck mig recreate

```
ck mig recreate <group> --region <region>
```

Replace the group's VMs in a rolling fashion with new ones from the instance template.

```bash
ck mig recreate web-mig --region us-central1
```
