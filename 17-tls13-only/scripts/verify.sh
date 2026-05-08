#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get configmap web-tls-config -n web >/dev/null 2>&1; then
  echo "ConfigMap web-tls-config not found in namespace web"
  exit 1
fi

config_data=$(kubectl get configmap web-tls-config -n web -o jsonpath='{.data.tls\.conf}')
if ! echo "$config_data" | grep -q "TLSv1.3"; then
  echo "ConfigMap must allow TLSv1.3"
  exit 1
fi

if echo "$config_data" | grep -q "TLSv1.2"; then
  echo "ConfigMap must not allow TLSv1.2"
  exit 1
fi

if ! grep -q "secure.demo.local" /etc/hosts; then
  echo "/etc/hosts must include secure.demo.local"
  exit 1
fi

echo "PASS"
exit 0
