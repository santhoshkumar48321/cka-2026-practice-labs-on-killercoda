#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get clusterrole pipeline-deployer >/dev/null 2>&1; then
  echo "ClusterRole pipeline-deployer not found"
  exit 1
fi

role_yaml=$(kubectl get clusterrole pipeline-deployer -o yaml)

if ! echo "$role_yaml" | grep -q "apiGroups:.*apps"; then
  echo "ClusterRole must target apps API group"
  exit 1
fi

if ! echo "$role_yaml" | grep -q "deployments"; then
  echo "ClusterRole must include deployments resource"
  exit 1
fi

if ! echo "$role_yaml" | grep -q "statefulsets"; then
  echo "ClusterRole must include statefulsets resource"
  exit 1
fi

if ! echo "$role_yaml" | grep -q "daemonsets"; then
  echo "ClusterRole must include daemonsets resource"
  exit 1
fi

if ! echo "$role_yaml" | grep -q "create"; then
  echo "ClusterRole must include create verb"
  exit 1
fi

if ! kubectl get serviceaccount cicd-bot -n app-squad >/dev/null 2>&1; then
  echo "ServiceAccount cicd-bot not found in namespace app-squad"
  exit 1
fi

if ! kubectl get rolebinding pipeline-deployer-binding -n app-squad >/dev/null 2>&1; then
  echo "RoleBinding pipeline-deployer-binding not found in namespace app-squad"
  exit 1
fi

role_ref=$(kubectl get rolebinding pipeline-deployer-binding -n app-squad -o jsonpath='{.roleRef.name}')
if test "$role_ref" != "pipeline-deployer"; then
  echo "RoleBinding must reference ClusterRole pipeline-deployer"
  exit 1
fi

subject=$(kubectl get rolebinding pipeline-deployer-binding -n app-squad -o jsonpath='{.subjects[0].name}')
if test "$subject" != "cicd-bot"; then
  echo "RoleBinding must reference ServiceAccount cicd-bot"
  exit 1
fi

echo "PASS"
exit 0
