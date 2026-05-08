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

kubectl create ns ing-private --dry-run=client -o yaml | kubectl apply -f -

cat <<'YAML' | kubectl apply -f -
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
        image: hashicorp/http-echo:0.2.3
        args:
        - -text=Hello from Kubernetes!
        - -listen=:5678
        ports:
        - containerPort: 5678
YAML

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: hello
  namespace: ing-private
spec:
  selector:
    app: hello
  ports:
  - port: 5678
    targetPort: 5678
YAML

kubectl delete ingress wave -n ing-private --ignore-not-found >/dev/null 2>&1 || true

echo "Setup complete"
