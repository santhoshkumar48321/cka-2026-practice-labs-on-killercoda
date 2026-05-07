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

kubectl create namespace team-a --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace team-b --dry-run=client -o yaml | kubectl apply -f -

kubectl create deployment app-a --image=nginx:latest -n team-a \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment app-b --image=nginx:latest -n team-b \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete: namespaces team-a and team-b with deployments ready"
