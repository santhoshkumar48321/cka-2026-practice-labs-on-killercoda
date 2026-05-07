#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get hpa nginx-scaler -n scaling >/dev/null 2>&1; then
  echo "HPA 'nginx-scaler' not found in namespace 'scaling'"
  exit 1
fi

target="$(kubectl get hpa nginx-scaler -n scaling -o jsonpath='{.spec.scaleTargetRef.name}')"
if ! test "$target" = "nginx-deployment"; then
  echo "HPA must target 'nginx-deployment', got: $target"
  exit 1
fi

stabilization="$(kubectl get hpa nginx-scaler -n scaling -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}')"
if ! test -n "$stabilization"; then
  echo "HPA must have scaleDown stabilizationWindowSeconds set"
  exit 1
fi

echo "PASS"
exit 0
