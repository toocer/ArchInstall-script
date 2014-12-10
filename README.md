ArchInstall-script BETA
==================

Install script for archlinux to provide easy install, Please Read README before you do anything.

First Edit the file to match your locale settings. (Mirror and locale)

The install is best tested on a virtual machine before you try this on a live machine, the default is for the script is to
use the entire disk.

To install with script you can either start it in the boot loader or start it by downloading the script and run it.

put it on a webserver

add script=http://adress.to/script.sh in the bootloader

or download the script to the machine and do "chmod +x scriptname.sh"
then runt it with "./scriptname.sh"

and PLEASE don´t run it on a machine you are not willing to lose data, this is only a BETA script.

NOTE: Remember to change the password to something of your own.

The configuration is following

Partiononing
* 1MB Bootrecord  
* /boot = 127mb  
* Swap  = 2gb  
* /     = The rest

The installations is with some questions to make your choices.
