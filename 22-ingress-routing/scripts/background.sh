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

kubectl create deployment app-v1 --image=nginx:latest --replicas=1 \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment app-v2 --image=nginx:latest --replicas=1 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl expose deployment app-v1 --name=app-v1 --port=80 --target-port=80 \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deployment app-v2 --name=app-v2 --port=80 --target-port=80 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml || true

echo "Setup complete: app-v1 and app-v2 deployments and services ready"
