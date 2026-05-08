#!/usr/bin/env bash
set -euo pipefail

CRD_NAME="virtualservices.networking.istio.io"
CRD_KIND="virtualservice"

if ! test -f "$HOME/crds-list.yaml"; then
  echo "crds-list.yaml not found in home directory"
  exit 1
fi

if ! grep -q "${CRD_NAME}" "$HOME/crds-list.yaml"; then
  echo "crds-list.yaml does not include ${CRD_NAME}"
  exit 1
fi

if ! test -f "$HOME/hosts-spec.yaml"; then
  echo "hosts-spec.yaml not found in home directory"
  exit 1
fi

if ! grep -q "hosts" "$HOME/hosts-spec.yaml"; then
  echo "hosts-spec.yaml does not include documentation for hosts"
  exit 1
fi

echo "PASS"
exit 0
