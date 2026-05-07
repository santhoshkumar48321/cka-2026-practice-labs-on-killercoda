#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get pod payment-api >/dev/null 2>&1; then
  fail "Pod payment-api not found"
fi

log_file="/opt/CKA2026/payment-api/errors.log"

if ! test -f "$log_file"; then
  fail "Expected file not found: $log_file"
fi
if ! test -s "$log_file"; then
  fail "Log file is empty: $log_file"
fi

if ! awk '/error file-not-found/{ok=1} END{exit ok?0:1}' "$log_file"; then
  fail "Log file must contain lines with: error file-not-found"
fi
if ! awk '/error file-not-found/{next} {bad=1} END{exit bad?1:0}' "$log_file"; then
  fail "Log file must contain only lines matching: error file-not-found"
fi

echo "PASS"
exit 0
