#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get networkpolicy allow-9000-from-team -n echo >/dev/null 2>&1; then
  echo "NetworkPolicy allow-9000-from-team not found in namespace echo"
  exit 1
fi

app_label="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath='{.spec.podSelector.matchLabels.app}')"
if ! test "$app_label" = "echo-server"; then
  echo "NetworkPolicy must target pods with label app: echo-server"
  exit 1
fi

ports="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath='{range .spec.ingress[*].ports[*]}{.port}{"\n"}{end}')"
if ! echo "$ports" | awk '$1==9000{ok=1} END{exit ok?0:1}'; then
  echo "NetworkPolicy must include port 9000 in ingress rules"
  exit 1
fi
if ! echo "$ports" | awk '$1!="" && $1!=9000{bad=1} END{exit bad?1:0}'; then
  echo "NetworkPolicy must allow ingress only on port 9000"
  exit 1
fi

policy_types="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath='{range .spec.policyTypes[*]}{.}{"\n"}{end}')"
if ! echo "$policy_types" | awk '$1=="Ingress"{ok=1} END{exit ok?0:1}'; then
  echo "NetworkPolicy must restrict ingress traffic"
  exit 1
fi

name_labels="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath='{range .spec.ingress[*].from[*]}{.namespaceSelector.matchLabels.name}{"\n"}{end}')"
meta_labels="$(kubectl get networkpolicy allow-9000-from-team -n echo -o jsonpath="{range .spec.ingress[*].from[*]}{.namespaceSelector.matchLabels['kubernetes.io/metadata.name']}{\"\n\"}{end}")"
combined_labels="$name_labels
$meta_labels"

if ! echo "$combined_labels" | awk '$1=="team-app"{ok=1} END{exit ok?0:1}'; then
  echo "NetworkPolicy must allow ingress from namespace team-app"
  exit 1
fi

if ! echo "$combined_labels" | awk '$1!="" && $1!="team-app"{bad=1} END{exit bad?1:0}'; then
  echo "NetworkPolicy allows ingress from namespace labels other than team-app"
  exit 1
fi

echo "PASS"
exit 0
