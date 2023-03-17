#!/usr/bin/env bash

set -e
set -o nounset
set -o pipefail

trap exit SIGINT
trap exit SIGTERM

USERPASSWORD=${MAILBOX_PASSWD:-vmail}

# check and create maildir

if [[ ! -d /home/vmail/.mails ]]; then
    mkdir -p /home/vmail/.mails
fi
chown -R vmail:vmail /home/vmail/.mails/

# set mailbox location

echo "mail_location = Maildir:~/.mails" >> /etc/dovecot/conf.d/10-mail.conf

# set password

sed -i \
    -e 's,scheme=CRYPT,scheme=SHA256-CRYPT,' \
    /etc/dovecot/conf.d/auth-passwdfile.conf.ext

if [[ ${USERPASSWORD} != *"CRYPT"* ]]; then
	USERPASSWORD=`doveadm pw -s SHA256-CRYPT -p${USERPASSWORD}`
fi

echo "vmail:${USERPASSWORD}:1000:1000::/home/vmail::" > /etc/dovecot/users # user:password:uid:gid:(gecos):home:(shell):extra_fields

# run supervisord or command

if [ -z "$@" ]; then
    exec supervisord -c /etc/supervisor/supervisord.conf
else
    exec "$@"
fi
