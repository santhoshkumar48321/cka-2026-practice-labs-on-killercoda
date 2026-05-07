#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get node worker-node01 >/dev/null 2>&1; then
  fail "Node worker-node01 not found"
fi

taints="$(kubectl get node worker-node01 -o jsonpath='{range .spec.taints[*]}{.key}{"="}{.value}{":"}{.effect}{"
"}{end}')"
if ! echo "$taints" | grep -q '^Env=Production:NoSchedule$'; then
  fail "Node worker-node01 must be tainted with Env=Production:NoSchedule"
fi

if ! kubectl get pod prod-pod >/dev/null 2>&1; then
  fail "Pod prod-pod not found"
fi

if ! test "$(kubectl get pod prod-pod -o jsonpath='{.spec.nodeName}')" = "worker-node01"; then
  fail "Pod prod-pod must be scheduled on worker-node01"
fi

tolerations="$(kubectl get pod prod-pod -o jsonpath='{range .spec.tolerations[*]}{.key}{"="}{.value}{":"}{.effect}{"
"}{end}')"
if ! echo "$tolerations" | grep -q '^Env=Production:NoSchedule$'; then
  fail "Pod prod-pod must include toleration Env=Production:NoSchedule"
fi

echo "PASS"
exit 0
