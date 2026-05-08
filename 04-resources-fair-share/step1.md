## Tasks
- Scale the deployment `webapp-deployment` down to 1 replica for safe editing.
- Calculate fair per-pod requests/limits for 3 replicas with a small overhead buffer.
- Update the deployment so init containers and main containers share identical requests/limits.
- Scale the deployment back to 3 replicas and ensure it stabilizes.

## Hints
- Compare init container and main container resource blocks in the pod template.
- Confirm replicas are back at 3 before finishing.
