#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

ns="web"

if ! kubectl -n "$ns" get deploy web-server >/dev/null 2>&1; then
  fail "Deployment web-server not found in namespace $ns"
fi
if ! kubectl -n "$ns" get svc web-service >/dev/null 2>&1; then
  fail "Service web-service not found in namespace $ns"
fi

cm_name="$(kubectl -n "$ns" get deploy web-server -o jsonpath='{.spec.template.spec.volumes[0].configMap.name}' 2>/dev/null || true)"
if ! test -n "$cm_name"; then
  fail "Deployment web-server must mount a ConfigMap"
fi

cm_dump="$(kubectl -n "$ns" get configmap "$cm_name" -o yaml)"
if ! echo "$cm_dump" | grep -q 'TLSv1\.3'; then
  fail "ConfigMap $cm_name must configure TLSv1.3"
fi
if echo "$cm_dump" | grep -q 'TLSv1\.2'; then
  fail "ConfigMap $cm_name must not allow TLSv1.2"
fi

if ! grep -q 'secure.demo.local' /etc/hosts; then
  fail "/etc/hosts must include secure.demo.local"
fi

echo "PASS"
exit 0
