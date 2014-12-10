ArchInstall-script BETA
==================

This is an install-script for Archlinux, created to provide a quick and easy fresh install, please read the **ENTIRE README** file before you do anything at all. I take no responsibility if this script breaks your machine, you use at your own risk! It's still a BETA. So PLEASE don't run this script on a server of yours unless you really know what you are doing, really!

## Prepare ##
The first thing you need to do, before using the script is to edit and match your locale settings, (mirror and locale). By default it is set to Swedish, because that's where I am from.

```shell
arch-chroot /mnt echo "sv_SE.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt echo "sv_SE ISO-8859-1" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "LANG=sv_SE.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt echo "KEYMAP=sv-latin1" > /mnt/etc/vconsole.conf
```

#### Installation ####
To execute an install with this script you can either start it directly inside the boot loader, or you could start it by downloading the script and run it.

* Put the script it on a webserver accessible by your machine. Then add `script=http://www.domain.tld/script.sh` in the bootloader configuration.

* Or you could download the script to your machine and do `chmod +x scriptname.sh` and then execute it with `./scriptname.sh`.

The script will ask you a few questions before it actually executes.

**NOTE:** Do remember to change the password inside the script to something of your own.

#### Default configuration ####

Partiononing | Space Usage | Notes
------------ | ----------- | -----
bootrecord | 1 Mb | 
/boot | 127 Mb | 
Swap | 2 Gb | Used on older machines
* / | Remaining | 

### NOTES ###
It's highly recommended to make a test run on a virtual machine **before** you execute this script on a live machine. The default script behaviour is set to using the entire disk.