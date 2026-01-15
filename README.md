# raumlinux

This project collects an alternative kernel + Debian-based root filesystem workflow for Teufel/Raumfeld devices.

Primary target (current): AM33xx-based Gen2 devices (e.g. Raumfeld/Teufel One S).

## What’s in this repo

- `buildroot/`: Buildroot additions (board support, defconfig, DTS, kernel patch, config fragment, helper scripts).
- `rootFS/`: Root filesystem archive split into GitHub-friendly chunks, plus a reassembly script.
- `images/`: Convenience copies of built `uImage` + DTBs (if present).
- `RE/`: Reference DTB/DTS/pinmux artifacts (historical/reference).

## Build (from a clean Buildroot checkout)

1. Copy/merge the contents of `buildroot/` into a standard Buildroot tree.
2. Run:

   make raumfeld_am33xx_ones_defconfig
   make linux-rebuild

## RootFS archive

The rootfs is not pushed to GitHub by default (it is large and contains machine-specific data).
If you need it, keep it locally or publish it as a separate download.

## Device overview (WIP)

Type | Gen | CPU | SSH | Availability
--- | --- | --- | --- | ---
Raumfeld Base | Gen 1 |  |  | 
Raumfeld Expand | Gen 1 |  |  | 
Raumfeld Speaker S | Gen 1 |  |  | 
Raumfeld Speaker M (Adam) | Gen 1 |  |  | 
Raumfeld Speaker L | Gen 1 |  |  | 
Raumfeld Stereo Cubes | Gen 1 |  |  | 
Raumfeld Connector 1 | Gen 1 |  |  | 
Raumfeld Connector 2 | Gen 2 | AM33xx |  | 
Raumfeld One S | Gen 2 | AM33xx |  | 
Raumfeld One M | Gen 2 |  |  | 
Teufel Connector | Gen 2 |  |  | 
Teufel One S | Gen 3 |  |  | 
Teufel Stereo M | Gen 3 |  |  | 
Teufel Stereo L | Gen 3 |  |  | 
Teufel Streamer | Gen 3 |  |  | 
Teufel One M | Gen 3 |  |  | 

## Installation notes (WIP)

- You need either a device with SSH enabled, or UART/JTAG access.
- USB boot vs netboot depends on U-Boot/bootcmd configuration.
- Some older U-Boot versions don’t like certain USB3 sticks; USB2 often works best.

