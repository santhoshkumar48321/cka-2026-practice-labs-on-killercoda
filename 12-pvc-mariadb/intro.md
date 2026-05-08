## Goal
Claim an existing retained PV with a PVC and update a deployment to use it.

## Requirements
- Namespace: `database`
- PersistentVolume: `database-pv` (Retain, 500Mi, RWO)
- PVC: `database-storage`
- Deployment: `database-app`
- Deployment image: `mariadb:10.11`
- Update `/opt/database.yaml` to use the PVC
