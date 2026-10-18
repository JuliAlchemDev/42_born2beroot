*This project has been created as part of the 42 curriculum by iualkhim*

<p align="center">
  <img src="./docs/srcs/born2beroot.png" alt="born2beroot 42 project badge" width="150"/>
</p>

## Description

The main goal of the **Born2beroot** project
is to create and configure a **Linux** environment inside a virtual machine.

The system is build from scratch to explore the fundamentals of **system administration**, **security** and **server management**.

The main topics covered are ***users and groups, permissions, `sudo`, SSH, password policies, disk partitioning, encrypted volumes, LVM, firewall configuration and system monitoring***.

The bonus part includes the following additional services:

- **WordPress** — Lighttpd, PHP and MariaDB.
- **Docker** — containerization.
- **n8n** — self-hosted workflow automation.

### Project Description

#### *Virtualization: VirtualBox vs UTM*

| | VirtualBox | UTM |
|---|---|---|
| **Strengths** | - Multiplatform (Windows, Linux, macOS Intel)<br> - Well-established, with extensive documentation and community support <br> - More networking modes<br> - Snapshots<br> - Great on Intel/AMD | - Apple's native virtualization<br> - Built for Apple Silicon (fast ARM guests)<br> - Lightweight |
| **Weaknesses** | - Limited performance on Apple Silicon (M1–M4)<br> - Heavier on resources | - macOS only<br> - Lacks some advanced features |

#### -> *Selected: VirtualBox*

- standard tool at 42.
- runs well on my Intel/AMD machine.
- plenty of documentation that helped me with the configuration.

#### *System: Debian vs Rocky Linux*

| | **Debian** | **Rocky Linux** |
|---|---|---|
|***Philosophy*** | Community-driven, independent | Enterprise-oriented |
| ***Docs & community*** | Extensive documentation, large community | Smaller community, fewer guides |
| ***Learning curve*** | Beginner-friendly | Steeper |
| ***Packages*** | Huge repository (`apt`) | Fewer packages in default repos |
| ***Security (MAC)*** | **AppArmor**:<br> + enabled by default<br> + simple, human-readable profiles<br> + easy to learn and maintain<br> - confines individual applications only | **SELinux**:<br> + enabled by default<br> + controls the whole system (users, files, processes, ports)<br> + very fine-grained control<br> - complex configuration<br> - harder to debug |
| ***Firewall*** | **UFW**:<br> + simple syntax<br> + ideal for a single server with few rules<br> - not installed by default<br> - less flexible | **firewalld**:<br> + default in Rocky Linux<br> + zones: different rules per network<br> - more complex |

#### -> *Selected: Debian (with AppArmor and UFW)*

- beginner-friendly and has extensive documentation.
- its huge package repository covers the bonus services (WordPress, Docker, n8n).
- AppArmor and UFW come with Debian's ecosystem and are simple enough to configure for a single server.

The repository contains the configuration scripts used during the project and documentation covering the system configuration, the purpose of its components and the concepts behind them.

| Documentation| Description |
| ----- | ------|
|[System Installation](./docs/system_install.md)| - virtual machine setup and Debian installation |
|[System Configuration](./docs/system_config.md)| - users, groups, sudo, SSH, password policy and firewall |
|[Monitoring](./docs/monitoring.md)| - system [monitoring script](./monitoring.sh)  and cron configuration |
|[WordPress](./docs/wordpress.md)| - WordPress setup with Lighttpd, PHP and MariaDB |
|[n8n](./docs/n8n.md)| - Docker and n8n setup and configuration |

## Instructions
## Resources
