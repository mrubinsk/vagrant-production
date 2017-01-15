pear-horde-5.2-production
=========================

Vagrant image for a full production-ready email server. Builds a full mail and
web stack including the following:

Email
=====

- Postfix/Dovecot with SASL/TLS and SQL based virtual domains/users
- Amavisd/ClamAV/SA/Postgrey/postfix-policyd-spf
- OpenDKIM
- Dovecot - including replication, shared folders and sieve support.
- MySQL
- Apache/PHP 7
- Installs a Git master checkout of Horde.

Usage:
  - Review the shared/config.sh and config.sh files and edit as appropriate.
  - change to the desired setup/* directory
  - Run "vagrant up". That's it.
    - To destroy, run "vagrant destroy"

Notes:

    - Based on Ubuntu Xenial64.

    - By default, Horde's web root is installed to /var/www/html/horde - this
      can be changed by editing shared/conf.sh file.


THINGS TO DO MANUALLY:

Review locales in bootstrap.sh and enable any that are desired.

Update passwords in conf/horde/conf.php.

ssh key setup for vmail user for replication to work.
(Place id_rsa in $REPLICATIONSSHKEY path and authorized_keys file too, if
setting up replication TO this server).

letsencrypt key setup and ensure path is correct for dovecot/postfix keys.
(Automate renewal?)

SSH  to/from this host at least once to both add the host to known_hosts
and to be sure there are no conflicts/permissions issues.

@TODO change mod to g-w /var/vmail to make ssh happy.

Copy any existing DKIM keys that may be desired.

Edit/create appropriate DKIM/SPF entries on the DNS server.

MySql replication?

Horde VFS rsync?
Horde Config rsync?
Sync custom spamassasin/amavis rules?

inotify-tools on master?