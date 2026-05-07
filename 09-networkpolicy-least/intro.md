## Goal
Allow traffic from frontend to backend while keeping policy least permissive.

## Requirements
- Namespace `frontend` with Pod `frontend-app`
- Namespace `backend` with Pod `backend-api`
- Create a NetworkPolicy that only allows required frontend-to-backend traffic
