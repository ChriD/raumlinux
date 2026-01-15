
# TODO: @@@@@@

This project aims to create an alternative kernel and rootFS for teufel-raumfeld devices so that those devices can be used for anything
It does not include any raumfeld specific application on the rootFS.

Kernel used: 
rootFS: minimalistic debian (mmdebstrab) with apt package manager


Type | Gen | CPU | SSH | Availabilty (Not possible/ available / not available)
*Raumfeld Base | Gen 1 |
Raumfeld Expand | Gen 1 |
Raumfeld Speaker S | Gen 1 |
Raumfeld Speaker M (Adam) | Gen 1 |
Raumfeld Speaker L | Gen 1 |
*Raumfeld Stereo Cubes | Gen 1 |
*Raumfeld Connector 1  | Gen 1 |
*Raumfeld Connector 2  | Gen 2 | AM33xx |
*Raumfeld One S | Gen 2 |
*Raumfeld One M | Gen 2 |
Teufel Connector | Gen 2 |
*Teufel One S | Gen 3 |
Teufel Stereo M
*Teufel Stereo L  | Gen 3 |
*Teufel Streamer | Gen 3 |
*Teufel One S | Gen 3 |
*Teufel One M | Gen 3 |

# Installation
* You need either a raumfeld device where SSH is activated
  - links to ssh enable
  Or you open the device and use the JTAG pinheaders with a serial to USB device

* update the boot command to be able to boot from USB
   - Booting from network would be possible too for development
* You need an USB 2.0 stick because many USB 3.0 sticks wont be regognized by the uBoot (too old)
* download the image and use a tool (e.g Rufus) to put it on the USB 
  - PaartUUID is very important diuw we do not use initramfs 
* update WPA_supplicant if WLAN is needed
* shut off device completely. Insert usb stick and start again
* wait for about 1 minute.
* device should be able to be reachable via SSH

# Building
* install a buildroot
* merge buildroot folder of this repo into the standard buildroot folder
* install toolchains for arm
* this will build you the kernel and dts.

* # Internal NAND 
 - Is not used. Is commented, you may add it







