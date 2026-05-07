#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

CRD_NAME="virtualservices.networking.istio.io"
CRD_KIND="virtualservice"

crd_file="${HOME}/crds-list.yaml"
hosts_file="${HOME}/hosts-spec.yaml"

if ! test -f "$crd_file"; then
  fail "Expected file not found: $crd_file"
fi
if ! test -s "$crd_file"; then
  fail "CRD output file is empty: $crd_file"
fi
if ! grep -q 'istio.io' "$crd_file"; then
  fail "CRD output must include Istio CRDs"
fi

if ! test -f "$hosts_file"; then
  fail "Expected file not found: $hosts_file"
fi
if ! test -s "$hosts_file"; then
  fail "Explain output file is empty: $hosts_file"
fi
if ! grep -qi 'hosts' "$hosts_file"; then
  fail "Explain output must contain hosts field documentation"
fi

if ! kubectl get crd "$CRD_NAME" >/dev/null 2>&1; then
  fail "CRD $CRD_NAME not found"
fi
if ! kubectl explain "$CRD_KIND".spec.hosts >/dev/null 2>&1; then
  fail "kubectl explain failed for $CRD_KIND.spec.hosts"
fi

echo "PASS"
exit 0
