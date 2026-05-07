#!/usr/bin/env bash
set -euo pipefail

if ! test -x /usr/local/bin/cri-dockerd; then
  echo "cri-dockerd binary not found at /usr/local/bin/cri-dockerd"
  exit 1
fi

if ! test -S /run/cri-dockerd.sock && ! test -S /var/run/cri-dockerd.sock; then
  echo "cri-dockerd does not appear active (socket not found)"
  exit 1
fi

echo "PASS"
exit 0
