## Tasks
- Update deployment `service-deployment` to expose container port 8080/TCP named `http`.
- Create NodePort service `service-nodeport` that exposes port 8080/TCP.

## Hints
- Match the service selector to the deployment labels.
- Keep the service port and targetPort aligned on 8080.
