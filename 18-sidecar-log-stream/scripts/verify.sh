#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get pod atlas-app >/dev/null 2>&1; then
  echo "Pod atlas-app not found"
  exit 1
fi

containers=$(kubectl get pod atlas-app -o jsonpath='{.spec.containers[*].name}')
if ! echo "$containers" | grep -qw log-sidecar; then
  echo "Sidecar log-sidecar not found in pod"
  exit 1
fi

sidecar_image=$(kubectl get pod atlas-app -o jsonpath='{.spec.containers[?(@.name=="log-sidecar")].image}')
if test "$sidecar_image" != "busybox:1.36"; then
  echo "Sidecar image must be busybox:1.36"
  exit 1
fi

sidecar_command=$(kubectl get pod atlas-app -o jsonpath='{.spec.containers[?(@.name=="log-sidecar")].command}')
if ! echo "$sidecar_command" | grep -q "tail -n+1 -F /var/log/atlas-app.log"; then
  echo "Sidecar command must tail /var/log/atlas-app.log"
  exit 1
fi

sidecar_volume=$(kubectl get pod atlas-app -o jsonpath='{.spec.containers[?(@.name=="log-sidecar")].volumeMounts[?(@.mountPath=="/var/log")].name}')
if test -z "$sidecar_volume"; then
  echo "Sidecar is missing the /var/log volume mount"
  exit 1
fi

main_volume=$(kubectl get pod atlas-app -o jsonpath='{.spec.containers[?(@.name=="atlas-main")].volumeMounts[?(@.mountPath=="/var/log")].name}')
if test -z "$main_volume"; then
  echo "Main container is missing the /var/log volume mount"
  exit 1
fi

if test "$sidecar_volume" != "$main_volume"; then
  echo "Sidecar and main container must share the same volume"
  exit 1
fi

volumes=$(kubectl get pod atlas-app -o jsonpath='{.spec.volumes[*].name}')
if ! echo "$volumes" | grep -qw "$sidecar_volume"; then
  echo "Shared volume is not defined in the pod spec"
  exit 1
fi

echo "PASS"
exit 0
