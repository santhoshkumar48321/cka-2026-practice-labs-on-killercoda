## Goal
Reconfigure an existing Deployment to expose a named port, then create a NodePort Service using that named port.

## Requirements
- Deployment name: `ui-frontend`
- Namespace: `portal`
- Deployment image: `nginx:1.27`
- Port name: `http`
- Container port: `80/TCP`
- Service: `ui-frontend-svc` (NodePort, targetPort `http`)
