#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get ingress api-ingress >/dev/null 2>&1; then
  fail "Ingress api-ingress not found"
fi
if ! kubectl get gateway api-gateway >/dev/null 2>&1; then
  fail "Gateway api-gateway not found"
fi
if ! kubectl get httproute api-route >/dev/null 2>&1; then
  fail "HTTPRoute api-route not found"
fi

if ! test "$(kubectl get gateway api-gateway -o jsonpath='{.spec.gatewayClassName}')" = "nginx-gateway"; then
  fail "Gateway api-gateway must use GatewayClass nginx-gateway"
fi

if ! test "$(kubectl get gateway api-gateway -o jsonpath='{.spec.listeners[0].hostname}')" = "api.demo.k8s.local"; then
  fail "Gateway listener hostname must be api.demo.k8s.local"
fi

if ! test "$(kubectl get httproute api-route -o jsonpath='{.spec.parentRefs[0].name}')" = "api-gateway"; then
  fail "HTTPRoute api-route must attach to gateway api-gateway"
fi

if ! test "$(kubectl get httproute api-route -o jsonpath='{.spec.hostnames[0]}')" = "api.demo.k8s.local"; then
  fail "HTTPRoute hostname must be api.demo.k8s.local"
fi

ingress_backend="$(kubectl get ingress api-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}:{.spec.rules[0].http.paths[0].backend.service.port.number}')"
route_backend="$(kubectl get httproute api-route -o jsonpath='{.spec.rules[0].backendRefs[0].name}:{.spec.rules[0].backendRefs[0].port}')"
if ! test "$route_backend" = "$ingress_backend"; then
  fail "HTTPRoute backend must match api-ingress backend ($ingress_backend)"
fi

echo "PASS"
exit 0
