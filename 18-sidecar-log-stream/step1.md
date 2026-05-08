## Tasks
- Edit Pod `atlas-app` to add a sidecar container named `log-sidecar`.
- Mount a shared volume at `/var/log` in both containers.
- Run the sidecar with `/bin/sh -c "tail -n+1 -F /var/log/atlas-app.log"`.

## Hints
- Use `kubectl edit pod atlas-app` to add the sidecar.
- Ensure the sidecar shares the same volume name as the main container.
