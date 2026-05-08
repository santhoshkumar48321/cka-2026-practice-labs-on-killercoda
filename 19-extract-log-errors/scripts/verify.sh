#!/usr/bin/env bash
set -euo pipefail

if ! test -f /opt/CKA2026/payment-api/errors.log; then
  echo "errors.log not found at /opt/CKA2026/payment-api/errors.log"
  exit 1
fi

if ! test -s /opt/CKA2026/payment-api/errors.log; then
  echo "errors.log is empty"
  exit 1
fi

if ! grep -q "error file-not-found" /opt/CKA2026/payment-api/errors.log; then
  echo "errors.log does not contain error file-not-found entries"
  exit 1
fi

echo "PASS"
exit 0
