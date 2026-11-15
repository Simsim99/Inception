FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

# When a user connects to FTP, vsftpd doesn't trust them. To keep the server safe,
# it tries to immediately drop the user's permissions and lock them into an isolated,
# empty folder (var/run/vsftpd/empty), this way if the user is a hacker, and they try to
# exploit a vulnerability in the FTP login screen, they will execute their code inside
# this folder. Because the folder is completely empty,there are no files to steal,
# no passwords to read, and no system tools (like ls or rm) they can use to attack the system. They are trapped in a padded cell.
# the user gets moved to /var/www/html after providing all the  correct credentials
RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

#"Unlike NGINX or MariaDB, which automatically look for their config files in the /etc/ directory, vsftpd does not load a config
# file by default. I had to explicitly pass the path /etc/vsftpd.conf as an argument to the vsftpd binary so it would read my custom
# passive mode and user authentication rules.
ENTRYPOINT ["/usr/local/bin/init.sh"]