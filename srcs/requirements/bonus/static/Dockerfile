FROM debian:bookworm

# --no-install-recommends tells Debian to only install the bare minimum required for NGINX.
# It skips extra documentation and optional tools, keeping our Docker image tiny and fast.
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# We MUST use COPY because Docker uses Linux namespaces/cgroups to isolate the filesystem.
# The container cannot see the host's SSD, so we have to physically copy the files into the Image.
COPY conf/index.html /var/www/html/index.html
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Copy the startup script and make it executable (mandatory for Linux to allow running it).
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Set the script as the primary process (PID 1) to run when the container starts.
ENTRYPOINT ["/usr/local/bin/init.sh"]