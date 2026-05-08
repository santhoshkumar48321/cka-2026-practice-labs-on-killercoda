#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get node worker-node01 >/dev/null 2>&1; then
  echo "Node worker-node01 not found"
  exit 1
fi

taints=$(kubectl get node worker-node01 -o jsonpath='{range .spec.taints[*]}{.key}{"="}{.value}{":"}{.effect}{"\n"}{end}')
if ! echo "$taints" | grep -q '^Env=Production:NoSchedule$'; then
  echo "Node worker-node01 must be tainted Env=Production:NoSchedule"
  exit 1
fi

if ! kubectl get pod prod-pod >/dev/null 2>&1; then
  echo "Pod prod-pod not found"
  exit 1
fi

pod_node=$(kubectl get pod prod-pod -o jsonpath='{.spec.nodeName}')
if test "$pod_node" != "worker-node01"; then
  echo "Pod prod-pod must be scheduled on worker-node01"
  exit 1
fi

tolerations=$(kubectl get pod prod-pod -o jsonpath='{range .spec.tolerations[*]}{.key}{"="}{.value}{":"}{.effect}{"\n"}{end}')
if ! echo "$tolerations" | grep -q '^Env=Production:NoSchedule$'; then
  echo "Pod prod-pod must tolerate Env=Production:NoSchedule"
  exit 1
fi

echo "PASS"
exit 0
