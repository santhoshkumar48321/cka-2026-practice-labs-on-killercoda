#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get service service-nodeport -n services >/dev/null 2>&1; then
  echo "Service 'service-nodeport' not found in namespace 'services'"
  exit 1
fi

svc_type="$(kubectl get service service-nodeport -n services -o jsonpath='{.spec.type}')"
if ! test "$svc_type" = "NodePort"; then
  echo "Service 'service-nodeport' must be type NodePort, got: $svc_type"
  exit 1
fi

# Check port 8080 exposed
port="$(kubectl get service service-nodeport -n services -o jsonpath='{.spec.ports[0].port}')"
if ! test "$port" = "8080"; then
  echo "Service must expose port 8080, got: $port"
  exit 1
fi

# Check deployment has containerPort 8080 named http
cport="$(kubectl get deployment service-deployment -n services -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')"
cname="$(kubectl get deployment service-deployment -n services -o jsonpath='{.spec.template.spec.containers[0].ports[0].name}')"
if ! test "$cport" = "8080"; then
  echo "Container port must be 8080, got: $cport"
  exit 1
fi
if ! test "$cname" = "http"; then
  echo "Container port must be named 'http', got: $cname"
  exit 1
fi

echo "PASS"
exit 0
