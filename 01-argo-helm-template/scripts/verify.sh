#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

manifest="/home/candidate/argocd-manifest.yaml"

if ! test -f "$manifest"; then
  fail "Expected manifest file not found at $manifest"
fi

if ! test -s "$manifest"; then
  fail "Manifest file is empty: $manifest"
fi

if ! grep -q '^kind:' "$manifest"; then
  fail "Manifest does not look like Kubernetes YAML output"
fi

if ! grep -q 'namespace: gitops' "$manifest"; then
  fail "Manifest must target namespace gitops"
fi

if grep -q '^kind: CustomResourceDefinition' "$manifest"; then
  fail "Manifest must not contain CustomResourceDefinition resources"
fi

echo "PASS"
exit 0
