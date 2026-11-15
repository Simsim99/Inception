# User Documentation — Inception Stack

The purpose of this document is to help an end-user or administrator understand how to use and manage the Inception infrastructure.

---

## Services Provided

Here is what this stack gives you:

* **WordPress:** The main dynamic website.
* **Adminer:** A web tool to visually look inside your database.
* **FTP Server:** A file transfer server to directly upload files to the WordPress volume.
* **Static Website:** A simple HTML page.
* **Portainer:** A web tool to visually see and manage your Docker containers.

---

## Starting and Stopping the Project

Open your terminal and navigate to the project root folder:

* **`make up`** — Builds and launches all services. Wait about 20 seconds for the database to initialize.
* **`make down`** — Turns off and stops the containers. Your saved data remains safe.
* **`make clean`** — Deletes everything (containers and persistent data) so you can test a completely fresh install.

---

## Accessing the Services

> **Prerequisite:** To access the web services via the domain name, ouchouir.42.fr must resolve to 127.0.0.1. Ensure 127.0.0.1 ouchouir.42.fr is added to your /etc/hosts file. NGINX is configured to reject requests made directly to localhost or 127.0.0.1.

> **Note on Security Warnings:** Your browser will show a *"Not Private / Untrusted"* warning because the web server uses self-signed SSL certificates. The purpose of this is local traffic encryption. Click **Advanced → Proceed** to continue.

| Service | Access URL | Login / Access Details |
| :--- | :--- | :--- |
| **WordPress Website** | `https://ouchouir.42.fr` *(or `https://127.0.0.1:4443`)* | Access the main dynamic website. |
| **Adminer (Database UI)** | `https://ouchouir.42.fr/adminer` | **System:** `MySQL`<br>**Server:** `mariadb`<br>**Username:** `wpuser`<br>**Password:** Found in `secrets/db_password.txt` |
  **FTP Server** | `ftp://127.0.0.1:21 (or <VM_IP>:21)` | **Username:** Found in `secrets/ftp_user.txt`<br>**Password:** Found in`secrets/ftp_password.txt` |
| **Static Site** | `https://ouchouir.42.fr/static` | Simple HTML landing page. |
| **Portainer (Docker UI)** | `http://127.0.0.1:9000` *(or `<VM_IP>:9000`)* | Visual Docker container dashboard. |

---

## Locating and Managing Credentials

The purpose of keeping credentials separate is security. They are never put directly into the source code.

All passwords are stored locally in the `secrets/` folder:

* `secrets/db_root_password.txt` — Holds the database master (root) password.
* `secrets/db_password.txt` — Holds the regular database user password (`wpuser`).
* `secrets/credentials.txt` — Holds the WordPress admin password.
* `secrets/ftp_user.txt` — Holds the FTP server username.
* `secrets/ftp_password.txt` — Holds the FTP server password.

> **Security Rule:** Never upload or commit the `secrets/` folder to Git!

---

## Checking Service Health

The easiest way to check if all services are running properly is to use Portainer:

1. Open the Portainer web UI in your browser (`http://127.0.0.1:9000`).
2. Click on **Containers** on the left menu.
3. **Verify Status:** This page shows a live view of your stack. Make sure all 8 containers show a green **`running`** status.
4. **Logs:** Click the document icon next to any container to inspect its live logs.