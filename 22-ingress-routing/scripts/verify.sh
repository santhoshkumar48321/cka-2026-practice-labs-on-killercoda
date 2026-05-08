#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get ingress wave -n ing-private >/dev/null 2>&1; then
  echo "Ingress wave not found in namespace ing-private"
  exit 1
fi

path=$(kubectl get ingress wave -n ing-private -o jsonpath='{.spec.rules[0].http.paths[0].path}')
if test "$path" != "/hello"; then
  echo "Ingress wave must route path /hello"
  exit 1
fi

backend_service=$(kubectl get ingress wave -n ing-private -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
if test "$backend_service" != "hello"; then
  echo "Ingress wave must route to service hello"
  exit 1
fi

backend_port=$(kubectl get ingress wave -n ing-private -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')
if test "$backend_port" != "5678"; then
  echo "Ingress wave must route to service port 5678"
  exit 1
fi

echo "PASS"
exit 0
