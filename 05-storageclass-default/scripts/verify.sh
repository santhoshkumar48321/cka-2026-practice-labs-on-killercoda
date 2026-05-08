#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get sc local-storage >/dev/null 2>&1; then
  echo "StorageClass local-storage not found"
  exit 1
fi

provisioner=$(kubectl get sc local-storage -o jsonpath='{.provisioner}')
if test "$provisioner" != "rancher.io/local-path"; then
  echo "StorageClass provisioner must be rancher.io/local-path"
  exit 1
fi

binding_mode=$(kubectl get sc local-storage -o jsonpath='{.volumeBindingMode}')
if test "$binding_mode" != "WaitForFirstConsumer"; then
  echo "StorageClass volumeBindingMode must be WaitForFirstConsumer"
  exit 1
fi

is_default=$(kubectl get sc local-storage -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')
if test "$is_default" != "true"; then
  echo "StorageClass must be marked as the default"
  exit 1
fi

echo "PASS"
exit 0
