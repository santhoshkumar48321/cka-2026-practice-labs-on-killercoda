#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

manifest="/etc/kubernetes/manifests/kube-apiserver.yaml"

if ! test -f "$manifest"; then
  fail "kube-apiserver manifest not found at $manifest"
fi

if ! grep -q -- '--etcd-servers=.*:2379' "$manifest"; then
  fail "kube-apiserver manifest must use etcd client port 2379"
fi
if grep -q -- '--etcd-servers=.*:2380' "$manifest"; then
  fail "kube-apiserver manifest still contains etcd peer port 2380"
fi

echo "PASS"
exit 0
