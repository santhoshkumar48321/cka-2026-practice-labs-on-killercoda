#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get service ui-frontend-svc -n portal >/dev/null 2>&1; then
  echo "Service 'ui-frontend-svc' not found in namespace 'portal'"
  exit 1
fi

svc_type="$(kubectl get service ui-frontend-svc -n portal -o jsonpath='{.spec.type}')"
if ! test "$svc_type" = "NodePort"; then
  echo "Service 'ui-frontend-svc' must be type NodePort, got: $svc_type"
  exit 1
fi

target_port="$(kubectl get service ui-frontend-svc -n portal -o jsonpath='{.spec.ports[0].targetPort}')"
if ! test "$target_port" = "http"; then
  echo "Service targetPort must be named 'http', got: $target_port"
  exit 1
fi

cport_name="$(kubectl get deployment ui-frontend -n portal -o jsonpath='{.spec.template.spec.containers[0].ports[0].name}')"
if ! test "$cport_name" = "http"; then
  echo "Deployment container port must be named 'http', got: $cport_name"
  exit 1
fi

echo "PASS"
exit 0
