[TOC]

# Intro
Notes about how I debug the boot sequence for raspberry pi 4 to get it to boot into the Grub Boot Loader, through u-boot.

## Enable UART - Raspberry Boot Loader
Downloaded Raspberry Buster and flashed it to a sd-card
```
unzip -p *-raspbian-buster-lite.zip | sudo dd of=/dev/sdX bs=4M conv=fsync
```
- [Download Raspberry Buster](https://www.raspberrypi.org/downloads/raspbian/)
- [Download Raspberry Buster (direct link)](https://downloads.raspberrypi.org/raspbian_lite_latest)

Boot into the newly flashed sd-card and follow the guide [Enable UART on PI4](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md)

## U-Boot as the 1st Boot Loader
First configure /boot/config.txt
```
# if required for u-boot
enable_uart=1

# u-boot filename in the /boot folder
kernel=uboot_rpi_4.bin

# Unknown if variables are needed
arm_64bit=1
device_tree_address=0x03000000
cmdline=nobtcmd.txt
dtoverlay=disable-bt
```

You may need to build u-boot yourself, if start4.elf will not boot it  
TODO: be documented
**NOTE:** I used the one from ubuntu

You need to create the boot script for u-boot /boot/boot.scr
```
### The file EFI/BOOT/BOOTAA64.EFI is the grub boot loader
cat <<'zEOFz' | sudo tee /boot/boot.txt
load mmc 0:1 ${loadaddr} EFI/BOOT/BOOTAA64.EFI
bootefi ${loadaddr}
zEOFz

### Generate /boot/boot.scr from /boot/boot.txt
sudo mkimage -A arm -O linux -T script -C none -n "U-Boot boot script" -d /boot/boot.txt /boot/boot.scr
```

## Install and configure Grub
**NOTE:** I don't know how to build Grub the package is in my distro  

Install Grub
```
grub-install --target=arm64-efi --efi-directory=/boot --removable
```

Configure Grub
```
TODO: be documented
```

## The aarch64 v5.5 kernel does not support PI 4
I can get the kernel to boot, but when it just randomly freeze and I have to reboot the PI, so I cannot get any thourght in this project on ArchLinuxARM, until the kernel gets better support upstream, but that should just be a question of time.

