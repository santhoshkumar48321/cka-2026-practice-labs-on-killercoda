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

if ! command -v docker >/dev/null 2>&1; then
  if ! apt-get update -y; then
    echo "Failed to update apt package index for docker installation" >&2
    exit 1
  fi
  if ! apt-get install -y docker.io; then
    echo "Failed to install docker.io" >&2
    exit 1
  fi
fi

echo "Setup complete"
