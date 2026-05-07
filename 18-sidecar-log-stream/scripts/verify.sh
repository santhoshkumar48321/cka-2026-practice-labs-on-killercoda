#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get pod atlas-app >/dev/null 2>&1; then
  fail "Pod atlas-app not found"
fi

if ! kubectl get pod atlas-app -o jsonpath='{.spec.containers[*].name}' | awk '{found=0; for(i=1;i<=NF;i++){if($i=="log-sidecar")found=1} exit found?0:1}'; then
  fail "Pod atlas-app must include sidecar container log-sidecar"
fi

if ! test "$(kubectl get pod atlas-app -o jsonpath='{.spec.containers[?(@.name=="log-sidecar")].image}')" = "busybox:1.36"; then
  fail "Container log-sidecar must use image busybox:1.36"
fi

if ! kubectl get pod atlas-app -o jsonpath='{range .spec.containers[?(@.name=="log-sidecar")].args[*]}{.}{"
"}{end}' | grep -q 'tail -n+1 -F /var/log/atlas-app.log'; then
  fail "Container log-sidecar must run tail -n+1 -F /var/log/atlas-app.log"
fi

mounts="$(kubectl get pod atlas-app -o jsonpath='{range .spec.containers[*]}{.name}{"|"}{range .volumeMounts[*]}{.mountPath}{","}{end}{"
"}{end}')"
if ! echo "$mounts" | awk -F'|' '$1=="log-sidecar" && $2 ~ /\/var\/log/{ok=1} END{exit ok?0:1}'; then
  fail "Container log-sidecar must mount /var/log"
fi
if ! echo "$mounts" | awk -F'|' '$1!="log-sidecar" && $2 ~ /\/var\/log/{ok=1} END{exit ok?0:1}'; then
  fail "Main container must mount /var/log"
fi

volumes="$(kubectl get pod atlas-app -o jsonpath='{range .spec.volumes[*]}{.name}{"|"}{.emptyDir}{"
"}{end}')"
if ! echo "$volumes" | awk -F'|' '$2!=""{ok=1} END{exit ok?0:1}'; then
  fail "Pod atlas-app must include a shared emptyDir volume"
fi

echo "PASS"
exit 0
