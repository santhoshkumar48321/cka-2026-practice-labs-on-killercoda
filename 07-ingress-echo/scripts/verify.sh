#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get svc app-service -n demo-app >/dev/null 2>&1; then
  echo "Service app-service not found in namespace demo-app"
  exit 1
fi

svc_type=$(kubectl get svc app-service -n demo-app -o jsonpath='{.spec.type}')
if test "$svc_type" != "ClusterIP"; then
  echo "Service app-service must be type ClusterIP"
  exit 1
fi

svc_port=$(kubectl get svc app-service -n demo-app -o jsonpath='{.spec.ports[0].port}')
if test "$svc_port" != "8090"; then
  echo "Service app-service must expose port 8090"
  exit 1
fi

selector=$(kubectl get svc app-service -n demo-app -o jsonpath='{.spec.selector.app}')
if test "$selector" != "demo-app"; then
  echo "Service selector must target app=demo-app"
  exit 1
fi

if ! kubectl get ingress app-ingress -n demo-app >/dev/null 2>&1; then
  echo "Ingress app-ingress not found in namespace demo-app"
  exit 1
fi

ingress_host=$(kubectl get ingress app-ingress -n demo-app -o jsonpath='{.spec.rules[0].host}')
if test "$ingress_host" != "demo.example.com"; then
  echo "Ingress host must be demo.example.com"
  exit 1
fi

ingress_path=$(kubectl get ingress app-ingress -n demo-app -o jsonpath='{.spec.rules[0].http.paths[0].path}')
if test "$ingress_path" != "/api"; then
  echo "Ingress path must be /api"
  exit 1
fi

backend_service=$(kubectl get ingress app-ingress -n demo-app -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
if test "$backend_service" != "app-service"; then
  echo "Ingress backend service must be app-service"
  exit 1
fi

backend_port=$(kubectl get ingress app-ingress -n demo-app -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')
if test "$backend_port" != "8090"; then
  echo "Ingress backend port must be 8090"
  exit 1
fi

echo "PASS"
exit 0
