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

# Create backend service that Ingress/HTTPRoute will route to
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-backend
  template:
    metadata:
      labels:
        app: api-backend
    spec:
      containers:
      - name: api-backend
        image: nginx:latest
        ports:
        - containerPort: 80
YAML

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: api-backend-svc
spec:
  type: ClusterIP
  selector:
    app: api-backend
  ports:
  - port: 80
    targetPort: 80
YAML

# Create existing Ingress for user to migrate
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
spec:
  rules:
  - host: api.demo.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-backend-svc
            port:
              number: 80
YAML

echo "Setup complete"
