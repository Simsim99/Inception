# Developer Documentation — Inception Stack

The purpose of this document is to explain to a developer how to set up this project from scratch, how the system components interact, and how data persistence is managed.

---

## Setting Up the Environment from Scratch

### 1. Virtual Machine & Storage Configuration (Crucial)

The project must run inside a Virtual Machine. At 42, standard home directories have strict disk quota limits. To bypass this restriction, use the `/goinfre` storage trick:

```bash
# Create the physical data directory on goinfre and symlink it to your home path
mkdir -p /goinfre/ouchouir/data
ln -s /goinfre/ouchouir/data /home/ouchouir/data
```

**Purpose:** Tricks Docker into saving persistent container volumes into your home directory path (`/home/ouchouir/data`), while the actual heavy files are stored on the larger `/goinfre` storage drive. Skipping this step will cause the VM to run out of disk space and crash during builds.

---

### 2. Local DNS / Host File Configuration

The purpose of editing the hosts file is to create a local fake DNS.
Edit /etc/hosts and add:

```bash
# Edit /etc/hosts on your host system
127.0.0.1 ouchouir.42.fr 
```
This tells your computer: "When I type this domain, do not search the internet. Look locally."

---

### 3. Secrets and Certificates

Before starting, you must create the secrets/ folder with your password files. The purpose of this is to feed passwords to the containers without hardcoding them:
- db_root_password.txt
- db_password.txt
- credentials.txt
- ftp_user.txt
- ftp_password.txt


You must also generate TLS certificates for NGINX using openssl. The purpose of these certificates is to enable secure HTTPS connections.

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout srcs/requirements/nginx/tools/inception.key -out srcs/requirements/nginx/tools/inception.crt -subj "/C=MA/ST=Khouribga/L=Khouribga/O=42/OU=42/CN=ouchouir.42.fr"
```
---

### Build and Launch

The Makefile acts as a control panel. It wraps Docker Compose commands.

- make up: Runs docker compose -f srcs/docker-compose.yml up -d --build.
- make down: Stops and removes containers but keeps data.
- make clean: Removes containers AND deletes the volumes (nuclear option).

---

### Architecture & Data Persistence

## Containers & Networks
All containers are attached to a custom bridge network named inception-network. Docker's internal DNS resolves container names to IP addresses, allowing NGINX to route traffic to wordpress:9000 or adminer:9000 without hardcoded IPs. NGINX is the sole entrypoint, exposing only port 443.
The FTP server exposes port 21 and passive ports 30000-30009 for file transfers.

## Volumes

Two named volumes are defined in docker-compose.yml using driver_opts to force them to physically reside in /home/ouchouir/data:

1. mariadb_data: Mounted to /var/lib/mysql in the MariaDB container. Stores all database tables.
2. wp_data: Mounted to /var/www/html in the WordPress, NGINX, and FTP containers. Stores WordPress core files, themes, and uploaded images. (Note: Sharing this volume with the FTP container allows administrators to upload files directly to the website via FileZilla).
Note: Redis and Portainer use their own small volumes or RAM for their data.

## Process Management (PID 1)

Every container uses an init.sh script as its ENTRYPOINT. This script configures the service and then uses the exec command to replace the bash process with the service's daemon (e.g., exec mariadbd, exec php-fpm8.2 -F, exec nginx -g 'daemon off;', exec vsftpd). This ensures the service runs in the foreground as PID 1, keeping the container alive and allowing graceful shutdowns.

