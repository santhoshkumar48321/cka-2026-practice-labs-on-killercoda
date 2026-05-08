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

kubectl create ns echo --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns team-app --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace team-app name=team-app --overwrite

cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server
  namespace: echo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo-server
  template:
    metadata:
      labels:
        app: echo-server
    spec:
      containers:
      - name: echo
        image: hashicorp/http-echo:0.2.3
        args:
        - -listen=:9000
        - -text=Hello from echo
        ports:
        - containerPort: 9000
YAML

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: echo-svc
  namespace: echo
spec:
  selector:
    app: echo-server
  ports:
  - port: 9000
    targetPort: 9000
YAML

kubectl delete netpol allow-9000-from-team -n echo --ignore-not-found >/dev/null 2>&1 || true

echo "Setup complete"
