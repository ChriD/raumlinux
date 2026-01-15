#!/bin/bash

# Configuration
TFTP_DIR="/srv/tftp"
NFS_DIR="/srv/nfs/raumfeld_buildroot"
BUILD_IMAGES_DIR="/home/dietpi/builds/buildroot/output/images"
ROOTFS_TAR="/home/dietpi/builds/buildroot/output/images/rootfs.tar"

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "=== Deploying to TFTP and NFS ==="

# 1. Deploy Kernel and DTB to TFTP
echo "[TFTP] Copying uImage and DTB(s) to $TFTP_DIR..."
mkdir -p "$TFTP_DIR"
cp "$BUILD_IMAGES_DIR/uImage" "$TFTP_DIR/"

NEW_DTB="raumfeld-am33xx-ones.dtb"
OLD_DTB="am335x-raumfeld-minimal.dtb"

if [ -f "$BUILD_IMAGES_DIR/$NEW_DTB" ]; then
  SRC_DTB="$NEW_DTB"
elif [ -f "$BUILD_IMAGES_DIR/$OLD_DTB" ]; then
  SRC_DTB="$OLD_DTB"
else
  echo "Error: no DTB found in $BUILD_IMAGES_DIR (expected $NEW_DTB or $OLD_DTB)"
  exit 1
fi

# Deploy DTB under both names for now (bootloader compatibility)
cp "$BUILD_IMAGES_DIR/$SRC_DTB" "$TFTP_DIR/$NEW_DTB"
cp "$BUILD_IMAGES_DIR/$SRC_DTB" "$TFTP_DIR/$OLD_DTB"

chmod 644 "$TFTP_DIR/uImage" "$TFTP_DIR/$NEW_DTB" "$TFTP_DIR/$OLD_DTB"
echo "[TFTP] Done."

# 2. Deploy RootFS to NFS
echo "[NFS]  Extracting RootFS to $NFS_DIR..."
if [ ! -f "$ROOTFS_TAR" ]; then
    echo "Error: RootFS tarball not found at $ROOTFS_TAR"
    exit 1
fi

# Create directory if it doesn't exist
mkdir -p "$NFS_DIR"

# Clean existing NFS directory (required to avoid corrupt overlay)
case "$NFS_DIR" in
  ""|"/"|"/srv"|"/srv/nfs"|"/srv/nfs/")
  echo "Refusing to clean unsafe NFS_DIR: '$NFS_DIR'"
  exit 1
  ;;
esac
echo "[NFS]  Cleaning old files in $NFS_DIR..."
rm -rf "$NFS_DIR"/*

# Extract
tar -xf "$ROOTFS_TAR" -C "$NFS_DIR"
tar_rc=$?
if [ "$tar_rc" -ne 0 ]; then
  echo "Error: extracting rootfs tar failed (exit=$tar_rc)."
  echo "NFS root may be incomplete; aborting."
  exit "$tar_rc"
fi

if [ ! -x "$NFS_DIR/sbin/init" ] && [ ! -x "$NFS_DIR/init" ]; then
  echo "Error: no init found in NFS root ($NFS_DIR)."
  echo "Expected $NFS_DIR/sbin/init or $NFS_DIR/init"
  exit 1
fi
echo "[NFS]  Done."

# 3. Restart Services (Optional, usually not needed but good for sanity)
echo "[SVC]  Restarting NFS and TFTP services..."
systemctl restart tftpd-hpa
systemctl restart nfs-kernel-server

echo "=== Deployment Complete ==="
echo "You can now boot the board via network."
