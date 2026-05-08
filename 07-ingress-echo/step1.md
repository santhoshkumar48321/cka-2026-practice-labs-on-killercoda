## Tasks
- Create Service `app-service` (ClusterIP) on port 8090 that targets the app pods.
- Create Ingress `app-ingress` with host `demo.example.com` and path `/api` routed to `app-service:8090`.

## Hints
- Verify the service selector matches the deployment labels.
- Use `networking.k8s.io/v1` Ingress syntax.
