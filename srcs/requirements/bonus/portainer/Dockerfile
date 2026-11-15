FROM debian:bookworm

# Chain commands in one layer to keep the image small.
# curl: The tool to download files.
# ca-certificates: The "certificate checker". curl needs this to verify GitHub's HTTPS certificate against the
# list of certificates(ca-certificates). 
# Without it, curl panics and refuses to download because the image is empty and has no trusted authorities.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Download the Portainer pre-compiled binary (ones and zeroes ready for the CPU, no compiling needed).
# -L: Follows GitHub's redirects to the actual download server.
# -o: Saves it directly to /usr/local/bin/ so it's in the container's system $PATH.
RUN curl -L https://github.com/portainer/portainer/releases/download/2.21.4/portainer-2.21.4-linux-amd64.tar.gz -o /tmp/portainer.tar.gz \
    && tar -xzf /tmp/portainer.tar.gz -C /tmp/ \
    && cp -r /tmp/portainer/* /usr/local/bin/ \
    && rm -rf /tmp/portainer /tmp/portainer.tar.gz

# Makes the binary runnable. Without this, Linux treats it as a text file and blocks it.
RUN chmod +x /usr/local/bin/portainer

# We MUST use COPY because containers are isolated by cgroups/namespaces and are blind to the host's SSD.
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# The leading "/" is CRITICAL. Without it, Docker looks for a relative path and crashes.
ENTRYPOINT ["/usr/local/bin/init.sh"]