## Goal
Expose an application via Ingress and confirm HTTP 200.

## Requirements
- Namespace: `demo-app`
- Deployment: `app-deployment`
- Deployment image: `hashicorp/http-echo:1.0`
- Ingress: `app-ingress`
- Service: `app-service` (ClusterIP) on port 8090
- Host: `demo.example.com`
- Path: `/api`
