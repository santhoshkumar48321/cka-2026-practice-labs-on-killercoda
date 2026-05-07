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

kubectl create namespace portal --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<'YAML'
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
      - name: ui-frontend
        image: nginx:1.27
YAML

echo "Setup complete"
