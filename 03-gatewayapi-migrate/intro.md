## Goal
Migrate the existing Ingress `api-ingress` to Gateway API resources while keeping HTTPS/TLS behavior and routing rules.

## Requirements
- Existing backend Deployment: `web`
- Existing backend Service: `web-svc`
- Existing Ingress: `api-ingress`
- GatewayClass available: `nginx-gateway`
- Preserve host: `api.demo.k8s.local`
