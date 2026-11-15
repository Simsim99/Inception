#!/bin/bash
# Crash immediately if a command fails, and print commands as they run for easy debugging in docker logs.
set -e


# Fix directory ownership. 
# PHP-FPM runs as www-data. If we don't do this, PHP cannot read the adminer/index.php file.
chown -R www-data:www-data /var/www/html

# 'exec' replaces bash with PHP-FPM, making it PID 1.
# '-F' forces it to run in the foreground so Docker knows the container is alive.
exec php-fpm8.2 -F