#!/usr/bin/env bash
set -euo pipefail

wait_kube() {
  for i in $(seq 1 60); do
    if kubectl get ns >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Kubernetes API not ready after 60 seconds" >&2
  exit 1
}

wait_kube

mkdir -p /home/candidate

# Install Istio CRDs only (no control plane needed for kubectl explain)
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/manifests/charts/base/crds/crd-all.gen.yaml || \
kubectl apply -f - <<'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: virtualservices.networking.istio.io
spec:
  group: networking.istio.io
  versions:
  - name: v1beta1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              hosts:
                type: array
                description: "The destination hosts to which traffic is being sent"
                items:
                  type: string
  scope: Namespaced
  names:
    plural: virtualservices
    singular: virtualservice
    kind: VirtualService
YAML

echo "Setup complete"
