#!/usr/bin/env bash
set -euo pipefail

# Check Gateway exists
if ! kubectl get gateway api-gateway -n default >/dev/null 2>&1; then
  echo "Gateway 'api-gateway' not found in default namespace"
  exit 1
fi

# Check HTTPRoute exists
if ! kubectl get httproute api-route -n default >/dev/null 2>&1; then
  echo "HTTPRoute 'api-route' not found in default namespace"
  exit 1
fi

# Check HTTPRoute has correct hostname
hostname="$(kubectl get httproute api-route -n default -o jsonpath='{.spec.hostnames[0]}')"
if ! test "$hostname" = "api.demo.k8s.local"; then
  echo "HTTPRoute hostname must be 'api.demo.k8s.local', got: $hostname"
  exit 1
fi

# Check HTTPRoute references backend service
if ! kubectl get httproute api-route -n default -o yaml | grep -q 'api-backend-svc'; then
  echo "HTTPRoute 'api-route' does not reference service 'api-backend-svc'"
  exit 1
fi

echo "PASS"
exit 0
