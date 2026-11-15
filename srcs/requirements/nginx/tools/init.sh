#!/bin/bash
# Tells the Linux kernel to run this script using the bash language.
set -e
# Crashes the script immediately if a command fails, which sends a failure code to Docker so 'restart: on-failure' can trigger.



# 'daemon off;' tells NGINX NOT to run in the background. 
# By default, NGINX forks to the background (like a game running while you use the terminal). 
# If it goes to the background, Docker thinks the script finished and kills the container.
# 'exec' replaces the bash script (PID 1) with NGINX. 
# This ensures NGINX receives Docker's 'stop' signals instantly when we type 'make down', preventing a 10-second timeout.
# -g flag as a command-line shortcut to inject a setting into NGINX's configuration file(/etc/nginx/nginx.conf) without 
# having to open the file on disk and type it myself.
exec nginx -g 'daemon off;'