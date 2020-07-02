- [Intro](#intro)
- [How to install](#how-to-install)
  - [Extra options](#extra-options)
- [How does it work?](#how-does-it-work)
- [The different playbooks](#the-different-playbooks)
- [Tips & Ticks](#tips--ticks)
  - [Install Ubuntu from Archlinux](#install-ubuntu-from-archlinux)
- [TODO](#todo)

# Intro
The goal of this project was to have a way to easily rollback a bad update, and not have the update interfere with the rest of the system while installing the update.  
Inspired by what I have heard about boot environment on ZFS from BSD (and because I like ZFS), I created a way to install the update/upgrade of the distro into a clone of the ROOT mounted filesystem, and when boot into the clone filesystem and use it as the new root filesystem.  
**Request:** Suggestion for a better name for this project is welcome :D  


# How to install
It is pretty simple. Run the ansible script and set the following 5 required variables.
- **install_device**  
The path of the device which you want to install this system onto. The playbook with not accept devices with an or more partition on.  
This is mainly don't so you don't accedently overwrite data on the wrong device.
- **zpool_number**  
The zpool name is gonna be "zroot_XX", there the number you pick will replace "XX".  
This is mainly done, because it makes it easier to import one pool onto another system with ZFS pool, if the 2 pools don't have the same name.
- **admin_user**  
The username of the user which the install is gonna create
- **admin_pass**  
The plain text password for the user which the install is gonna create.  
Note: The variable **admin_pass_hash** can be used instead.
- **hostname**  
The name of the computer you are installing this OS on.

```sh
sudo ansible-playbook install_linux.yml \
  -e install_device=/dev/sdX \
  -e zpool_number=42 \
  -e admin_user=admin \
  -e admin_pass=password \
  -e hostname=new-server-1337 \
  -e @vars/OPERATING_SYSTEM.yml
```

## Extra options
- **admin_pass_hash**  
Instead of having the playbook create a hash of the password declared in the variable *admin_pass*. The playbook will just use the hash in *admin_pass_hash* if declared.
- **root_pass**  
Set the password for the root user to something different then the *admin_pass* (or *admin_pass_hash*)
- **root_pass_hash**  
same as **admin_pass_hash** just for the root
- **zfs_package**  
Use this variable if you want to specify the package providing ZFS
- **time_zone**  
Set time zone. Example: `Europe/Copenhagen`
- **overwrite_distribution & overwrite_machine**  
There are 2 files from the vars folder included, which are picked automatically based on the distribution and machine/architecture you are running this playbook on.  
This variable allows you to overwrite which files are selected. Just be aware that it may not work.

# How does it work?
A simplified overall step by step explanation for the patch management process.

1. Patch Management is triggered (probably by a timer).
2. Patch Management creates a snapshot of the current root mounted (ZFS) filesystem and when uses the snapshot to create a clone of the filesystem.
3. Patch Management mounts the filesystem and starts to update/upgrade the filesystem
4. Patch Management changes the grub.cfg file, to boot into the up-to-date OS
5. Patch Management reboots the system
6. The system boots and load the GRUB (the boot loader), which loads and boots the kernel
7. Before the kernel mounts the new ROOT ZFS filesystem, the script post_patchmgmt.sh is executed, which rename the ROOT ZFS filesystem, because that cannot/should not be done when it is mounted.
8. The kernel now mounts the new ROOT ZFS filesystem and starts the OS
9. 5 mins into the OS boot process (hopefully went everything there can start is started) the playbook system_update_checker.yml will verify the system.


# The different playbooks
There are 3 playbooks in this project

- **install_linux.yml**  
This playbook setup create ZFS filesystem layout on a disk without partitions and install linux on to it, with the all the packages needed. It also installs the Patch Management onto the system.
- **patchmgmt.yml**  
This playbook handle the updating/upgrating of the OS.
- **system_update_checker.yml**  
This play verify that the update/upgrade of the system was succesful and if it was, cleans the last bits up. If it wasn't a succesful update/upgrade it reboot the system into the previous boot enviroment.

# Tips & Ticks
## Install Ubuntu from Archlinux
Ubuntu still have file in `/bin`, `/sbin` & `/lib` so you need to add this path to the global/export'ed `PATH` variable, before running running the Ansible Playbook.
```
# fish
set --export PATH "$PATH:/bin:/sbin:/lib"

# bash
export "PATH=$PATH:/bin:/sbin:/lib"
```

# TODO
- Added option to set schedule for patchmgmt
- Make the grub menu expose bootable snapshots of the root filesystem with datetime for when they was created
- ArchlinuxARM
  - mkinitcpio needs testing and don't build on aarch64
    - It may need the 'zfs' hook to build when using the zfs-dkms(-any) packages
  - Change there the kernel is installed
    ```
    dennis@ServerPI ~/zfs_maintainer> diff {,/tmp/pre-pare_next_boot}/etc/mkinitcpio.d/linux-aarch64.preset
    9c9
    < default_image="/boot/initramfs-linux.img"
    ---
    > default_image="/kernel/initramfs-linux.img"
    13c13
    < fallback_image="/boot/initramfs-linux-fallback.img"
    ---
    > fallback_image="/kernel/initramfs-linux-fallback.img"
    ```











