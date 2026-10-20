# shellcheck shell=bash
SERVICES_DIR=$(dirname "$0")
export SERVICES_DIR

# GCE (GCloud Compute Engine) CLI function
gce() {
  case "$1" in
    ls)
      if [[ "$2" == "--filter" && -n "$3" ]]; then
        gcloud compute instances list --filter="name~$3"
      else
        gcloud compute instances list
      fi
      ;;

    ssh)
      if [[ $# -lt 2 ]]; then
        echo "Usage: gce ssh <instance-name> [--zone <zone>] [--project <project>] [--tunnel-iap] [--forward <local:host:remote>] [command]"
        echo "Example: gce ssh my-vm --zone us-central1-a"
        echo "Example: gce ssh my-vm --zone us-central1-a \"ls -la\""
        echo "Example: gce ssh my-vm --zone us-central1-a --tunnel-iap --forward 3308:127.0.0.1:3306"
        return 1
      fi

      local instance="$2"
      shift 2

      local zone=""
      local project=""
      local tunnel_iap="auto"
      local disable_iap=false
      local forward=""
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
          --forward)
            forward="$2"
            shift 2
            ;;
          *)
            break
            ;;
        esac
      done

      local command="${*:1}"
      local args=()
      if [[ -n "$zone" ]]; then
        args+=(--zone "$zone")
      fi
      if [[ -n "$project" ]]; then
        args+=(--project "$project")
      fi
      if [[ "$disable_iap" = false && "$tunnel_iap" = "true" ]]; then
        args+=(--tunnel-through-iap)
      elif [[ "$disable_iap" = false && "$tunnel_iap" = "auto" && -n "$forward" ]]; then
        args+=(--tunnel-through-iap)
      fi

      if [[ -n "$command" ]]; then
        gcloud compute ssh "$instance" \
          "${args[@]}" \
          --command "$command"
      elif [[ -n "$forward" ]]; then
        gcloud compute ssh "$instance" \
          "${args[@]}" \
          -- \
          -L "$forward"
      else
        gcloud compute ssh "$instance" \
          "${args[@]}"
      fi
      ;;

    scp)
      if [[ $# -lt 3 ]]; then
        echo "Usage: gce scp <source> <destination> [--zone <zone>]"
        echo "Example: gce scp ./file.txt my-vm:/tmp/file.txt --zone us-central1-a"
        echo "Example: gce scp my-vm:/var/log/syslog ./syslog --zone us-central1-a"
        return 1
      fi

      local source="$2"
      local destination="$3"
      shift 3

      local zone=""
      if [[ "$1" == "--zone" && -n "$2" ]]; then
        zone="$2"
        shift 2
      fi

      local args=()
      if [[ -n "$zone" ]]; then
        args+=(--zone "$zone")
      fi

      gcloud compute scp \
        "${args[@]}" \
        "$source" "$destination"
      ;;

    *)
      cat << 'EOF'
Usage: gce <command> [options]

Commands:
  ls [--filter <pattern>]
                          List GCE instances (optional name filter)
  ssh <instance-name> [--zone <zone>] [--project <project>] [--tunnel-iap] [--forward <local:host:remote>] [command]
                          SSH to a GCE VM (optional command)
  scp <source> <destination> [--zone <zone>]
                          Copy files to/from a GCE VM

Examples:
  gce ls
  gce ls --filter laravel-staging
  gce ssh my-vm --zone us-central1-a
  gce ssh my-vm --zone us-central1-a "ls -la"
  gce ssh laravel-production-cs77 --zone us-central1-b --project speero-works --tunnel-iap --forward 3308:127.0.0.1:3306
  gce scp ./file.txt my-vm:/tmp/file.txt --zone us-central1-a
  gce scp my-vm:/var/log/syslog ./syslog --zone us-central1-a
EOF
      return 1
      ;;
  esac
}
