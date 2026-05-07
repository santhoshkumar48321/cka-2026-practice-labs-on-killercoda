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
  name: log-pod
spec:
  containers:
  - name: logger
    image: busybox:1.36
    command: ["/bin/sh","-c","while true; do echo \"INFO request ok\" >> /var/log/app.log; echo \"ERROR failed to process\" >> /var/log/app.log; sleep 1; done"]
YAML

echo "Setup complete"
