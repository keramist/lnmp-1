#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
echo "========================================================================="
echo "Upgrade MySQL to MariaDB for LNMP,  Written by Licess"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://dev.tekin.cn/"
echo "========================================================================="
cur_dir=$(pwd)
upgrade_date=$(date +"%Y%m%d")

old_mysql_version=`/usr/local/mysql/bin/mysql -V | awk '{print $5}' | tr -d ","`
#echo $old_mysql_version


	read -p "Please input your MYSQL root password:" mysql_root_password
cat >testmysqlrootpassword.sql<<EOF
quit
EOF
	/usr/local/mysql/bin/mysql -uroot -p$mysql_root_password<testmysqlrootpassword.sql
	if [ $? -eq 0 ]; then
		echo "MariaDB root password correct.";
	else
		echo "MariaDB root password incorrect!Please check!"
		exit 1
	fi
	rm -rf testmysqlrootpassword.sql
#set mysql version

	mariadb_version=""
	echo "Current MySQL Version:$old_mysql_version"
	echo "You can get version number from https://downloads.mariadb.org/"
	echo "Please input MariaDB Version you want."
	read -p "(example: 5.5.36 ):" mariadb_version
	if [ "$mariadb_version" = "" ]; then
		echo "Error: You must input MariaDB Version!!"
		exit 1
	fi

#do you want to install the InnoDB Storage Engine?
echo "==========================="

	installinnodb="n"
	echo "Do you want to install the InnoDB Storage Engine?"
	read -p "(Default no,if you want please input: y ,if not please press the enter button):" installinnodb

	case "$installinnodb" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install the InnoDB Storage Engine"
	installinnodb="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will NOT install the InnoDB Storage Engine!"
	installinnodb="n"
	;;
	*)
	echo "INPUT error,The InnoDB Storage Engine will NOT install!"
	installinnodb="n"
	esac

	echo "=================================================="
	echo "You will upgrade MySQL $old_mysql_version to MariaDB $mariadb_version"
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

echo "============================check files=================================="
if [ -s mariadb-$mariadb_version.tar.gz ]; then
  	echo "mariadb-$mariadb_version.tar.gz [found]"
  else
  	echo "Error: mariadb-$mariadb_version.tar.gz not found!!!download now......"
  	wget -c https://downloads.mariadb.org/interstitial/mariadb-$mariadb_version/kvm-tarbake-jaunty-x86/mariadb-$mariadb_version.tar.gz
	if [ $? -eq 0 ]; then
		echo "Download mariadb-$mariadb_version.tar.gz successfully!"
	else
		wget -c https://downloads.mariadb.org/interstitial/mariadb-$mariadb_version/source/mariadb-$mariadb_version.tar.gz
	  	if [ $? -eq 0 ]; then
			echo "Download mariadb-$mariadb_version.tar.gz successfully!"
	  	else
			echo "WARNING!May be the MariaDB Version you input was wrong,please check!"
			echo "MariaDB Version input was:"$mariadb_version
			sleep 5
			exit 1
		fi
	fi
fi
echo "============================check files=================================="

function stopall {
	echo "Stoping Nginx..."
	$initd_dir/nginx stop
	if [ -s $initd_dir/httpd ] && [ -s /usr/local/apache ]; then
	echo "Stoping Apache......"
	$initd_dir/httpd -k stop
	else
	echo "Stoping php-fpm......"
	$initd_dir/php-fpm stop
	fi
	if [ -s $initd_dir/memceached ]; then
  		echo "Stoping Memcached..."
 		$initd_dir/memcacehd stop
	fi	
}

function backup_mysql {
	echo "Starting backup all databases..."
	echo "If the database is large, the backup time will be longer."
	/usr/local/mysql/bin/mysqldump -uroot -p$mysql_root_password --all-databases > /root/mysql_all_backup$(date +"%Y%m%d").sql
	if [ $? -eq 0 ]; then
		echo "MariaDB databases backup successfully.";
	else
		echo "MariaDB databases backup failed,Please backup databases manually!"
		exit 1
	fi
	echo "Stoping MySQL..."
	$initd_dir/mysql stop
	echo "Remove autostart..."
	if [ -s /etc/debian_version ]; then
	update-rc.d -f mysql remove
	elif [ -s /etc/redhat-release ]; then
	chkconfig mysql off
	fi
	mv $initd_dir/mysql $initd_dir/mysql2mariadb.bak.$upgrade_date
	mv /etc/my.cnf /etc/my.conf.mysql2mariadbbak.$upgrade_date
}

function upgrade2mariadb {
	echo "Starting upgrade MySQL to MariaDB..."
	cd $cur_dir

	rm -rf mariadb-$mariadb_version
	rm -f /etc/my.cnf
	tar zxf mariadb-$mariadb_version.tar.gz
	cd mariadb-$mariadb_version/
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
	make && make install

	groupadd mariadb
	useradd -s /sbin/nologin -M -g mariadb mariadb

	cp support-files/my-medium.cnf /etc/my.cnf
	sed '/skip-external-locking/i\pid-file = /usr/local/mariadb/var/mariadb.pid' -i /etc/my.cnf
	sed '/skip-external-locking/i\log_error = /usr/local/mariadb/var/mariadb.err' -i /etc/my.cnf
	sed '/skip-external-locking/i\basedir = /usr/local/mariadb' -i /etc/my.cnf
	sed '/skip-external-locking/i\datadir = /usr/local/mariadb/var' -i /etc/my.cnf
	sed '/skip-external-locking/i\user = mariadb' -i /etc/my.cnf
	if [ $installinnodb = "y" ]; then
	sed -i 's:#innodb:innodb:g' /etc/my.cnf
	sed -i 's:/usr/local/mariadb/data:/usr/local/mariadb/var:g' /etc/my.cnf
	else
	sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
	fi

cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
/usr/local/mariadb/lib
/usr/local/lib
EOF

	/usr/local/mariadb/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mariadb --datadir=/usr/local/mariadb/var --user=mariadb
	chown -R mariadb /usr/local/mariadb/var
	chgrp -R mariadb /usr/local/mariadb/.
	cp support-files/mysql.server $initd_dir/mariadb
	chmod 755 $initd_dir/mariadb

	if [ -d "/proc/vz" ];then
		ulimit -s unlimited
	fi
	$initd_dir/mariadb start

	/usr/local/mariadb/bin/mysqladmin -u root password $mysql_root_password

cat > /tmp/mariadb_sec_script<<EOF
use mysql;
update user set password=password('$mysql_root_password') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mariadb/bin/mysql -u root -p$mysql_root_password -h localhost < /tmp/mariadb_sec_script

rm -f /tmp/mariadb_sec_script
mv /usr/local/mysql /usr/local/mysql$(date +"%Y%m%d")
}

function startall {
	echo "import backup databases..."
	/usr/local/mariadb/bin/mysql -u root -p$mysql_root_password < /root/mysql_all_backup$(date +"%Y%m%d").sql
	if [ $? -eq 0 ]; then
		echo "MariaDB databases import successfully.";
	else
		echo "MariaDB databases import failed,Please import databases manually!"
	fi

	echo "Repair databases..."
	/usr/local/mariadb/bin/mysql_upgrade -u root -p$mysql_root_password

	rm -f /usr/bin/mysql
	rm -f /usr/bin/mysqldump
	rm -f /usr/bin/myisamchk
	rm -f /usr/bin/mysqld_safe
	ln -s /usr/local/mariadb/bin/mysql /usr/bin/mysql
	ln -s /usr/local/mariadb/bin/mysqldump /usr/bin/mysqldump
	ln -s /usr/local/mariadb/bin/myisamchk /usr/bin/myisamchk
	ln -s /usr/local/mariadb/bin/mysqld_safe /usr/bin/mysqld_safe

	if [ -s /root/lnmpa ]; then
		sed -i 's:$initd_dir/mysql:$initd_dir/mariadb:g' /root/lnmpa
	else
		sed -i 's:$initd_dir/mysql:$initd_dir/mariadb:g' /root/lnmp
	fi

	echo "Start Nginx..."
	$initd_dir/nginx start
	if [ -s $initd_dir/httpd ] && [ -s /usr/local/apache ]; then
	echo "Start Apache......"
	$initd_dir/httpd -k start
	else
	echo "Start php-fpm......"
	$initd_dir/php-fpm start
	fi
	if [ -s $initd_dir/memceached ]; then
		echo "Start Memcached..."
		$initd_dir/memcacehd start
	fi
	echo "Add to autostart..."
	if [ -s /etc/debian_version ]; then
	update-rc.d -f mariadb defaults
	elif [ -s /etc/redhat-release ]; then
	chkconfig --level 345 mariadb on
	fi
	echo "Restart MariaDB..."
	$initd_dir/mariadb restart

	cd $cur_dir
}


stopall  2>&1 | tee -a /root/mysql2mariadb_upgrade$upgrade_date.log

backup_mysql  2>&1 | tee -a /root/mysql2mariadb_upgrade$upgrade_date.log

upgrade2mariadb  2>&1 | tee -a /root/mysql2mariadb_upgrade$upgrade_date.log

startall  2>&1 | tee -a /root/mysql2mariadb_upgrade$upgrade_date.log

echo "========================================================================="
echo "You have successfully upgrade MySQL $old_mysql_version to MariaDB $mariadb_version"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://dev.tekin.cn/"
echo ""
echo "========================================================================="