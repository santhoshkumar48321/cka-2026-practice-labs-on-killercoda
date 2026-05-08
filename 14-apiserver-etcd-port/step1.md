## Tasks
- Inspect `/etc/kubernetes/manifests/kube-apiserver.yaml`.
- Replace the etcd server port `2380` with `2379` in `--etcd-servers`.
- Save the manifest and wait for the static pod to restart.

## Hints
- The kubelet will automatically reload the manifest after you save changes.
