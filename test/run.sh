#!/usr/bin/env bash
# Smoke tests for CloudKit CLI. No AWS/GCloud credentials required.
# Run from repo root: bash test/run.sh

# Resolve repo root first (before set -e) so we can cd reliably
_run_sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$(cd "$_run_sh_dir/.." && pwd)"

set -e
cd "$REPO_ROOT" || { echo "Could not cd to REPO_ROOT=$REPO_ROOT" >&2; exit 1; }

fail() { echo "FAIL: $*" >&2; exit 1; }

# Test 1: Sourcing main.sh does not fail
echo "=== Test 1: Sourcing main.sh does not fail ==="
( unset AWS_PROFILE; source "$REPO_ROOT/main.sh" ) || fail "Sourcing main.sh failed"
echo "Sourcing main.sh: OK"

# Test 2: ec2 with no args prints usage and returns non-zero
echo ""
echo "=== Test 2: ec2 with no args prints usage and returns non-zero ==="
ec2_out=$( ( source "$REPO_ROOT/main.sh"; ec2 ) 2>&1 ) || true
echo "$ec2_out" | grep -q "Usage: ec2" || fail "ec2 did not print usage"
( source "$REPO_ROOT/main.sh"; ec2 ) 2>/dev/null && fail "ec2 should exit non-zero" || true
echo "ec2 usage output: OK"

# Test 3: ecs with no args prints usage and returns non-zero
echo ""
echo "=== Test 3: ecs with no args prints usage and returns non-zero ==="
ecs_out=$( ( source "$REPO_ROOT/main.sh"; ecs ) 2>&1 ) || true
echo "$ecs_out" | grep -q "Usage: ecs" || fail "ecs did not print usage"
( source "$REPO_ROOT/main.sh"; ecs ) 2>/dev/null && fail "ecs should exit non-zero" || true
echo "ecs usage output: OK"

# Test 4: gce with no args prints usage and returns non-zero
echo ""
echo "=== Test 4: gce with no args prints usage and returns non-zero ==="
gce_out=$( ( source "$REPO_ROOT/main.sh"; gce ) 2>&1 ) || true
echo "$gce_out" | grep -q "Usage: gce" || fail "gce did not print usage"
( source "$REPO_ROOT/main.sh"; gce ) 2>/dev/null && fail "gce should exit non-zero" || true
echo "gce usage output: OK"

# Test 5: instance pickers (stub gcloud/aws on PATH)
echo ""
echo "=== Test 5: gce ssh / ec2 session instance pickers ==="
stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT
cat > "$stub_dir/gcloud" << 'STUB'
#!/usr/bin/env bash
if [[ "$*" == *"status=RUNNING"* ]]; then
  printf 'web-1\tus-central1-a\t10.0.0.2\nweb-2\tus-central1-b\t10.0.0.3\n' | head -n "${N:-2}"
  exit
fi
echo "gcloud $*"
STUB
cat > "$stub_dir/aws" << 'STUB'
#!/usr/bin/env bash
if [[ "$1" == ec2 ]]; then
  printf 'i-aaa\tweb\tus-east-1a\t10.0.0.1\ni-bbb\tNone\tus-east-1b\t10.0.0.2\n' | head -n "${N:-2}"
  exit
fi
echo "aws $*"
STUB
chmod +x "$stub_dir/gcloud" "$stub_dir/aws"

pick() { ( PATH="$stub_dir:$PATH"; source "$REPO_ROOT/main.sh"; "$@" ) 2>&1; }

out=$(echo 2 | pick gce ssh)
echo "$out" | grep -q "gcloud compute ssh web-2 --zone us-central1-b" || fail "gce ssh picker did not select web-2: $out"
out=$(N=1 pick gce ssh)
echo "$out" | grep -q "gcloud compute ssh web-1 --zone us-central1-a" || fail "gce ssh did not auto-select single instance: $out"
N=0 pick gce ssh > /dev/null && fail "gce ssh should fail with no running instances"
echo 9 | pick gce ssh > /dev/null && fail "gce ssh should fail on invalid selection"
out=$(echo 2 | pick ec2 session)
echo "$out" | grep -q "aws ssm start-session --target i-bbb" || fail "ec2 session picker did not select i-bbb: $out"
N=0 pick ec2 session > /dev/null && fail "ec2 session should fail with no running instances"
echo "instance pickers: OK"

echo ""
echo "=== All smoke tests passed ==="
