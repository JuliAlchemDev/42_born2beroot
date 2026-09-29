# N8N: Simple Workflow Automation

## Overview
**N8N** is a workflow automation platform that allows different applications, services, and scripts to communicate with each other and automate tasks.

### Docker
**Docker** is a platform used to package and run applications in containers. A container includes an application together with its dependencies and configuration, allowing it to run in an isolated and consistent environment.

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
# =======================================
                 Docker
                   │
          ┌────────┴────────┐
          │                 │
       IMAGE            CONTAINER
          │                 │
     "template"       "running instance"
# =======================================
n8n image
├── n8n
├── Node.js
├── dependencies
└── required filesystem
# =======================================
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
| | Defines the URL used to access the n8n editor -> | N8N_EDITOR_BASE_URL=http://${HOST_IP}:5678 |
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
      - N8N_EDITOR_BASE_URL=http://${HOST_IP}:5678
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

Once the service is started, you should be able to access the n8n editor at: `http://${HOST_IP}:5678`.

For more advanced automation setups, see the [n8n Docker Compose documentation](https://docs.n8n.io/deploy/host-n8n/install-options/install-using-docker-compose#optional-turn-on-n8n-assistant).

## Basic Workflow

### Webhook
### HTTP Request
### Email Notification

## User Management Integration

### adduser.local
### deluser.local
### User Information Snapshots

#### DNS Configuration

The n8n container initially had problems resolving `smtp.gmail.com`.
Debian itself could resolve the hostname correctly, but the container could not
resolve it through Docker's internal DNS resolver.

To provide reliable DNS resolution, the n8n container was configured to use:

8.8.8.8  → Google Public DNS
1.1.1.1  → Cloudflare DNS

## Architecture
