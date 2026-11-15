#!/bin/bash
# Tells the Linux kernel to run the commands below using the bash language.
set -e
# Crashes the script immediately if a command fails, sending a failure code to Docker so 'restart: on-failure' can trigger.



# 'exec' replaces the bash script (PID 1) with the Portainer engine, keeping the container alive forever.
# The '=' is critical. --bind=":9000" tells Portainer to serve its web UI on port 9000.
exec portainer --bind=":9000"