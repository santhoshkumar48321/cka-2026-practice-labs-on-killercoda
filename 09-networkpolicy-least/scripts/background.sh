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

kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend  --dry-run=client -o yaml | kubectl apply -f -

kubectl label namespace frontend kubernetes.io/metadata.name=frontend --overwrite
kubectl label namespace backend  kubernetes.io/metadata.name=backend  --overwrite

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["/bin/sh", "-c", "sleep 3600"]
YAML

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  namespace: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
YAML

echo "Setup complete"
