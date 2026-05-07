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
  apt-get update -y
  apt-get install -y docker.io
fi

# Download cri-dockerd .deb to home directory
DEB_URL="https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.15/cri-dockerd_0.3.15.3-0.ubuntu-jammy_amd64.deb"
DEB_PATH="/root/cri-dockerd_0.3.15.3-0.ubuntu-jammy_amd64.deb"

if [ ! -f "$DEB_PATH" ]; then
  curl -fsSL "$DEB_URL" -o "$DEB_PATH" || echo "Warning: could not download cri-dockerd .deb" >&2
fi

echo "Setup complete"
