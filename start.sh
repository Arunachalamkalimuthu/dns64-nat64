#!/bin/bash

set -e

echo "Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

echo "Setting up NAT64 interface..."
tayga --mktun || true
ip link set nat64 up
ip addr add 192.0.2.1 dev nat64 || true
ip addr add fd00::1 dev nat64 || true
ip route add 64:ff9b::/96 dev nat64 || true

echo "Setting up iptables..."
iptables -t nat -A POSTROUTING -s 192.0.2.0/24 -j MASQUERADE

echo "Starting Unbound DNS64 server..."
service unbound restart

echo "Starting Tayga..."
tayga &

touch /var/log/unbound.log
tail -F /var/log/unbound.log
