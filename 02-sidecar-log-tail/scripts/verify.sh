#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get deploy webapp >/dev/null 2>&1; then
  echo "Deployment webapp not found"
  exit 1
fi

containers=$(kubectl get deploy webapp -o jsonpath='{.spec.template.spec.containers[*].name}')
if ! echo "$containers" | grep -qw log-reader; then
  echo "Sidecar log-reader not found in deployment"
  exit 1
fi

sidecar_image=$(kubectl get deploy webapp -o jsonpath='{.spec.template.spec.containers[?(@.name=="log-reader")].image}')
if test "$sidecar_image" != "busybox:1.36"; then
  echo "Sidecar image must be busybox:1.36"
  exit 1
fi

sidecar_command=$(kubectl get deploy webapp -o jsonpath='{.spec.template.spec.containers[?(@.name=="log-reader")].command}')
if ! echo "$sidecar_command" | grep -q "tail -f /var/log/application.log"; then
  echo "Sidecar command must tail /var/log/application.log"
  exit 1
fi

sidecar_volume=$(kubectl get deploy webapp -o jsonpath='{.spec.template.spec.containers[?(@.name=="log-reader")].volumeMounts[?(@.mountPath=="/var/log")].name}')
if test -z "$sidecar_volume"; then
  echo "Sidecar is missing the /var/log volume mount"
  exit 1
fi

app_volume=$(kubectl get deploy webapp -o jsonpath='{.spec.template.spec.containers[?(@.name=="webapp")].volumeMounts[?(@.mountPath=="/var/log")].name}')
if test -z "$app_volume"; then
  echo "Main container is missing the /var/log volume mount"
  exit 1
fi

if test "$app_volume" != "$sidecar_volume"; then
  echo "Main and sidecar containers must share the same volume"
  exit 1
fi

volumes=$(kubectl get deploy webapp -o jsonpath='{.spec.template.spec.volumes[*].name}')
if ! echo "$volumes" | grep -qw "$sidecar_volume"; then
  echo "Shared volume is not defined in the pod spec"
  exit 1
fi

echo "PASS"
exit 0
