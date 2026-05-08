#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get priorityclass critical-priority >/dev/null 2>&1; then
  echo "PriorityClass critical-priority not found"
  exit 1
fi

highest=$(kubectl get priorityclass -o custom-columns=NAME:.metadata.name,VALUE:.value --no-headers | awk '$1 !~ /^system-/ && $1 != "critical-priority" {if ($2 > max) max=$2} END{print max}')
if test -z "$highest"; then
  echo "Unable to determine highest user-defined PriorityClass"
  exit 1
fi

expected=$((highest - 1))
actual=$(kubectl get priorityclass critical-priority -o jsonpath='{.value}')
if test "$actual" != "$expected"; then
  echo "PriorityClass critical-priority must have value ${expected}"
  exit 1
fi

pc_name=$(kubectl get deploy logger-app -n production -o jsonpath='{.spec.template.spec.priorityClassName}')
if test "$pc_name" != "critical-priority"; then
  echo "Deployment logger-app must use priorityClassName critical-priority"
  exit 1
fi

echo "PASS"
exit 0
