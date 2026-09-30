# n8n: Simple Workflow Automation

## Overview

This bonus project integrates **n8n** with Debian's user management system to automate email notifications when users are created or deleted.

The goal is to connect system events with an external workflow:

* When a user is created, `adduser.local` collects the user's information and sends it to an n8n webhook.
* When a user is deleted, `deluser.local` retrieves the stored information and sends it to a second n8n webhook.
* n8n processes the received data and sends an email notification through SMTP.
* User information is also stored locally in snapshots, allowing the deletion workflow to access information that would otherwise be lost after the account is removed.

### Architecture & Workflows

The two workflows follow the same general pattern, with different hooks and webhook endpoints depending on the user event:

```text
                        Debian
                           │
                ┌──────────┴──────────┐
                ▼                     ▼
          adduser.local         deluser.local
                │                     │
          HTTP POST + JSON      HTTP POST + JSON
                ▼                     ▼
      Webhook: user-created   Webhook: user-deleted
                │                     │
                ▼                     ▼
       n8n creation workflow  n8n deletion workflow
                │                     │
                └──────────┬──────────┘
                           ▼
                  Email Notification
                           │
                           ▼
                          SMTP
```
| adduser | deluser |
| --------------| ------------|
| ![adduser](/docs/srcs/adduser.png) | ![deluser](/docs/srcs/deluser.png) |

### Docker
**Docker** is a platform used to package and run applications in containers. A container runs an application together with its required dependencies in an isolated environment.

For this project, Docker is used to run the n8n workflow automation platform without installing n8n and its dependencies directly on the Debian server.

#### Installation & Quick Test

| Preparation | Version & Status | Activate & Test |
| --------------| ------------| ------------|
| `sudo apt update` | `docker-compose --version && docker --version` | `sudo systemctl enable --now docker` |
| - update package list | - check installed versions | - start Docker and enable it at boot |
| `apt install --simulate docker.io docker-compose` | `sudo systemctl status docker` | `sudo docker run hello-world` |
| - simulate installation and check dependencies | - check Docker service status | - download the hello-world image and run a test container |
| `sudo apt install docker.io docker-compose`|  | |
| - install Docker and Docker Compose | | |

```bash
$ sudo docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:

# Summary: Docker client -> Docker daemon -> Local Image / (Docker Hub -> Docker image) -> Docker container -> Program execution
```

#### Image vs Container

A **Docker image** is a read-only template containing an application and everything it needs to run. A **Docker container** is a running instance created from an image.

```bash
                 Docker
                   │
          ┌────────┴────────┐
          │                 │
       IMAGE            CONTAINER
          │                 │
     "template"       "running instance"


n8n image
├── n8n
├── Node.js
├── dependencies
└── required filesystem
```

### n8n Installation

#### Docker Compose

**Docker Compose** is a tool used to define and manage Docker applications using a configuration file. Instead of creating and configuring containers manually with multiple Docker commands, Compose allows us to describe the required configuration in a single YAML file and start the application from it.

```bash
# Create a folder to store the n8n configuration:
$ mkdir ~/n8n
$ cd ~/n8n
$ nano compose.yml
```

#### Configuration
| Configuration | Purpose | Example |
| --------------| ------------| ------------|
| services | - defines *what runs* | services: n8n: |
| image | - defines the Docker image used to create the n8n container | image: docker.n8n.io/n8nio/n8n:latest |
| restart | - defines container behavior | restart: unless-stopped |
| ports | - maps port on the host to port inside the container | ports: - "5678:5678" |
| [dns](#dns-configuration)| - provides explicit DNS servers for the container| dns: - 8.8.8.8 |
| environment: | - defines environment variables used by n8n | ▼ see below |
|  | Allows n8n to work over HTTP in this local setup instead of requiring HTTPS -> | N8N_SECURE_COOKIE=false |
| | Defines the URL used to access the n8n editor -> | N8N_EDITOR_BASE_URL=http://192.0.2.11:5678 |
| volumes | - define *where data is stored* | volumes: - n8n_data:/home/node/.n8n |

```yml
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    restart: unless-stopped
    ports:
      - "5678:5678"
    dns:
      - 8.8.8.8
      - 1.1.1.1
    environment:
      - N8N_SECURE_COOKIE=false
      - N8N_EDITOR_BASE_URL=http://192.0.2.11:5678
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:

# =======================================
# volumes:
#   n8n_data:                 ← DEFINE
#       │
#       ▼
# services:
#   n8n:
#     volumes:
#       - n8n_data:/home/node/.n8n   ← USE / MOUNT
```

#### Start and Test

Make sure you are in the project folder where `compose.yml` is located.

| Test | Start |
| --------------| ------------|
| `docker compose config` | `sudo docker compose up -d`|
| - checks the configuration | - start n8n in detached mode |
| `sudo docker compose ps` | `sudo docker compose down` |
|- checks that the container is running | - stops and removes the n8n container |
| `sudo ss -ltnp \| grep 5678` | `sudo docker compose restart` |
|- check that port 5678 is listening | - restarts the existing container |

Once the service is started, you should be able to access the n8n editor at: `http://192.0.2.11:5678`.

For more advanced automation setups, see the [n8n Docker Compose documentation](https://docs.n8n.io/deploy/host-n8n/install-options/install-using-docker-compose#optional-turn-on-n8n-assistant).

### First Test & Basic Workflow

The workflows in this project are triggered by **HTTP webhooks**. This allows external scripts to send data to n8n through an HTTP request and start the corresponding workflow automatically.

- **tool: `curl`**, command-line tool used to transfer data to or from a server using URLs. In this project, it is used to send HTTP requests from the shell to the n8n webhook.

```bash
$ sudo apt update
$ sudo apt install curl
```

#### Webhook

A **Webhook** is an HTTP endpoint exposed by n8n. When an external application sends a request to this endpoint, n8n receives the data and triggers the workflow.

For this project, create a new workflow in the n8n editor and add a **Webhook** trigger.

Configure it as follows:

| Configuration | Value      | Purpose                                |
| ------------- | ---------- | -------------------------------------- |
| HTTP Method   | `POST`     | Receives data sent in the request body |
| Path          | `first_test` | Defines the webhook endpoint         |

During testing, n8n provides a temporary `/webhook-test/` endpoint:
`http://localhost:5678/webhook-test/...`

After the workflow is activated, use the `/webhook/` endpoint instead:
`http://localhost:5678/webhook/...`

```bash
# Send a test request:

curl -X POST http://localhost:5678/webhook-test/first_test\
  -H "Content-Type: application/json" \
  -d '{
    "username": "new user",
    "hostname": "iualkhim42",
    "date": "2026-09-17",
    "time": "09:30"
  }'
```

When the request is received, the Webhook node is triggered and the JSON data becomes available to the following nodes in the workflow.

#### Email Notification
The next step is to add an **Send Email** action and configure an SMTP account.

**SMTP (Simple Mail Transfer Protocol)** is a standard protocol used to send emails between mail clients and mail servers. One possible disadvantage is that emails may end up in the recipient's spam folder, depending on the email provider and the sender's configuration.

Configure the email action as follows:

| Configuration | Purpose                          |
| ------------- | -------------------------------- |
| From Email    | Email address used as the sender |
| To Email      | Recipient email address          |
| Subject       | Subject of the notification      |
| Email Format  | Format of the email content      |
| Text          | Message body                     |

### User Management Integration

The previous workflow was triggered manually by sending a test request to the n8n webhook. The next step is to connect n8n with the Debian user management system and trigger the workflow automatically when a user is created or deleted.

- Both hook scripts are located in: `/usr/local/sbin/`

#### adduser.local

A local hook script used by Debian's `adduser` command. When a new user is created with adduser, Debian can execute this script automatically after the user creation process.

This allows additional actions to be performed whenever a user is created, without modifying the adduser command itself.

In this project, `adduser.local` is used to:

1. Collect information about the newly created user.
2. Save a local snapshot of the user information.
3. Send the information to the n8n webhook using an HTTP `POST` request.
4. Trigger the corresponding n8n workflow.

```bash adduser.local
#!/bin/bash
USER_DIR="/var/lib/born2beroot/users"

name=$1
email=$(getent passwd "$1" | awk -F: '{print $5}' | awk -F, '{print $5}')
hostname=$(hostname)
date=$(date '+%Y-%m-%d')
time=$(date '+%H:%M:%S')

if [ ! -d "$USER_DIR" ]; then
  mkdir -p "$USER_DIR"
  chmod 700 "$USER_DIR"
fi

echo "username=$name
email=$email
hostname=$hostname
date=$date
time=$time" > "$USER_DIR/$1_info.txt"

chmod 600 "$USER_DIR/$1_info.txt"

response=$(curl -s -X POST http://localhost:5678/webhook/user-created \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$name\",
    \"email\": \"$email\",
    \"hostname\": \"$hostname\",
    \"date\": \"$date\",
    \"time\": \"$time\"
  }")

echo "Msg from n8n server: $(echo "$response" | awk -F'"' '{print $4}')"
echo "Sending welcome message to $name..."
echo "Notifying admin..."
```

#### deluser.local

`deluser.local` is a local hook script executed by Debian's `deluser` command when a user is removed.

In this project, it is used to:

1. Retrieve the user's stored information before removing the local snapshot.
2. Send the information to the n8n webhook using an HTTP `POST` request.
3. Trigger the corresponding n8n workflow.
4. Rename the user's snapshot to indicate that the user has been deleted.

```bash deluser.local
#!/bin/bash
USER_DIR="/var/lib/born2beroot/users"

name=$1
email=$(grep email "${USER_DIR}/${name}_info.txt"| awk -F= '{print $2 }')
hostname=$(hostname)
date=$(date '+%Y-%m-%d')
time=$(date '+%H:%M:%S')


response=$(curl -s -X POST http://localhost:5678/webhook/user-deleted \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$name\",
    \"email\": \"$email\",
    \"hostname\": \"$hostname\",
    \"date\": \"$date\",
    \"time\": \"$time\"
  }")

echo "Msg from n8n server: $(echo "$response" | awk -F'"' '{print $4}')"
echo "Sending farewell message to $name..."
echo "Notifying admin..."

mv $USER_DIR/${name}_info.txt $USER_DIR/${name}_info_deleted.txt
```

### User Information Snapshots

In addition to sending user information to n8n, the hooks maintain a local snapshot of each user's information.

Snapshots are stored in:

```text
/var/lib/born2beroot/users/
```

When a user is created, `adduser.local` creates a file containing basic information such as:

```text
username=iualkhim
email=...
hostname=iualkhim42
date=2026-09-30
time=08:30:00
```

The snapshot is protected with restricted permissions:

```bash
chmod 700 /var/lib/born2beroot/users
chmod 600 /var/lib/born2beroot/users/<username>_info.txt
```

The snapshot is especially important when a user is deleted. Once `deluser` removes the user, information such as the user's email address is no longer available through the system.

The stored snapshot allows `deluser.local` to retrieve the user's information **before it is lost** and send it to the n8n workflow for the farewell notification.

After the notification is triggered, the snapshot is renamed:

```text
<username>_info.txt
        ↓
<username>_info_deleted.txt
```

This provides a simple local record of user creation and deletion events while allowing the deletion workflow to access the information required for the farewell email.

---
### DNS Configuration

The n8n container initially had problems resolving `smtp.gmail.com`.
Debian itself could resolve the hostname correctly, but the container could not
resolve it through Docker's internal DNS resolver.

To provide reliable DNS resolution, the n8n container was configured to use:

| DNS Server | Provider          |
| ---------- | ----------------- |
| `8.8.8.8`  | Google Public DNS |
| `1.1.1.1`  | Cloudflare DNS    |

