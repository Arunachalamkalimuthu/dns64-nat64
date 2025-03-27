#!/bin/bash

set -e

# Enable IP forwarding
echo "Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Setup tayga TUN interface
echo "Setting up NAT64 interface..."
tayga --mktun || true
ip link set nat64 up
ip addr add 192.0.2.1 dev nat64 || true
ip addr add 64:ff9b::1 dev nat64 || true
ip route add 64:ff9b::/96 dev nat64 || true

# Setup NAT
echo "Setting up iptables NAT rule..."
iptables -t nat -A POSTROUTING -s 192.0.2.0/24 -j MASQUERADE

# Start Unbound
echo "Starting Unbound DNS64 server..."
service unbound restart

echo "Starting Tayga NAT64 service..."
tayga &