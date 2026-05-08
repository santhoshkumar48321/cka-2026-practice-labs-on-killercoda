#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get pvc database-storage -n database >/dev/null 2>&1; then
  echo "PVC database-storage not found in namespace database"
  exit 1
fi

access_mode=$(kubectl get pvc database-storage -n database -o jsonpath='{.spec.accessModes[0]}')
if test "$access_mode" != "ReadWriteOnce"; then
  echo "PVC access mode must be ReadWriteOnce"
  exit 1
fi

storage_size=$(kubectl get pvc database-storage -n database -o jsonpath='{.spec.resources.requests.storage}')
if test "$storage_size" != "500Mi"; then
  echo "PVC storage request must be 500Mi"
  exit 1
fi

if ! kubectl get deploy database-app -n database >/dev/null 2>&1; then
  echo "Deployment database-app not found in namespace database"
  exit 1
fi

claim_name=$(kubectl get deploy database-app -n database -o jsonpath='{.spec.template.spec.volumes[?(@.persistentVolumeClaim.claimName=="database-storage")].name}')
if test -z "$claim_name"; then
  echo "Deployment database-app must use PVC database-storage"
  exit 1
fi

if ! grep -q "database-storage" /opt/database.yaml; then
  echo "/opt/database.yaml must reference database-storage"
  exit 1
fi

echo "PASS"
exit 0
