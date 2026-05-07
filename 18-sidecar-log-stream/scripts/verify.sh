#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get pod atlas-app -n default >/dev/null 2>&1; then
  echo "Pod 'atlas-app' not found in default namespace"
  exit 1
fi

containers="$(kubectl get pod atlas-app -n default -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}')"
count="$(echo "$containers" | awk 'END{print NR+0}')"
if ! test "$count" -eq 2; then
  echo "Pod 'atlas-app' must have exactly 2 containers, found: $count"
  exit 1
fi

if ! echo "$containers" | grep -q 'log-sidecar'; then
  echo "Pod 'atlas-app' must have sidecar container named 'log-sidecar'"
  exit 1
fi

sidecar_cmd="$(kubectl get pod atlas-app -n default -o jsonpath='{range .spec.containers[?(@.name=="log-sidecar")]}{.command}{.args}{end}')"
if ! echo "$sidecar_cmd" | grep -q 'tail'; then
  echo "Sidecar container 'log-sidecar' must run a tail command"
  exit 1
fi
if ! echo "$sidecar_cmd" | grep -q 'atlas-app.log'; then
  echo "Sidecar must tail '/var/log/atlas-app.log'"
  exit 1
fi

echo "PASS"
exit 0
