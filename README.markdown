# cyberdudebivash Operating System

## Overview
**cyberdudebivash** is a custom Linux-based operating system built from scratch, designed to provide a modern, user-friendly environment with a focus on performance and customization. It integrates the latest Linux kernel, Bash shell, GNOME desktop environment, Debian-based package management, and XFS filesystem. System utilities are branded as "cyberdudebivash's utilities" to reflect the unique identity of the OS.

- **Version**: 12.2
- **Release Date**: July 2025
- **License**: Open-source (components under respective licenses, e.g., GPL for Linux kernel, MIT for Bash)

## Features
- **Latest Linux Kernel**: Version 6.11.2 for cutting-edge hardware support and performance.
- **Bash Shell**: Version 5.2.37, customized as `cyberdudebivash-bash`.
- **GNOME Desktop**: Version 47, providing a modern and intuitive graphical user interface.
- **Debian Package Management**: Based on Debian "bookworm" for a robust and extensive software ecosystem.
- **XFS Filesystem**: High-performance filesystem optimized for scalability and reliability.
- **Custom Branding**: System utilities (e.g., XFS tools) prefixed with `cyberdudebivash-utils-`.
- **Bootable ISO**: Ready for testing in virtual machines or installation on physical hardware.

## Prerequisites
To build or install cyberdudebivash, you need:
- A Debian-based host system (e.g., Debian 12) with root privileges.
- At least 20 GB of free disk space.
- Internet connection for downloading packages.
- Required tools: `build-essential`, `libncurses-dev`, `xz-utils`, `libssl-dev`, `flex`, `libelf-dev`, `bison`, `debootstrap`, `xfsprogs`, `live-build`, `curl`, `wget`, `gawk`.
- Optional: QEMU for testing or a USB drive for installation.

## Building the OS
The `build-cyberdudebivash.sh` script automates the creation of the cyberdudebivash OS. Follow these steps:

1. **Prepare the Host System**:
   ```bash
   sudo apt update
   sudo apt install -y build-essential libncurses-dev xz-utils libssl-dev flex libelf-dev bison debootstrap xfsprogs live-build curl wget gawk
   ```

2. **Download the Build Script**:
   Save the `build-cyberdudebivash.sh` script provided in the repository or documentation.

3. **Run the Script**:
   ```bash
   chmod +x build-cyberdudebivash.sh
   sudo ./build-cyberdudebivash.sh
   ```

4. **Output**:
   - The script creates a bootable ISO file at `/tmp/cyberdudebivash-iso/cyberdudebivash-12.2.iso`.
   - Build time varies (30-60 minutes) depending on hardware and internet speed.

## Installation
To install cyberdudebivash on a physical machine:
1. **Create a Bootable USB**:
   - Use a tool like `dd` to write the ISO to a USB drive:
     ```bash
     sudo dd if=/tmp/cyberdudebivash-iso/cyberdudebivash-12.2.iso of=/dev/sdX bs=4M status=progress
     ```
     Replace `/dev/sdX` with your USB device (use `lsblk` to identify it).
2. **Boot from USB**:
   - Insert the USB, reboot, and select it from your BIOS/UEFI boot menu.
3. **Install**:
   - Follow the GRUB bootloader prompts to boot into the live system.
   - Use the Debian installer or manually partition and install to a disk with XFS as the root filesystem.

## Testing with QEMU
To test the ISO without installing:
```bash
qemu-system-x86_64 -cdrom /tmp/cyberdudebivash-iso/cyberdudebivash-12.2.iso -m 2G -enable-kvm
```

## Usage
- **Login**: The live system boots into GNOME 47. Default user credentials (if any) are set by the Debian installer.
- **Shell**: Use `cyberdudebivash-bash` (linked as `/bin/bash`) for command-line tasks.
- **Package Management**: Install software using `apt`:
  ```bash
  sudo apt update
  sudo apt install <package>
  ```
- **System Utilities**: XFS tools (e.g., `xfsprogs`) are available as `cyberdudebivash-utils-<tool>` (e.g., `cyberdudebivash-utils-xfs_admin`).
- **Customization**: Modify `/etc/os-release` or GRUB settings in `/etc/default/grub` for further branding.

## Directory Structure
- `/etc/os-release`: Contains OS metadata (e.g., `PRETTY_NAME="cyberdudebivash 12.2"`).
- `/bin/cyberdudebivash-bash`: Custom-branded Bash shell.
- `/usr/sbin/cyberdudebivash-utils-*`: Branded XFS utilities.
- `/boot`: Contains the Linux kernel and initramfs.

## Notes
- **Kernel and Versions**: The build script uses Linux 6.11.2, Bash 5.2.37, and GNOME 47. Update version numbers in the script if newer versions are available.
- **Filesystem**: The root filesystem is XFS. Ensure your hardware supports it.
- **Production Use**: For production, replace the loop device in the script with a physical disk and adjust GRUB installation (`grub-install /dev/sdX`).
- **Customization**: Extend the system by adding more packages or utilities via `apt` or by modifying the build script.

## Troubleshooting
- **Build Errors**: Ensure all dependencies are installed and the host has sufficient disk space.
- **Boot Issues**: Verify the ISO integrity or check GRUB configuration.
- **XFS Issues**: Confirm XFS support in the kernel and proper `xfsprogs` installation.

## Contributing
Contributions are welcome! Submit patches or suggestions via the project repository (if hosted) or contact the maintainer.

## License
cyberdudebivash is built from open-source components under their respective licenses:
- Linux Kernel: GPLv2
- Bash: GPLv3
- GNOME: LGPL/GPL
- Debian packages: Various (check individual packages)
- XFS utilities: GPLv2

## Contact
For support or inquiries, visit:
- **Home**: https://www.cyberdudebivash.com/
- **Support**: https://cyberdudebivash.com/support
- **Bugs**: https:///cyberdudebivash/bugs/contact

*Built with ❤️ for open-source enthusiasts!*  @Author - CYBERDUDEBIVASH iambivash.bn@gmail.com 