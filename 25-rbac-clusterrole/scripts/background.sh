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

kubectl create namespace apps --dry-run=client -o yaml | kubectl apply -f -
kubectl create serviceaccount deploy-manager -n apps --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete"
