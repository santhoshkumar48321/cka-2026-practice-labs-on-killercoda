#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get hpa nginx-scaler -n scaling >/dev/null 2>&1; then
  echo "HPA nginx-scaler not found in namespace scaling"
  exit 1
fi

min_replicas=$(kubectl get hpa nginx-scaler -n scaling -o jsonpath='{.spec.minReplicas}')
if test "$min_replicas" != "2"; then
  echo "HPA minReplicas must be 2"
  exit 1
fi

max_replicas=$(kubectl get hpa nginx-scaler -n scaling -o jsonpath='{.spec.maxReplicas}')
if test "$max_replicas" != "6"; then
  echo "HPA maxReplicas must be 6"
  exit 1
fi

cpu_target=$(kubectl get hpa nginx-scaler -n scaling -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')
if test "$cpu_target" != "60"; then
  echo "HPA CPU target must be 60%"
  exit 1
fi

scale_down_window=$(kubectl get hpa nginx-scaler -n scaling -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}')
if test "$scale_down_window" != "45"; then
  echo "HPA scaleDown stabilization window must be 45 seconds"
  exit 1
fi

echo "PASS"
exit 0
