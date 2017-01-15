#!/usr/bin/env bash

# TODO, make this configurable.
echo 'Provisioning Environment with Postfix.';
if which postfix > /dev/null; then
    echo 'Postfix is already installed.'
else
    debconf-set-selections <<< "postfix postfix/mailname string $HOSTNAME"
    debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet Site"
    sudo apt-get install -y postfix postfix-mysql Postgrey

    postconf -e 'smtpd_tls_security_level = may'
    postconf -e 'smtp_tls_security_level = may'

    # Ensure we're not using no-longer-secure protocols.
    postconf -e 'smtpd_tls_mandatory_protocols= '
    postconf -e 'smtp_tls_note_starttls_offer = yes'
    postconf -e 'smtpd_tls_loglevel = 1'
    postconf -e 'smtpd_tls_received_header = yes'

    # Logjam prevention https://weakdh.org/sysadmin.html
    postconf -e 'smtpd_tls_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, PSK, aECDH, EDH-DSS-DES-CBC3-SHA, EDH-RSA-DES-CDC3-SHA, KRB5-DE5, CBC3-SHA'
    postconf -e 'smtpd_tls_dh1024_param_file = /etc/ssl/private/dhparams.pem'

    postconf -e 'smtpd_helo_restrictions = permit_mynetworks, warn_if_reject reject_non_fqdn_hostname, reject_invalid_hostname, permit'
    postconf -e 'smtpd_sender_restrictions = permit_mynetworks, reject_authenticated_sender_login_mismatch, warn_if_reject reject_non_fqdn_sender, reject_unknown_sender_domain, reject_unauth_pipelining, permit'
    postconf -e 'smtpd_client_restrictions = reject_rbl_client sbl.spamhaus.org, reject_rbl_client blackholes.easynet.nl'

    # Note that this enables Postgrey and SPF checks, so they must be installed.
    postconf -e 'smtpd_recipient_restrictions = reject_unauth_pipelining, permit_mynetworks, reject_non_fqdn_recipient, reject_unknown_recipient_domain, reject_unauth_destination, check_policy_service unix:private/policyd-spf, check_policy_service inet:127.0.0.1:10023, permit'
    postconf -e 'smtpd_data_restrictions = reject_unauth_pipelining'
    postconf -e 'smtpd_relay_restrictions = reject_unauth_pipelining, permit_mynetworks, reject_non_fqdn_recipient, reject_unknown_recipient_domain, reject_unauth_destination, check_policy_service inet:127.0.0.1:10023, permit'
    postconf -e 'smtpd_helo_required = yes'

    # Piss off spammers.
    postconf -e 'smtpd_delay_reject = yes'
    postconf -e 'disable_vrfy_command = yes'

    postconf -e 'mydestination = localhost'
    postconf -e "myhostname = $HOSTNAME"
    postconf -e 'myorigin = /etc/hostname'
    postconf -e 'mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128'
    postconf -e 'mynetworks_style = host'
    postconf -e 'recipient_delimiter = +'
    postconf -e 'inet_interfaces = all'

    # Specific to backup MX
    postconf -e 'relay_recipient_maps = hash:/etc/postfix/relay_recipients'
    postconf -e "relay_domains = theupstairsroom.com"
    # CHANGE THIS TO REAL IP
    #postconf -e "proxy_interfaces = 212.47.236.196"
    postconf -e "proxy_interfaces = $HOSTNAME"


    postconf -M smtp-amavis/unix="smtp-amavis     unix    -   -   -   - 3 smtp"
    postconf -P smtp-amavis/unix/smtp_data_done_timeout=1200
    postconf -P smtp-amavis/unix/smtp_send_xforward_command=yes
    postconf -P smtp-amavis/unix/disable_dns_lookups=yes
    postconf -P smtp-amavis/unix/max_use=20

    postconf -M 127.0.0.1:10025/inet="127.0.0.1:10025    inet  n     -   -   -   -   smtpd"
    postconf -P 127.0.0.1:10025/inet/content_filter=
    postconf -P 127.0.0.1:10025/inet/local_recipient_maps=
    postconf -P 127.0.0.1:10025/inet/smtpd_restriction_classes=
    postconf -P 127.0.0.1:10025/inet/smtpd_delay_reject=no
    postconf -P 127.0.0.1:10025/inet/smtpd_client_restrictions=permit_mynetworks,reject
    postconf -P 127.0.0.1:10025/inet/smtpd_helo_restrictions=
    postconf -P 127.0.0.1:10025/inet/smtpd_sender_restrictions=
    postconf -P 127.0.0.1:10025/inet/smtpd_recipient_restrictions=permit_mynetworks,reject
    postconf -P 127.0.0.1:10025/inet/smtpd_data_restrictions=reject_unauth_pipelining
    postconf -P 127.0.0.1:10025/inet/smtpd_end_of_data_restrictions=
    postconf -P 127.0.0.1:10025/inet/mynetworks=127.0.0.0/8
    postconf -P 127.0.0.1:10025/inet/smtpd_error_sleep_time=0
    postconf -P 127.0.0.1:10025/inet/smtpd_soft_error_limit=1001
    postconf -P 127.0.0.1:10025/inet/smtpd_hard_error_limit=1000
    postconf -P 127.0.0.1:10025/inet/smtpd_client_connection_count_limit=0
    postconf -P 127.0.0.1:10025/inet/smtpd_client_connection_rate_limit=0
    postconf -P 127.0.0.1:10025/inet/receive_override_options=no_header_body_checks,no_unknown_recipient_checks

    service postfix reload
fi
