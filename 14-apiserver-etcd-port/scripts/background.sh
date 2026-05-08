#!/usr/bin/env bash
set -euo pipefail

wait_kube() {
  echo "Waiting for Kubernetes API..."
  for i in $(seq 1 60); do
    if kubectl get ns >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Kubernetes API not ready"
  exit 1
}

manifest="/etc/kubernetes/manifests/kube-apiserver.yaml"
if test -f "$manifest"; then
  sed -i 's/2379/2380/' "$manifest"
fi

echo "Setup complete"
