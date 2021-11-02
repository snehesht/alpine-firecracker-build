#!/usr/bin/env bash

ARCH=x86_64
ALPINE_VERSION_MAJOR=v3.14
ALPINE_VERSION=3.14.2
OPENRC_VERSION=0.43.3-r2

BUILD_DIR="./dist"
ALPINE_PKG="alpine-minirootfs-${ALPINE_VERSION}-${ARCH}.tar.gz"
OPENRC_PKG="openrc-${OPENRC_VERSION}.apk"

# Clean up
sudo rm -rf "${BUILD_DIR}" || true
mkdir "${BUILD_DIR}"

# Build Rootfs
cd $BUILD_DIR

# Download Alpine and Kernel
wget "https://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION_MAJOR}/releases/${ARCH}/${ALPINE_PKG}"

wget "https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/${ARCH}/kernels/vmlinux.bin"

# Download openrc
wget "https://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION_MAJOR}/main/${ARCH}/${OPENRC_PKG}"

fallocate -l 256M alpine-rootfs
mkfs.ext4 alpine-rootfs

mkdir -p mount

sudo mount alpine-rootfs mount

sudo tar xf "${ALPINE_PKG}" -C mount  &> /dev/null
sudo tar xf "${OPENRC_PKG}" -C mount &> /dev/null

# empty root password
sudo sed 's/^root:.*/root::14871::::::/' -i mount/etc/shadow

# faster package
sudo sed 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' -i mount/etc/apk/repositories

# default nameserver
echo 'nameserver 1.1.1.1' | sudo tee mount/etc/resolv.conf

# inittab
sudo cp ../inittab  mount/etc/inittab

sudo umount mount

# Cleanup
rm -rf "${ALPINE_PKG}" || true
rm -rf "${OPENRC_PKG}" || true
rm -rf mount || true
