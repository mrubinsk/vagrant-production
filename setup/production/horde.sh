#!/usr/bin/env bash

echo 'Creating horde database.'
mysql -u root --password=$MYSQLPASSWORD -e "create database horde";

# This will create just the tables that are needed for Horde to manage
# the users and will match the schema that those tables would have under
# POSTFIXADMIN.
#
newdb="CREATE DATABASE mail;
grant all on mail.* to 'mail'@'localhost' identified by '$MYSQLMAILPASSWORD';
grant all on mail.* to 'mail'@'127.0.0.1' identified by '$MYSQLMAILPASSWORD';"

echo $newdb | mysql -u root --password=$MYSQLPASSWORD
mysql -u root --password=$MYSQLPASSWORD < /vagrant/postfixadmin_schema.sql

# Create initial user.
echo 'Creating initial admin user.'
echo "INSERT INTO domain (name, description) VALUES ('$DOMAIN', 'First Domain')" | mysql -u root --password=$MYSQLPASSWORD mail
echo "INSERT INTO mailbox (domain_id, email, password) VALUES (1, '$ADMINUSER', ENCRYPT('$ADMINUSERPASSWORD', CONCAT('\$6\$', SUBSTRING(SHA(RAND()), -16))))" | mysql -u root --password=$MYSQLPASSWORD mail

# Install Horde from source
apt-get install -y git
mkdir -p /horde/data
mkdir -p /horde/src
mkdir -p /horde/data/vfs

# Clone Git master
if [ "$GIT_DEPTH" = "shallow" ]
then
    git clone --depth 1 https://github.com/horde/horde.git /horde/src
else
    git clone https://github.com/horde/horde.git /horde/src
fi

# Needed so we can copy the install_dev.conf file.
chown vagrant:vagrant /horde/src/framework/bin

# Move prebuilt configuration over.
echo 'Copying configuration files.'
cp /vagrant/conf/horde/* /horde/src/horde/config/
cp /vagrant/conf/imp/* /horde/src/imp/config/
cp /vagrant/conf/kronolith/* /horde/src/kronolith/config/
cp /vagrant/conf/turba/* /horde/src/turba/config/
cp /vagrant/conf/ingo/* /horde/src/ingo/config/
chown www-data:www-data /horde/src/horde/config/conf.php

# Install framework
cp /vagrant/conf/install_dev.conf /horde/src/framework/bin
/horde/src/framework/bin/pear_batch_install -p ../framework/Role
/horde/src/framework/bin/install_dev

echo 'Restarting Apache.'
/etc/init.d/apache2 restart

/horde/src/horde/bin/horde-db-migrate
/horde/src/horde/bin/horde-db-migrate
/horde/src/horde/bin/horde-db-migrate