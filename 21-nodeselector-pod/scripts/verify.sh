#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get pod nginx-kusc01801 >/dev/null 2>&1; then
  echo "Pod nginx-kusc01801 not found"
  exit 1
fi

selector_value=$(kubectl get pod nginx-kusc01801 -o jsonpath='{.spec.nodeSelector.disk}')
if test "$selector_value" != "ssd"; then
  echo "Pod nginx-kusc01801 must use nodeSelector disk=ssd"
  exit 1
fi

pod_node=$(kubectl get pod nginx-kusc01801 -o jsonpath='{.spec.nodeName}')
if test -z "$pod_node"; then
  echo "Pod nginx-kusc01801 is not scheduled on any node"
  exit 1
fi

node_label=$(kubectl get node "$pod_node" -o jsonpath='{.metadata.labels.disk}')
if test "$node_label" != "ssd"; then
  echo "Pod nginx-kusc01801 must run on a node labeled disk=ssd"
  exit 1
fi

echo "PASS"
exit 0
