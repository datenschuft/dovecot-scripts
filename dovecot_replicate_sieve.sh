#!/bin/bash
#
#Replicate SIEVE Scripts (and status) on a 2 node dovecot mailbox server setup.
#Running on an dovecot director node.
#Fetching manage-sieve logins to detect the maibox-server-node with the latest sieve scripts of your users.
#replication via rsync (via director-node)
#dovecot mailbox-servers 10.20.1.6 and 10.20.1.7
#run every x Minutes on all director-servers
# (c) wenger@unifox.at 2018

#checking needed programs
LOGTAIL2="/usr/sbin/logtail2"
if [ ! -x "$LOGTAIL2" ]; then
        echo "$LOGTAIL2 not found; exiting"
        exit 127
fi

# run as root
if [ `id -u` != "0" ]; then
        echo "you have to be root !"
        exit 1
fi
#rest a bit
sleep $(( ( RANDOM % 30 )  + 1 ))

#logtail offset
LOGTAILOFFSET="/var/lib/dovecot_replicate_sieve"
#mail log
MAILLOG="/var/log/mail.log"
mkdir -p $LOGTAILOFFSET
# fetching last sieve logins
echo "$($LOGTAIL2 -o $LOGTAILOFFSET/offset -f $MAILLOG | grep managesieve-login | grep "started proxying" | sort -r | cut -d ' ' -f 1,2,3,11,12 | uniq -f4)" | while read i
do
   if [ ! "$i" = "" ]
   then
        SRCSRV=$(echo $i | awk {'print $4'} | awk -F":" {'print $1'})
        DOVECOTUSER=$(echo $i | awk {'print $5'} | awk -F"<|>" {'print $2'})
        DOVECOTHOME=$(doveadm user -f home -u "$DOVECOTUSER")
        if [ "$SRCSRV" = "10.20.1.7" ]
        then
                OTHERNODE="10.20.1.6"
        fi
        if [ "$SRCSRV" = "10.20.1.6" ]
        then
                OTHERNODE="10.20.1.7"
        fi
        echo "rsync von $SRCSRV $DOVECOTHOME (sieve) zu  $OTHERNODE"
        #set -x
        TMP=$(mktemp -d)
        rsync -au --numeric-ids vmail@$SRCSRV:$DOVECOTHOME/sieve/ $TMP
        rsync -au --numeric-ids $TMP vmail@$OTHERNODE:$DOVECOTHOME/sieve
        rm -r $TMP
        #check for .dovecot.sieve - file
        ssh vmail@$SRCSRV test -e $DOVECOTHOME/.dovecot.sieve
        if [ "$?" = "0" ]
        then
                scp vmail@$SRCSRV:$DOVECOTHOME/.dovecot.sieve /tmp
                scp /tmp/.dovecot.sieve vmail@$OTHERNODE:$DOVECOTHOME/.dovecot.sieve
                rm /tmp/.dovecot.sieve
        else
                ssh vmail@$OTHERNODE rm $DOVECOTHOME/.dovecot.sieve
        fi
   fi
done
