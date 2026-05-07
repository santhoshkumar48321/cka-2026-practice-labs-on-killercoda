#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

sc="local-storage"

if ! kubectl get sc "$sc" >/dev/null 2>&1; then
  fail "StorageClass $sc not found"
fi

if ! test "$(kubectl get sc "$sc" -o jsonpath='{.provisioner}')" = "rancher.io/local-path"; then
  fail "StorageClass $sc must use provisioner rancher.io/local-path"
fi

if ! test "$(kubectl get sc "$sc" -o jsonpath='{.volumeBindingMode}')" = "WaitForFirstConsumer"; then
  fail "StorageClass $sc must use volumeBindingMode WaitForFirstConsumer"
fi

if ! test "$(kubectl get sc "$sc" -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')" = "true"; then
  fail "StorageClass $sc must be marked as default"
fi

echo "PASS"
exit 0
