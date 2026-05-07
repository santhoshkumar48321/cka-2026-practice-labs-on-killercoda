#!/usr/bin/env bash
set -euo pipefail

if ! test -s /home/candidate/argocd-manifest.yaml; then
  echo "Missing or empty file: /home/candidate/argocd-manifest.yaml"
  exit 1
fi

if grep -q 'kind: CustomResourceDefinition' /home/candidate/argocd-manifest.yaml; then
  echo "File must not contain kind: CustomResourceDefinition"
  exit 1
fi

echo "PASS"
exit 0
