#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get networkpolicy allow-9000-from-team -n echo >/dev/null 2>&1; then
  echo "NetworkPolicy allow-9000-from-team not found in namespace echo"
  exit 1
fi

policy="$(kubectl get networkpolicy allow-9000-from-team -n echo -o yaml)"

if ! echo "$policy" | grep -q 'app: echo-server'; then
  echo "NetworkPolicy must target pods with label app: echo-server"
  exit 1
fi

if ! echo "$policy" | grep -q 'port: 9000'; then
  echo "NetworkPolicy must allow ingress to TCP port 9000"
  exit 1
fi

if ! echo "$policy" | grep -q -- '- Ingress'; then
  echo "NetworkPolicy must restrict ingress traffic"
  exit 1
fi

if ! echo "$policy" | grep -q 'name: team-app'; then
  if ! echo "$policy" | grep -q 'kubernetes.io/metadata.name: team-app'; then
    echo "NetworkPolicy must allow ingress only from namespace team-app"
    exit 1
  fi
fi

echo "PASS"
exit 0
