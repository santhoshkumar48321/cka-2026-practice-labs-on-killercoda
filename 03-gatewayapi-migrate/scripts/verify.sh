#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get gateway api-gateway >/dev/null 2>&1; then
  echo "Gateway api-gateway not found"
  exit 1
fi

gateway_class=$(kubectl get gateway api-gateway -o jsonpath='{.spec.gatewayClassName}')
if test "$gateway_class" != "nginx-gateway"; then
  echo "GatewayClass must be nginx-gateway"
  exit 1
fi

gateway_hosts=$(kubectl get gateway api-gateway -o jsonpath='{.spec.listeners[*].hostname}')
if ! echo "$gateway_hosts" | grep -qw "api.demo.k8s.local"; then
  echo "Gateway hostname must be api.demo.k8s.local"
  exit 1
fi

gateway_protocols=$(kubectl get gateway api-gateway -o jsonpath='{.spec.listeners[*].protocol}')
if ! echo "$gateway_protocols" | grep -qw "HTTPS"; then
  echo "Gateway must have an HTTPS listener"
  exit 1
fi

gateway_tls=$(kubectl get gateway api-gateway -o jsonpath='{.spec.listeners[*].tls.certificateRefs[0].name}')
if test "$gateway_tls" != "api-tls"; then
  echo "Gateway must reference TLS secret api-tls"
  exit 1
fi

if ! kubectl get httproute api-route >/dev/null 2>&1; then
  echo "HTTPRoute api-route not found"
  exit 1
fi

route_hosts=$(kubectl get httproute api-route -o jsonpath='{.spec.hostnames[*]}')
if ! echo "$route_hosts" | grep -qw "api.demo.k8s.local"; then
  echo "HTTPRoute hostname must be api.demo.k8s.local"
  exit 1
fi

route_parents=$(kubectl get httproute api-route -o jsonpath='{.spec.parentRefs[*].name}')
if ! echo "$route_parents" | grep -qw "api-gateway"; then
  echo "HTTPRoute must attach to api-gateway"
  exit 1
fi

backend_names=$(kubectl get httproute api-route -o jsonpath='{.spec.rules[*].backendRefs[*].name}')
if ! echo "$backend_names" | grep -qw "web-svc"; then
  echo "HTTPRoute must route to service web-svc"
  exit 1
fi

backend_ports=$(kubectl get httproute api-route -o jsonpath='{.spec.rules[*].backendRefs[*].port}')
if ! echo "$backend_ports" | grep -qw "80"; then
  echo "HTTPRoute backend port must be 80"
  exit 1
fi

echo "PASS"
exit 0
