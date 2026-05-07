#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get clusterrole pipeline-deployer >/dev/null 2>&1; then
  echo "ClusterRole 'pipeline-deployer' not found"
  exit 1
fi

cr_yaml="$(kubectl get clusterrole pipeline-deployer -o yaml)"
if ! echo "$cr_yaml" | grep -q 'deployments'; then
  echo "ClusterRole must include 'deployments' resource"
  exit 1
fi
if ! echo "$cr_yaml" | grep -q 'create'; then
  echo "ClusterRole must include 'create' verb"
  exit 1
fi

if ! kubectl get rolebinding pipeline-deployer-binding -n app-squad >/dev/null 2>&1; then
  echo "RoleBinding 'pipeline-deployer-binding' not found in namespace 'app-squad'"
  exit 1
fi

rb_yaml="$(kubectl get rolebinding pipeline-deployer-binding -n app-squad -o yaml)"
if ! echo "$rb_yaml" | grep -q 'pipeline-deployer'; then
  echo "RoleBinding must reference ClusterRole 'pipeline-deployer'"
  exit 1
fi
if ! echo "$rb_yaml" | grep -q 'cicd-bot'; then
  echo "RoleBinding must bind to ServiceAccount 'cicd-bot'"
  exit 1
fi

echo "PASS"
exit 0
