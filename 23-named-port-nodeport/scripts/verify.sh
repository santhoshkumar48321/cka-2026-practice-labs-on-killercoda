#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

ns="portal"

if ! kubectl -n "$ns" get deploy ui-frontend >/dev/null 2>&1; then
  fail "Deployment ui-frontend not found in namespace $ns"
fi
if ! kubectl -n "$ns" get svc ui-frontend-svc >/dev/null 2>&1; then
  fail "Service ui-frontend-svc not found in namespace $ns"
fi

if ! test "$(kubectl -n "$ns" get deploy ui-frontend -o jsonpath='{.spec.template.spec.containers[0].ports[0].name}')" = "http"; then
  fail "Deployment ui-frontend must expose named port http"
fi
if ! test "$(kubectl -n "$ns" get deploy ui-frontend -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')" = "80"; then
  fail "Deployment ui-frontend must expose containerPort 80"
fi
if ! test "$(kubectl -n "$ns" get deploy ui-frontend -o jsonpath='{.spec.template.spec.containers[0].ports[0].protocol}')" = "TCP"; then
  fail "Deployment ui-frontend port protocol must be TCP"
fi

if ! test "$(kubectl -n "$ns" get svc ui-frontend-svc -o jsonpath='{.spec.type}')" = "NodePort"; then
  fail "Service ui-frontend-svc must be type NodePort"
fi

target_port="$(kubectl -n "$ns" get svc ui-frontend-svc -o jsonpath='{.spec.ports[0].targetPort}')"
if ! test "$target_port" = "http"; then
  fail "Service ui-frontend-svc targetPort must be named port http"
fi

echo "PASS"
exit 0
