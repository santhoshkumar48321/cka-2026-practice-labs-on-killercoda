#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get deploy webapp-deployment >/dev/null 2>&1; then
  echo "Deployment webapp-deployment not found"
  exit 1
fi

replicas=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.replicas}')
if test "$replicas" != "3"; then
  echo "Deployment webapp-deployment must be scaled to 3 replicas"
  exit 1
fi

main_req_cpu=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
init_req_cpu=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}')
if test -z "$main_req_cpu" || test -z "$init_req_cpu"; then
  echo "CPU requests must be set for both init and main containers"
  exit 1
fi
if test "$main_req_cpu" != "$init_req_cpu"; then
  echo "CPU request values must match between init and main containers"
  exit 1
fi

main_req_mem=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
init_req_mem=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.memory}')
if test -z "$main_req_mem" || test -z "$init_req_mem"; then
  echo "Memory requests must be set for both init and main containers"
  exit 1
fi
if test "$main_req_mem" != "$init_req_mem"; then
  echo "Memory request values must match between init and main containers"
  exit 1
fi

main_lim_cpu=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')
init_lim_cpu=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.initContainers[0].resources.limits.cpu}')
if test -z "$main_lim_cpu" || test -z "$init_lim_cpu"; then
  echo "CPU limits must be set for both init and main containers"
  exit 1
fi
if test "$main_lim_cpu" != "$init_lim_cpu"; then
  echo "CPU limit values must match between init and main containers"
  exit 1
fi

main_lim_mem=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')
init_lim_mem=$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.initContainers[0].resources.limits.memory}')
if test -z "$main_lim_mem" || test -z "$init_lim_mem"; then
  echo "Memory limits must be set for both init and main containers"
  exit 1
fi
if test "$main_lim_mem" != "$init_lim_mem"; then
  echo "Memory limit values must match between init and main containers"
  exit 1
fi

echo "PASS"
exit 0
