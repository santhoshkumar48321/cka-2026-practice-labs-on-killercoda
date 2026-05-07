#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get deploy webapp-deployment >/dev/null 2>&1; then
  fail "Deployment webapp-deployment not found"
fi

if ! test "$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.replicas}')" = "3"; then
  fail "Deployment webapp-deployment must be scaled to 3 replicas"
fi

main_req="$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}:{.spec.template.spec.containers[0].resources.requests.memory}')"
main_lim="$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}:{.spec.template.spec.containers[0].resources.limits.memory}')"
init_req="$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}:{.spec.template.spec.initContainers[0].resources.requests.memory}')"
init_lim="$(kubectl get deploy webapp-deployment -o jsonpath='{.spec.template.spec.initContainers[0].resources.limits.cpu}:{.spec.template.spec.initContainers[0].resources.limits.memory}')"

if ! echo "$main_req" | awk -F: '$1!="" && $2!="" {ok=1} END{exit ok?0:1}'; then
  fail "Main container must have CPU and memory requests"
fi
if ! echo "$main_lim" | awk -F: '$1!="" && $2!="" {ok=1} END{exit ok?0:1}'; then
  fail "Main container must have CPU and memory limits"
fi
if ! echo "$init_req" | awk -F: '$1!="" && $2!="" {ok=1} END{exit ok?0:1}'; then
  fail "Init container must have CPU and memory requests"
fi
if ! echo "$init_lim" | awk -F: '$1!="" && $2!="" {ok=1} END{exit ok?0:1}'; then
  fail "Init container must have CPU and memory limits"
fi

if ! test "$main_req" = "$init_req"; then
  fail "Init and main container requests must match"
fi
if ! test "$main_lim" = "$init_lim"; then
  fail "Init and main container limits must match"
fi

echo "PASS"
exit 0
