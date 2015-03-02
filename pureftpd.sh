# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#    LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+    #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################"

#get pwd
sed -i "s@^lnmp_dir.*@lnmp_dir=`pwd`@" ./options.conf

# get local ip address
local_IP=`./functions/get_local_ip.py`

# Definition Directory
. ./options.conf
. functions/check_os.sh

chmod +x functions/*.sh init/* *.sh

. functions/pureftpd.sh
Install_PureFTPd 2>&1 | tee -a $lnmp_dir/pureftpd-install.log 

