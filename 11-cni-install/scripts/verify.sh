#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get deployment tigera-operator -n tigera-operator >/dev/null 2>&1; then
  echo "tigera-operator deployment not found in namespace tigera-operator"
  exit 1
fi

if ! kubectl get daemonset calico-node -n calico-system >/dev/null 2>&1; then
  echo "calico-node daemonset not found in namespace calico-system"
  exit 1
fi

echo "PASS"
exit 0
