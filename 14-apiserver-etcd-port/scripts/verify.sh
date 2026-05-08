#!/usr/bin/env bash
set -euo pipefail

manifest="/etc/kubernetes/manifests/kube-apiserver.yaml"
if ! test -f "$manifest"; then
  echo "kube-apiserver manifest not found at /etc/kubernetes/manifests/kube-apiserver.yaml"
  exit 1
fi

if ! grep -q '2379' "$manifest"; then
  echo "kube-apiserver manifest must reference etcd port 2379"
  exit 1
fi

if grep -q '2380' "$manifest"; then
  echo "kube-apiserver manifest still references etcd port 2380"
  exit 1
fi

echo "PASS"
exit 0
