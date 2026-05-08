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

kubectl create ns app-squad --dry-run=client -o yaml | kubectl apply -f -

kubectl delete rolebinding pipeline-deployer-binding -n app-squad --ignore-not-found >/dev/null 2>&1 || true
kubectl delete serviceaccount cicd-bot -n app-squad --ignore-not-found >/dev/null 2>&1 || true
kubectl delete clusterrole pipeline-deployer --ignore-not-found >/dev/null 2>&1 || true

echo "Setup complete"
