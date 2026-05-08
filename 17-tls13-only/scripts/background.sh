#!/usr/bin/env bash
set -euo pipefail

wait_kube() {
  echo "Waiting for Kubernetes API..."
  for i in $(seq 1 60); do
    if kubectl get ns >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Kubernetes API not ready"
  exit 1
}

wait_kube

kubectl create ns web --dry-run=client -o yaml | kubectl apply -f -

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-tls-config
  namespace: web
data:
  tls.conf: |
    ssl_protocols TLSv1.2 TLSv1.3;
YAML

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: web-tls
  namespace: web
type: kubernetes.io/tls
data:
  tls.crt: dGVzdA==
  tls.key: dGVzdA==
YAML

cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
  namespace: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        volumeMounts:
        - name: tls-config
          mountPath: /etc/nginx/conf.d/tls.conf
          subPath: tls.conf
        - name: tls-secret
          mountPath: /etc/nginx/tls
      volumes:
      - name: tls-config
        configMap:
          name: web-tls-config
      - name: tls-secret
        secret:
          secretName: web-tls
YAML

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: web
spec:
  selector:
    app: web-server
  ports:
  - name: https
    port: 443
    targetPort: 443
YAML

echo "Setup complete"
