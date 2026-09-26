# System Configuration

## Overview

### Sudo (Superuser Do)
Allows an authorized user to execute commands with administrative (superuser) privileges. Without logging in directly as the root user.

```bash
$ sudo -V # show sudo version
```
| Installation | Configuration |
| ------------ | --------------|
| `apt install sudo` | `visudo` |

- **cmd: `visudo`**, edit the sudoers file to configure sudo policies and logging. Also validates the syntax before applying the changes, helping prevent syntax errors from breaking the sudo configuration.

```bash
$ visudo
# LOGS config, allows us to keep a record of privileged activity performed through sudo.

Defaults        log_input
Defaults        log_output
Defaults        iolog_dir=/var/log/sudo
Defaults        logfile="/var/log/sudo/sudo.log"
```

#### Sudo vs `su -s` vs `su root`

| Command | Meaning       | Why / When |
| ------- | --------------| ------------|
| `sudo`   | - execute command with administrative privileges | ✅ Preferred for individual administrative commands; activity can be logged |
| `sudo -s`   | - open shell with administrative privileges |⚠️ Use with care, all commands run with elevated privileges, **no logs** |
| `su root`   | - switch to root user | ⚠️ Avoid for normal administration; opens a full root shell, giving every command maximum privileges |

[More Info on GeeksforGeeks...](https://www.geeksforgeeks.org/linux-unix/sudo-command-in-linux-with-examples/)

### Users, Groups & Hostname

```bash
System
  |
  └── Hostname  # $ hostname
        |
        └── iualkhim42
              |
              └── User # $ whoami
                    |
                    └── iualkhim
                          |
                          └── Groups # $ groups iualkhim
                                |
                                └── iualkhim sudo users user42 ...
```

| Hostname | User | Group |
| ------- | --------------| ------------|
| - identifies the machine on the network | - account identifies a person or service on the system | - used to organize users and assign permissions
| `hostnamectl` | `adduser "name"` | `groups "name"` |
| `hostname` | `deluser "name"` | `groupadd "name"`
| `hostnamectl set-hostname "new_name"`| `deluser --remove-home "name"` | `groupdel "name"`|

```bash
$ usermod -aG user42,sudo "name"

# -a: append the groups without removing existing memberships
# -G: specify supplementary groups
# Multiple groups are separated by commas, without spaces
```

#### System files
Linux stores information about users and groups in specific system files:

| File | Info |
|--------------| ------------|
| `cat /etc/passwd` | - contains info about the users configured on the system |
| `cat /etc/group` | - contains info about the groups configured on the system |
| `ls /home` | - shows personal home directories |

### Password Policy

- **cmd: `man -k password | grep config`**, searches the manual pages for information related to password configuration.

| Source| Definition |
| --------------| ------------|
| `/etc/login.defs` | - defines password aging and expiration rule |
| `pwquality` | - applies password complexity and validation rules

#### 1st Layer: Aging

To define default password-aging settings for newly created users edit `nano /etc/login.defs`. Existing users may need `chage` to apply or update their password-aging settings.

| Control | Command |
| --------------| ------------|
| PASS_MAX_DAYS 30 | `chage -M 30 "name"` |
| PASS_MIN_DAYS 2 | `chage -m 2 "name"` |
| PASS_WARN_AGE 7 | `chage -W 7 "name"` |

```bash
$ chage -l iualkhim

Last password change                                    : Sep 08, 2026
Password expires                                        : Oct 08, 2026
Minimum number of days between password change          : 2
Maximum number of days between password change          : 30
Number of days of warning before password expires       : 7
```

#### 2nd Layer: Complexity & Validation Rules

**PAM, pam** - Pluggable Authentication Modules for Linux.

**pam_pwquality** - PAM module to perform password quality checking

```bash
# Execute command with administrative privileges
$ apt update
$ apt install libpam-pwquality
```

1. Check PAM config:
```bash
$ nano /etc/pam.d/common-password

# password   requisite      pam_pwquality.so retry=3
```
2. Add password quality rules:
```bash
$ nano /etc/security/pwquality.conf

# Follow comments to config new password rules
```

3. Apply the rules:
```bash
$ passwd "name"

# Difok: Root vs User
# user → provides old password → difok comparison possible ✓
# root → does not provide old password → difok comparison not possible ✗
```
| root | user |
| --------------| ------------|
| $ `passwd root` | $ `passwd iualkhim` |
| New password: | Current password: |
| Retype new password:  | New password: |
|                        | Retype new password: |

### SSH & Port Forwarding & Usage

#### SSH (Secure Shell)
Allows us to securely connect to and manage system remotely.
To accept SSH connections, the system needs an SSH server:

```bash
$ apt update
$ apt install openssh-server

#            Debian
#       ┌───────┴───────┐
#       │               │
#      ──→ sshd         │
#       |    ssh client ──→
#       │               │
#       └───────────────┘

$ systemctl status ssh
```
- **ssh**  - client used to initiate an SSH connection.
- **sshd** - SSH daemon (server) that listens for and handles incoming SSH connections.

```bash
# SSH Configuration

$ nano /etc/ssh/sshd_config
┌──────────────────┐
| PORT: 4242       | # defines the port used by the SSH server
| PermitRootLog no | # prevents direct SSH login as root
└──────────────────┘
$ sshd -t #checks for errors

# Restart to apply the changes
$ systemctl restart ssh
```

#### Port Forwarding
- **Virtual Box** ─→ **Settings** ─→ **Network** ─→ **Port Forwarding**

| Name  | Host  |  Guest |
| ----- | ------| -------|
| ssh   | 4241  | 4242   |

### Usage
Once configured, we can use SSH services to remotely access and manage the Debian system.

- **cmd: `ssh iualkhim@192.0.2.11 -p 4241`**, connects as iualkhim to the host IP through port 4241, which VirtualBox forwards to port 4242 of the Debian VM.

- **cmd: `scp -P 4241 -r ./docs iualkhim@192.0.2.11:/home/iualkhim/`**, copies the docs folder from the local machine to the SSH server.
