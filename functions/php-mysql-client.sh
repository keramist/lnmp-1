#!/bin/bash
# Web: http://lnmp.yunnan.ws
# Support: tekintian@gmail.com

Install_PHP-MySQL-Client()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf

src_url=http://cdn.mysql.com/Downloads/MySQL-5.5/mysql-5.5.41.tar.gz && Download_src
tar zxf mysql-5.5.41.tar.gz
cd mysql-5.5.41
cmake . -DCMAKE_INSTALL_PREFIX=$mysql_install_dir
make mysqlclient libmysql 
mkdir -p $mysql_install_dir/{lib,bin}
/bin/cp libmysql/libmysqlclient* $mysql_install_dir/lib
/bin/cp scripts/mysql_config $mysql_install_dir/bin
/bin/cp -R include $mysql_install_dir
cd ..
/bin/rm -rf mysql-5.5.41
cd ..
}
