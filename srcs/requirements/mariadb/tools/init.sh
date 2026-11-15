#!/bin/bash
# Tells the system to use the bash language to run this script.
set -e
# Stops the script immediately if a command fails, which sends a failure code to Docker so 'restart: on-failure' can trigger.


DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)
# Uses command substitution to read the secure text files from the container's RAM and stores them in variables.

if [ ! -f "/var/lib/mysql/.initialized" ]; then
    # Check if the .initialized file does NOT exist. If it's missing, this is a first run.
    # also Checks if the base system tables (the database's internal filing cabinets) do NOT exist
    # in volume directory (/var/lib/mysql).
    # If they don't exist (like on a first run), install them. We use an 'if' statement so we don't crash on
    # a second run when the volume already has data ("Data directory is not empty!").
    # "Create these files on /var/lib/mysql, but set their ownership to the mysql user."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    #....
    # We start the engine(using mysql) in the background(&) TEMPORARILY just so we can talk to it locally. 
    # We use --skip-networking so it only listens locally (safer/faster).
    mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    # Wait until the engine is fully awake before sending SQL commands
    # Loops and checks the status of the background server every second until MariaDB responds to a
    # ping, ensuring the server is awake before running SQL queries(look down).
    # &>/dev/null: Silences all output (both standard output and errors) so it doesn't clutter
    # your terminal startup logs.
    until mariadb-admin --socket=/run/mysqld/mysqld.sock ping &>/dev/null; do
	    sleep 1
    done

# Pipes raw SQL commands directly into the MariaDB client interface:
# 1. Creates the database specified in MYSQL_DATABASE (e.g., wordpress).
# 2. Secures the default root account with your secret password.
# 3. Creates your custom database user with % (allowing access from other containers, such as WordPress).
# 4. Grants full permissions on the new database to your custom user and reloads privileges
    # Uses a Here-Document(<< EOF)to feed a chunk of SQL commands to the database without opening an interactive terminal.
    mariadb --socket=/run/mysqld/mysqld.sock -u root << EOF
# WordPress needs a specific database to store its tables.
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
# ALTER: updates the password for the SQL root user so that it matches the
# secret value stored in your ${DB_ROOT_PASSWORD} variable
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
# Creates the limited user (using the name stored in MYSQL_USER) and sets its password.
# Uses '%' instead of 'localhost' so services from OTHER containers (like WordPress) can connect to this database.
# and Allows this user to connect from any external container (like WordPress) over the network.
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
# Gives this user full rights only on ${MYSQL_DATABASE}.* (e.g., the WordPress database and its tables).
FLUSH PRIVILEGES;
# Tells the database to refresh its memory and apply the new user permissions immediately.
EOF
    # Shut down the temporary engine gracefully so we can start it permanently in the foreground.
    mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown
    # -u: user, -p: password
    touch /var/lib/mysql/.initialized
fi
exec mariadbd --user=mysql --bind-address=0.0.0.0
# 'exec' replaces the bash process, making the database the PID 1 process so it stays in the foreground and catches Docker stop signals.
# '--user=mysql' runs the database as the restricted 'mysql' user instead of root for security.
# IMPORTANT:
# mariadbd (The Engine): The worker in the background receiving instructions.
# mariadb (The SQL Client): Shouts SQL commands ("Create a user!") into the socket file.
# mariadb-admin (The Admin Tool): Shouts admin commands ("Ping me!" or "Shut down!") into the socket file.