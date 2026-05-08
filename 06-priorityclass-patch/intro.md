## Goal
Create a PriorityClass with value = (highest user-defined PriorityClass - 1) and patch a deployment to use it.

## Requirements
- Namespace: `production`
- Deployment: `logger-app`
- Deployment image: `busybox:1.36`
- Existing PriorityClasses: `baseline-priority`, `top-priority`
- New PriorityClass: `critical-priority`
