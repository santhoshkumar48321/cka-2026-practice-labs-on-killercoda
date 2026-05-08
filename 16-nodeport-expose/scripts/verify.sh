#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get deploy service-deployment -n services >/dev/null 2>&1; then
  echo "Deployment service-deployment not found in namespace services"
  exit 1
fi

container_port=$(kubectl get deploy service-deployment -n services -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')
if test "$container_port" != "8080"; then
  echo "Deployment must expose container port 8080"
  exit 1
fi

port_name=$(kubectl get deploy service-deployment -n services -o jsonpath='{.spec.template.spec.containers[0].ports[0].name}')
if test "$port_name" != "http"; then
  echo "Container port must be named http"
  exit 1
fi

if ! kubectl get svc service-nodeport -n services >/dev/null 2>&1; then
  echo "Service service-nodeport not found in namespace services"
  exit 1
fi

svc_type=$(kubectl get svc service-nodeport -n services -o jsonpath='{.spec.type}')
if test "$svc_type" != "NodePort"; then
  echo "Service service-nodeport must be type NodePort"
  exit 1
fi

svc_port=$(kubectl get svc service-nodeport -n services -o jsonpath='{.spec.ports[0].port}')
if test "$svc_port" != "8080"; then
  echo "Service port must be 8080"
  exit 1
fi

svc_proto=$(kubectl get svc service-nodeport -n services -o jsonpath='{.spec.ports[0].protocol}')
if test "$svc_proto" != "TCP"; then
  echo "Service protocol must be TCP"
  exit 1
fi

echo "PASS"
exit 0
