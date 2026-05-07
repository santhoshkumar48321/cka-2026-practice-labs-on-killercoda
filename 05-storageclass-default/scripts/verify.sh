#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get storageclass local-storage >/dev/null 2>&1; then
  echo "StorageClass 'local-storage' not found"
  exit 1
fi

provisioner="$(kubectl get storageclass local-storage -o jsonpath='{.provisioner}')"
if ! test "$provisioner" = "rancher.io/local-path"; then
  echo "StorageClass provisioner must be 'rancher.io/local-path', got: $provisioner"
  exit 1
fi

vbm="$(kubectl get storageclass local-storage -o jsonpath='{.volumeBindingMode}')"
if ! test "$vbm" = "WaitForFirstConsumer"; then
  echo "StorageClass volumeBindingMode must be 'WaitForFirstConsumer', got: $vbm"
  exit 1
fi

ann="$(kubectl get storageclass local-storage -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')"
if ! test "$ann" = "true"; then
  echo "StorageClass 'local-storage' must have is-default-class annotation set to true"
  exit 1
fi

echo "PASS"
exit 0
