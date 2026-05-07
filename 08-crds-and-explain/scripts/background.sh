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

# Install a sample CRD for practice
kubectl apply -f - <<EOF
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              storageClass:
                type: string
              backupInterval:
                type: string
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
EOF

echo "Setup complete: sample CRD installed"
