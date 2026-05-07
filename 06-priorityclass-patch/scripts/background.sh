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

kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'YAML'
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: platform-high
value: 2000
globalDefault: false
description: "Baseline high priority"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: platform-medium
value: 1000
globalDefault: false
description: "Baseline medium priority"
YAML

kubectl create deployment logger-app -n production --image=nginx:1.27 --replicas=1 --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete"
