#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

ns="demo-app"

if ! kubectl get svc app-service -n "$ns" >/dev/null 2>&1; then
  fail "Service app-service not found in namespace $ns"
fi
if ! kubectl get ingress app-ingress -n "$ns" >/dev/null 2>&1; then
  fail "Ingress app-ingress not found in namespace $ns"
fi

if ! test "$(kubectl get svc app-service -n "$ns" -o jsonpath='{.spec.type}')" = "ClusterIP"; then
  fail "Service app-service must be type ClusterIP"
fi

if ! test "$(kubectl get svc app-service -n "$ns" -o jsonpath='{.spec.ports[0].port}')" = "8090"; then
  fail "Service app-service must expose port 8090"
fi

if ! test "$(kubectl get ingress app-ingress -n "$ns" -o jsonpath='{.spec.rules[0].host}')" = "demo.example.com"; then
  fail "Ingress app-ingress must use host demo.example.com"
fi
if ! test "$(kubectl get ingress app-ingress -n "$ns" -o jsonpath='{.spec.rules[0].http.paths[0].path}')" = "/api"; then
  fail "Ingress app-ingress must route path /api"
fi
if ! test "$(kubectl get ingress app-ingress -n "$ns" -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')" = "app-service"; then
  fail "Ingress backend service must be app-service"
fi
if ! test "$(kubectl get ingress app-ingress -n "$ns" -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')" = "8090"; then
  fail "Ingress backend service port must be 8090"
fi

echo "PASS"
exit 0
