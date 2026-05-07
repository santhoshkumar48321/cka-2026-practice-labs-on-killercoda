#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get pvc database-storage -n database >/dev/null 2>&1; then
  echo "PVC 'database-storage' not found in namespace 'database'"
  exit 1
fi

phase="$(kubectl get pvc database-storage -n database -o jsonpath='{.status.phase}')"
if ! test "$phase" = "Bound"; then
  echo "PVC 'database-storage' is not Bound (status: $phase)"
  exit 1
fi

pods="$(kubectl get pods -n database -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\t"}{range .spec.containers[*]}{.image}{","}{end}{"\t"}{range .spec.volumes[*]}{.persistentVolumeClaim.claimName}{","}{end}{"\n"}{end}')"
if ! echo "$pods" | awk -F'\t' '$2=="Running" && $3 ~ /mariadb/ && $4 ~ /database-storage/{ok=1} END{exit ok?0:1}'; then
  echo "No Running MariaDB pod using PVC 'database-storage' found in namespace 'database'"
  exit 1
fi

echo "PASS"
exit 0
