#!/usr/bin/env bash
/etc/init.d/amavis restart
/etc/init.d/clamav-daemon restart
/etc/init.d/postfix restart
service dovecot restart
/etc/init.d/apache2 restart


# TODO need to add servername to default-ssl conf before this will work.
a2ensite default-ssl.conf

letsencrypt --apache --domains $HOSTNAME --email $ADMINEMAIL --agree-tos -n