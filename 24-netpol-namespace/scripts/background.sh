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

kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -

kubectl label namespace frontend  ns=frontend --overwrite
kubectl label namespace backend   ns=backend  --overwrite

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: frontend-pod
  namespace: frontend
  labels:
    app: frontend
spec:
  containers:
  - name: app
    image: nginx:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: backend-pod
  namespace: backend
  labels:
    app: backend
spec:
  containers:
  - name: app
    image: nginx:latest
EOF

echo "Setup complete: frontend and backend namespaces with pods ready"
