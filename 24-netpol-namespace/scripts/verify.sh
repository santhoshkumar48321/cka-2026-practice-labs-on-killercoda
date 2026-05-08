#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get netpol allow-9000-from-team -n echo >/dev/null 2>&1; then
  echo "NetworkPolicy allow-9000-from-team not found in namespace echo"
  exit 1
fi

policy_yaml=$(kubectl get netpol allow-9000-from-team -n echo -o yaml)

if ! echo "$policy_yaml" | grep -q "app: echo-server"; then
  echo "NetworkPolicy must target pods with label app=echo-server"
  exit 1
fi

if ! echo "$policy_yaml" | grep -q "name: team-app"; then
  echo "NetworkPolicy must allow traffic from namespace team-app"
  exit 1
fi

if ! echo "$policy_yaml" | grep -q "port: 9000"; then
  echo "NetworkPolicy must allow TCP port 9000"
  exit 1
fi

echo "PASS"
exit 0
