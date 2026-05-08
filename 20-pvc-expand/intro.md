## Goal
Create a PVC, mount it into a Pod, then expand the PVC and record the change.

## Requirements
- PVC name: `site-content`
- StorageClass: `csi-hostpath-sc`
- AccessMode: `ReadWriteOnce`
- Initial size: `12Mi`
- Pod name: `nginx-site`
- Pod image: `nginx:1.27`
- Mount path: `/usr/share/nginx/html`
- Expanded size: `80Mi`
- Save resized PVC YAML to `/opt/CKA2026/resize-record.yaml`
