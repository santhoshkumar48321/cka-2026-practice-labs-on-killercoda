## Tasks

1. Edit Deployment `webapp` to add a sidecar container `log-reader`
2. Mount a shared volume at `/var/log` in both containers
3. Sidecar runs: `/bin/sh -c "tail -f /var/log/application.log"`

### Specs

| Field | Value |
|---|---|
| Sidecar name | `log-reader` |
| Sidecar image | `busybox:1.36` |
| Command | `/bin/sh -c "tail -f /var/log/application.log"` |
| Volume mount path | `/var/log` (both containers) |

## Verify

```bash
kubectl rollout status deploy/webapp
kubectl get pod -l app=webapp -o jsonpath='{.items[0].spec.containers[*].name}'; echo
kubectl logs deploy/webapp -c log-reader --tail=20
```
