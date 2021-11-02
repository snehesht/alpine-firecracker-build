#!/bin/bash

# Setup Network
IFACE=eno1
sudo ip link set tap0 down
sudo ip tuntap del tap0 mode tap


# Cleanup
rm /tmp/firecracker.socket || true
