#!/usr/bin/env bash
/etc/init.d/amavis restart
/etc/init.d/clamav-daemon restart
/etc/init.d/postfix restart
service dovecot restart
/etc/init.d/apache2 restart


# TODO need to add servername to default-ssl conf before this will work.
a2ensite default-ssl.conf

# Write out the SQL passwords to the Horde config
echo -e "\$conf['auth']['params']['password'] = '$MYSQLMAILPASSWORD';" | sudo tee -a /horde/src/horde/config/conf.php
echo -e "\$conf['sql']['password'] = '$MYSQLPASSWORD';" | sudo tee -a /horde/src/horde/config/conf.php
