# dovecot-scripts
dovecot administrate scripts


## dovecot_replicate_sieve.sh
Replicate SIEVE Scripts (and status) on a 2 node dovecot mailbox server setup.
Running on an dovecot director node. (start via cron every 5 Minutes)
Fetching manage-sieve logins to detect the maibox-server-node with the latest sieve scripts of your users.
replication via rsync 

Todo: 
rsync via director-node -> find a better way
dovecot mailbox-servers 10.20.1.6 and 10.20.1.7 hardcoded ->  config file ?
