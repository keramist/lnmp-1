#!/bin/bash
# Web: http://lnmp.yunnan.ws
# Support: tekintian@gmail.com

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && kill -9 $$

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
echo "#######################################################################"
echo "#         LNMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #"
echo "#                    Upgrade PHP for LNMP                             #"
echo "# For more information Please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"

cd src
. ../options.conf

# PHP
sed -i "s@/usr/local/php53@/usr/local/php56@" $lnmp_dir/options.conf
. functions/php-5.6.sh
Install_PHP-5-6 2>&1 | tee -a $lnmp_dir/install_php56.log


