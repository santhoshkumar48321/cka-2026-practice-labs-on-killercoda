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

kubectl create namespace database --dry-run=client -o yaml | kubectl apply -f -

cat <<'YAML' >/opt/database.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:11
        env:
        - name: MARIADB_ROOT_PASSWORD
          value: rootpass
        volumeMounts:
        - name: dbdata
          mountPath: /var/lib/mysql
      volumes:
      - name: dbdata
        persistentVolumeClaim:
          claimName: REPLACE_WITH_DATABASE_STORAGE
YAML

echo "Setup complete"
