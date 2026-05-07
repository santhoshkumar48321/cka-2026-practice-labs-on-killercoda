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

kubectl create deployment web --image=nginx:latest --replicas=2 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl expose deployment web --name=web-svc --port=80 --target-port=80 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl wait --for=condition=available deployment/web --timeout=90s

echo "Setup complete: web deployment and web-svc ClusterIP service ready"
