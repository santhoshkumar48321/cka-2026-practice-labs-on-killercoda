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

kubectl create ns production --dry-run=client -o yaml | kubectl apply -f -

cat <<'YAML' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: baseline-priority
value: 10000
globalDefault: false
description: "Baseline PriorityClass for labs"
YAML

cat <<'YAML' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: top-priority
value: 20000
globalDefault: false
description: "Highest PriorityClass for labs"
YAML

cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logger-app
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logger-app
  template:
    metadata:
      labels:
        app: logger-app
    spec:
      containers:
      - name: logger
        image: busybox:1.36
        command:
        - /bin/sh
        - -c
        - while true; do echo "log"; sleep 5; done
YAML

echo "Setup complete"
