

> *This project has been created as part of the 42 curriculum by **ouchouir**.*

---

## Description

The purpose of the **Inception** project is to learn system administration by building a small, secure web infrastructure using Docker. Instead of installing everything on one big server, the website is split into separate isolated "containers" (like shipping containers).

This project runs a WordPress website powered by three core infrastructure containers:
* **NGINX:** The web server that handles incoming traffic and SSL termination.
* **WordPress + PHP-FPM:** The application engine that builds web pages.
* **MariaDB:** The relational database that stores site data.

### Bonus Containers:
* **Adminer:** Database management tool with a graphical interface.
* **Redis:** In-memory object cache to speed up website performance.
* **FTP Server:** File transfer protocol server (vsftpd) allowing direct file uploads to the WordPress volume.
* **Static Website:** A dedicated static web page served by NGINX.
* **Portainer:** Graphical management dashboard for Docker containers.

---

## Instructions

To run the project, navigate to the root directory of the repository in your terminal and use the provided `Makefile` commands:

| Command | Action | Purpose |
| :--- | :--- | :--- |
| `make up` | Builds and starts containers | Builds all Docker images from scratch and starts all containers in the background. |
| `make down` | Stops containers | Stops and deletes running containers while keeping your persistent data safe. |
| `make clean` | Fresh reboot | Stops all containers **AND deletes all saved data** (use when starting completely fresh). |

---

## Project Architecture & Design Choices

The project uses Docker to isolate every service for **security and stability**. If an attacker compromises the web server container, they cannot directly access the database because the services live in isolated environments. 

`debian:bookworm` is used as the base OS image across all custom containers because it is thoroughly tested, reliable, and secure.

---

### Technical Comparisons

#### 1. Virtual Machines vs Docker

| Metric | Virtual Machines (VMs) | Docker Containers |
| :--- | :--- | :--- |
| **Analogy** | Building a whole new house just for an extra kitchen. | A pop-up shipping container sharing the house plumbing. |
| **Architecture** | Runs a complete, heavy guest Operating System on top of a hypervisor. | Shares the host machine's Linux kernel and isolates processes. |
| **Performance** | Takes gigabytes of disk space and minutes to boot up. | Lightweight, uses megabytes of space, and boots in seconds. |

---

#### 2. Secrets vs Environment Variables

* **Environment Variables (`.env` file):**
  * **Purpose:** Used for non-sensitive settings (e.g., domain names, database names).
  * **Drawback:** Stored in plain text and visible to anyone who runs `docker inspect`.
* **Docker Secrets:**
  * **Purpose:** Used for sensitive data (e.g., database passwords, admin credentials).
  * **Benefit:** Loaded directly into the container's RAM as read-only files (`/run/secrets/`), making them completely hidden from `docker inspect` and protected against leaks.

---

#### 3. Docker Network vs Host Network

* **Host Network:**
  * **Function:** Removes network isolation between the container and the host machine.
  * **Drawback:** Insecure. If a container on the host network is breached, the attacker gains direct access to the host machine's local interfaces.
* **Docker Bridge Network:**
  * **Function:** Creates a private virtual router exclusively for your container stack (`inception-network`).
  * **Benefit:** Total network isolation. Only the **NGINX** container exposes port `443` to the outside world; MariaDB and Redis remain strictly hidden inside the internal bridge network.

---

#### 4. Docker Volumes vs Bind Mounts

* **Bind Mounts:**
  * **Function:** Directly maps a specific folder on the host machine into the container.
  * **Drawback:** Relies on rigid host directory structures staying identical across different environments.
* **Docker Named Volumes:**
  * **Function:** Storage fully managed by the Docker daemon.
  * **Benefit:** Configured with `driver_opts` to bind persistent storage to `/home/ouchouir/data`. This guarantees that database tables and website uploads survive intact even if containers are destroyed and recreated.

---

## Resources
* https://youtu.be/PrusdhS2lmo
* https://kodekloud.com/studio/labs/docker
* https://learn.kodekloud.com/learn/courses/docker-training-course-for-the-absolute-beginner

### AI Usage Statement
Artificial Intelligence was utilized as a personal tutor throughout this project to explain complex system administration concepts (such as Linux **PID 1**, process signal handling, and Docker layer caching) using real-world analogies. AI was also used to assist in debugging shell script syntax when initialization scripts failed inside containers.

*The purpose of AI interaction was strictly to learn and verify technical concepts, not to blindly copy code. All scripts, Dockerfiles, and configurations were tested, understood, and authored directly by the student.*