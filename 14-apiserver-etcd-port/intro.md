## Scenario
After migration, kube-apiserver points to etcd peer port 2380 instead of client port 2379.

## Goal
Fix kube-apiserver etcd endpoint to use port 2379.

## Requirements
- File to edit: `/etc/kubernetes/manifests/kube-apiserver.yaml`
- etcd endpoint must use client port `2379`
- Do not change unrelated kube-apiserver flags
