## Tasks
- Edit Deployment `webapp` to add a sidecar container named `log-reader`.
- Mount a shared volume at `/var/log` in both containers.
- Run the sidecar with `/bin/sh -c "tail -f /var/log/application.log"`.

## Hints
- Use `kubectl edit` or `kubectl patch` to update the deployment spec.
- Ensure the sidecar uses the same volume name as the main container.
