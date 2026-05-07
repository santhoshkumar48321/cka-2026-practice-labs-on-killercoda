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

backup_dir="/etc/cni/net.d.backup.$(date +%s)"
if [ -d /etc/cni/net.d ]; then
  cp -a /etc/cni/net.d "$backup_dir"
fi

rm -rf /etc/cni/net.d/*
systemctl restart kubelet
if ! systemctl is-active --quiet kubelet; then
  echo "kubelet is not active after restart" >&2
  exit 1
fi

echo "Setup complete"
