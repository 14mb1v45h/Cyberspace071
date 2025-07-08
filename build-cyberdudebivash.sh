#!/bin/bash
# Script to build cyberdudebivash OS with Linux kernel, Bash, GNOME, Debian packages, and XFS filesystem
# Run as root on a Debian-based host system (e.g., Debian 12)

set -e

# Configuration variables
LFS=/mnt/lfs
VERSION=12.2
KERNEL_VERSION=6.11.2
BASH_VERSION=5.2.37
GNOME_VERSION=47
OS_NAME="cyberdudebivash"
UTIL_PREFIX="cyberdudebivash-utils"

# Step 1: Prepare the build environment
echo "Preparing build environment..."
apt update
apt install -y build-essential libncurses-dev xz-utils libssl-dev flex libelf-dev bison \
    debootstrap xfsprogs live-build curl wget gawk

mkdir -p $LFS
mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -v -t proc proc $LFS/proc
mount -v -t sysfs sysfs $LFS/sys
mount -v -t tmpfs tmpfs $LFS/run

# Step 2: Set up XFS filesystem on a loop device for testing
echo "Setting up XFS filesystem..."
dd if=/dev/zero of=/tmp/cyberdudebivash.img bs=1M count=10000
losetup /dev/loop0 /tmp/cyberdudebivash.img
mkfs.xfs -f /dev/loop0
mkdir -p $LFS
mount /dev/loop0 $LFS

# Step 3: Bootstrap Debian base system
echo "Bootstrapping Debian base system..."
debootstrap --arch=amd64 bookworm $LFS http://deb.debian.org/debian

# Step 4: Chroot into the new system
echo "Entering chroot environment..."
cat << EOF > $LFS/build.sh
#!/bin/bash
set -e

# Update package sources
echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security bookworm-security main" >> /etc/apt/sources.list
apt update
apt upgrade -y

# Install latest Linux kernel
apt install -y linux-source-$KERNEL_VERSION linux-image-$KERNEL_VERSION
tar -xf /usr/src/linux-source-$KERNEL_VERSION.tar.xz -C /usr/src
cd /usr/src/linux-source-$KERNEL_VERSION
cp /boot/config-$(uname -r) .config
make -j$(nproc) bindeb-pkg
dpkg -i ../linux-image-$KERNEL_VERSION*.deb ../linux-headers-$KERNEL_VERSION*.deb

# Install latest Bash
wget https://ftp.gnu.org/gnu/bash/bash-$BASH_VERSION.tar.gz
tar -xf bash-$BASH_VERSION.tar.gz
cd bash-$BASH_VERSION
./configure --prefix=/usr --sysconfdir=/etc
make -j$(nproc)
make install
mv /bin/bash /bin/$OS_NAME-bash
ln -s /bin/$OS_NAME-bash /bin/bash

# Install GNOME desktop environment
apt install -y task-gnome-desktop
systemctl set-default graphical.target

# Install XFS utilities and brand them
apt install -y xfsprogs
for util in /usr/sbin/xfs_*; do
    base=\$(basename \$util)
    mv \$util /usr/sbin/$UTIL_PREFIX-\$base
    ln -s /usr/sbin/$UTIL_PREFIX-\$base /usr/sbin/\$base
done

# Configure GRUB bootloader
apt install -y grub-pc
echo "GRUB_DISTRIBUTOR=$OS_NAME" >> /etc/default/grub
grub-install /dev/loop0
update-grub

# Create custom OS branding
echo "$OS_NAME" > /etc/hostname
echo "Welcome to $OS_NAME" > /etc/issue
cat << EOM > /etc/os-release
PRETTY_NAME="$OS_NAME $VERSION"
NAME="$OS_NAME"
VERSION_ID="$VERSION"
VERSION="$VERSION"
ID=$OS_NAME
ID_LIKE=debian
HOME_URL="https://example.com/$OS_NAME"
SUPPORT_URL="https://example.com/$OS_NAME/support"
BUG_REPORT_URL="https://example.com/$OS_NAME/bugs"
EOM

# Clean up
apt clean
rm -rf /usr/src/* /tmp/*
EOF

chmod +x $LFS/build.sh
chroot $LFS /build.sh

# Step 5: Create initramfs and configure fstab
echo "Configuring initramfs and fstab..."
chroot $LFS update-initramfs -c -k $KERNEL_VERSION
cat << EOF > $LFS/etc/fstab
# /etc/fstab: static file system information.
UUID=$(blkid -s UUID -o value /dev/loop0) / xfs defaults 0 1
proc /proc proc defaults 0 0
sysfs /sys sysfs defaults 0 0
devpts /dev/pts devpts gid=5,mode=620 0 0
tmpfs /run tmpfs defaults 0 0
EOF

# Step 6: Create a bootable ISO
echo "Creating bootable ISO..."
mkdir -p /tmp/cyberdudebivash-iso
cd /tmp/cyberdudebivash-iso
lb config -d bookworm --architectures amd64 --linux-packages linux-image-$KERNEL_VERSION \
    --bootloader grub-pc --archive-areas "main contrib non-free"
cp -r $LFS/* chroot/
lb build
mv live-image-amd64.hybrid.iso $OS_NAME-$VERSION.iso

# Step 7: Clean up
echo "Cleaning up..."
umount $LFS/dev/pts $LFS/dev $LFS/proc $LFS/sys $LFS/run
umount $LFS
losetup -d /dev/loop0

echo "Build complete! ISO image created at /tmp/cyberdudebivash-iso/$OS_NAME-$VERSION.iso"