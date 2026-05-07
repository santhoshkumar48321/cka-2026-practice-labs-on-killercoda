#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get pod nginx-kusc01801 >/dev/null 2>&1; then
  fail "Pod nginx-kusc01801 not found"
fi

if ! test "$(kubectl get pod nginx-kusc01801 -o jsonpath='{.spec.containers[0].image}')" = "nginx:1.27"; then
  fail "Pod nginx-kusc01801 must use image nginx:1.27"
fi

if ! test "$(kubectl get pod nginx-kusc01801 -o jsonpath='{.spec.nodeSelector.disk}')" = "ssd"; then
  fail "Pod nginx-kusc01801 must set nodeSelector disk=ssd"
fi

echo "PASS"
exit 0
