#!/bin/bash

#DISK="$@"
DISK="/dev/sda"

function do_stage_1 {
  echo "Running Stage 1"

  if [ ! -x "/sbin/parted" ]; then
    echo "This script requires /sbin/parted to run!" >&2
    exit 1
  fi

  #while true; do
  #    read -p "Warning! This will partition and format any unformatted storage volumes! Are you sure? " yn
  #    case $yn in
  #        [Yy]* ) break;;
  #        [Nn]* ) exit;;
  #        * ) echo "Please answer yes or no.";;
  #    esac
  #done

  ## Begins of auto-parted part and format

  parted -a optimal --script ${DISK} -- mktable gpt
  parted -a none --script ${DISK} -- mkpart none 0 1MB
  parted -a optimal --script ${DISK} -- mkpart ext2 1MB 128MB
  parted -a optimal --script ${DISK} -- mkpart ext2 128MB 2174MB
  parted -a optimal --script ${DISK} -- mkpart ext2 2174MB 100%
  parted -a optimal --script ${DISK} -- set 1 bios_grub on

  mkfs.ext4 ${DISK}2
  mkfs.ext4 ${DISK}4
  mkswap ${DISK}3
  swapon ${DISK}3

  #expect ${DISK}1 to be GRUB-GPT-BIOS COMPAT
  #	${DISK}2 to be /boot
  #	${DISK}3 to be /

  ##################################################################
  # Stage 1, bootstrap partitions/filesystems and OS Base packages #
  ##################################################################
  # Mount /
  mount ${DISK}4 /mnt

  # Make /boot mountpoint
  mkdir /mnt/boot

  # Mount /boot on previously made mountpoint
  mount ${DISK}2 /mnt/boot

  # Replace mirrorlist with known fast and good Swedish mirror
  echo 'Server = http://ftp.portlane.com/pub/os/linux/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

  #echo '[xyne-any]' >> /etc/pacman.conf
  #echo 'SigLevel = Required' >> /etc/pacman.conf
  #echo 'Server = http://xyne.archlinux.ca/repos/xyne' >> /etc/pacman.conf

  #pacman -Sy --noconfirm pacserve
  #systemctl start pacserve.service
  #pacman.conf-insert_pacserve > /tmp/pacman.conf
  #cp /tmp/pacman.conf /etc/pacman.conf

  # Bootstrap the Base OS packages (and grub)
  pacstrap /mnt base grub dialog openssh

  cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

  # Sync FS for consistency
  sync

}
############################################
function do_stage_2 {
  echo "Running Stage 2"

  ########################################################
  # Stage 2, Chroot, Bootloader, Base Config, Mkinitcpio #
  ########################################################

  # Configure and embed installed GRUB from pacstrap stage
  arch-chroot /mnt grub-install --target=i386-pc ${DISK}
  arch-chroot /mnt grub-mkconfig > /mnt/boot/grub/grub.cfg
  # Generate appropriate fstab entries
  genfstab -U /mnt >> /mnt/etc/fstab

  # Configure Swedish Locale, language and keymaps
  arch-chroot /mnt echo "sv_SE.UTF-8 UTF-8" >> /mnt/etc/locale.gen
  arch-chroot /mnt echo "sv_SE ISO-8859-1" >> /mnt/etc/locale.gen
  arch-chroot /mnt locale-gen
  arch-chroot /mnt echo "LANG=sv_SE.UTF-8" > /mnt/etc/locale.conf
  arch-chroot /mnt echo "KEYMAP=sv-latin1" > /mnt/etc/vconsole.conf

  # Enable SSHD and DHCP-Client for remote access
  arch-chroot /mnt systemctl enable sshd
  arch-chroot /mnt systemctl enable dhcpcd


  # Set dumb easy PW for easy remote config
  #arch-chroot /mnt passwd root hackthis123

  echo "root:hackthis123" | arch-chroot /mnt/ chpasswd root

}
function do_stage_3 {
  echo "Running Stage 3"


  # Install yaourt and dependecis
  # Now only downloading not finished

  cat <<EOF > /mnt/root/dostage3stuff.sh
  #!/bin/bash
  pacman -S wget base-devel --noconfirm
  wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz -O /root/yaourt.tar.gz
  wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz -O /root/package-query.tar.gz
  wget https://aur.archlinux.org/packages/cu/customizepkg/customizepkg.tar.gz -O /root/customizepkg.tar.gz
  tar -zxf /root/yaourt.tar.gz -C /root
  tar -zxf /root/customizepkg.tar.gz -C /root
  tar -zxf /root/package-query.tar.gz -C /root
  cd /root/package-query && makepkg -si --asroot --noconfirm
  cd /root/customizepkg && makepkg -si --asroot --noconfirm
  cd /root/yaourt && makepkg -si --asroot --noconfirm
  EOF
  chmod +x /mnt/root/dostage3stuff.sh
  arch-chroot /mnt /root/dostage3stuff.sh



}
function do_stage_4 {
  echo "Running stage 4, Installing XFCE"

  cat <<EOF > /mnt/root/dostage4stuff.sh
  #!/bin/bash

  yaourt -S xorg xfce4 xfce4-goodies lightdm-gtk2-greeter --noconfirm

  EOF



  # If you whant to skip XFCE comment this out
  #
  #
  while true; do
    read -p "Do you whant to install XFCE? " yn
    case $yn in
      [Yy]* ) arch-chroot /mnt sh /root/dostage4stuff.sh; break;;
      [Nn]* ) do_stage_5; exit;;
      * ) echo "Please answer yes or no.";;
    esac

  done

  #
  # End of XFCE YN part
  #
  # If you whant to install XFCE without question remove comments from the next line
  # arch-chroot /mnt sh /root/dostage4stuff.sh


  while true; do
    read -p "Do you whant to enable lightdm ? " yn
    case $yn in
      [Yy]* ) arch-chroot /mnt systemctl enable lightdm; break;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no."
    esac
  done
  # If you whant to enable lightdm at boot uncomment next line
  # arch-chroot /mnt sh /root/dostage4stuff1.sh
}

function do_stage_5 {
  echo "Running stage 5, Final stage"
  # Clear screen
  clear
  # Print out this text
  echo "The system will reboot in 10 seconds then it will boot in your new archlinux installation."
  # Pause for 10 second
  sleep 10
  # clean up /root
  rm /mnt/root/* -rf
  # Sync before reboot
  sync
  # reboot into installed system
  reboot


}

do_stage_1
do_stage_2
do_stage_3
do_stage_4
do_stage_5

# TODO: Rebuild script for question in the beginning then automate everything.
