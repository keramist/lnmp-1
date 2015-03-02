#!/bin/bash

#
# Version: 1.0 build 20150218 tekintian@gmail.com
# Notes: LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+ 
#

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
echo "========================================================================="
echo "Install PHP 2.17 for LNMP with PHP 5.3.*,  Written by Licess"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://dev.tekin.cn/"
echo "========================================================================="
cur_dir=$(pwd)

. functions/download.sh 
. ./options.conf
. functions/check_os.sh

src_url=http://museum.php.net/php5/php-5.2.17.tar.gz && Download_src
src_url=http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz && Download_src
src_url=http://soft.vpser.net/lib/autoconf/autoconf-2.13.tar.gz

if [ -s /usr/local/mariadb/bin/mysql ]; then
	ismysql="no"
else
	ismysql="yes"
fi

cur_php_version=`/usr/local/php/bin/php -r 'echo PHP_VERSION;'`
echo "Current PHP Version:$cur_php_version"
	if [[ "$cur_php_version" =~ "5.2." ]]; then
	   echo "Do NOT need to install PHP 5.2.17!"
	   exit 1
	fi

	echo "=================================================="
	echo "You will install PHP 5.2.17"
	echo "=================================================="

	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`

echo "Stoping Nginx..."
$initd_dir/nginx stop
echo "Stoping MySQL..."
$initd_dir/mysql stop
echo "Stoping PHP-FPM..."
$initd_dir/php-fpm53 stop
if [ -s $initd_dir/memceached ]; then
  echo "Stoping Memcached..."
  $initd_dir/memcacehd stop
fi


ln -s /usr/lib64/libevent-1.4.so.2 /usr/local/lib/libevent-1.4.so.2
ln -s /usr/lib64/libltdl.so.7 /usr/lib/libltdl.so.3

echo "Start install autoconf"
tar zxvf autoconf-2.13.tar.gz
cd autoconf-2.13/
./configure --prefix=/usr/local/autoconf-2.13
make && make install
cd ../

echo "Start install php-5.2.17....."
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
rm -rf php-5.2.17
tar zxvf php-5.2.17.tar.gz
gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -d php-5.2.17 -p1
cd php-5.2.17/
wget -c http://soft.vpser.net/web/php/bug/php-5.2.17-max-input-vars.patch
patch -p1 < php-5.2.17-max-input-vars.patch

#
if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ] ;then

   if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
      ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so  /usr/lib/libjpeg.so
      ln -s /usr/lib/x86_64-linux-gnu/libpng.so  /usr/lib/libpng.so
    else
     ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so
     ln -s /usr/lib64/libpng.so /usr/lib/libpng.so
   fi
fi

# linked library
if [ "$ismysql"="yes" ];then
        PHP_MySQL_options="--with-mysql=$db_install_dir --with-mysqli=$db_install_dir/bin/mysql_config "
        
else
  if [ "$DB_ISR"="src" ];then
    ln -s $db_install_dir/include /usr/include/mysql
    PHP_MySQL_options="--with-mysql=$db_install_dir --with-mysqli=$db_install_dir/bin/mysql_config"
  elif [ "$DB_ISR"="repo" ];then
  PHP_MySQL_options="--with-mysql --with-mysqli --with-sqlite --enable-pdo --with-pdo-mysql "
   fi
fi

./buildconf --force
./configure --prefix=/usr/local/php52 --with-config-file-path=/usr/local/php52/etc $PHP_MySQL_options --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic

if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
    cd ext/openssl/
    wget -c http://soft.vpser.net/lnmp/ext/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    patch -p3 <debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    cd ../../
fi
make ZEND_EXTRA_LIBS='-liconv'
make install

cp php.ini-dist /usr/local/php52/etc/php.ini

cd $lnmp_dir/php-5.2.17/ext/pdo_mysql/
/usr/local/php52/bin/phpize
./configure --with-php-config=/usr/local/php52/bin/php-config --with-pdo-mysql=$db_install_dir
make && make install
cd $cur_dir

# php extensions
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php52/lib/php/extensions/no-debug-non-zts-20060613/"\nextension = "pdo_mysql.so"\n#' /usr/local/php52/etc/php.ini
sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/php52/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php52/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php52/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php52/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php52/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php52/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php52/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php52/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php52/etc/php.ini

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    wget -c http://soft.vpser.net/web/zend/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
    tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
	mkdir -p /usr/local/php52/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/php52/zend/
else
    wget -c http://soft.vpser.net/web/zend/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	tar zxvf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	mkdir -p /usr/local/php52/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/php52/zend/
fi

cat >>/usr/local/php52/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer] 
zend_optimizer.optimization_level=1 
zend_extension="/usr/local/php52/zend/ZendOptimizer.so" 
EOF

rm -f /usr/local/php52/etc/php-fpm.conf
wget -c http://soft.vpser.net/lnmp/lnmp0.9/conf/php-fpm.conf
cp php-fpm.conf /usr/local/php52/etc/php-fpm.conf

/usr/local/php52/sbin/php-fpm start
wget -c http://soft.vpser.net/lnmp/ext/init.d.php-fpm5.2
cp init.d.php-fpm5.2 $initd_dir/php-fpm52
chmod +x $initd_dir/php-fpm52


OS_CentOS='chkconfig --add php-fpm52 \n
chkconfig --level 345 php-fpm52 on'
OS_Debian_Ubuntu='update-rc.d php-fpm52 defaults'
OS_command

sed -i 's#/usr/local/php/#/usr/local/php52/#g' /usr/local/php52/etc/php-fpm.conf
sed -i 's#php-cgi.sock#php-cgi52.sock#g' /usr/local/php52/etc/php-fpm.conf
sed -i 's#/usr/local/php/#/usr/local/php52/#g' $initd_dir/php-fpm52

sleep 2

echo "Starting Nginx..."
$initd_dir/nginx start
echo "Starting MySQL..."
$initd_dir/mysqld start
echo "Starting PHP-FPM..."
$initd_dir/php-fpm53 start

if [ -s $initd_dir/memceached ]; then
  echo "Starting Memcached..."
  $initd_dir/memcacehd start
fi
echo "Starting PHP 5.2.17 PHP-FPM..."
$initd_dir/php-fpm52 start

cd $cur_dir

if [ -s /usr/local/php52/sbin/php-fpm ] && [ -s /usr/local/php52/etc/php.ini ] && [ -s /usr/local/php52/bin/php ]; then
echo "========================================================================="
echo "You have successfully install PHP 5.2.17 "
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://dev.tekin.cn/"
echo ""
echo "========================================================================="
else
echo "Failed to install PHP 5.2.17!,you need try to run ./php5.2.17.sh 2>&1 | tee installphp5.2.17.log to record install logs."
fi