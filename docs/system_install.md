# Virtual Machine Setup & Debian Installation

## Overview

## Virtual Machine Setup
- Reference: [Google Cloud — What is a Virtual Machine?](https://cloud.google.com/learn/what-is-a-virtual-machine)

A **Virtual Machine (VM)** is a software-based computer that runs on a physical host machine. It uses virtualization to provide virtual hardware such as CPU, memory, storage and network interfaces, allowing it to run an operating system and applications independently from the host system.

In this project, the VM provides an isolated environment where Debian can be installed, configured and tested without modifying the host machine.

### VirtualBox Installation

*Oracle VirtualBox* is a virtualization software used to create and manage virtual machines.

| Feature | Description |
| ----- | ------|
| Open Source  | - built on an open-source core with great community support |
| Compatibility | - supports a wide range of host and guest operating systems |
| Integration |  - works well with automation tools like Vagrant and Docker |
| Cross-platform | - available for major host operating systems, including macOS, Linux and Windows |


The installation is quite straightforward. Download the appropriate version for the host operating system from the official website and follow the installation steps:

- [Oracle VM VirtualBox - Downloads](https://www.oracle.com/virtualization/technologies/vm/downloads/virtualbox-downloads.html?source=:ow:o:p:nav:mmddyyVirtualBoxHero&intcmp=:ow:o:p:nav:mmddyyVirtualBoxHero)

### Creating the Virtual Machine

**VirtualBox Manager** is the graphical interface used to create, configure and manage virtual machines. It provides access to the VM's hardware settings, storage, network configuration and other options.

Launch **VirtualBox Manager** and click **New** to create a new virtual machine.

| Option | Description |
|---------|-------------|
| **VM Name** | - Name assigned to the virtual machine |
| **VM Folder** | - Location where the VM files are stored |
| **ISO Image** | - [Debian ISO](#debian-iso) used to install the operating system |
| **OS** | - Linux |
| **OS Distribution** | - Debian |
| **OS Version** | - Debian 13 Trixie (64-bit) |
- **Unattended Installation** was not selected, allowing the Debian installation and initial system configuration to be performed manually.

### VM Configuration

Born2beroot is a **server-oriented** project designed to develop system administration skills through the command line. Therefore, the installation of a graphical interface is forbidden, and the system must be managed through the shell.

Since no graphical interface is required, the VM can run with relatively low hardware resources while providing enough capacity for the Debian system and its services. The VM was configured with the following resources:

| Configuration | Value | Purpose |
|---------|---------------|---------|
| **Base Memory** | - 2048 MB used | Provides memory for the Debian system and its services |
| **Processors** | - 2 CPUs | Provides sufficient processing resources for the VM |
| **Disk Format** | - VDI (VirtualBox Disk Image) | Native VirtualBox disk format |
| **Disk Size** | - 30 GB | Provides enough storage for Debian and the Born2beroot bonus services |
- **Pre-allocate Full Size** was not selected, allowing VirtualBox to allocate disk space dynamically as it is needed, up to the configured 30 GB limit.

## Debian Installation

### Debian ISO

The ISO image is used as the installation media to install Debian inside the VirtualBox virtual machine.

- Choose **small installation image** from official [Download Debian page](https://www.debian.org/distrib/).

### Installation
Once the virtual machine is configured, launch it by clicking the Start button. The Debian installer menu will appear in BIOS mode. Select Install to start the installation process.

During the installation, you will be asked to configure the system's **language and time settings, network configuration, and user accounts**.

***Language & Time Configuration***
| Configuration | Value | Description |
|---------|---------------|---------|
| **Language** | *English* | - language used during the installation process and by the installed system |
| **Location** | *Other -> Europe -> Spain* | - defines the geographical location and helps configure the time zone |
| **Locale** | *United States - en_US.UTF-8* | - defines regional settings such as language conventions, number formats, date and time formats, and character encoding |
| **Keyboard** | *American English* | - defines the keyboard layout used to enter characters and commands |
| **Clock** | *Madrid* | - the system clock is configured according to the selected location and time zone |
 - The **Clock** configuration appears after configuring the users and is included here as it belongs to the language and time settings.

***Network Configuration***
| Configuration | Value | Description |
|---------|---------------|---------|
| **Hostname** | iualkhim42 |  - name assigned to the machine on the network |
| **Domain name** | *(empty)* |  - used to define a network domain for the machine. It is not required for this installation. |

***User Configuration***

| Account | Purpose | Configuration |
| ------- | ------- | ------- |
| **Root** | - allows authentication with the highest level of privileges on the system | *password, repeat password* |
| **User** | - regular user account used for everyday tasks | *full name, username, password, repeat password* |


### Partitioning & LVM

#### Partition Disks

**Partitioning** divides the physical disk into separate sections, allowing the available storage to be organized for different purposes.

- **Select `Manual`** from the Debian partitioning method menu.
- Then **choose `(sda)`**, which represents the hard disk of the virtual machine. This creates a new empty partition table where we can define the required storage structure.
- Define a **Boot** partition as **Primary** and one **Logical** partition that will be used for LVM.

```bash
#         (sda)                   (sda)
#   ┌───────┴───────┐       ┌───────┴───────┐
#   │               │       │     Boot      │
#   |    32.2GB     │       |    500MB      │
#   | VBOX HARDDISK |  ->   |_______________|
#   │               │       │               │
#   │  FREE SPACE   │       │     LVM       │
#   │               │       │               │
#   └───────────────┘       └───────────────┘
```

| Partition | Purpose | Type | Mount Point |
| --------- | --------| --------| --------|
| **Boot**  | - contains the files required to start the system, including the bootloader  | Primary | /boot |
| **LVM**   | - provides the space managed by LVM, where the system's Logical Volumes will be created | LVM | - |

- The Boot area is placed at the beginning of the disk as it contains the files required for system startup.

#### Encrypted Volume & LVM

**LVM (Logical Volume Management)** allows the available space to be organized into independent **Logical Volumes**, which can be managed separately and resized when needed.

The remaining space is encrypted before being managed by **LVM**:

- Select **Configure encrypted volumes** to encrypt the space that will be used by LVM.
- Enter a password that will be required to unlock the encrypted volume during system startup.
- Notice: The LVM space is now encrypted. The next step is to create a **Volume Group**, named `LVMGroup`.
- Once the Volume Group is created, we configure the **Logical Volumes** that will be stored inside it:
```bash
#         (sda)                   (sda)
#   ┌───────┴───────┐       ┌───────┴───────┐
#   │               │       │     Boot      │
#   |    32.2GB     │       |     500MB     │
#   | VBOX HARDDISK |  ->   |_______________|
#   │               │       │               │
#   │  FREE SAPACE  │       │      LVM      │
#   │               │       │    (crypt)    │
#   └───────────────┘       └───────────────┘

#          Encrypted Volume
#                 │
#                 ▼
#            ┌───────────┐
#            │ LVMGroup  │
#            └─────┬─────┘
#                  │
#        ┌─────────┼─────────┐
#        ▼         ▼         ▼
#      root       swap      home
#        │         │         │
#        ▼         ▼         ▼
#       /        [SWAP]    /home
```

**Logical Volumes** are independent storage units that can be managed and resized separately.

| Logical Volume | Purpose                                                          | File System | Mount Point |
| -------------- | ---------------------------------------------------------------- | ----------- | ----------- |
| **root**       | - contains the main system files and applications.               | Ext4        | `/`         |
| **swap**       | - provides swap space when additional memory is needed.          | Swap        | `[SWAP]`    |
| **home**       | - stores users' personal files and directories.                  | Ext4        | `/home`     |
| **var**        | - stores variable data generated by the system and applications. | Ext4        | `/var`      |
| **srv**        | - stores data provided by services running on the system.        | Ext4        | `/srv`      |
| **tmp**        | - stores temporary files.                                        | Ext4        | `/tmp`      |
| **var-log**    | - stores system and application logs.                            | Ext4        | `/var/log`  |

- Most of the logical volumes use **Ext4**, a reliable and widely used Linux file system for storing and organizing files and directories. It provides journaling, which helps maintain file system consistency after unexpected shutdowns or system failures.

- The **Swap Area** is used as additional memory space when the available RAM is insufficient. It allows the system to temporarily move less frequently used data from RAM to disk, helping the system continue running when memory usage is high.

### Package Manager & Software Selection

#### Package Manager

The package manager handles the installation, update, and removal of software packages while automatically managing their dependencies. **APT (Advanced Package Tool)** is Debian's default package management system.

- **Select `No`** to skip the **apt** configuration at this stage.

- **Select the appropriate `country` and `deb.debian.org` as the Debian mirror**. The mirror provides the package repository that APT can use to download and update Debian packages.

- Leave the **HTTP proxy** field empty if no proxy is required.
- **Select `No`** for **popularity-contes**t, as it is an optional service that collects anonymous usage statistics about installed packages.

#### Software Selection

The **Software Selection** screen allows you to choose which software groups and desktop environments are installed with Debian.

| Graphical environments     | Services & utilities      |
| -------------------------- | ------------------------- |
| Debian desktop environment | Web server                |
| GNOME                      | SSH server                |
| GNOME Flashback            | Standard system utilities |
| Xfce                       |
| KDE Plasma                 |
| Cinnamon                   |
| MATE                       |
| LXDE                       |
| LXQt                       |

- Install only the **base system**. A graphical interface is **forbidden** for this project, and the required software and services will be installed manually later.


### GRUB Boot Loader

**GRUB (GRand Unified Bootloader)** is a **bootloader program** that runs during system startup and is responsible for loading an operating system. It can also manage a **dual-boot system**, allowing the user to choose between multiple operating systems.

For Debian, GRUB loads the Linux kernel and the files required to continue the boot process from the `/boot` partition.

```Bash
NO DUAL BOOT                                DUAL
BIOS/UEFI → GRUB → Linux kernel → Debian    BIOS/UEFI → GRUB → [ Debian | Windows ]

#  BIOS / UEFI                              BIOS / UEFI
#     │                                         │
#     ▼                                         ▼
#  ┌──────┐                                  ┌──────┐
#  │ GRUB │                                  │ GRUB │
#  └─┬────┘                                  └───┬──┘
#    └──> /boot                                  ▼
#          ├── GRUB files                       ┌───────────────────┐
#          └── Linux kernel ─┐                  │   Boot menu       │
#                            │                  │                   │
#                            ▼                  │   Debian          │
#                      ┌──────────┐             │   Windows         │
#                      │  Debian  │             └─────┬───────┬─────┘
#                      └──────────┘                choose     │
#                                                     │       │
#                                                     ▼       ▼
#                                                ┌────────┐ ┌─────────┐
#                                                │ Debian │ │ Windows │
#                                                └────────┘ └─────────┘
#                                                     │
#                                                     └── Debian:
#                                                          /boot
#                                                            ├── GRUB files
#                                                            └── Linux kernel
```
- **Select `Yes`** to install GRUB boot loader to your primary drive.

- **Choose`/dev/sda (ata_VBOX_HARDDISK)`** as the device for boot loader installation. Notice that this is the virtual hard disk configured earlier for the virtual machine.

- **Complete the installation** by clicking the `Continue` button.

### First Boot

Now you can boot the Debian virtual machine for the first time.

During the startup process, the system will ask for the **encryption password** configured earlier to unlock the encrypted volume.

Once the disk is unlocked, Debian continues the boot process and displays the login prompt.

- **Log in with the regular user account** created during the installation. This is the account used for everyday tasks.

- When administrative privileges are required, **switch to the `root` user** to execute commands with elevated privileges.

| Command   | Purpose |
| --------- | ------- |
| `su root` | Switches to `root` while keeping part of the current user's environment. |
| `su -`    | Switches to `root` and loads the root user's full environment. |

```bash
/home/iualkhim/Documents
          │
          ├── su root ──→ /home/iualkhim/Documents
          │
          └── su - ─────→ /root
```

The system is now ready for the [next configuration steps](/docs/system_config.md) required by the Born2beroot project.


