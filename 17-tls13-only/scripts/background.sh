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

if ! command -v openssl >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y openssl
fi

kubectl create namespace web --dry-run=client -o yaml | kubectl apply -f -

# Generate self-signed TLS cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt \
  -subj "/CN=secure.demo.local/O=demo" \
  -addext "subjectAltName=DNS:secure.demo.local" 2>/dev/null

kubectl create secret tls web-tls --cert=/tmp/tls.crt --key=/tmp/tls.key \
  -n web --dry-run=client -o yaml | kubectl apply -f -

# Create nginx config allowing TLS 1.2 and 1.3 (user must restrict to 1.3 only)
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-tls-config
  namespace: web
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 443 ssl;
        ssl_certificate     /etc/nginx/certs/tls.crt;
        ssl_certificate_key /etc/nginx/certs/tls.key;
        ssl_protocols       TLSv1.2 TLSv1.3;
        location / { return 200 "ok\n"; }
      }
    }
YAML

kubectl apply -f - <<'YAML'
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
        image: nginx:latest
        ports:
        - containerPort: 443
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: certs
          mountPath: /etc/nginx/certs
      volumes:
      - name: config
        configMap:
          name: nginx-tls-config
      - name: certs
        secret:
          secretName: web-tls
YAML

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: web
spec:
  type: ClusterIP
  selector:
    app: web-server
  ports:
  - port: 443
    targetPort: 443
YAML

echo "Setup complete"
