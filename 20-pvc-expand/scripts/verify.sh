#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get pvc site-content >/dev/null 2>&1; then
  fail "PVC site-content not found"
fi
if ! test "$(kubectl get pvc site-content -o jsonpath='{.spec.storageClassName}')" = "csi-hostpath-sc"; then
  fail "PVC site-content must use StorageClass csi-hostpath-sc"
fi
if ! test "$(kubectl get pvc site-content -o jsonpath='{.spec.resources.requests.storage}')" = "80Mi"; then
  fail "PVC site-content must be expanded to 80Mi"
fi
if ! test "$(kubectl get pvc site-content -o jsonpath='{.spec.accessModes[0]}')" = "ReadWriteOnce"; then
  fail "PVC site-content must use ReadWriteOnce"
fi

if ! kubectl get pod nginx-site >/dev/null 2>&1; then
  fail "Pod nginx-site not found"
fi
if ! test "$(kubectl get pod nginx-site -o jsonpath='{.spec.containers[0].image}')" = "nginx:1.27"; then
  fail "Pod nginx-site must use image nginx:1.27"
fi
if ! test "$(kubectl get pod nginx-site -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}')" = "/usr/share/nginx/html"; then
  fail "Pod nginx-site must mount PVC at /usr/share/nginx/html"
fi
if ! test "$(kubectl get pod nginx-site -o jsonpath='{.spec.volumes[0].persistentVolumeClaim.claimName}')" = "site-content"; then
  fail "Pod nginx-site must reference PVC site-content"
fi

record="/opt/CKA2026/resize-record.yaml"
if ! test -f "$record"; then
  fail "Resize record file not found: $record"
fi
if ! grep -q '^  name: site-content$' "$record"; then
  fail "Resize record must contain PVC name site-content"
fi
if ! grep -q 'storage: 80Mi' "$record"; then
  fail "Resize record must include resized storage value 80Mi"
fi

echo "PASS"
exit 0
