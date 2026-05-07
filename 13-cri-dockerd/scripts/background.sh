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

pkg="$HOME/cri-dockerd_0.3.15.3-0.ubuntu-jammy_amd64.deb"
if ! test -f "$pkg"; then
  curl -fsSL -o "$pkg" "https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.15/cri-dockerd_0.3.15.3-0.ubuntu-jammy_amd64.deb" || true
fi

echo "Setup complete"
