## Goal
Allow traffic from frontend to backend while keeping policy least permissive.

## Requirements
- Frontend namespace: `frontend`
- Frontend deployment: `frontend-app`
- Frontend image: `busybox:1.36`
- Backend namespace: `backend`
- Backend deployment: `backend-api`
- Backend image: `hashicorp/http-echo:1.0`
- Backend port: `8080/TCP`
- NetworkPolicy: `frontend-to-backend`
