#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get pod nginx-kusc01801 -n default >/dev/null 2>&1; then
  echo "Pod 'nginx-kusc01801' not found in default namespace"
  exit 1
fi

phase="$(kubectl get pod nginx-kusc01801 -n default -o jsonpath='{.status.phase}')"
if ! test "$phase" = "Running"; then
  echo "Pod 'nginx-kusc01801' is not Running (status: $phase)"
  exit 1
fi

selector="$(kubectl get pod nginx-kusc01801 -n default -o jsonpath='{.spec.nodeSelector.disk}')"
if ! test "$selector" = "ssd"; then
  echo "Pod must have nodeSelector disk=ssd, got: $selector"
  exit 1
fi

echo "PASS"
exit 0
