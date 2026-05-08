#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get deploy ui-frontend -n portal >/dev/null 2>&1; then
  echo "Deployment ui-frontend not found in namespace portal"
  exit 1
fi

port_name=$(kubectl get deploy ui-frontend -n portal -o jsonpath='{.spec.template.spec.containers[0].ports[0].name}')
if test "$port_name" != "http"; then
  echo "Deployment must define container port named http"
  exit 1
fi

port_number=$(kubectl get deploy ui-frontend -n portal -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')
if test "$port_number" != "80"; then
  echo "Container port must be 80"
  exit 1
fi

port_protocol=$(kubectl get deploy ui-frontend -n portal -o jsonpath='{.spec.template.spec.containers[0].ports[0].protocol}')
if test "$port_protocol" != "TCP"; then
  echo "Container port protocol must be TCP"
  exit 1
fi

if ! kubectl get svc ui-frontend-svc -n portal >/dev/null 2>&1; then
  echo "Service ui-frontend-svc not found in namespace portal"
  exit 1
fi

svc_type=$(kubectl get svc ui-frontend-svc -n portal -o jsonpath='{.spec.type}')
if test "$svc_type" != "NodePort"; then
  echo "Service ui-frontend-svc must be type NodePort"
  exit 1
fi

svc_target=$(kubectl get svc ui-frontend-svc -n portal -o jsonpath='{.spec.ports[0].targetPort}')
if test "$svc_target" != "http"; then
  echo "Service targetPort must reference named port http"
  exit 1
fi

echo "PASS"
exit 0
