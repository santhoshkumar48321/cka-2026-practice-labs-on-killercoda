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
apiVersion: v1
kind: Pod
metadata:
  name: log-pod
spec:
  containers:
  - name: log-gen
    image: busybox:1.36
    command: ["/bin/sh", "-c"]
    args:
    - |
      while true; do
        echo "INFO: application started" >> /var/log/app.log
        echo "ERROR: connection refused" >> /var/log/app.log
        echo "INFO: processing request" >> /var/log/app.log
        echo "ERROR: timeout occurred" >> /var/log/app.log
        sleep 2
      done
    volumeMounts:
    - name: log-vol
      mountPath: /var/log
  volumes:
  - name: log-vol
    emptyDir: {}
EOF

echo "Setup complete: log-pod generating mixed INFO/ERROR logs"
