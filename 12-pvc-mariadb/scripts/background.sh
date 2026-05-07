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

# Ensure a default StorageClass exists
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF

echo "Setup complete: StorageClass 'standard' ready. User must create PVC and MariaDB pod."
