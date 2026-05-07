#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get pods -A | awk '$1=="calico-system" || $1=="tigera-operator" {if($4=="Running" || $4=="Completed") ok=1} END{exit ok?0:1}'; then
  fail "Calico/Tigera pods are not running"
fi

if ! kubectl get nodes | awk 'NR>1 {if($2!="Ready") bad=1; seen=1} END{if(!seen) exit 1; exit bad?1:0}'; then
  fail "All nodes must be Ready after CNI installation"
fi

echo "PASS"
exit 0
