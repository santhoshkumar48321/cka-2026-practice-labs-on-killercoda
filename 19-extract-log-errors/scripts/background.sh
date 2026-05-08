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

mkdir -p /opt/CKA2026/payment-api
rm -f /opt/CKA2026/payment-api/errors.log

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: payment-api
spec:
  containers:
  - name: payment
    image: busybox:1.36
    command:
    - /bin/sh
    - -c
    - |
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 3)) -eq 0 ]; then
          echo "error file-not-found: /data/config-${i}.json"
        else
          echo "INFO: Processing request ${i}"
        fi
        echo "error file-not-found: /var/log/config-${i}.json" >> /var/log/payment.log
        sleep 2
      done
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: log-volume
    emptyDir: {}
YAML

echo "Setup complete"
