---
title: ck ec2
description: List, start, stop and connect to EC2 instances, forward ports and upload files through SSM.
sidebar:
  order: 1
---

Commands for EC2 instances in the active AWS profile and region. Log in first with [`ck aws login`](/sessions/).

| Command | What it does |
|---|---|
| [`ls`](#ck-ec2-ls) | List all instances |
| [`ls-running`](#ck-ec2-ls-running) | List running instances |
| [`ls-stopped`](#ck-ec2-ls-stopped) | List stopped instances |
| [`session`](#ck-ec2-session) | Open an SSM shell |
| [`run`](#ck-ec2-run) | Start an instance |
| [`stop`](#ck-ec2-stop) | Stop an instance |
| [`port-forward`](#ck-ec2-port-forward) | Forward a port through SSM |
| [`upload`](#ck-ec2-upload) | Upload a file through SSM |

:::note[Requirements]
`session`, `port-forward` and `upload` use AWS Systems Manager. The instance needs the SSM agent and an instance role with SSM permissions; your machine needs the [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html).
:::

## ck ec2 ls

```
ck ec2 ls
```

List all instances as JSON with their ID, `Name` tag and state.

## ck ec2 ls-running

```
ck ec2 ls-running
```

List only instances in the `running` state.

## ck ec2 ls-stopped

```
ck ec2 ls-stopped
```

List only instances in the `stopped` state.

## ck ec2 session

```
ck ec2 session [instance-id]
```

Open an interactive SSM shell on an instance. Leave out the instance ID to pick from a list of running instances (ID, name, availability zone, private IP).

```bash
ck ec2 session                  # pick from running instances
ck ec2 session i-0abc123        # specific instance
```

## ck ec2 run

```
ck ec2 run <instance-id>
```

Start a stopped instance and show its previous and current state.

```bash
ck ec2 run i-0abc123
```

## ck ec2 stop

```
ck ec2 stop <instance-id>
```

Stop a running instance and show its previous and current state.

```bash
ck ec2 stop i-0abc123
```

## ck ec2 port-forward

```
ck ec2 port-forward <remote-port> <local-port> <instance-id> [host]
```

Forward a port to `localhost` through SSM.

| Argument | Meaning |
|---|---|
| `remote-port` | Port on the instance, or on `host` when given |
| `local-port` | Port to listen on locally |
| `instance-id` | Instance to tunnel through |
| `host` | Optional remote host reachable from the instance, such as an RDS endpoint |

```bash
# localhost:8080 -> port 80 on the instance
ck ec2 port-forward 80 8080 i-0abc123

# localhost:5433 -> a private RDS database, through the instance
ck ec2 port-forward 5432 5433 i-0abc123 mydb.xxxx.eu-west-1.rds.amazonaws.com
```

Press `Ctrl+C` to close the tunnel.

## ck ec2 upload

```
ck ec2 upload <instance-id> <local-file> [remote-path] [port]
```

Upload a file to an instance over an SSM port-forwarding session.

| Argument | Meaning |
|---|---|
| `instance-id` | Target instance |
| `local-file` | File to send |
| `remote-path` | Destination path (default: `/home/ec2-user/<file name>`) |
| `port` | Port used for the transfer (default: random between 50000 and 59999) |

```bash
ck ec2 upload i-0abc123 ./build.tar.gz /tmp/build.tar.gz
```

Needs `expect` and `nc` on your machine. The first time you run `ck ec2 upload` without them, CloudKit offers to install them.
