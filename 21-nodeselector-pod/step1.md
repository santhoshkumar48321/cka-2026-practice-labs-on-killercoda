## Tasks
- Identify nodes labeled `disk=ssd`.
- Create Pod `nginx-kusc01801` with image `nginx:1.27` and nodeSelector `disk=ssd`.

## Hints
- Use `kubectl get nodes --show-labels` to find labeled nodes.
- The nodeSelector must match the label key and value exactly.
