#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get nodes >/dev/null 2>&1; then
  echo "kubectl get nodes failed"
  exit 1
fi

not_ready="$(kubectl get nodes --no-headers | awk '$2 !~ /^Ready/{c++} END{print c+0}')"
if ! test "$not_ready" -eq 0; then
  echo "One or more nodes are NotReady"
  exit 1
fi

echo "PASS"
exit 0
