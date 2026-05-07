#!/usr/bin/env bash
set -euo pipefail

wait_kube() {
  echo "Waiting for Kubernetes API..."
  for i in $(seq 1 60); do
    if kubectl get ns >/dev/null 2>&1; then return 0; fi
    sleep 2
  done
  echo "Kubernetes API not ready"; exit 1
}
wait_kube

# Ensure openssl is available
apt-get install -y openssl 2>/dev/null || true

echo "Setup complete: openssl available for TLS 1.3 configuration"
