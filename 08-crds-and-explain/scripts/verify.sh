#!/usr/bin/env bash
set -euo pipefail

crd_name="${CRD_NAME:-backups.stable.example.com}"
crd_kind="${CRD_KIND:-Backup}"

if ! test -n "$crd_name"; then
  echo "CRD_NAME is empty"
  exit 1
fi

if ! test -n "$crd_kind"; then
  echo "CRD_KIND is empty"
  exit 1
fi

if ! kubectl get crd "$crd_name" >/dev/null 2>&1; then
  echo "CRD $crd_name not found"
  exit 1
fi

if ! kubectl explain "$crd_kind" >/dev/null 2>&1; then
  echo "kubectl explain failed for kind $crd_kind"
  exit 1
fi

echo "PASS"
exit 0
