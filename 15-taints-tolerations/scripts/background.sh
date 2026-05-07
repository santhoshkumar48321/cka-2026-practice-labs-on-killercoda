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

# Get worker node name
WORKER=$(kubectl get nodes --no-headers | grep -v control-plane | awk '{print $1}' | head -1)

if [ -n "$WORKER" ]; then
  kubectl taint nodes "$WORKER" env=prod:NoSchedule --overwrite
fi

kubectl create deployment tainted-app --image=nginx:latest --replicas=2 \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete: taint applied to $WORKER, tainted-app deployment created"
