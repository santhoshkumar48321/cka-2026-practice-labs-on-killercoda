## Tasks
- Create ClusterRole `pipeline-deployer` with `create` on Deployments, StatefulSets, and DaemonSets in the `apps` API group.
- Create ServiceAccount `cicd-bot` in namespace `app-squad`.
- Create RoleBinding `pipeline-deployer-binding` in `app-squad` that binds the ClusterRole to the ServiceAccount.

## Hints
- Use a RoleBinding (not ClusterRoleBinding) to scope access to one namespace.
- Ensure the RoleBinding subject references `app-squad:cicd-bot`.
