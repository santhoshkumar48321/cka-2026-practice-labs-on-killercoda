#!/usr/bin/env bash
set -euo pipefail

file="/opt/CKA2026/payment-api/errors.log"

if ! test -s "$file"; then
  echo "Missing or empty file: $file"
  exit 1
fi

if grep -qi '^INFO' "$file"; then
  echo "File must not contain INFO lines"
  exit 1
fi

if ! grep -q 'error file-not-found' "$file"; then
  echo "File must contain 'error file-not-found' lines"
  exit 1
fi

echo "PASS"
exit 0
