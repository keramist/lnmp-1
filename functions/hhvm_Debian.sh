#!/bin/bash
# Web: http://lnmp.yunnan.ws
# Support: tekintian@gmail.com

Install_hhvm_Debian()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf

useradd -M -s /sbin/nologin www

if [ -n "$(cat /etc/redhat-release | grep ' 7\.')" ];then
	CentOS_RHL=7
elif [ -n "$(cat /etc/redhat-release | grep ' 6\.')" ];then
	CentOS_RHL=6
fi

if [ "$CentOS_RHL" == '7' ];then
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
echo deb http://dl.hhvm.com/debian wheezy main | sudo tee /etc/apt/sources.list.d/hhvm.list
apt-get -y update
apt-get -y install hhvm hhvm-fastcgi

userdel -r nginx
rm -rf /var/run/hhvm/ /var/log/hhvm/
mkdir /var/run/hhvm/ /var/log/hhvm/
chown -R www.www /var/run/hhvm /var/log/hhvm

cat > /etc/hhvm/config.hdf << EOF
ResourceLimit {
  CoreFileSize = 0          # in bytes
  MaxSocket = 10000         # must be not 0, otherwise HHVM will not start
  SocketDefaultTimeout = 5  # in seconds
  MaxRSS = 0
  MaxRSSPollingCycle = 0    # in seconds, how often to check max memory
  DropCacheCycle = 0        # in seconds, how often to drop disk cache
}

Log {
  Level = Info
  AlwaysLogUnhandledExceptions = true
  RuntimeErrorReportingLevel = 8191
  UseLogFile = true
  UseSyslog = false
  File = /var/log/hhvm/error.log
  Access {
    * {
      File = /var/log/hhvm/access.log
      Format = %h %l %u % t \"%r\" %>s %b
    }
  }
}

MySQL {
  ReadOnly = false
  ConnectTimeout = 1000      # in ms
  ReadTimeout = 1000         # in ms
  SlowQueryThreshold = 1000  # in ms, log slow queries as errors
  KillOnTimeout = false
}

Mail {
  SendmailPath = /usr/sbin/sendmail -t -i
  ForceExtraParameters =
}
EOF

cat > /etc/hhvm/server.ini << EOF
; php options
pid = /var/run/hhvm/pid

; hhvm specific
;hhvm.server.port = 9001
hhvm.server.file_socket = /var/run/hhvm/sock
hhvm.server.type = fastcgi
hhvm.server.default_document = index.php
hhvm.log.use_log_file = true
hhvm.log.file = /var/log/hhvm/error.log
hhvm.repo.central.path = /var/run/hhvm/hhvm.hhbc
EOF

cat > /etc/hhvm/php.ini << EOF
hhvm.mysql.socket = /var/run/mysqld/mysqld.sock
expose_php = 0
memory_limit = 400000000
post_max_size = 50000000
EOF


/bin/cp ../init/hhvm-init-Debian /etc/init.d/hhvm
chmod +x /etc/init.d/hhvm

update-rc.d hhvm defaults
service hhvm start


if [ -e "/usr/bin/hhvm" -o -e "/usr/local/bin/hhvm" ];then
	sed -i 's@/dev/shm/php-cgi.sock@/var/run/hhvm/sock@' $web_install_dir/conf/nginx.conf 
	[ -z "`grep 'fastcgi_param SCRIPT_FILENAME' $web_install_dir/conf/nginx.conf`" ] && sed -i "s@fastcgi_index index.php;@&\n\t\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;@" $web_install_dir/conf/nginx.conf 
	sed -i 's@include fastcgi.conf;@include fastcgi_params;@' $web_install_dir/conf/nginx.conf 
	service nginx reload
fi
cd ..
}
