ArchInstall-script BETA
==================

This is an install-script for Archlinux, created to provide a quick and easy fresh install, please read the **ENTIRE README** file before you do anything at all. I take no responsibility if this script breaks your machine, you use at your own risk! It's still a BETA. So PLEASE don't run this script on a server of yours unless you really know what you are doing, really!

## GPL3 ##

	Copyright (C) 2014 Ulf Hagström & Kristoffer Tångfelt

    This script is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This script is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>


## Prepare ##
The first thing you need to do, before using the script is to edit and match your locale settings, (mirror and locale). By default it is set to Swedish, because that's where I am from.

```shell
arch-chroot /mnt echo "sv_SE.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt echo "sv_SE ISO-8859-1" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "LANG=sv_SE.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt echo "KEYMAP=sv-latin1" > /mnt/etc/vconsole.conf
```

## Installation ##

**NOTE:** Now you will get one question to install or not, then it goes thru the installation, Nothing vill be left on the /dev/sda disk

To execute an install with this script you can either start it directly inside the boot loader, or you could start it by downloading the script and run it.

* Put the script it on a webserver accessible by your machine. Then add `script=http://www.domain.tld/script.sh` in the bootloader configuration.

* Or you could download the script to your machine and do `chmod +x scriptname.sh` and then execute it with `./scriptname.sh`.

The script will ask you a few questions before it actually executes.

**NOTE:** Do remember to change the password inside the script to something of your own.

### Default configuration ###

Partiononing | Space Usage | Notes
------------ | ----------- | -----
bootrecord | 1 Mb | 
/boot | 127 Mb | 
Swap | 2 Gb | Not optional
* / | Remaining | 

### Packages installed ###

* yaourt _useful tool_ [More info about Yaourt](https://aur.archlinux.org/packages/yaourt/)
* package-query
* customizepkg
* base
* grub
* dialog
* openssh _also started after installation_

~~When you get the question: _Do you want to install XFCE?_ you ar not forced to do so, it is optional. If you do choose to installl XFCE, the following additional packages will also be installed:~~

* xorg
* xfce4
* xfce4-goodies
* lightdm-gtk2-greeter

~~If you've selected to install XFCE you will get another question: _Do you whant to enable lightdm?_ It's the Light Desktop Manager, without it you only get the console.~~

### Notes ###
It's highly recommended to make a test run on a virtual machine **before** you execute this script on a live machine. The default script behaviour is set to using the entire disk.

### Bugs ###
If you find an issue, let us know [here](https://github.com/toocer/ArchInstall-script/issues)!

### Contributions ###
Anyone is welcome to contribute to the ArchInstall script. There are various ways you can contribute:

1. Raise an [Issue](https://github.com/toocer/ArchInstall-script/issues) on GitHub
2. Send us a pull request with your bug fixes and/or new features

### Special Thanks ###

Special thanks to Kristoffer Tångfelt [Visit him here](https://dynamict.se)  
In one of his blogpost a early version that he created was run this is a fork of that script
