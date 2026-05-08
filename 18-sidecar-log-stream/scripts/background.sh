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
apiVersion: v1
kind: Pod
metadata:
  name: atlas-app
spec:
  containers:
  - name: atlas-main
    image: busybox:1.36
    command:
    - /bin/sh
    - -c
    - while true; do echo "atlas log" >> /var/log/atlas-app.log; sleep 5; done
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: log-volume
    emptyDir: {}
YAML

echo "Setup complete"
