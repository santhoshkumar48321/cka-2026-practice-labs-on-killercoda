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

kubectl create namespace team-a --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace team-b --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: team-a-pod
  namespace: team-a
spec:
  containers:
  - name: app
    image: nginx:latest
YAML

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: team-b-pod
  namespace: team-b
spec:
  containers:
  - name: app
    image: nginx:latest
YAML

echo "Setup complete"
