## Tasks
- Edit deployment `ui-frontend` in namespace `portal` and add a named container port `http` (80/TCP).
- Create NodePort service `ui-frontend-svc` targeting the named port `http`.

## Hints
- The service selector should match `app=ui-frontend`.
- Use the port name as the service targetPort.
