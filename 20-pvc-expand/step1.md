## Tasks
- Create PVC `site-content` with StorageClass `csi-hostpath-sc`, RWO, and 12Mi.
- Create Pod `nginx-site` that mounts the PVC at `/usr/share/nginx/html`.
- Expand the PVC to 80Mi.
- Save the updated PVC YAML to `/opt/CKA2026/resize-record.yaml`.

## Hints
- Confirm the StorageClass allows volume expansion.
- Use `kubectl get pvc -o yaml` to capture the resized PVC.
