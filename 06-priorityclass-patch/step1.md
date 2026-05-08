## Tasks
- Identify the highest user-defined PriorityClass value in the cluster.
- Create PriorityClass `critical-priority` with value (highest - 1).
- Patch deployment `logger-app` in namespace `production` to use `priorityClassName: critical-priority`.

## Hints
- Filter out PriorityClasses that start with `system-` when computing the highest user-defined value.
- Use a patch or edit workflow to update the deployment spec.
