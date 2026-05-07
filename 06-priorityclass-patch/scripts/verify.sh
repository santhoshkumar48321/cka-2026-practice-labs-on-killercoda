#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get priorityclass critical-priority >/dev/null 2>&1; then
  echo "PriorityClass 'critical-priority' not found"
  exit 1
fi

if ! kubectl get deployment logger-app -n production >/dev/null 2>&1; then
  echo "Deployment 'logger-app' not found in namespace 'production'"
  exit 1
fi

pcn="$(kubectl get deployment logger-app -n production -o jsonpath='{.spec.template.spec.priorityClassName}')"
if ! test "$pcn" = "critical-priority"; then
  echo "Deployment 'logger-app' must use priorityClassName 'critical-priority', got: $pcn"
  exit 1
fi

echo "PASS"
exit 0
