# WordPress Server Configuration

## Overview

**WordPress** is a content management system (CMS) used to create and manage websites. It is built mainly with PHP and uses a database to store website content, configuration, and user information.

Instead of using a hosted WordPress service, this bonus sets up WordPress on our own Debian server. This allows us to understand how the different components work together and how a web application is served, executed, and connected to a database.

The WordPress server configuration focuses on setting up the complete environment required to run WordPress. It covers 4 main components:

| Component                   | What it does                                      |
| --------------------------- | ------------------------------------------------- |
| [**Lighttpd**](#lighttpd)   | Serves web pages and handles HTTP requests        |
| [**PHP**](#php)             | Executes WordPress application code               |
| [**MariaDB**](#mariadb)     | Stores WordPress data                             |
| [**WordPress**](#wordpress) | Provides the website and administration interface |

### Lighttpd

The web server designed to be fast, secure, flexible, and standards-compliant. It is optimized for
environments where speed is a top priority because it consumes less CPU and RAM than other servers.

| Installation| Configuration |
| --------------| ------------|
| `apt update` | - Add HTTP (80/tcp) to the VirtualBox port forwarding rules |
| `apt install lighttpd` | `ufw allow http`|
| | `ufw status` |

#### Test Server
Open http://192.0.2.10:80 in the browser to verify that Lighttpd is serving the web page.

- **cmd: `grep -n "server.document-root" /etc/lighttpd/lighttpd.conf`**, checks the configured document root.

```bash
$ ls /var/www/html/
# Change the content of the Welcome Page
$ nano /var/www/html/index.lighttpd.html
```
