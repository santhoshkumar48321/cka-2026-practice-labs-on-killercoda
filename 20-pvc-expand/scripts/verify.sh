#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get pvc site-content >/dev/null 2>&1; then
  echo "PVC site-content not found"
  exit 1
fi

pvc_size=$(kubectl get pvc site-content -o jsonpath='{.spec.resources.requests.storage}')
if test "$pvc_size" != "80Mi"; then
  echo "PVC site-content must be expanded to 80Mi"
  exit 1
fi

pvc_sc=$(kubectl get pvc site-content -o jsonpath='{.spec.storageClassName}')
if test "$pvc_sc" != "csi-hostpath-sc"; then
  echo "PVC site-content must use storageClass csi-hostpath-sc"
  exit 1
fi

if ! kubectl get pod nginx-site >/dev/null 2>&1; then
  echo "Pod nginx-site not found"
  exit 1
fi

claim=$(kubectl get pod nginx-site -o jsonpath='{.spec.volumes[?(@.persistentVolumeClaim.claimName=="site-content")].name}')
if test -z "$claim"; then
  echo "Pod nginx-site must mount PVC site-content"
  exit 1
fi

if ! test -f /opt/CKA2026/resize-record.yaml; then
  echo "resize-record.yaml not found at /opt/CKA2026/resize-record.yaml"
  exit 1
fi

if ! grep -q "80Mi" /opt/CKA2026/resize-record.yaml; then
  echo "resize-record.yaml must include the expanded size 80Mi"
  exit 1
fi

echo "PASS"
exit 0
