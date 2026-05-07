#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1"
  exit 1
}

if ! test -f /usr/bin/cri-dockerd; then
  fail "cri-dockerd binary not found at /usr/bin/cri-dockerd"
fi

if ! test -f /etc/systemd/system/cri-docker.service; then
  fail "cri-docker systemd service file not found"
fi

if ! grep -q '^net.bridge.bridge-nf-call-iptables=1$' /etc/sysctl.conf; then
  fail "Missing net.bridge.bridge-nf-call-iptables=1 in /etc/sysctl.conf"
fi
if ! grep -q '^net.ipv6.conf.all.forwarding=1$' /etc/sysctl.conf; then
  fail "Missing net.ipv6.conf.all.forwarding=1 in /etc/sysctl.conf"
fi
if ! grep -q '^net.ipv4.ip_forward=1$' /etc/sysctl.conf; then
  fail "Missing net.ipv4.ip_forward=1 in /etc/sysctl.conf"
fi
if ! grep -q '^net.netfilter.nf_conntrack_max=262144$' /etc/sysctl.conf; then
  fail "Missing net.netfilter.nf_conntrack_max=262144 in /etc/sysctl.conf"
fi

if ! awk 'BEGIN{ok=0} {if($1=="1") ok=1} END{exit ok?0:1}' /proc/sys/net/bridge/bridge-nf-call-iptables; then
  fail "Runtime sysctl net.bridge.bridge-nf-call-iptables must be 1"
fi
if ! awk 'BEGIN{ok=0} {if($1=="1") ok=1} END{exit ok?0:1}' /proc/sys/net/ipv6/conf/all/forwarding; then
  fail "Runtime sysctl net.ipv6.conf.all.forwarding must be 1"
fi
if ! awk 'BEGIN{ok=0} {if($1=="1") ok=1} END{exit ok?0:1}' /proc/sys/net/ipv4/ip_forward; then
  fail "Runtime sysctl net.ipv4.ip_forward must be 1"
fi
if ! awk 'BEGIN{ok=0} {if($1=="262144") ok=1} END{exit ok?0:1}' /proc/sys/net/netfilter/nf_conntrack_max; then
  fail "Runtime sysctl net.netfilter.nf_conntrack_max must be 262144"
fi

echo "PASS"
exit 0
