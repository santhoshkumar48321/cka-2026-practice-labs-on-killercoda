## Goal
Monitor logs of a Pod and extract only the error lines matching a pattern.

## Requirements
- Namespace: `default`
- Pod name: `payment-api`
- Pod image: `busybox:1.36`
- Extract log lines that contain: `error file-not-found`
- Write them to: `/opt/CKA2026/payment-api/errors.log`
