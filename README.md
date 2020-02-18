[TOC]

# Intro
**Request:** Suggestion for a better name for this project is welcome :D  
The goal of this project was to have a way to easily rollback a bad update, and not have the update interfere with the rest of the system while installing the update.  
Inspired by what I have heard about boot envirement on ZFS from BSD (and because I like ZFS), I created a way to install the update/upgrade of the distro into a clone of the ROOT mounted filesystem, and when boot into the clone filesystem and use it as the new root filesystem.

# How does it work?
There are 3 playbooks in this project

- install_linux.yml (The biggest one)  
This playbook setup create filesystem layout on a disk without partitions and install linux on to it, with the all the packages needed. It also install the Patch Management onto the system.
- patchmgmt.yml (for install the update/upgrade)
- system_update_checker.yml (verifies the update/upgrade)


## TODO
- Added self installing
  - Added scheduled patchmgmt
