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

# Remove existing CNI to simulate broken cluster
rm -f /etc/cni/net.d/*
systemctl restart kubelet || true

echo "Setup complete: CNI removed, cluster nodes will show NotReady"
