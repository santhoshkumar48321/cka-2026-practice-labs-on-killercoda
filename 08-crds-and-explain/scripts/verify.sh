#!/usr/bin/env bash
set -euo pipefail

CRD_NAME="virtualservices.networking.istio.io"
CRD_KIND="VirtualService"

if ! test -s /root/crds-list.yaml; then
  echo "Missing or empty file: ~/crds-list.yaml"
  exit 1
fi

if ! grep -q "$CRD_NAME" /root/crds-list.yaml; then
  echo "~/crds-list.yaml must contain CRD: $CRD_NAME"
  exit 1
fi

if ! test -s /root/hosts-spec.yaml; then
  echo "Missing or empty file: ~/hosts-spec.yaml"
  exit 1
fi

if ! grep -q "$CRD_KIND" /root/hosts-spec.yaml; then
  echo "~/hosts-spec.yaml must contain kind reference: $CRD_KIND"
  exit 1
fi

if ! grep -qi 'hosts' /root/hosts-spec.yaml; then
  echo "~/hosts-spec.yaml must contain kubectl explain output for VirtualService.spec.hosts"
  exit 1
fi

echo "PASS"
exit 0
