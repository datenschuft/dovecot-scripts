#!/bin/bash
# configure in 90-quota.conf
#service quota-warning {
#  executable = script /usr/local/bin/quota-warning.sh
#  unix_listener quota-warning {
#    user = vmail
#  }
#  user = vmail
#}
#
#
PERCENT=$1
USER=$2
cat <<EOF | /usr/lib/dovecot/dovecot-lda -d $USER -o "plugin/quota=maildir:User quota:noenforcing"
From: postmaster@yoursystem.tld
Subject: Quota Warning

Ihr Postfach ist derzeit zu $PERCENT% gefuellt.
EOF
