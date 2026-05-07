#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get ingress wave -n ing-private >/dev/null 2>&1; then
  echo "Ingress 'wave' not found in namespace 'ing-private'"
  exit 1
fi

ing_yaml="$(kubectl get ingress wave -n ing-private -o yaml)"

if ! echo "$ing_yaml" | grep -q 'path: /hello'; then
  echo "Ingress 'wave' must route path '/hello'"
  exit 1
fi

if ! echo "$ing_yaml" | grep -q 'name: hello'; then
  echo "Ingress 'wave' must route to service 'hello'"
  exit 1
fi

if ! echo "$ing_yaml" | grep -q 'number: 5678'; then
  echo "Ingress 'wave' must route to service port 5678"
  exit 1
fi

echo "PASS"
exit 0
