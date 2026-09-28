# Monitoring Script & Cron Job

## Overview
A bash script that runs on a schedule (via cron) and broadcasts a summary of
the machine's current state to every open session (via `wall`). The goal is
a fast, at-a-glance health check — not deep diagnostics — covering 5 areas:

| Area | What it answers |
|------|------------------|
| [**System**](#system) | What am I running on? (architecture, physical CPU / vCPU, last boot) |
| [**Resource Usage**](#resource-usage) | How loaded is it right now? (CPU load, RAM, disk) |
| [**Storage**](#storage) | How is space actually allocated? (LVM usage) |
| [**Users & Sessions**](#users--sessions) | Who's on the machine, and what have they done? (logged-in users, sudo history) |
| [**Network**](#network) | How is it reachable? (IP, MAC, TCP connections) |


## Command Reference

| Command  | Main purpose                                            |
| -------- | ------------------------------------------------------- |
| `uname -a`  | Display system/kernel/architecture info.             |
| `lscpu`  | Display CPU architecture and configuration              |
| `vmstat` | Display overall system performance statistics           |
| `free`   | Display RAM and swap memory usage                       |
| `df`     | Display filesystem disk space usage                     |
| `who`    | Show logged in users                                    |
| `lsblk`  | List block devices (used here to detect LVM)            |
| `ss -ta` | List active TCP sockets/connections.                    |
| `w`      | Show who is logged on and what they are doing           |
| `ip route` / `ip link` |  Show routing table / interface + MAC info|
| `journalctl`  | Query systemd logs                                 |


### **Extra command worth knowing** (not used in this script):

| Command | Main purpose                                            |
| ------- | --------------------------------------------------------|
| `top`   | Monitor processes and their resource usage in real time |

## Cron Job

The **cron** program allows you to run scripts/commands automatically according to defined schedule.

- **cmd: `crontab -e`** — set up cron job (edit as root to run the job with root privileges).

```bash
# Config
@reboot           /path/to/script.sh   # runs once when the system boots

*/10 * * * *  /path/to/script.sh # runs every 10 minutes after that
│ │ │ │ │
│ │ │ │ └── day of week (0-6, Sun-Sat)
│ │ │ └──── month (1-12)
│ │ └────── day of month (1-31)
│ └──────── hour (0-23)
└────────── minute (0-59)
```

## Diving Deeper into Concepts and Commands

### **System**

#### OS & Kernel Info

- **cmd: `uname -a`**, shows us all operating system information, the most important are:

| Kernel name (`-s`) | Hostname (`-n`) | Kernel release (`-r`) | Machine (`-m`) | Operating system (`-o`) |
| --------- | --------- | --------- | --------- |  --------- |
| Linux     | iualkhim42    | ...deb13-amd64 | x86_64 | GNU/Linux |


#### Architecture

The **instruction set architecture (ISA)** determines what machine code the CPU understands, and whether binaries built for one architecture can run on another.

| **x86** | **x86_64 / amd64** |  **arm64** |
| --------- | --------- |  --------- |
| - Original 32-bit instruction-set architecture associated with Intel/AMD. | - 64-bit extension of x86. | - 64-bit ARM architecture, based on the RISC design philosophy. |
| - Commonly refers to the 32-bit version of the x86 family. | - x86_64 and amd64 refer to essentially the same architecture. |  - Used in phones, many Raspberry Pis, and Apple Silicon. |
| - The older standard before widespread 64-bit computing.| - AMD designed the 64-bit extension first; Intel later adopted it — hence amd64. | - Not binary-compatible with x86_64 in general; x86_64 programs need recompilation or a compatibility/translation layer. |

#### 32-bit vs 64-bit

The CPU architecture affects how much memory it can address and how much data it processes per cycle.

| **32-bit:** | **64-bit:**|
| --------- | --------- |
| - The processor handles data and memory addresses in 32-bit chunks.| - The processor can work with 64-bit values and addresses. |
| - Can address a maximum of **4GB of RAM** (2^32 addresses). | - Can address a much larger amount of RAM (theoretically 16 exabytes, 2^64). |
| - Uses smaller CPU registers for general-purpose operations. | - Larger CPU registers → more data processed per cycle → better performance. |
| | - The current standard across almost all systems (PCs, servers, mobile devices). |

#### Processor (CPU)

The **CPU (Central Processing Unit)** is the component that executes instructions — the actual "brain" doing the work described by the architecture above.

- **cmd: `lscpu`**, shows cpu architecture

| **`lscpu`** field | Meaning |
| --------- | --------- |
| Architecture | CPU architecture seen by machine  |
| Socket(s) | Number of CPU sockets presented  |
| CPU(s) | Number of logical CPUs/vCPUs available |

#### CPU Types: Physical vs Logical
```bash
# Physical Socket vs Virtual CPU (lscpu)

Socket(s): 1                  ← physical CPU slot(s) presented
    │
    └── Core(s) per socket: 1
            │
            └── Thread(s) per core: 1
                    │
                    └── CPU(s): 1   ← total logical CPUs
```
```bash
# Note:
Since the system runs inside a virtual machine, the CPU resources are presented to Debian as virtual hardware. lscpu allows us to see the CPU configuration available to the VM.
```

### **Resource Usage**

#### CPU Load Info

- **cmd: `vmstat`** (Virtual Memory Statistics), reports information about  **cpu activity**, memory, and processes.

```bash
$ vmstat 1 2 # took 2 samples in 1 sec

--------cpu--------
 us sy id wa st gu
 1  1 99  0  0  0
 0  4 96  0  0  0

# All fields are % of CPU time:
us: Time spent running non-kernel code.
sy: Time spent running kernel code.
id: Time spent idle (not active, not in use).
...
```

#### Memory (RAM)

- **cmd: `free -h`**, displays memory usage statistics (human readable)

```bash
$ free --mega -h

               total        used        free      shared  buff/cache   available
Mem:            2.1G        870M        582M        3.3M        788M        1.2G
Swap:           2.3G          0B        2.3G
```

#### **Extra command worth knowing** (not used in this script):
```bash
$ ps aux --sort=-%mem | head

# lists the processes using the most memory, sorted by memory usage.
```

#### Memory (Disk Usage)

- **cmd: `df -h`**, report file system space usage.

| **Filesystem** | **Size**| **Used** |  **Avail** |  **Use%** | **Mounted on** |
| --------- | --------- | --------- | --------- | --------- | --------- |
| /dev/mapper/LVMGroup-home | 4.6G | 1.3M | 4.3G | 1% | /home |
| ... |
---

```bash
# Note:

- `df` reports file system usage, while
`lsblk` shows block devices and their partitions.
- `df` also provides the `--total` option to get the combined usage.
```

### **Storage**

A **LVM (Logical Volume Manager)** creates virtual block devices ("Logical Volumes") on top of physical ones, allowing dynamic resizing/allocation of storage across filesystems, instead of being locked into fixed physical partitions.

- **cmd: `lsblk`** — lists block devices in a tree-like format. The indentation shows the
  parent-child hierarchy (disk → partition → encrypted volume → logical
  volumes), while the **TYPE** column labels what each one is.

```bash
$ lsblk

NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                         8:0    0   30G  0 disk              # (physical disk)
|-sda1                      8:1    0  476M  0 part  /boot       # (partition)
|-sda2                      8:2    0    1K  0 part
`-sda5                      8:5    0 29.5G  0 part
  `-sda5_crypt            254:0    0 29.5G  0 crypt             # (encrypted volume)
    |-LVMGroup-root       254:1    0  9.3G  0 lvm   /           # (logical volume)
    |-LVMGroup-swap       254:2    0  2.1G  0 lvm   [SWAP]
    |-LVMGroup-home       254:3    0  4.7G  0 lvm   /home
    `.....................................................
sr0                        11:0    1 1024M  1 rom               # virtual CD/DVD drive
```

### **Users & Sessions**

#### Logged Users & Activity
- **cmd: `who`**, prints information about users who are currently logged in.
The output generally includes the following information:
**User** | **Terminal** | **Date/Time** | **Remote host**

```bash
$ who

iualkhim sshd pts/0   Sep 20 09:18 (192.0.2.10)
```

- **cmd: `w`**, adds a bit more detail (what each user is doing, system load).

```bash
$ w

  18:07:24 up 19 min,  2 users,  load average: 0.01, 0.09, 0.07
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU  WHAT
iualkhim tty1     -                17:54   13:15   0.03s  0.03s -bash
iualkhim pts/0    192.0.2.10       17:51    4.00s  0.06s   ?    w
```

#### Sudo Logs Info

A **Systemd-journald** is a system service that collects and stores logging data in the **systemd journal**. The journal contains structured log entries generated by system services and applications.

- **cmd: `journalctl`**, prints log entries from the **systemd journal**. `_COMM=sudo `filters it by the sudo process. A single sudo execution can generate multiple journal entries, such as opening and closing a session, so the script adds `grep COMMAND` on top to count only the actual command executions.

```bash
$ journalctl _COMM=sudo | grep COMMAND

Sep 22 10:15:03 iualkhim sudo[1234]: iualkhim : TTY=pts/0 ; PWD=/home/iualkhim ; USER=root ; COMMAND=/usr/bin/apt update
```

### **Network**

#### TCP Connections
**Transmission Control Protocol (TCP)** is a network protocol that provides reliable and ordered communication between devices.

- **cmd: `ss`**, displays information about network sockets and active connections.

```bash
# TCP Connection

Client                              Server
192.0.2.10:4242                  192.0.2.11:4242
      │                                 │
      └────────── TCP connection ───────┘
                       │
                  ESTABLISHED

```

#### IP address and MAC

An **IP address** identifies a network interface within a network and lets devices communicate.

A **MAC address (Media Access Control address)** is a unique identifier assigned to a network interface (e.g. Ethernet or Wi-Fi).

- **cmd: `ip route`**, displays the routing table, showing how network traffic is routed to different destinations.
- **cmd: `ip link`**, displays and manages network interfaces and their link-layer information, including their MAC addresses.

```bash
# Example of IP addresses in local network and port forwarding through VirtualBox

                   Router
                 192.168.1.1
                      │
        ┌─────────────┴─────────────┐
        │                           │
     Mac M3                     Mac Intel
  192.0.2.10                   192.0.2.11
                                    │
                                VirtualBox
                                    │
                               NAT network
                                    │
                   ┌────────────────┴────────────────┐
                   │                                 │
               Debian VM                         Kali VM
               10.0.2.15                         10.0.2.16
                   :22                               :22
                   ▲                                 ▲
                   │                                 │
         host :4242 → :22                 host :2222 → :22
```
```bash
# IP vs MAC

Network interface
       │
       ├── MAC → normally stays the same
       │
       └── IP → changes depending on the network
```










