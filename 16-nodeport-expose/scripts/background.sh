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

kubectl create namespace services --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-deployment
  namespace: services
spec:
  replicas: 2
  selector:
    matchLabels:
      app: service-deployment
  template:
    metadata:
      labels:
        app: service-deployment
    spec:
      containers:
      - name: app
        image: nginx:latest
YAML

echo "Setup complete"
