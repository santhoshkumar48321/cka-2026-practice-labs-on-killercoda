## Tasks
- Inspect Ingress `api-ingress` to capture the host, TLS secret, backend service/port, and routing paths.
- Create Gateway `api-gateway` using GatewayClass `nginx-gateway` with an HTTPS listener for `api.demo.k8s.local` and the same TLS secret.
- Create HTTPRoute `api-route` for `api.demo.k8s.local`, attach it to `api-gateway`, and mirror the same backend routing rules as the Ingress.

## Hints
- Use `kubectl get ingress api-ingress -o yaml` to see the source routing rules.
- Gateway API resources are in `gateway.networking.k8s.io`.
