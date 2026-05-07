#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get networkpolicy -n backend >/dev/null 2>&1; then
  echo "No NetworkPolicy found in namespace 'backend'"
  exit 1
fi

np_yaml="$(kubectl get networkpolicy -n backend -o yaml)"

if ! echo "$np_yaml" | grep -q -- '- Ingress'; then
  echo "NetworkPolicy must define Ingress policyType"
  exit 1
fi

if ! echo "$np_yaml" | grep -q 'frontend'; then
  echo "NetworkPolicy must allow ingress from 'frontend' namespace"
  exit 1
fi

echo "PASS"
exit 0
