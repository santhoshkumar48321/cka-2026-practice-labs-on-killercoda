## Tasks
- Verify namespace `ing-private` and service `hello` exist.
- Create Ingress `wave` in namespace `ing-private`.
- Route path `/hello` to service `hello` on port `5678`.

## Hints
- Use `networking.k8s.io/v1` Ingress syntax with `pathType: Prefix`.
- The backend service name and port must match the existing service.
