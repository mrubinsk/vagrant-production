#!/usr/bin/env bash

#TODO NEED TO MAKE SURE THE DEFAULT NAMESPACE HAS /
shared_namespace="namespace {\n
  separator = /\n
  type = shared\n
  prefix = shared/%%u/\n
  location = maildir:/var/vmail/%%n:INDEX=/home/%u/Maildir/shared/%%u\n
}"

echo -e $shared_namespace | sudo tee -a /etc/dovecot/conf.d/10-mail.conf
echo -e 'mail_plugins = $mail_plugins acl notify replication sieve' | sudo tee -a /etc/dovecot/conf.d/10-mail.conf

if [[ ! -f /etc/dovecot/conf.d/20-imap.conf.orig ]]; then
    mv /etc/dovecot/conf.d/20-imap.conf /etc/dovecot/conf.d/20-imap.conf.orig
fi
echo -e "protocol imap {\n
# Space separated list of plugins to load (default is global mail_plugins).\n
mail_plugins = \$mail_plugins imap_acl\n
}\n" | sudo tee -a /etc/dovecot/conf.d/20-imap.conf

if [[ ! -f /etc/dovecot/conf.d/90-acl.conf.orig ]]; then
    mv /etc/dovecot/conf.d/90-acl.conf /etc/dovecot/conf.d/90-acl.conf.orig
fi
echo -e "plugin {\n
  acl = vfile\n
  acl_shared_dict = file:/var/lib/dovecot/shared-mailboxes
}\n" | sudo tee -a /etc/dovecot/90-acl.conf

chgrp mail /var/lib/dovecot
chmod g+w /var/lib/dovecot
usermod -a -G mail vmail