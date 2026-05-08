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

kubectl create ns services --dry-run=client -o yaml | kubectl apply -f -

cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-deployment
  namespace: services
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-deployment
  template:
    metadata:
      labels:
        app: service-deployment
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
          name: web
YAML

kubectl delete svc service-nodeport -n services --ignore-not-found >/dev/null 2>&1 || true

echo "Setup complete"
