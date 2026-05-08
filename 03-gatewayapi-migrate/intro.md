## Goal
Migrate the existing Ingress `api-ingress` to Gateway API resources while keeping HTTPS/TLS behavior and routing rules.

## Requirements
- Namespace: `default`
- Deployment: `web`
- Deployment image: `nginx:1.25`
- Service: `web-svc` (port 80)
- Ingress: `api-ingress`
- TLS secret: `api-tls`
- Hostname: `api.demo.k8s.local`
- GatewayClass: `nginx-gateway`
- Gateway: `api-gateway`
- HTTPRoute: `api-route`
