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

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logger
  template:
    metadata:
      labels:
        app: logger
    spec:
      volumes:
      - name: log-vol
        emptyDir: {}
      containers:
      - name: log-writer
        image: busybox:1.36
        command: ["/bin/sh", "-c"]
        args:
        - while true; do echo "$(date) INFO log entry" >> /var/log/app.log; sleep 1; done
        volumeMounts:
        - name: log-vol
          mountPath: /var/log
EOF

kubectl wait --for=condition=available deployment/logger --timeout=90s

echo "Setup complete: logger deployment writing to /var/log/app.log"
