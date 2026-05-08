#!/usr/bin/env bash
set -euo pipefail

if ! test -x /usr/bin/cri-dockerd; then
  echo "cri-dockerd binary not found at /usr/bin/cri-dockerd"
  exit 1
fi

if ! test -L /etc/systemd/system/multi-user.target.wants/cri-docker.service; then
  echo "cri-docker service is not enabled"
  exit 1
fi

if ! grep -q '^1$' /proc/sys/net/bridge/bridge-nf-call-iptables; then
  echo "sysctl net.bridge.bridge-nf-call-iptables must be 1"
  exit 1
fi

if ! grep -q '^1$' /proc/sys/net/ipv6/conf/all/forwarding; then
  echo "sysctl net.ipv6.conf.all.forwarding must be 1"
  exit 1
fi

if ! grep -q '^1$' /proc/sys/net/ipv4/ip_forward; then
  echo "sysctl net.ipv4.ip_forward must be 1"
  exit 1
fi

if ! grep -q '^262144$' /proc/sys/net/netfilter/nf_conntrack_max; then
  echo "sysctl net.netfilter.nf_conntrack_max must be 262144"
  exit 1
fi

echo "PASS"
exit 0
