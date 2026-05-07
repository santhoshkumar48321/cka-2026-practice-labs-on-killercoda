#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get pvc site-content -n default >/dev/null 2>&1; then
  echo "PVC 'site-content' not found"
  exit 1
fi

phase="$(kubectl get pvc site-content -n default -o jsonpath='{.status.phase}')"
if ! test "$phase" = "Bound"; then
  echo "PVC 'site-content' is not Bound (status: $phase)"
  exit 1
fi

req="$(kubectl get pvc site-content -n default -o jsonpath='{.spec.resources.requests.storage}')"
if ! echo "$req" | awk '
/Mi$/ {v=$0; sub(/Mi$/,"",v); if (v+0>=80) ok=1}
/Gi$/ {ok=1}
END{exit ok?0:1}
'; then
  echo "PVC 'site-content' must be expanded to at least 80Mi, got: $req"
  exit 1
fi

if ! kubectl get pod nginx-site -n default >/dev/null 2>&1; then
  echo "Pod 'nginx-site' not found"
  exit 1
fi

if ! test -s /opt/CKA2026/resize-record.yaml; then
  echo "Missing or empty file: /opt/CKA2026/resize-record.yaml"
  exit 1
fi

echo "PASS"
exit 0
