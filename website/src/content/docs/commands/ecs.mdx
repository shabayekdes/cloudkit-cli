---
title: ck ecs
description: List ECS clusters, services and tasks, exec into containers, and stop tasks.
sidebar:
  order: 2
---

Commands for Amazon ECS in the active AWS profile and region. Log in first with [`ck aws login`](/sessions/).

| Command | What it does |
|---|---|
| [`clusters`](#ck-ecs-clusters) | List clusters |
| [`services`](#ck-ecs-services) | List services in a cluster |
| [`tasks`](#ck-ecs-tasks) | List tasks in a cluster |
| [`service-tasks`](#ck-ecs-service-tasks) | List tasks of one service |
| [`task-info`](#ck-ecs-task-info) | Show details of a task |
| [`exec`](#ck-ecs-exec) | Run a command in a container |
| [`exec-running`](#ck-ecs-exec-running) | Run a command in the first running task |
| [`logs`](#ck-ecs-logs) | Show a task's container name |
| [`stop`](#ck-ecs-stop) | Stop a task |
| [`describe`](#ck-ecs-describe) | Describe a service |

## ck ecs clusters

```
ck ecs clusters
```

List all clusters.

## ck ecs services

```
ck ecs services <cluster>
```

List the services in a cluster.

```bash
ck ecs services my-cluster
```

## ck ecs tasks

```
ck ecs tasks <cluster> [--running]
```

List tasks in a cluster with their ID, last and desired status, container and uptime. Add `--running` to show only tasks whose desired status is `RUNNING`.

```bash
ck ecs tasks my-cluster --running
```

## ck ecs service-tasks

```
ck ecs service-tasks <cluster> <service> [--running]
```

Same as [`tasks`](#ck-ecs-tasks), limited to one service.

```bash
ck ecs service-tasks my-cluster api --running
```

## ck ecs task-info

```
ck ecs task-info <cluster> <task-id>
```

Show a task's status, first container, image, uptime and creation time.

```bash
ck ecs task-info my-cluster abc123def456
```

## ck ecs exec

```
ck ecs exec <cluster> <task-id> <container> [command]
```

Run a command in a container through ECS Exec. Without a command, it opens `/bin/bash`.

```bash
ck ecs exec my-cluster abc123def456 app
ck ecs exec my-cluster abc123def456 app "php artisan migrate:status"
```

:::note[Requirements]
Enable ECS Exec on the service (`enableExecuteCommand: true`), give the task role SSM permissions, and install the [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) locally.
:::

## ck ecs exec-running

```
ck ecs exec-running <cluster> <container> [--service <service>] [command]
```

Like [`exec`](#ck-ecs-exec), but picks the first running task for you. Add `--service` to pick from one service only. Without a command, it opens `/bin/bash`.

```bash
ck ecs exec-running my-cluster app
ck ecs exec-running my-cluster app --service api ls -la /var/log
```

## ck ecs logs

```
ck ecs logs <cluster> <task-id> [--tail N]
```

Show the task ID and its first container's name.

:::caution
This command doesn't fetch log lines yet, and `--tail` is accepted but not used. Read container logs in CloudWatch Logs for now.
:::

## ck ecs stop

```
ck ecs stop <cluster> <task-id> [reason]
```

Stop a task. The reason defaults to `Stopped via CLI`.

```bash
ck ecs stop my-cluster abc123def456 "stuck task"
```

## ck ecs describe

```
ck ecs describe <cluster> <service>
```

Show a service's name, status, running and desired task counts, and task definition.

```bash
ck ecs describe my-cluster api
```
