#!/bin/bash
service mysqld start &
wait

if [[ -e /firstrun ]]; then
  source /firstrun.sh
fi

wait
service httpd start
wait
service crond start
exec /usr/sbin/sshd -D
