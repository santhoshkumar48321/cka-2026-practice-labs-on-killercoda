#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get clusterrole pipeline-deployer >/dev/null 2>&1; then
  fail "ClusterRole pipeline-deployer not found"
fi
if ! kubectl -n app-squad get sa cicd-bot >/dev/null 2>&1; then
  fail "ServiceAccount cicd-bot not found in namespace app-squad"
fi
if ! kubectl -n app-squad get rolebinding pipeline-deployer-binding >/dev/null 2>&1; then
  fail "RoleBinding pipeline-deployer-binding not found in namespace app-squad"
fi

role_data="$(kubectl get clusterrole pipeline-deployer -o jsonpath='{range .rules[*]}{.apiGroups[0]}{"|"}{.verbs[0]}{"|"}{.resources[*]}{"
"}{end}')"
if ! echo "$role_data" | awk -F'|' '$1=="apps" && $2=="create" {ok=1} END{exit ok?0:1}'; then
  fail "ClusterRole pipeline-deployer must grant create on apps resources"
fi
if ! echo "$role_data" | grep -q 'deployments'; then
  fail "ClusterRole pipeline-deployer must include deployments resource"
fi
if ! echo "$role_data" | grep -q 'statefulsets'; then
  fail "ClusterRole pipeline-deployer must include statefulsets resource"
fi
if ! echo "$role_data" | grep -q 'daemonsets'; then
  fail "ClusterRole pipeline-deployer must include daemonsets resource"
fi

if ! test "$(kubectl -n app-squad get rolebinding pipeline-deployer-binding -o jsonpath='{.roleRef.kind}')" = "ClusterRole"; then
  fail "RoleBinding roleRef kind must be ClusterRole"
fi
if ! test "$(kubectl -n app-squad get rolebinding pipeline-deployer-binding -o jsonpath='{.roleRef.name}')" = "pipeline-deployer"; then
  fail "RoleBinding must reference ClusterRole pipeline-deployer"
fi
if ! test "$(kubectl -n app-squad get rolebinding pipeline-deployer-binding -o jsonpath='{.subjects[0].kind}')" = "ServiceAccount"; then
  fail "RoleBinding subject must be a ServiceAccount"
fi
if ! test "$(kubectl -n app-squad get rolebinding pipeline-deployer-binding -o jsonpath='{.subjects[0].name}')" = "cicd-bot"; then
  fail "RoleBinding subject name must be cicd-bot"
fi
if ! test "$(kubectl -n app-squad get rolebinding pipeline-deployer-binding -o jsonpath='{.subjects[0].namespace}')" = "app-squad"; then
  fail "RoleBinding subject namespace must be app-squad"
fi

if ! test "$(kubectl auth can-i create deployments --as=system:serviceaccount:app-squad:cicd-bot -n app-squad)" = "yes"; then
  fail "ServiceAccount cicd-bot must be able to create deployments in app-squad"
fi
if ! test "$(kubectl auth can-i create deployments --as=system:serviceaccount:app-squad:cicd-bot -n default)" = "no"; then
  fail "ServiceAccount cicd-bot must not be able to create deployments in default"
fi

echo "PASS"
exit 0
