#!/usr/bin/env bash
set -euo pipefail

# Do NOT wait_kube here — we are intentionally breaking the API server

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

if [ -f "$MANIFEST" ]; then
  # Backup original
  cp "$MANIFEST" "${MANIFEST}.bak"
  # Break etcd endpoint port (2379 → 2380)
  sed -i 's/etcd-servers=https:\/\/127.0.0.1:2379/etcd-servers=https:\/\/127.0.0.1:2380/' "$MANIFEST"
  echo "Setup complete: kube-apiserver etcd port broken (2379→2380). User must fix it."
else
  echo "kube-apiserver manifest not found — skipping break"
fi
