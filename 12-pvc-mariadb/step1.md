## Tasks
- Create PVC `database-storage` in namespace `database` with 500Mi and ReadWriteOnce.
- Edit `/opt/database.yaml` to use the new PVC for `/var/lib/mysql`.
- Apply the manifest and verify the deployment is running.

## Hints
- The PV already exists and uses `Retain`.
- Ensure the PVC name matches the volume claim in the manifest.
