   This script is free collection of shell scripts for rapid deployment of `LNMP`/`LAMP`/`LANMP` stacks (`Linux`, `Nginx`/`Tengine`, `MySQL`/`MariaDB`/`Percona` and `PHP`) for CentOS/Redhat Debian and Ubuntu.

   Script features: 
- Constant updates 
- Source compiler installation, most source code is the latest stable version, and downloaded from the official website
- Fixes some security issues 
- You can freely choose to install database version (MySQL-5.6, MySQL-5.5, MariaDB-10.0, MariaDB-10.0 galery, MariaDB-5.5, Percona-5.6, Percona-5.5)
- You can freely choose to install PHP version (php5.2, php-5.3, php-5.4, php-5.5, php-5.6, php-7/phpng(alpha))
- You can freely choose to install PHP version (CentOS6.5 64bit, CentOS7 64bit)
- You can freely choose to install Nginx or Tengine
- You can freely choose to install Apache version (Apache-2.4, Apache-2.2)
- According to their needs can to install ZendOPcache, xcache, APCU, eAccelerator, ionCube and ZendGuardLoader (php-5.4, php-5.3)
- According to their needs can to install Pureftpd, phpMyAdmin
- According to their needs can to install memcached, redis
- According to their needs can to optimize MySQL and Nginx with jemalloc or tcmalloc
- Add a virtual host script provided
- Nginx/Tengine, PHP, Redis, phpMyAdmin upgrade script provided
- Add backup script provided

## How to use 

```bash
   yum -y install wget screen # for CentOS/Redhat
   #apt-get -y install wget screen # for Debian/Ubuntu 
   wget https://github.com/tekintian/lnmp-tiny/archive/master.zip
   #or wget https://github.com/tekintian/lnmp-tiny/archive/master.zip # include source packages
  unzip lnmp-tiny-master.zip
   cd lnmp
   chmod +x install.sh
   # Prevent interrupt the installation process. If the network is down, you can execute commands `screen -r lnmp` network reconnect the installation window.
   screen -S lnmp
   ./install.sh
```
