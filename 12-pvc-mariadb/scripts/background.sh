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

kubectl create ns database --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /mnt/data

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: database-pv
spec:
  capacity:
    storage: 500Mi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
YAML

cat <<'YAML' > /opt/database.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database-app
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database-app
  template:
    metadata:
      labels:
        app: database-app
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.11
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: root
        volumeMounts:
        - name: db-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: db-storage
        emptyDir: {}
YAML

echo "Setup complete"
