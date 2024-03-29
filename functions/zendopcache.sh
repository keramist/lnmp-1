#!/bin/bash
# Web: http://lnmp.yunnan.ws
# Support: tekintian@gmail.com

Install_ZendOPcache()
{
cd $lnmp_dir/src
. ../options.conf

#rm -rf ZendOptimizerPlus-master*

if [ -s $lnmp_dir/src/ZendOptimizerPlus-master.zip ]; then
  echo "ZendOptimizerPlus-master.zip [found]"
  else
  echo "Error: ZendOptimizerPlus-master.zip not found!!!download now......"
  wget -c --no-check-certificate -O ZendOptimizerPlus-master.zip https://github.com/zendtech/ZendOptimizerPlus/archive/master.zip
  if [ $? -eq 0 ]; then
	echo "Download ZendOptimizerPlus-master.zip successfully!"
  else
  	echo "Download ZendOptimizerPlus-master.zip  error!"
  fi
fi
echo "Unzip ZendOptimizerPlus-master.zip"
unzip -q ZendOptimizerPlus-master.zip 
cd ZendOptimizerPlus-master 
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
Mem=`free -m | awk '/Mem:/{print $2}'`
if [ $Mem -gt 1024 -a $Mem -le 1500 ];then
        Memory_limit=192
elif [ $Mem -gt 1500 -a $Mem -le 3500 ];then
        Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
        Memory_limit=320
elif [ $Mem -gt 4500 ];then
        Memory_limit=448
else
        Memory_limit=128
fi

if [ ! -z "`ls $php_install_dir | grep 53`" ];then
        php-fpm=php-fpm53
 elif [ ! -z "`ls $php_install_dir | grep 54`" ];then
    php-fpm=php-fpm54
fi


if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/opcache.so" ];then
ln -s "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/opcache.so" $php_install_dir/zend/opcache.so

        cat >> $php_install_dir/etc/php.ini << EOF
[opcache]
zend_extension="$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/opcache.so"
opcache.memory_consumption=$Memory_limit
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
opcache.optimization_level=0
EOF
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service "$php-fpm" restart || service httpd restart
else
        echo -e "\033[31meZend OPcache module install failed, Please contact the author! \033[0m"
fi
cd ..
/bin/rm -rf ZendOptimizerPlus-master
cd ..
}
