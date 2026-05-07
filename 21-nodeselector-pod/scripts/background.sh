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

worker_node="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane,!node-role.kubernetes.io/master' -o jsonpath='{.items[0].metadata.name}')"
if [ -z "$worker_node" ]; then
  worker_node="$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')"
fi

kubectl label node "$worker_node" disk=ssd --overwrite

echo "Setup complete"
