## Goal
Update the `webapp` Deployment by adding a sidecar container that tails an application log file from a shared volume.

## Requirements
- Namespace: `default`
- Deployment: `webapp`
- Main container image: `busybox:1.36`
- Sidecar name: `log-reader`
- Sidecar image: `busybox:1.36`
- Sidecar command: `/bin/sh -c "tail -f /var/log/application.log"`
- Use a volume mounted at `/var/log` in both containers
