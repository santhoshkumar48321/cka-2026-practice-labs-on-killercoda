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

kubectl create deployment web --image=nginx:1.27 --replicas=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl create service clusterip web-svc --tcp=80:80 --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic api-tls --from-literal=tls.crt=dummy --from-literal=tls.key=dummy --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.demo.k8s.local
    secretName: api-tls
  rules:
  - host: api.demo.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
YAML

echo "Setup complete"
