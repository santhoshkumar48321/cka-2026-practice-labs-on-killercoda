## Tasks
- Taint node `worker-node01` with `Env=Production:NoSchedule`.
- Create pod `prod-pod` that tolerates the taint and schedules onto `worker-node01`.

## Hints
- Add a toleration with key `Env`, value `Production`, and effect `NoSchedule`.
- Use `nodeName` if you need to force placement.
