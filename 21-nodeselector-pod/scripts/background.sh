#!/usr/bin/env bash
set -euo pipefail

wait_kube() {
  echo "Waiting for Kubernetes API..."
  for i in $(seq 1 60); do
    if kubectl get ns >/dev/null 2>&1; then return 0; fi
    sleep 2
  done
  echo "Kubernetes API not ready"; exit 1
}
wait_kube

WORKER=$(kubectl get nodes --no-headers | grep -v control-plane | awk '{print $1}' | head -1)

if [ -n "$WORKER" ]; then
  kubectl label node "$WORKER" disk=ssd --overwrite
  echo "Setup complete: node $WORKER labeled with disk=ssd"
else
  echo "No worker node found"
fi
