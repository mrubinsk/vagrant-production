#!/usr/bin/env bash
replication="service replicator {\n
  process_min_avail = 1\n
  unix_listener replicator-doveadm {\n
    mode = 0600\n
  }\n
}\n
dsync_remote_cmd = ssh -i $REPLICATIONSSHKEY vmail@$REPLICATIONHOST doveadm dsync-server -u %u\n
plugin {\n
  mail_replica =  remote:vmail@$REPLICATIONHOST\n
}\n
service aggregator {\n
  fifo_listener replication-notify-fifo {\n
    user = vmail\n
  }\n
  unix_listener replication-notify {\n
    user = vmail\n
  }\n
}\n"
echo -e $replication | sudo tee -a /etc/dovecot/conf.d/10-master.conf