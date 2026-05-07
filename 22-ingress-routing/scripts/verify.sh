#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

ns="ing-private"

if ! kubectl -n "$ns" get ingress wave >/dev/null 2>&1; then
  fail "Ingress wave not found in namespace $ns"
fi
if ! kubectl -n "$ns" get svc hello >/dev/null 2>&1; then
  fail "Service hello not found in namespace $ns"
fi

if ! test "$(kubectl -n "$ns" get ingress wave -o jsonpath='{.spec.rules[0].http.paths[0].path}')" = "/hello"; then
  fail "Ingress wave must route path /hello"
fi
if ! test "$(kubectl -n "$ns" get ingress wave -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')" = "hello"; then
  fail "Ingress wave backend service must be hello"
fi
if ! test "$(kubectl -n "$ns" get ingress wave -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')" = "5678"; then
  fail "Ingress wave backend service port must be 5678"
fi

echo "PASS"
exit 0
