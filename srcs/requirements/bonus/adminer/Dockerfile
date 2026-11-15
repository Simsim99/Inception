FROM debian:bookworm

# Install php-fpm (to run the Adminer PHP script) and php-mysql (so Adminer can talk to MariaDB over the network).
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a subfolder so Adminer files don't conflict with WordPress files.
RUN mkdir -p /var/www/html/adminer

# Download the single Adminer PHP file.
# -sSL: -s (silent), -S (show errors if they happen), -L (follow GitHub redirects to the actual file).
# Rename it to index.php so the user can just type /adminer/ in their browser (handled by NGINX index directive).
RUN curl -sSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -o /var/www/html/adminer/index.php

# Change PHP-FPM to listen on TCP port 9000 instead of a local socket, so NGINX can send traffic to it over the Docker network.
RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf

# Copy the startup script and make it executable (mandatory, or Linux blocks it with Permission Denied).
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Set the script as the primary process (PID 1) to run when the container starts.
ENTRYPOINT ["/usr/local/bin/init.sh"]