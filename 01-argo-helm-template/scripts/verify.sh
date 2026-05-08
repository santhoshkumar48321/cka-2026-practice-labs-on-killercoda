#!/usr/bin/env bash
set -euo pipefail

if ! test -f /home/candidate/argocd-manifest.yaml; then
  echo "argocd-manifest.yaml not found at /home/candidate"
  exit 1
fi

if ! test -s /home/candidate/argocd-manifest.yaml; then
  echo "argocd-manifest.yaml is empty"
  exit 1
fi

if grep -q '^kind: CustomResourceDefinition' /home/candidate/argocd-manifest.yaml; then
  echo "CRDs found in rendered manifest"
  exit 1
fi

echo "PASS"
exit 0
