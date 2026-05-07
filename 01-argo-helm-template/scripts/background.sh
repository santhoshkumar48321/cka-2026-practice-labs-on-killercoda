#!/usr/bin/env bash
set -euo pipefail

wait_kube() {
  for i in $(seq 1 60); do
    if kubectl get ns >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Kubernetes API not ready after 60 seconds" >&2
  exit 1
}

wait_kube

mkdir -p /home/candidate

if ! command -v helm >/dev/null 2>&1; then
  installer="/tmp/get-helm-3.sh"
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o "$installer"
  if ! bash "$installer"; then
    echo "Failed to install helm" >&2
    exit 1
  fi
  rm -f "$installer"
fi

echo "Setup complete"
