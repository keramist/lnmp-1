#!/bin/bash
# Web: http://lnmp.yunnan.ws
# Support: tekintian@gmail.com

if [ -f /etc/redhat-release ];then
        OS=CentOS
         sed -i 's@^initd_dir.*@initd_dir=/etc/rc.d/init.d@' $lnmp_dir/options.conf
elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=Debian
        sed -i 's@^initd_dir.*@initd_dir=/etc/init.d@' $lnmp_dir/options.conf
elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=Ubuntu
        sed -i 's@^initd_dir.*@initd_dir=/etc/init.d@' $lnmp_dir/options.conf
else
        echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
        kill -9 $$
fi

OS_command()
{
	if [ $OS == 'CentOS' ];then
	        echo -e $OS_CentOS | bash
	elif [ $OS == 'Debian' -o $OS == 'Ubuntu' ];then
		echo -e $OS_Debian_Ubuntu | bash
	else
		echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
		kill -9 $$
	fi
}
