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

kubectl create ns portal --dry-run=client -o yaml | kubectl apply -f -

cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ui-frontend
  namespace: portal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ui-frontend
  template:
    metadata:
      labels:
        app: ui-frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
YAML

kubectl delete svc ui-frontend-svc -n portal --ignore-not-found >/dev/null 2>&1 || true

echo "Setup complete"
