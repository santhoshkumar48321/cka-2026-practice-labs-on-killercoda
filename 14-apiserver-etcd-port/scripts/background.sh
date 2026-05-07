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

manifest="/etc/kubernetes/manifests/kube-apiserver.yaml"
if ! test -f "$manifest"; then
  echo "API server manifest not found at $manifest" >&2
  exit 1
fi

cp -a "$manifest" "${manifest}.bak"
sed -i -E '/--etcd-servers=/ s#(https://[^,[:space:]]+:)(2379)#\12380#g' "$manifest"

wait_kube

echo "Setup complete"
