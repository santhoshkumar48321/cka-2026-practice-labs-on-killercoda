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

kubectl create namespace restricted --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'YAML'
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
YAML

kubectl apply -f - <<'YAML'
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
    command: ["/bin/sh","-c","sleep 3600"]
YAML

echo "Setup complete"
