# raumkernel

This repository contains only the custom Buildroot bits needed to reproduce the Raumfeld AM33xx kernel/DTB build on top of a fresh Buildroot checkout.

Included:
- buildroot/board/raumfeld/ (overlays, initramfs helpers, kernel patches)
- buildroot/configs/raumfeld_am33xx_ones_defconfig
- buildroot/raumfeld/*.dts (device-tree sources)
- buildroot/.vscode/tasks.json (optional convenience tasks)
- buildroot/deploy_netboot.sh (optional, if present in the original tree)

Usage:
1) Copy this subtree into your Buildroot checkout:
   ./install.sh /path/to/buildroot

2) Build:
   cd /path/to/buildroot
   make raumfeld_am33xx_ones_defconfig
   make linux-rebuild

Outputs are in output/images/ (uImage and DTBs).

Notes:
- This repo intentionally does not include output/, dl/, toolchains, or rootfs artifacts.
