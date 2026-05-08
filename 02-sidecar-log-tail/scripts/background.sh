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

cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: busybox:1.36
        command:
        - /bin/sh
        - -c
        - while true; do echo "log entry" >> /var/log/application.log; sleep 5; done
        volumeMounts:
        - name: app-logs
          mountPath: /var/log
      volumes:
      - name: app-logs
        emptyDir: {}
YAML

echo "Setup complete"
