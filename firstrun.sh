#!/bin/bash
wait

mysql -uroot -e "CREATE DATABASE otrs;CREATE USER 'otrs'@'localhost' IDENTIFIED BY 'otrs';GRANT ALL PRIVILEGES ON otrs.* TO 'otrs'@'localhost' WITH GRANT OPTION;"&
wait
mysql -f -u root otrs < /opt/otrs/scripts/database/otrs-schema.mysql.sql &
wait
mysql -f -u root otrs < /opt/otrs/scripts/database/otrs-initial_insert.mysql.sql &
wait
#/opt/otrs/bin/otrs.SetPassword.pl --agent root@localhost root &
su -c "/opt/otrs/bin/otrs.Console.pl Admin::User::SetPassword root@localhost root" -s /bin/bash otrs &
wait
#/opt/otrs/bin/otrs.RebuildConfig.pl &
su -c "/opt/otrs/bin/otrs.Console.pl Maint::Config::Rebuild" -s /bin/bash otrs &
wait
#/opt/otrs/bin/otrs.PackageManager.pl -a install -p /ITSM-6.0.8.opm &
su -c "/opt/otrs/bin/otrs.Console.pl Admin::Package::Install /ITSM-6.0.8.opm" -s /bin/bash otrs &
wait
/opt/otrs/bin/Cron.sh start otrs &
wait
curl -o /tmp/Znuny4OTRS-Repo.opm https://addons.znuny.com/api/addon_repos/public/1029/latest
#/opt/otrs/bin/otrs.PackageManager.pl -a install -p /tmp/Znuny4OTRS-Repo.opm &
su -c "/opt/otrs/bin/otrs.Console.pl Admin::Package::Install /tmp/Znuny4OTRS-Repo.opm" -s /bin/bash otrs &
wait
rm /firstrun
