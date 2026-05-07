#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

policy_name="$(kubectl -n backend get networkpolicy -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if ! test -n "$policy_name"; then
  fail "No NetworkPolicy found in namespace backend"
fi

selector_app="$(kubectl -n backend get networkpolicy "$policy_name" -o jsonpath='{.spec.podSelector.matchLabels.app}')"
if ! test "$selector_app" = "backend-api"; then
  fail "NetworkPolicy $policy_name must target app=backend-api"
fi

from_names="$(kubectl -n backend get networkpolicy "$policy_name" -o jsonpath='{range .spec.ingress[*].from[*]}{.namespaceSelector.matchLabels.name}{"
"}{end}')"
from_meta="$(kubectl -n backend get networkpolicy "$policy_name" -o jsonpath="{range .spec.ingress[*].from[*]}{.namespaceSelector.matchLabels['kubernetes.io/metadata.name']}{'
'}{end}")"
combined="$from_names
$from_meta"

if ! echo "$combined" | awk '$1=="frontend"{ok=1} END{exit ok?0:1}'; then
  fail "NetworkPolicy $policy_name must allow namespace frontend"
fi
if ! echo "$combined" | awk '$1!="" && $1!="frontend"{bad=1} END{exit bad?1:0}'; then
  fail "NetworkPolicy $policy_name allows namespaces other than frontend"
fi

ports="$(kubectl -n backend get networkpolicy "$policy_name" -o jsonpath='{range .spec.ingress[*].ports[*]}{.port}{"
"}{end}')"
if ! echo "$ports" | awk '$1!=""{ok=1} END{exit ok?0:1}'; then
  fail "NetworkPolicy $policy_name must define ingress port restrictions"
fi
if ! echo "$ports" | awk '$1==80{ok=1} END{exit ok?0:1}'; then
  fail "NetworkPolicy $policy_name must allow backend port 80"
fi

echo "PASS"
exit 0
