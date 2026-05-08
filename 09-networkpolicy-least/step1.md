## Tasks
- Create a NetworkPolicy named `frontend-to-backend` in namespace `backend`.
- Select pods labeled `app=backend-api` and allow ingress only from `frontend` namespace pods labeled `app=frontend-app`.
- Restrict ingress to TCP port 8080 and keep everything else blocked.

## Hints
- Use a namespace selector for `kubernetes.io/metadata.name: frontend`.
- Keep the policy limited to ingress only.
