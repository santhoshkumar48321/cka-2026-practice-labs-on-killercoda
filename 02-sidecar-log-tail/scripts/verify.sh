#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get deploy webapp >/dev/null 2>&1; then
  fail "Deployment webapp not found"
fi

if ! kubectl get deploy webapp -o jsonpath='{.spec.template.spec.containers[*].name}' | awk '{found=0; for(i=1;i<=NF;i++){if($i=="log-reader")found=1} exit found?0:1}'; then
  fail "Deployment webapp must include sidecar container log-reader"
fi

if ! test "$(kubectl get deploy webapp -o jsonpath='{.spec.template.spec.containers[?(@.name=="log-reader")].image}')" = "busybox:1.36"; then
  fail "Container log-reader must use image busybox:1.36"
fi

if ! kubectl get deploy webapp -o jsonpath='{range .spec.template.spec.containers[?(@.name=="log-reader")].args[*]}{.}{"
"}{end}' | grep -q 'tail -f /var/log/application.log'; then
  fail "Container log-reader must run tail -f /var/log/application.log"
fi

mounts="$(kubectl get deploy webapp -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"|"}{range .volumeMounts[*]}{.mountPath}{","}{end}{"
"}{end}')"
if ! echo "$mounts" | awk -F'|' '$1=="log-reader" && $2 ~ /\/var\/log/{ok=1} END{exit ok?0:1}'; then
  fail "Container log-reader must mount /var/log"
fi
if ! echo "$mounts" | awk -F'|' '$1!="log-reader" && $2 ~ /\/var\/log/{ok=1} END{exit ok?0:1}'; then
  fail "Primary container must mount /var/log"
fi

echo "PASS"
exit 0
