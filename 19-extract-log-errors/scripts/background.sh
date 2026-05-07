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

mkdir -p /opt/CKA2026/payment-api

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: payment-api
spec:
  volumes:
  - name: app-logs
    emptyDir: {}
  containers:
  - name: payment-api
    image: busybox:1.36
    command: ["/bin/sh", "-c"]
    args:
    - |
      while true; do
        echo "INFO processing payment request id=1234" | tee -a /var/log/payment-api.log
        echo "error file-not-found: receipt_1234.pdf" | tee -a /var/log/payment-api.log
        echo "INFO payment completed successfully" | tee -a /var/log/payment-api.log
        echo "error file-not-found: invoice_5678.pdf" | tee -a /var/log/payment-api.log
        echo "INFO request completed" | tee -a /var/log/payment-api.log
        sleep 2
      done
    volumeMounts:
    - name: app-logs
      mountPath: /var/log
YAML

echo "Setup complete"
