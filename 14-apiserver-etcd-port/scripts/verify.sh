#!/usr/bin/env bash
set -euo pipefail

manifest="/etc/kubernetes/manifests/kube-apiserver.yaml"

if ! test -s "$manifest"; then
  echo "kube-apiserver manifest not found at $manifest"
  exit 1
fi

if ! grep -q -- '--etcd-servers=.*:2379' "$manifest"; then
  echo "kube-apiserver etcd port is not set to 2379"
  exit 1
fi

if ! kubectl get nodes >/dev/null 2>&1; then
  echo "API server is not responding to kubectl get nodes"
  exit 1
fi

echo "PASS"
exit 0
