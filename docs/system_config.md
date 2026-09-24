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

## 2. Users, Groups & Hostname

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
--------------| ------------|
| `cat /etc/passwd` | - contains info about the users configured on the system |
| `cat /etc/group` | - contains info about the groups configured on the system |
| `ls /home` | - shows personal home directories
