#!/usr/bin/env bash
set -euo pipefail

# Check taint exists
tainted_node="$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.taints[*]}{.key}={.value}:{.effect}{","}{end}{"\n"}{end}' | awk -F'\t' '$2 ~ /Env=Production:NoSchedule/{print $1; exit}')"
if ! test -n "$tainted_node"; then
  echo "No node found with taint Env=Production:NoSchedule"
  exit 1
fi

# Check prod-pod exists and is running
if ! kubectl get pod prod-pod -n default >/dev/null 2>&1; then
  echo "Pod 'prod-pod' not found in default namespace"
  exit 1
fi

pod_status="$(kubectl get pod prod-pod -n default -o jsonpath='{.status.phase}')"
if ! test "$pod_status" = "Running"; then
  echo "Pod 'prod-pod' is not Running (status: $pod_status)"
  exit 1
fi

# Check toleration
pod_yaml="$(kubectl get pod prod-pod -n default -o yaml)"
if ! echo "$pod_yaml" | grep -q 'key: Env'; then
  echo "Pod 'prod-pod' missing toleration key 'Env'"
  exit 1
fi
if ! echo "$pod_yaml" | grep -q 'value: Production'; then
  echo "Pod 'prod-pod' missing toleration value 'Production'"
  exit 1
fi
if ! echo "$pod_yaml" | grep -q 'effect: NoSchedule'; then
  echo "Pod 'prod-pod' missing toleration effect 'NoSchedule'"
  exit 1
fi

echo "PASS"
exit 0
