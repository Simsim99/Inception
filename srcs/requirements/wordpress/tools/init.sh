#!/bin/bash
# Tells the system to use bash, crash on errors (so Docker restarts), and print commands for debugging.
set -e


# Read the secure passwords from the container's temporary RAM filesystem (Docker Secrets).
# $() extracts what 'cat' prints and stores it in the variable without exposing it in the code.
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Check if wp-config.php does NOT exist. 
# if not we create it: it is the core settings file for wordpress, php executes wordpress code in
# /var/www/html/ thus worpress looks inside this config file info to open network connection to
# MariaDB to load data from it
# We need this because our Docker Volume (wp_data) saves data across restarts. 
# Without this, we would overwrite our website and reset passwords on every restart.
if [ ! -f "/var/www/html/wp-config.php" ]; then
    # netcat (nc) networking tool that reads and writes data across networks
    # netcat (nc) to knock on port 3306 of the mariadb container. The -z flag just
    # checks if the port is open without sending data
    while ! nc -z mariadb 3306; do
    sleep 2
    done

    # creating wp-config.php file
    # Tells WordPress where to find MariaDB. 
    # "mariadb" is used as the IP address because Docker's virtual DNS server swaps it with the dynamic IP.
    # --allow-root is mandatory because this script runs as root, and WP-CLI refuses to run as root without it.
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --path="/var/www/html" \
        --allow-root
        # goes into /var/www/html/, creates a brand new text file called wp-config.php, and writes the
        # database credentials inside it.
        # path is where the wordpress files(Wordpress website) are
    # DATABASE STILL EMPTY, config file with just database credentials

    # Uses the config we just created to build the actual website.
    # insted of going to a browser , type my domain and see a screen that asks for the info below then
    # click "install wordpress"  and create all tables inside database, we use wp core install to do that automatically
    # why? containers should start without a single human click
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="ouchouir" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="admin@42.fr" \
        --path="/var/www/html" \
        --allow-root
        # goes into /var/www/html/, reads the wp-config.php file to find the database password, connects to MariaDB, and
        # creates all the default database tables. Then it registers the admin user in those tables.
    # DATABASE IS FILLED WITH TABELS, THE SITE IS LIVE

    # Creates the second required user. 
    # They are an "author" (not admin) so they cannot change sensitive info like passwords or delete the site.
    wp user create \
        "guest" \
        "user@42.fr" \
        --user_pass="user1999" \
        --role=author \
        --path="/var/www/html" \
        --allow-root
        # path: goes into /var/www/html/, reads wp-config.php to connect to the database, and inserts a new row into the wp_users table.
    # Install the Redis PLUGIN (an add-on app to give WordPress caching features it doesn't have natively).
    # --activate turns the plugin on immediately so it can act as a TRANSLATOR between WP and Redis.
    # since WordPress only understands SQL (for MariaDB). now wordpress can talk to redis container
    wp plugin install redis-cache --activate --path="/var/www/html" --allow-root

    # Tell WordPress where the Redis container is. 
    # 'redis' is the container name, which Docker's internal DNS translates to a private IP.
    # 6379 is the default standard port for Redis servers worldwide.
    # Write the Redis container's address and port into wp-config.php.
    # Goal: Tell the Redis plugin (translator) where the Redis app (notepad) lives.
    wp config set WP_REDIS_HOST redis --path="/var/www/html" --allow-root
    wp config set WP_REDIS_PORT 6379 --path="/var/www/html" --allow-root

    # Flips the physical switch! This copies a special 'object-cache.php' file into wp-content/,
    # forcing WordPress to start routing database queries through Redis instead of hitting MariaDB every time.
    # Now, WordPress will cache database results in Redis (RAM) so it skips asking MariaDB (SSD) in the future, making the site faster.
    # object-cache.php intercepts the request and talks to the redis container over port 6379.
    wp redis enable --path="/var/www/html" --allow-root
    # !IMPORTANT FLOW:
    # WordPress has built-in cache functions like wp_cache_get. When WordPress decides it needs to cache or fetch data, it
    # calls those functions. PHP-FPM is the engine that executes them from inside 'object-cache.php' that got copied into
    # wp-content/, PHP-FPM uses the custom code in that file, which translates the request and sends it over the network to the Redis container.
fi  

# Swaps ownership of the files from 'root' to 'www-data'.
# PHP-FPM runs as www-data. If we don't do this, PHP cannot read the config file and the site crashes.
chown -R www-data:www-data /var/www/html

# 'exec' swaps the script out and makes PHP-FPM the PID 1 process.
# '-F' forces it to run in the foreground so Docker knows the container is alive.
exec php-fpm8.2 -F