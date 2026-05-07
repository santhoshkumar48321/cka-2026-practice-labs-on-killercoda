#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get deployment webapp -n default >/dev/null 2>&1; then
  echo "Deployment webapp not found in default namespace"
  exit 1
fi

containers="$(kubectl get deployment webapp -n default -o jsonpath='{range .spec.template.spec.containers[*]}{.name}:{.image}{"\n"}{end}')"
count="$(echo "$containers" | awk 'END{print NR+0}')"
if ! test "$count" -eq 2; then
  echo "Deployment webapp must have exactly 2 containers, found: $count"
  exit 1
fi

if ! echo "$containers" | grep -q '^log-reader:.*busybox:1\.36'; then
  echo "Sidecar container 'log-reader' with image busybox:1.36 not found"
  exit 1
fi

mounts="$(kubectl get deployment webapp -n default -o jsonpath='{range .spec.template.spec.containers[*]}{.name}:{range .volumeMounts[*]}{.mountPath}{" "}{end}{"\n"}{end}')"
missing="$(echo "$mounts" | awk '$0 !~ /\/var\/log/{c++} END{print c+0}')"
if ! test "$missing" -eq 0; then
  echo "Both containers must mount a shared volume at /var/log"
  exit 1
fi

echo "PASS"
exit 0
