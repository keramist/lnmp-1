#!/bin/bash
# Web: http://lnmp.yunnan.ws
# Support: tekintian@gmail.com

Install_PureFTPd-repo()
{
. ../functions/check_os.sh
. ../options.conf

if [ $OS == 'CentOS' ];then
	   yum install -y pure-ftpd-mysql
elif [ $OS == 'Debian' -o $OS == 'Ubuntu' ];then
		apt-get install -y pure-ftpd-mysql
	else
		echo -e "\033[31m Repo install Does not support this OS, more info http://lnmp.tekin.cn ! \033[0m"
		kill -9 $$
fi

/bin/cp $lnmp_dir/conf/pureftpd /etc/init.d/pureftpd
mv /etc/pure-ftpd/db/mysql.conf /etc/pure-ftpd/db/mysql_conf.bak
/bin/cp $lnmp_dir/conf/pureftpd-mysql.conf /etc/pure-ftpd/db/mysql.conf

chmod +x /etc/init.d/pureftpd

OS_CentOS='chkconfig --del pure-ftpd-mysql \n
chkconfig --add pureftpd \n
chkconfig pureftpd on '
OS_Debian_Ubuntu='update-rc.d -f pure-ftpd-mysql remove  \n
update-rc.d pureftpd defaults '
OS_command

rm -rf /etc/init.d/pure-ftpd-mysql

#更改FTP用户的最小ID为500
sed -i "s@^.*@500@" /etc/pure-ftpd/conf/MinUID

#添加锁定用户到自己的目录
sh -c "echo 'yes' > /etc/pure-ftpd/conf/ChrootEveryone" 


conn_ftpusers_dbpwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`

sed -i "s@^MYSQLSocket.*@MYSQLSocket      /tmp/mysql.sock@" /etc/pure-ftpd/db/mysql.conf
sed -i "s@^MYSQLUser .*@MYSQLUser   ftp@" /etc/pure-ftpd/db/mysql.conf
sed -i "s@^MYSQLPassword.*@MYSQLPassword   $conn_ftpusers_dbpwd@" /etc/pure-ftpd/db/mysql.conf
sed -i "s@^MYSQLCrypt.*@MYSQLCrypt      md5@" /etc/pure-ftpd/db/mysql.conf

	sed -i "s@^conn_ftpusers_dbpwd.*@conn_ftpusers_dbpwd=$conn_ftpusers_dbpwd@" options.conf

	sed -i 's/conn_ftpusers_dbpwd/'$conn_ftpusers_dbpwd'/g' conf/script.mysql
	sed -i 's/ftpmanagerpwd/'$ftpmanagerpwd'/g' conf/script.mysql
	ulimit -s unlimited
	service mysql restart
	$db_install_dir/bin/mysql -uroot -p$dbrootpwd < conf/script.mysql
	service pureftpd start

	cd $lnmp_dir/src 
	tar xzf ftp_v2.1.tar.gz
	sed -i 's/tmppasswd/'$conn_ftpusers_dbpwd'/' ftp/config.php
	sed -i "s/myipaddress.com/`echo $local_IP`/" ftp/config.php
	sed -i 's@\$DEFUserID.*;@\$DEFUserID = "501";@' ftp/config.php
	sed -i 's@\$DEFGroupID.*;@\$DEFGroupID = "501";@' ftp/config.php
	sed -i 's@iso-8859-1@UTF-8@' ftp/language/english.php
	/bin/cp ../conf/chinese.php ftp/language/
	sed -i 's@\$LANG.*;@\$LANG = "chinese";@' ftp/config.php
	rm -rf  ftp/install.php
	mv ftp $home_dir/default
	cd ..

	# iptables Ftp
	iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
	iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
	OS_CentOS='service iptables save'
	OS_Debian_Ubuntu='iptables-save > /etc/iptables.up.rules'
	OS_command

}
