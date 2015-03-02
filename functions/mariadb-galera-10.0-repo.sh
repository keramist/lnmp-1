#!/bin/bash
# Author:  Tekin
# Web: http://lnmp.tekin.cn

Install_MariaDB-Galera-10-0-repo()
{
cd $lnmp_dir/src
. ../functions/check_os.sh
. ../options.conf

apt-get install -y software-properties-common python-software-properties
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.0/debian wheezy main'
apt-get update
# reserve the lock issue
rm -rf /var/cache/apt/archives/lock
rm -rf /var/lib/dpkg/lock

apt-get install -y rsync mariadb-galera-server-10.0 libmariadbclient-dev

service mysql stop

mkdir -p $mariadb_data_dir
mv /var/lib/mysql/* $mariadb_data_dir
chown -R mysql.mysql $mariadb_data_dir

# my.cf
cat > /etc/mysql/my.cnf << EOF
[client]
port		= 3306
socket		= /tmp/mysql.sock

[mysqld_safe]
socket		= /tmp/mysql.sock
nice		= 0

[mysqld]
user		= mysql
pid-file	= $mariadb_data_dir/mysql.pid
socket = /tmp/mysql.sock
port = 3306
basedir		= /usr
datadir = $mariadb_data_dir
tmpdir		= /tmp
lc_messages_dir	= /usr/share/mysql
lc_messages	= en_US
skip-external-locking

bind-address = 0.0.0.0
server-id = 1

max_connections = 1000
connect_timeout		= 5
wait_timeout		= 600
max_allowed_packet = 16M
thread_cache_size       = 128
sort_buffer_size	= 4M
bulk_insert_buffer_size	= 16M
tmp_table_size		= 32M
max_heap_table_size	= 32M

# Automatically check and repair not properly closed MyISAM tables. 
#myisam_recover=BACKUP,FORCE

myisam_recover  = BACKUP,FORCE
key_buffer_size		= 64M

table_open_cache = 400
concurrent_insert	= 2
read_buffer_size	= 2M
read_rnd_buffer_size	= 1M

query_cache_limit		= 128K
query_cache_size = 64M

log_warnings		= 2

slow_query_log_file	= /var/log/mysql/mariadb-slow.log
long_query_time = 10

log_slow_verbosity	= query_plan

log_bin			= /var/log/mysql/mariadb-bin
log_bin_index		= /var/log/mysql/mariadb-bin.index

expire_logs_days	= 7
max_binlog_size         = 50M
#default_storage_engine = InnoDB
default_storage_engine	= MyISAM
skip-innodb

innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
quote-names
max_allowed_packet	= 16M

[mysql]

[isamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
!includedir /etc/mysql/conf.d/
EOF

Memtatol=`free -m | grep 'Mem:' | awk '{print $2}'`
if [ $Memtatol -gt 1500 -a $Memtatol -le 2500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' /etc/mysql/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 16M@' /etc/mysql/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/mysql/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' /etc/mysql/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' /etc/mysql/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' /etc/mysql/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/mysql/my.cnf
elif [ $Memtatol -gt 2500 -a $Memtatol -le 3500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' /etc/mysql/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 32M@' /etc/mysql/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/mysql/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/mysql/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' /etc/mysql/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' /etc/mysql/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/mysql/my.cnf
elif [ $Memtatol -gt 3500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' /etc/mysql/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 64M@' /etc/mysql/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/mysql/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' /etc/mysql/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' /etc/mysql/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' /etc/mysql/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 1024@' /etc/mysql/my.cnf
fi

service mysql start

ln -s /tmp/mysql.sock /var/run/mysqld/mysqld.sock

/usr/bin

sed -i "s@^socket.*@socket = /tmp/mysql.sock@" /etc/mysql/debian.cnf

sed -i "s@^db_install_dir.*@db_install_dir=/usr@" options.conf
sed -i "s@^db_data_dir.*@db_data_dir=$mariadb_data_dir@" options.conf

service mysql stop
}
