#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get priorityclass critical-priority >/dev/null 2>&1; then
  fail "PriorityClass critical-priority not found"
fi

if ! kubectl get deploy logger-app -n production >/dev/null 2>&1; then
  fail "Deployment logger-app not found in namespace production"
fi

if ! test "$(kubectl get deploy logger-app -n production -o jsonpath='{.spec.template.spec.priorityClassName}')" = "critical-priority"; then
  fail "Deployment logger-app must use priorityClassName critical-priority"
fi

echo "PASS"
exit 0
