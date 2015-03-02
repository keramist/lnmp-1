#!/bin/bash

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear

#get pwd
sed -i "s@^lnmp_dir.*@lnmp_dir=`pwd`@" ./options.conf

# get local ip address
chmod +x functions/*.py
local_IP=`./functions/get_local_ip.py`

# Definition Directory
. ./options.conf
. functions/check_os.sh


# PHP
sed -i "s@/usr/local/php.*@/usr/local/php53@" $lnmp_dir/options.conf
. functions/php-cgi-5.3.sh
Install_PHP-CGI-5-3 2>&1 | tee -a $lnmp_dir/install_php-cgi-53.log


