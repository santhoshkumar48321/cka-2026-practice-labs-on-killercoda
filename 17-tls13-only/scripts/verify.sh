#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get configmap nginx-tls-config -n web >/dev/null 2>&1; then
  echo "ConfigMap 'nginx-tls-config' not found in namespace 'web'"
  exit 1
fi

cm_yaml="$(kubectl get configmap nginx-tls-config -n web -o yaml)"

if echo "$cm_yaml" | grep -q 'TLSv1.2' && ! echo "$cm_yaml" | grep -q 'TLSv1.3'; then
  echo "nginx config must include TLSv1.3"
  exit 1
fi

if echo "$cm_yaml" | grep 'ssl_protocols' | grep -q 'TLSv1.2'; then
  echo "nginx config must NOT allow TLSv1.2 (only TLSv1.3)"
  exit 1
fi

if ! echo "$cm_yaml" | grep 'ssl_protocols' | grep -q 'TLSv1.3'; then
  echo "nginx config must explicitly set ssl_protocols TLSv1.3"
  exit 1
fi

echo "PASS"
exit 0
