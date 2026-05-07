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

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: payment-api
spec:
  containers:
  - name: payment-api
    image: busybox:1.36
    command: ["/bin/sh", "-c", "while true; do echo info started; echo error file-not-found; sleep 2; done"]
    volumeMounts:
    - name: applogs
      mountPath: /var/log
  volumes:
  - name: applogs
    emptyDir: {}
YAML

mkdir -p /opt/CKA2026/payment-api

echo "Setup complete"
