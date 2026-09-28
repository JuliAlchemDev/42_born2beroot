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

The **web server** designed to be fast, secure, flexible, and standards-compliant. It is optimized for
environments where speed is a top priority because it consumes less CPU and RAM than other servers.

| Installation| Configuration |
| --------------| ------------|
| `apt update` | - Add HTTP (80/tcp) to the VirtualBox port forwarding rules |
| `apt install lighttpd` | `ufw allow http`|
| | `ufw status` |

#### Test Server

```bash
Lighttpd
   │
   └── /var/www/html/
          └── index.html
```

Open http://192.0.2.10:80 in the browser to verify that Lighttpd is serving the web page.

- **cmd: `grep -n "server.document-root" /etc/lighttpd/lighttpd.conf`**, checks the configured document root.

```bash
$ ls /var/www/html/
# Change the content of the Welcome Page
$ nano /var/www/html/index.lighttpd.html
```

### PHP
A **programming language** mainly used to develop dynamic web
applications and interactive websites. PHP runs on the server side, meaning that the PHP code is executed by the server before the result is sent to the browser.

```bash
$ php --version

$ sudo apt install php-cgi php-mysql
```

| **php-cgi** | **php-mysql** |
| --------------| ------------|
| - provides the PHP CGI executable that a web server can use to execute PHP scripts. | - provides PHP extensions that allow PHP applications to communicate with MySQL/MariaDB databases. |
| `php-cgi -v` | |
| Lighttpd -> "Hey PHP, execute this .php file" -> php-cgi -> executes the PHP code -> returns the result -> Lighttpd -> Browser | WordPress (PHP) -> **php-mysql** -> MariaDB |

#### Test PHP directly

A quick check to verify that PHP is installed and can execute PHP scripts:

```bash
$ nano test.php

<?php
echo "Hello from PHP!";
?>

$ php-cgi test.php

# Content-type: text/html; charset=UTF-8
# Hello from PHP!
```

#### Configuring Lighttpd + PHP

Lighttpd uses FastCGI to communicate with PHP.

```bash
# Check the available Lighttpd configurations:
$ ls /etc/lighttpd/conf-available/
# PHP FastCGI configuration:
$ cat /etc/lighttpd/conf-available/15-fastcgi-php.conf
# Check which PHP CGI executable is configured:
$ grep "bin-path" /etc/lighttpd/conf-available/15-fastcgi-php.conf
"bin-path" => "/usr/bin/php-cgi"
# This tells Lighttpd which PHP CGI executable to use for PHP requests.

# Check currently enabled configurations:
$ ls -l /etc/lighttpd/conf-enabled/
# Enable FastCGI and PHP:
$ sudo lighttpd-enable-mod fastcgi fastcgi-php
# Expected output:
- Enabling fastcgi: ok
- Enabling fastcgi-php: ok
# This creates symbolic links in conf-enabled:

# 10-fastcgi.conf -> ../conf-available/10-fastcgi.conf
# 15-fastcgi-php.conf -> ../conf-available/15-fastcgi-php.conf
# 99-unconfigured.conf -> ../conf-available/99-unconfigured.conf

# Reload Lighttpd:
$ sudo service lighttpd force-reload
```

#### Test PHP through Lighttpd

```bash
Lighttpd
    │
    └── /var/www/html/
        └── test.php
              │
              │ FastCGI
              ▼
            php-cgi
              │
              │ executes PHP
              ▼
            HTML response
              │
              ▼
            Browser
```
Create a .php file inside Lighttpd's document root: `$ nano /var/www/html/test.php`. Then open: http://192.0.2.10:80/test.php

```bash
# If the browser displays:
> Hello from PHP!
# Lighttpd is successfully serving PHP through FastCGI.
```

### MariaDB

The **relational database** management system used by WordPress to store and manage website data, such as posts, users, settings, comments, and other application information.

#### Installation & Configuration
| **Command** | **Purpose**  |
| --------------| ------------|
| `apt update` | - update package information |
| `sudo apt install mariadb-server`| - install MariaDB |
| `mariadb --version` | - check installed version |
|`sudo systemctl status mariadb` | - check service status |
| `sudo systemctl is-enabled mariadb` | - check if service starts at boot |
| `sudo systemctl enable mariadb` | - enable MariaDB to start at boot |

#### Basic navigation

| **Command** | **Purpose**  |
| --------------| ------------|
| `mariadb` | - enter the MariaDB client using the default authentication |
| `mariadb -u wp_user -p` | - connect as the WordPress database user |
| `exit` | - exit the MariaDB client |

#### Database & User Configuration
```sql
-- Show existing database users and their authentication method
SELECT User, Host, plugin FROM mysql.user;

-- Create the WordPress database
CREATE DATABASE wordpress_db;
-- SHOW DATABASES;

-- Create the WordPress database user
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wordpress'; -- password included
-- CREATE USER wp_user@localhost; -- no password

SELECT USER();
SELECT CURRENT_USER();
```

#### Permissions 
```sql
-- Check WordPress user permissions:
SHOW GRANTS FOR 'wp_user'@'localhost';
-- Grant the WordPress user full access to the WordPress database:
GRANT ALL PRIVILEGES ON wordpress_db.* TO wp_user@localhost;

-- Check root privileges
SHOW GRANTS FOR 'root'@'localhost';

-- Check root authentication information
SELECT User, Host, authentication_string FROM mysql.user WHERE User = 'root';
```
