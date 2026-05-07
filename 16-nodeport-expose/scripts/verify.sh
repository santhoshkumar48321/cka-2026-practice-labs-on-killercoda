#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

ns="services"

if ! kubectl -n "$ns" get deploy service-deployment >/dev/null 2>&1; then
  fail "Deployment service-deployment not found in namespace $ns"
fi
if ! kubectl -n "$ns" get svc service-nodeport >/dev/null 2>&1; then
  fail "Service service-nodeport not found in namespace $ns"
fi

if ! test "$(kubectl -n "$ns" get deploy service-deployment -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')" = "8080"; then
  fail "Deployment service-deployment must expose container port 8080"
fi
if ! test "$(kubectl -n "$ns" get deploy service-deployment -o jsonpath='{.spec.template.spec.containers[0].ports[0].name}')" = "http"; then
  fail "Deployment service-deployment container port name must be http"
fi
if ! test "$(kubectl -n "$ns" get deploy service-deployment -o jsonpath='{.spec.template.spec.containers[0].ports[0].protocol}')" = "TCP"; then
  fail "Deployment service-deployment container port protocol must be TCP"
fi

if ! test "$(kubectl -n "$ns" get svc service-nodeport -o jsonpath='{.spec.type}')" = "NodePort"; then
  fail "Service service-nodeport must be type NodePort"
fi
if ! test "$(kubectl -n "$ns" get svc service-nodeport -o jsonpath='{.spec.ports[0].port}')" = "8080"; then
  fail "Service service-nodeport must expose port 8080"
fi
if ! test "$(kubectl -n "$ns" get svc service-nodeport -o jsonpath='{.spec.ports[0].protocol}')" = "TCP"; then
  fail "Service service-nodeport protocol must be TCP"
fi

target_port="$(kubectl -n "$ns" get svc service-nodeport -o jsonpath='{.spec.ports[0].targetPort}')"
if ! echo "$target_port" | awk '$1=="http" || $1==8080 {ok=1} END{exit ok?0:1}'; then
  fail "Service service-nodeport targetPort must be http (or numeric 8080)"
fi

echo "PASS"
exit 0
