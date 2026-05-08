## Goal
Fix kube-apiserver etcd endpoint to use port 2379.

## Requirements
- File: `/etc/kubernetes/manifests/kube-apiserver.yaml`
- Update `--etcd-servers` to use port `2379`
