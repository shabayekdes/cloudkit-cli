# shellcheck shell=bash
SERVICES_DIR=$(dirname "$0")
export SERVICES_DIR

# Parse flags shared by gce subcommands. Flags may appear anywhere; everything
# after a bare `--` is treated as positional. Populates the caller's locals
# (zone, project, tunnel_iap, disable_iap, tunnel_only, recurse, forwards,
# positional) via dynamic scoping, so callers must declare them first.
_gce_parse_flags() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --zone)
        zone="$2"
        shift 2
        ;;
      --project)
        project="$2"
        shift 2
        ;;
      --tunnel-iap)
        tunnel_iap="true"
        shift 1
        ;;
      --no-iap)
        disable_iap=true
        shift 1
        ;;
      --tunnel-only)
        tunnel_only=true
        shift 1
        ;;
      -r|--recurse)
        recurse=true
        shift 1
        ;;
      --forward)
        forwards+=("$2")
        shift 2
        ;;
      --)
        shift 1
        positional+=("$@")
        break
        ;;
      *)
        positional+=("$1")
        shift 1
        ;;
    esac
  done
}

# Look up the zone of an instance by name. Prints the zone, or fails if the
# instance is missing or the name matches instances in more than one zone.
_gce_resolve_zone() {
  local instance="$1"
  local project="$2"
  local args=()
  if [[ -n "$project" ]]; then
    args+=(--project "$project")
  fi

  local zones
  zones=$(gcloud compute instances list \
    "${args[@]}" \
    --filter="name=($instance)" \
    --format="value(zone.basename())" 2>/dev/null)

  if [[ -z "$zones" ]]; then
    echo "Error: instance '$instance' not found. Pass --zone explicitly." >&2
    return 1
  fi
  if [[ $(echo "$zones" | wc -l) -gt 1 ]]; then
    echo "Error: instance '$instance' exists in multiple zones:" >&2
    local z
    while IFS= read -r z; do
      echo "  $z" >&2
    done <<< "$zones"
    echo "Pass --zone explicitly." >&2
    return 1
  fi
  echo "$zones"
}

# Build zone/project args for an instance, resolving the zone when not given.
# Populates the caller's `args` array.
_gce_location_args() {
  local instance="$1"
  if [[ -z "$zone" ]]; then
    zone=$(_gce_resolve_zone "$instance" "$project") || return 1
    echo "Using zone: $zone" >&2
  fi
  args+=(--zone "$zone")
  if [[ -n "$project" ]]; then
    args+=(--project "$project")
  fi
}

# GCE (GCloud Compute Engine) CLI function
gce() {
  local zone="" project="" tunnel_iap="auto" disable_iap=false tunnel_only=false recurse=false
  local forwards=() positional=() args=()

  case "$1" in
    ls)
      if [[ "$2" == "--filter" && -n "$3" ]]; then
        gcloud compute instances list --filter="name~$3"
      else
        gcloud compute instances list
      fi
      ;;

    ls-running)
      gcloud compute instances list --filter="status=RUNNING"
      ;;

    ls-stopped)
      gcloud compute instances list --filter="status=TERMINATED"
      ;;

    start|stop|reset)
      local action="$1"
      if [[ $# -lt 2 ]]; then
        echo "Usage: gce $action <instance-name> [--zone <zone>] [--project <project>]"
        return 1
      fi
      _gce_parse_flags "${@:2}"
      set -- "${positional[@]}"
      local instance="$1"
      _gce_location_args "$instance" || return 1

      echo "Running '$action' on instance $instance..."
      gcloud compute instances "$action" "$instance" "${args[@]}"
      ;;

    ssh)
      if [[ $# -lt 2 ]]; then
        cat << 'EOF'
Usage: gce ssh <instance-name> [--zone <zone>] [--project <project>]
               [--tunnel-iap | --no-iap] [--forward <local:host:remote>]...
               [--tunnel-only] [--] [command]

  --zone          Instance zone (auto-detected when omitted)
  --tunnel-iap    Connect through IAP (default when --forward is used)
  --no-iap        Never connect through IAP
  --forward       Local port forward; repeatable
  --tunnel-only   With --forward: hold the tunnel open without a shell

Example: gce ssh my-vm
Example: gce ssh my-vm --zone us-central1-a "ls -la"
Example: gce ssh my-vm --forward 3308:127.0.0.1:3306 --forward 6380:127.0.0.1:6379
Example: gce ssh my-vm --forward 3308:127.0.0.1:3306 --tunnel-only
EOF
        return 1
      fi

      local instance="$2"
      _gce_parse_flags "${@:3}"
      local command="${positional[*]}"
      _gce_location_args "$instance" || return 1

      if [[ "$disable_iap" = false && "$tunnel_iap" = "true" ]]; then
        args+=(--tunnel-through-iap)
      elif [[ "$disable_iap" = false && "$tunnel_iap" = "auto" && ${#forwards[@]} -gt 0 ]]; then
        args+=(--tunnel-through-iap)
      fi
      if [[ -n "$command" ]]; then
        args+=(--command "$command")
      fi

      local ssh_flags=()
      local f
      for f in "${forwards[@]}"; do
        ssh_flags+=(-L "$f")
      done
      if [[ "$tunnel_only" = true && -z "$command" && ${#forwards[@]} -gt 0 ]]; then
        ssh_flags+=(-N)
        echo "Holding tunnel(s) open: ${forwards[*]} (Ctrl+C to close)"
      fi

      if [[ ${#ssh_flags[@]} -gt 0 ]]; then
        gcloud compute ssh "$instance" "${args[@]}" -- "${ssh_flags[@]}"
      else
        gcloud compute ssh "$instance" "${args[@]}"
      fi
      ;;

    scp)
      _gce_parse_flags "${@:2}"
      if [[ ${#positional[@]} -lt 2 ]]; then
        echo "Usage: gce scp <source>... <destination> [--zone <zone>] [--project <project>] [--tunnel-iap] [-r]"
        echo "Example: gce scp ./file.txt my-vm:/tmp/file.txt"
        echo "Example: gce scp my-vm:/var/log/syslog ./syslog --zone us-central1-a"
        echo "Example: gce scp -r ./dist my-vm:/srv/app --tunnel-iap"
        return 1
      fi

      # Resolve the zone from the first remote path (instance:path)
      local p instance=""
      for p in "${positional[@]}"; do
        if [[ "$p" == *:* && "$p" != /* && "$p" != ./* ]]; then
          instance="${p%%:*}"
          instance="${instance#*@}"
          break
        fi
      done
      if [[ -z "$instance" ]]; then
        echo "Error: one of source/destination must be a remote path (instance:path)." >&2
        return 1
      fi
      _gce_location_args "$instance" || return 1

      if [[ "$disable_iap" = false && "$tunnel_iap" = "true" ]]; then
        args+=(--tunnel-through-iap)
      fi
      if [[ "$recurse" = true ]]; then
        args+=(--recurse)
      fi

      gcloud compute scp "${args[@]}" "${positional[@]}"
      ;;

    port-forward)
      _gce_parse_flags "${@:2}"
      if [[ ${#positional[@]} -lt 3 ]]; then
        echo "Usage: gce port-forward <remote-port> <local-port> <instance-name> [host] [--zone <zone>] [--project <project>]"
        echo ""
        echo "Examples:"
        echo "  # Forward to the VM itself (e.g., web server) via an IAP TCP tunnel"
        echo "  gce port-forward 8080 8080 my-vm"
        echo ""
        echo "  # Forward to a remote service through the VM (e.g., Cloud SQL private IP)"
        echo "  gce port-forward 3306 3308 my-vm 10.20.0.5"
        return 1
      fi

      # Positional order matches `ec2 port-forward`
      set -- "${positional[@]}"
      local remote_port="$1"
      local local_port="$2"
      local instance="$3"
      local host="$4"
      _gce_location_args "$instance" || return 1

      if [[ -z "$host" ]]; then
        echo "Forwarding localhost:$local_port -> $instance:$remote_port (via IAP)"
        gcloud compute start-iap-tunnel "$instance" "$remote_port" \
          --local-host-port="localhost:$local_port" \
          "${args[@]}"
      else
        echo "Forwarding localhost:$local_port -> $host:$remote_port (via $instance, IAP)"
        gcloud compute ssh "$instance" \
          "${args[@]}" \
          --tunnel-through-iap \
          -- -N -L "$local_port:$host:$remote_port"
      fi
      ;;

    *)
      cat << 'EOF'
Usage: gce <command> [options]

Commands:
  ls [--filter <pattern>]
                          List GCE instances (optional name filter)
  ls-running              List only running instances
  ls-stopped              List only stopped (TERMINATED) instances
  start <instance-name>   Start an instance
  stop <instance-name>    Stop an instance
  reset <instance-name>   Hard-reset an instance
  ssh <instance-name> [--tunnel-iap | --no-iap] [--forward <local:host:remote>]...
      [--tunnel-only] [command]
                          SSH to a GCE VM (optional command / port forwards)
  scp <source>... <destination> [--tunnel-iap] [-r]
                          Copy files to/from a GCE VM
  port-forward <remote-port> <local-port> <instance-name> [host]
                          Forward a port to the local machine via IAP
                          - Without host: forwards from the VM itself
                          - With host: forwards from a remote service through the VM

All instance commands accept [--zone <zone>] [--project <project>].
When --zone is omitted, it is looked up from the instance name.

Examples:
  gce ls
  gce ls --filter laravel-staging
  gce ls-running
  gce start my-vm
  gce stop my-vm --zone us-central1-a
  gce ssh my-vm
  gce ssh my-vm --zone us-central1-a "ls -la"
  gce ssh laravel-production-cs77 --project speero-works --forward 3308:127.0.0.1:3306 --tunnel-only
  gce scp ./file.txt my-vm:/tmp/file.txt
  gce scp my-vm:/var/log/syslog ./syslog --zone us-central1-a
  gce port-forward 8080 8080 my-vm
  gce port-forward 3306 3308 my-vm 10.20.0.5
EOF
      return 1
      ;;
  esac
}
