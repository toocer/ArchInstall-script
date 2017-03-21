#!/bin/bash

#DISK="$@"
DISK="/dev/sda"

if [ ! -x "/sbin/parted" ]; then
  echo "This script requires /sbin/parted to run!" >&2
  exit 1
fi

while true; do
    read -p "Warning! This will partition and format '${DISK}' Are you sure? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

function partioning {

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
  ##################################################################
  # expect ${DISK}1 to be GRUB-GPT-BIOS COMPAT
  #	${DISK}2 to be /boot
  #	${DISK}4 to be /
  # ${DISK}3 to be SWAP
  ##################################################################

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
  # Change this to mirror close to you.
  echo 'Server = http://ftp.portlane.com/pub/os/linux/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist


 sleep 10

 install_arch_basic

}

function install_arch_basic {
  # Replace mirrorlist with known fast and good Swedish mirror
  # Change this to mirror close to you.
  echo 'Server = http://ftp.portlane.com/pub/os/linux/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

  # Bootstrap the Base OS packages (and grub)
  pacstrap /mnt base grub dialog openssh

  cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

  # Sync FS for consistency
  sync

  install_yaourt

}

function install_yaourt {
cat <<EOF > /mnt/root/InstallYaourt.sh
#!/bin/bash
pacman -S wget base-devel --noconfirm
useradd -m tempo
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers
usermod -a -G wheel tempo
cd /home/tempo
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz -O /home/tempo/yaourt.tar.gz
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz -O /home/tempo/package-query.tar.gz
wget https://aur.archlinux.org/cgit/aur.git/snapshot/customizepkg-git.tar.gz -O /home/tempo/customizepkg.tar.gz
tar -zxf /home/tempo/yaourt.tar.gz -C /home/tempo
tar -zxf /home/tempo/customizepkg.tar.gz -C /home/tempo
tar -zxf /home/tempo/package-query.tar.gz -C /home/tempo
chmod -R 777 /home/tempo
su - tempo -c "cd /home/tempo/package-query && makepkg -si --noconfirm"
su - tempo -c "cd /home/tempo/customizepkg && makepkg -si --noconfirm"
su - tempo -c "cd /home/tempo/yaourt && makepkg -si --noconfirm"
userdel -r tempo
EOF

chmod +x /mnt/root/InstallYaourt.sh
arch-chroot /mnt /root/InstallYaourt.sh


finishing
}


function finishing {
  echo "root:hackthis123" | arch-chroot /mnt/ chpasswd root

  # Configure and embed installed GRUB from pacstrap stage
  arch-chroot /mnt grub-install --target=i386-pc ${DISK}
  arch-chroot /mnt grub-mkconfig > /mnt/boot/grub/grub.cfg
  # Generate appropriate fstab entries
  genfstab -U /mnt >> /mnt/etc/fstab

  # Configure Swedish Locale, language and keymaps
  # Change this to your LANG
  arch-chroot /mnt echo "sv_SE.UTF-8 UTF-8" >> /mnt/etc/locale.gen
  arch-chroot /mnt echo "sv_SE ISO-8859-1" >> /mnt/etc/locale.gen
  arch-chroot /mnt locale-gen
  arch-chroot /mnt echo "LANG=sv_SE.UTF-8" > /mnt/etc/locale.conf
  arch-chroot /mnt echo "KEYMAP=sv-latin1" > /mnt/etc/vconsole.conf

  # Enable SSHD and DHCP-Client for remote access
  arch-chroot /mnt systemctl enable sshd
  arch-chroot /mnt systemctl enable dhcpcd

 sync

}

partioning
