#!/usr/bin/env bash

echo 'Installing and configuring letsencrypt certs.'
apt-get -y install letsencrypt python-letsencrypt-apache
letsencrypt --apache --domains $HOSTNAME --email $ADMINEMAIL --agree-tos -n
