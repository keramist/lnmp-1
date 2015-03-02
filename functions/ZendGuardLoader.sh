#!/bin/bash
# Web: http://lnmp.yunnan.ws
# Support: tekintian@gmail.com

Install_ZendGuardLoader()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

php_version=`$php_install_dir/bin/php -r 'echo PHP_VERSION;'`
PHP_version=${php_version%.*}

mkdir -p $php_install_dir/zend

if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ] ;then
	if [ "$PHP_version" == '5.4' ];then
		src_url=http://downloads.zend.com/guard/6.0.0/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz && Download_src
		tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		/bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so $php_install_dir/zend/
		/bin/rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64
	fi

	if [ "$PHP_version" == '5.3' ];then
		src_url=http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz && Download_src
		tar xzf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		/bin/cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so $php_install_dir/zend/
		/bin/rm -rf ZendGuardLoader-php-5.3-linux-glibc23-x86_64
	fi
else
        if [ "$PHP_version" == '5.4' ];then
		src_url=http://downloads.zend.com/guard/6.0.0/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz && Download_src
		tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		/bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so $php_install_dir/zend/
		/bin/rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386
        fi

        if [ "$PHP_version" == '5.3' ];then
		src_url=http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz && Download_src
		tar xzf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		/bin/cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so $php_install_dir/zend/
		/bin/rm -rf ZendGuardLoader-php-5.3-linux-glibc23-i386
        fi
fi

if [ -f "$php_install_dir/zend/ZendGuardLoader.so" ];then
        cat >> $php_install_dir/etc/php.ini << EOF
[Zend Guard Loader]
zend_extension="$php_install_dir/zend/ZendGuardLoader.so"
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
        echo -e "\033[31meZendGuardLoader module install failed, Please contact the author! \033[0m"
fi

# Fix Bug for opcache and zendguard
if [ "$PHP_cache"=='1' ]
sed -i 's@^.*opcache.optimization_level.*@opcache.optimization_level=0@' $php_install_dir/etc/php.ini
else
sed -i 's@^*opcache.optimization_level.*@opcache.optimization_level=1@' $php_install_dir/etc/php.ini
fi


cd ../

}
