#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get networkpolicy allow-9000-from-team -n echo >/dev/null 2>&1; then
  echo "NetworkPolicy 'allow-9000-from-team' not found in namespace 'echo'"
  exit 1
fi

np_yaml="$(kubectl get networkpolicy allow-9000-from-team -n echo -o yaml)"

if ! echo "$np_yaml" | grep -q -- '- Ingress'; then
  echo "NetworkPolicy must define Ingress policyType"
  exit 1
fi

if ! echo "$np_yaml" | grep -q 'team-app'; then
  echo "NetworkPolicy must allow ingress from namespace 'team-app'"
  exit 1
fi

if ! echo "$np_yaml" | grep -q '9000'; then
  echo "NetworkPolicy must restrict to port 9000"
  exit 1
fi

echo "PASS"
exit 0
