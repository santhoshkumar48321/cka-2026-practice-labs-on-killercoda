#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

ns="scaling"

if ! kubectl -n "$ns" get hpa nginx-scaler >/dev/null 2>&1; then
  fail "HPA nginx-scaler not found in namespace $ns"
fi

if ! test "$(kubectl -n "$ns" get hpa nginx-scaler -o jsonpath='{.spec.scaleTargetRef.kind}')" = "Deployment"; then
  fail "HPA target kind must be Deployment"
fi
if ! test "$(kubectl -n "$ns" get hpa nginx-scaler -o jsonpath='{.spec.scaleTargetRef.name}')" = "nginx-deployment"; then
  fail "HPA must target deployment nginx-deployment"
fi
if ! test "$(kubectl -n "$ns" get hpa nginx-scaler -o jsonpath='{.spec.minReplicas}')" = "2"; then
  fail "HPA minReplicas must be 2"
fi
if ! test "$(kubectl -n "$ns" get hpa nginx-scaler -o jsonpath='{.spec.maxReplicas}')" = "6"; then
  fail "HPA maxReplicas must be 6"
fi
if ! test "$(kubectl -n "$ns" get hpa nginx-scaler -o jsonpath='{.spec.metrics[0].resource.name}')" = "cpu"; then
  fail "HPA metric must target cpu"
fi
if ! test "$(kubectl -n "$ns" get hpa nginx-scaler -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')" = "60"; then
  fail "HPA CPU averageUtilization must be 60"
fi
if ! test "$(kubectl -n "$ns" get hpa nginx-scaler -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}')" = "45"; then
  fail "HPA scaleDown stabilizationWindowSeconds must be 45"
fi

echo "PASS"
exit 0
