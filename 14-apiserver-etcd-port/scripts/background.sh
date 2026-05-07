#!/usr/bin/env bash
set -euo pipefail

wait_kube() {
  for i in $(seq 1 60); do
    if kubectl get ns >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Kubernetes API not ready after 60 seconds" >&2
  exit 1
}

wait_kube

manifest="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ ! -f "$manifest" ]; then
  echo "API server manifest not found at $manifest" >&2
  exit 1
fi

if grep -q '2379' "$manifest"; then
  sed -i -E 's#(https://[^: ,]+:)(2379)#\12380#g' "$manifest"
fi
if ! grep -q '2380' "$manifest"; then
  echo "Failed to update etcd endpoint port to 2380 in $manifest" >&2
  exit 1
fi

echo "Setup complete"
