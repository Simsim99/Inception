FROM debian:bookworm

# Chain commands in one layer (pancake) so Docker doesn't use a stale cache.
# --no-install-recommends skips optional docs/tools, keeping the image tiny.
# rm -rf in the same layer ensures the apt cache doesn't bloat the image size.
RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# We MUST use COPY because containers are isolated and cannot see the host's SSD.
# This bridges the gap by physically placing the file into the container's Image.
COPY tools/init.sh /usr/local/bin/init.sh

# Adds the "Execute" permission to the file's metadata. 
# Without this, Linux treats it as a text file and Docker crashes with "Permission denied".
RUN chmod +x /usr/local/bin/init.sh

# Tells Docker to run this script during Run Time (when the container turns on).
# Unlike RUN (which finishes), this script must stay alive in the foreground to keep the container running.
ENTRYPOINT ["/usr/local/bin/init.sh"]