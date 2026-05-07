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

kubectl create namespace ing-private --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello
  namespace: ing-private
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - name: hello
        image: nginx:latest
        ports:
        - containerPort: 5678
YAML

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: hello
  namespace: ing-private
spec:
  type: ClusterIP
  selector:
    app: hello
  ports:
  - port: 5678
    targetPort: 5678
YAML

echo "Setup complete"
