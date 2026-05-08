## Goal
Reserve a node so normal pods can't schedule, then schedule a pod with toleration on that node.

## Requirements
- Node: `worker-node01`
- Taint: key=`Env`, value=`Production`, effect=`NoSchedule`
- Pod name: `prod-pod`
- Pod image: `busybox:1.36`
- Pod must land on `worker-node01`
