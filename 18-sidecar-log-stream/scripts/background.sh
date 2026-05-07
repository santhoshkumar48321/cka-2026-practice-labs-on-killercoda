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
  name: atlas-app
spec:
  volumes:
  - name: log-vol
    emptyDir: {}
  containers:
  - name: atlas-app
    image: busybox:1.36
    command: ["/bin/sh", "-c"]
    args:
    - |
      mkdir -p /var/log
      while true; do
        echo "$(date) INFO atlas-app processing request" >> /var/log/atlas-app.log
        sleep 2
      done
    volumeMounts:
    - name: log-vol
      mountPath: /var/log
YAML

echo "Setup complete"
