#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get netpol frontend-to-backend -n backend >/dev/null 2>&1; then
  echo "NetworkPolicy frontend-to-backend not found in backend namespace"
  exit 1
fi

policy_yaml=$(kubectl get netpol frontend-to-backend -n backend -o yaml)

if ! echo "$policy_yaml" | grep -q "app: backend-api"; then
  echo "NetworkPolicy must select pods with label app=backend-api"
  exit 1
fi

if ! echo "$policy_yaml" | grep -q "kubernetes.io/metadata.name: frontend"; then
  echo "NetworkPolicy must allow traffic from namespace frontend"
  exit 1
fi

if ! echo "$policy_yaml" | grep -q "app: frontend-app"; then
  echo "NetworkPolicy must allow traffic from pods labeled app=frontend-app"
  exit 1
fi

if ! echo "$policy_yaml" | grep -q "port: 8080"; then
  echo "NetworkPolicy must allow TCP port 8080"
  exit 1
fi

echo "PASS"
exit 0
