## Tasks
- Create NetworkPolicy `allow-9000-from-team` in namespace `echo`.
- Allow ingress only from namespace `team-app` to pods labeled `app=echo-server`.
- Restrict ingress to TCP port 9000 and deny other access.

## Hints
- Use a namespaceSelector matching the label `name=team-app`.
- Ensure the policy is ingress-only.
