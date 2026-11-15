#!/bin/bash
set -e


FTP_USER=$(cat /run/secrets/ftp_user)
FTP_PASS=$(cat /run/secrets/ftp_password)

# check if the user already exists in /etc/passwd
if ! id "$FTP_USER" &>/dev/null; then
    # -d(directory):want the user to land directly inside the WordPress folder (/var/www/html) as soon as they connect via FTP!
    # now he can Upload, download, rename, or delete files inside /var/www/html using an FTP program
    # -m(make home): if /var/www/html does not exist, make it automatically
    # -s(Shell): Sets the terminal shell program for this user when they log in (Bash) meaning
    # give the user a valid Linux ID card so vsftpd doesn't instantly reject them when they try to connect over FTP.
    useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"

    # chpasswd= change password
    # make the username and password pair (ouchouir:my_secret_password) and hand it directly to the
    # system password manager so it can set the password automatically without asking for manual user input.
    echo "$FTP_USER:$FTP_PASS" | chpasswd

    # Appends (-a) the user to the www-data supplementary group (-G).
    # Grants the FTP user identical group-level access rights as PHP-FPM and NGINX to the same files.
    usermod -aG www-data "$FTP_USER"
fi
# sets owner and group on /var/www/html to www-data.
# Guarantees that PHP-FPM (which runs under www-data) retains full access to process and render WordPress files uploaded via FTP.
chown -R www-data:www-data /var/www/html

# Grants read, write, and execute permissions (rwxrwxr-x) to both the owner (www-data) and members of the group (www-data).
# Because THE FTP user is a member of the www-data group, 775 allows both PHP-FPM and THE FTP user to create, edit, and
# delete files inside /var/www/html without encountering permission errors.
chmod -R 775 /var/www/html

exec vsftpd /etc/vsftpd.conf