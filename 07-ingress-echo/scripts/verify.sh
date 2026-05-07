#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get ingress app-ingress -n demo-app >/dev/null 2>&1; then
  echo "Ingress 'app-ingress' not found in namespace 'demo-app'"
  exit 1
fi

if ! kubectl get service app-service -n demo-app >/dev/null 2>&1; then
  echo "Service 'app-service' not found in namespace 'demo-app'"
  exit 1
fi

svc_port="$(kubectl get service app-service -n demo-app -o jsonpath='{.spec.ports[0].port}')"
if ! test "$svc_port" = "8090"; then
  echo "Service 'app-service' must expose port 8090, got: $svc_port"
  exit 1
fi

ing_yaml="$(kubectl get ingress app-ingress -n demo-app -o yaml)"
if ! echo "$ing_yaml" | grep -q 'demo.example.com'; then
  echo "Ingress must use host 'demo.example.com'"
  exit 1
fi
if ! echo "$ing_yaml" | grep -q 'path: /api'; then
  echo "Ingress must route path '/api'"
  exit 1
fi

echo "PASS"
exit 0
