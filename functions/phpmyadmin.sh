#!/bin/bash
# Web: http://lnmp.yunnan.ws
# Support: tekintian@gmail.com

Install_phpMyAdmin()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf 

src_url=http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/$phpMyAdmin_version/phpMyAdmin-$phpMyAdmin_version-all-languages.tar.gz && Download_src

tar xzf phpMyAdmin-$phpMyAdmin_version-all-languages.tar.gz
/bin/mv phpMyAdmin-$phpMyAdmin_version-all-languages $home_dir/default/phpMyAdmin
/bin/cp $home_dir/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
mkdir $home_dir/default/phpMyAdmin/{upload,save}
sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" $home_dir/default/phpMyAdmin/config.inc.php
sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" $home_dir/default/phpMyAdmin/config.inc.php
chown -R www.www $home_dir/default/phpMyAdmin
cd ..
}
