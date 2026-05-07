#!/usr/bin/env bash
set -euo pipefail

if ! test -s /root/crds-list.yaml; then
  echo "Missing or empty file: ~/crds-list.yaml"
  exit 1
fi

if ! grep -q 'istio.io' /root/crds-list.yaml; then
  echo "~/crds-list.yaml must contain Istio CRD entries"
  exit 1
fi

if ! test -s /root/hosts-spec.yaml; then
  echo "Missing or empty file: ~/hosts-spec.yaml"
  exit 1
fi

if ! grep -qi 'hosts\|VirtualService' /root/hosts-spec.yaml; then
  echo "~/hosts-spec.yaml must contain kubectl explain output for VirtualService.spec.hosts"
  exit 1
fi

echo "PASS"
exit 0
