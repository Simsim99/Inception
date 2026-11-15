# Use a specific stable Debian version. We do not use 'latest' because it updates over time and might break our code later. 
FROM debian:bookworm

# Update and install packages in one layer to save image size.
# - php-fpm: The background engine that processes PHP code into web pages (The Kitchen Station).
# - php-mysql: The module/extension (PDO/mysqli) that lets PHP talk to the MariaDB database.
# - curl: To download WordPress files.
# - netcat: WordPress is completely dependent on MariaDB, so we need the package to use nc to  knock on mariadb port
# Clean up temporary installation files so the image size stays small.
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Fix PHP-FPM to listen on TCP port 9000 across the container network (instead of local unix socket)
# to receive FastCGI requests from NGINX.
# 'sed' is a stream editor. The '-i' flag means "in-place" (actually overwrite the original file).
# We use pipes '|' instead of slashes '/' to avoid "leaning toothpick syndrome" because the file path has slashes.
# We must do this because NGINX is in a different container and cannot use a local socket; it needs a network port.
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Create directory, download WordPress, and extract directly to /var/www/html
# - curl -o: Saves the downloaded data to a file instead of dumping gibberish to the terminal screen.
# - tar -xzf: x=extract, z=unzip (gzip), f=file (use the next word as the filename).
# - -C (change directory): tells tar to extract every file directly into /var/www/html/
# - --strip-components=1: Strips the top-level 'wordpress' folder from the archive, so files drop directly   
# into /var/www/html/ instead of /var/www/html/wordpress/. If we forgot this, the website would break. this
# way i wont copy the worpress directory and copy the files directly
RUN mkdir -p /var/www/html && \
    curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/html/ --strip-components=1 && \
    rm /tmp/wordpress.tar.gz

# Download WP-CLI and make it executable
# A '.phar' (PHP Archive) is like a zip file for PHP that can be run directly.
# We save it to /usr/local/bin/wp because that folder is in the system's $PATH, 
# allowing us to just type 'wp' from anywhere inside the container.
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# COPY physically moves the script from your host computer into the isolated container's file system.
COPY tools/init.sh /usr/local/bin/init.sh

# chmod +x is mandatory. Without execute permission, Linux will block Docker from running it (Permission denied).
RUN chmod +x /usr/local/bin/init.sh

# Set the Entrypoint, tells Docker to execute your script as soon as the container boots up.
ENTRYPOINT ["/usr/local/bin/init.sh"]