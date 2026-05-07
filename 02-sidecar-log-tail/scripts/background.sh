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

kubectl create deployment webapp --image=nginx:latest --replicas=1 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl wait --for=condition=available deployment/webapp --timeout=90s

echo "Setup complete: webapp deployment is ready"
