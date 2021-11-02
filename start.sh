#!/bin/bash

# Cleanup
rm /tmp/firecracker.socket || true

# Setup Network
IFACE=eno1

sudo ip link add name fcbridge0 type bridge
sudo ip addr add 172.16.32.1/24 dev fcbridge0
sudo ip link set dev fcbridge0 up
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables --table nat --append POSTROUTING --out-interface $IFACE -j MASQUERADE
sudo iptables --insert FORWARD --in-interface fcbridge0 -j ACCEPT

sudo ip tuntap add tap0 mode tap
sudo brctl addif fcbridge0 tap0
sudo ifconfig tap0 up

# Start Firecracker
exec firecracker \
    --api-sock /tmp/firecracker.socket \
    --config-file vm-config.json
