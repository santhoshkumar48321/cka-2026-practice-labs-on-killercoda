#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

ns="database"

if ! kubectl -n "$ns" get pvc database-storage >/dev/null 2>&1; then
  fail "PVC database-storage not found in namespace $ns"
fi
if ! test "$(kubectl -n "$ns" get pvc database-storage -o jsonpath='{.spec.resources.requests.storage}')" = "500Mi"; then
  fail "PVC database-storage must request 500Mi"
fi
if ! test "$(kubectl -n "$ns" get pvc database-storage -o jsonpath='{.spec.accessModes[0]}')" = "ReadWriteOnce"; then
  fail "PVC database-storage must use ReadWriteOnce"
fi

if ! test -f /opt/database.yaml; then
  fail "Expected manifest /opt/database.yaml not found"
fi
if ! grep -q 'claimName: database-storage' /opt/database.yaml; then
  fail "/opt/database.yaml must reference PVC database-storage"
fi

echo "PASS"
exit 0
