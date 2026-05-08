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

wait_kube

node_name=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl label node "$node_name" disk=ssd --overwrite

echo "Setup complete"
