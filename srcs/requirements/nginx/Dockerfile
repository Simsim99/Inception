# Starts from a clean Debian Bookworm Linux environment
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    # nginx provides the web server engine.
    nginx \
    && rm -rf /var/lib/apt/lists/*

# standard folder where I will put the certificates(inside the container)
RUN mkdir -p /etc/nginx/ssl

# Transfers inception.key and inception.crt from your host machine
# (requirements/nginx/tools/) directly into /etc/nginx/ssl/ inside the container.
# so NGINX can read these files directly from this folder.
COPY tools/inception.key /etc/nginx/ssl/
COPY tools/inception.crt /etc/nginx/ssl/

# Overwrites the default NGINX server configuration file with your custom nginx.conf
# Out of the box, NGINX listens on plain HTTP port 80, I overwrite that
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

#Moves my LAUNCH script into /usr/local/bin/, gives it execution permissions
# (chmod +x), and assigns it as the primary ENTRYPOINT.
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh
ENTRYPOINT ["/usr/local/bin/init.sh"]