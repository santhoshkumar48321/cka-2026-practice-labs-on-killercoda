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

kubectl create namespace restricted --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: restricted
  labels:
    app: app
spec:
  containers:
  - name: app
    image: nginx:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: allowed-client
  namespace: restricted
  labels:
    app: client
spec:
  containers:
  - name: client
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF

echo "Setup complete: restricted namespace with app-pod and allowed-client ready"
