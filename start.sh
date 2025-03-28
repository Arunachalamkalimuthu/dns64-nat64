#!/bin/bash
set -e

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

# Setup NAT64 TUN
tayga --mktun || true
ip link set nat64 up
ip addr add 192.0.2.1 dev nat64 || true
ip addr add 2001:db8:1::1 dev nat64 || true
ip -6 route add 64:ff9b::/96 dev nat64 || true
iptables -t nat -A POSTROUTING -s 192.0.2.0/24 -o ens6 -j MASQUERADE

# Start Unbound + Tayga
service unbound restart
tayga &

# Log output
touch /var/log/unbound.log
chmod 644 /var/log/unbound.log
tail -F /var/log/unbound.log