# Use a specific stable Debian version. We do not use 'latest' because it updates over time and might break our code later. 
FROM debian:bookworm

# updating apt to get latest version softwares from debian's sercers(catalog)
# from catalog downloads the mariadb-server app files, and installs them
# Chain commands with '&&' so Docker doesn't use an old cached package list (which causes 404 errors). 
# We delete the apt catalog at the end to save disk space and make the image smaller.
# delete a baked pre-existing, default database inside the image caused by installation ,this
# avoids the "Data directory is not empty" from the if block in init.sh
RUN apt-get update && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql/*

    
# Debian normally makes this folder, but our slim container does not. We must make it manually.
# MariaDB needs this folder to create its local UNIX socket file (mysqld.sock). Because the daemon drops root privileges
# and runs under the unprivileged mysql user for security, it will fail to start if it
# doesn't own this directory.
# the mysqld.sock will get created in the init.sh file by mariadbd when it wakes up for a bit
RUN mkdir -p /run/mysqld

# The init script runs as 'root', but the database engine drops to the 'mysql' user. 
# The mysql user needs to own this folder to write its local socket file (mysqld.sock)(a local phone jack, not the network).
RUN chown -R mysql:mysql /run/mysqld

# We copy the script to /usr/local/bin/ because it is a standard folder in the system PATH (so we can run it from anywhere).
COPY tools/init.sh /usr/local/bin/init.sh

# We MUST make it executable. If we forget this, Linux will crash the container with 'Permission denied'.
RUN chmod +x /usr/local/bin/init.sh

# ENTRYPOINT is stricter than CMD; it locks the container to only run this script.
# forces the container to run your initialization sequence first
# (setting up passwords, users, databases, and starting mysqld) every time it launches.
# The script must end by running the database in the foreground so it stays alive as PID 1.
ENTRYPOINT ["/usr/local/bin/init.sh"]