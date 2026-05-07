#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get deployment webapp-deployment -n default >/dev/null 2>&1; then
  echo "Deployment 'webapp-deployment' not found"
  exit 1
fi

# Check replicas = 3
replicas="$(kubectl get deployment webapp-deployment -n default -o jsonpath='{.spec.replicas}')"
if ! test "$replicas" -eq 3; then
  echo "Deployment must have 3 replicas, found: $replicas"
  exit 1
fi

# Check main container has resource requests
cpu_req="$(kubectl get deployment webapp-deployment -n default -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')"
mem_req="$(kubectl get deployment webapp-deployment -n default -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')"
if ! test -n "$cpu_req"; then
  echo "Main container is missing CPU requests"
  exit 1
fi
if ! test -n "$mem_req"; then
  echo "Main container is missing memory requests"
  exit 1
fi

# Check initContainer has same resource requests as main container
init_cpu="$(kubectl get deployment webapp-deployment -n default -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}')"
if ! test "$init_cpu" = "$cpu_req"; then
  echo "initContainer CPU requests ($init_cpu) must match main container ($cpu_req)"
  exit 1
fi

echo "PASS"
exit 0
