#!/bin/bash
# Tells the Linux kernel to run the commands below using the bash language.
set -e
# Crashes the script immediately if a command fails, sending a failure code to Docker so 'restart: on-failure' can trigger.


# 'exec' replaces the bash script (PID 1) with the Redis engine, keeping the container alive forever.
# '--protected-mode no' stops Redis from refusing external connections outside 127.0.0.1
# '--bind 0.0.0.0' tells Redis to listen on all network interfaces inside the container, allowing WordPress to talk to it over the Docker network.
exec redis-server --protected-mode no --bind 0.0.0.0