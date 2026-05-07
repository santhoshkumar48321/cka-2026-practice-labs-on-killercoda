#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! kubectl get networkpolicy allow-9000-from-team -n echo >/dev/null 2>&1; then
  fail "NetworkPolicy allow-9000-from-team not found in namespace echo"
fi

app_label="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath='{.spec.podSelector.matchLabels.app}')"
if ! test "$app_label" = "echo-server"; then
  fail "NetworkPolicy must target pods with label app=echo-server"
fi

ports="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath='{range .spec.ingress[*].ports[*]}{.port}{"
"}{end}')"
if ! echo "$ports" | awk '$1==9000{ok=1} END{exit ok?0:1}'; then
  fail "NetworkPolicy must include ingress port 9000"
fi
if ! echo "$ports" | awk '$1!="" && $1!=9000{bad=1} END{exit bad?1:0}'; then
  fail "NetworkPolicy must only allow ingress on port 9000"
fi

policy_types="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath='{range .spec.policyTypes[*]}{.}{"
"}{end}')"
if ! echo "$policy_types" | awk '$1=="Ingress"{ok=1} END{exit ok?0:1}'; then
  fail "NetworkPolicy must restrict ingress traffic"
fi

name_labels="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath='{range .spec.ingress[*].from[*]}{.namespaceSelector.matchLabels.name}{"
"}{end}')"
meta_labels="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath="{range .spec.ingress[*].from[*]}{.namespaceSelector.matchLabels['kubernetes.io/metadata.name']}{'
'}{end}")"
combined_labels="$name_labels
$meta_labels"

if ! echo "$combined_labels" | awk '$1=="team-app"{ok=1} END{exit ok?0:1}'; then
  fail "NetworkPolicy must allow namespace team-app"
fi
if ! echo "$combined_labels" | awk '$1!="" && $1!="team-app"{bad=1} END{exit bad?1:0}'; then
  fail "NetworkPolicy allows namespaces other than team-app"
fi

echo "PASS"
exit 0
