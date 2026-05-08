## Tasks
- Create an `autoscaling/v2` HPA named `nginx-scaler` targeting deployment `nginx-deployment` in namespace `scaling`.
- Set CPU target to 60%, minReplicas to 2, and maxReplicas to 6.
- Configure scaleDown stabilization window to 45 seconds.

## Hints
- Use the `behavior.scaleDown.stabilizationWindowSeconds` field in the HPA spec.
- Ensure the deployment has CPU requests set before creating the HPA.
