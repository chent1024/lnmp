#!/bin/bash
if [ ! $USER = root ];then
	echo "Please run this script as root."
	exit 1
fi

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#配置
WORK_DIR=$(pwd)

INSTALL_DIR_PHP72=/opt/app/php7.2
INSTALL_DIR_NGINX=/opt/app/nginx

HTTP_USER=www

groupadd $HTTP_USER
useradd -s /sbin/nologin -g $HTTP_USER $HTTP_USER

# echo 'LANG="en_US.UTF-8"' > /etc/sysconfig/i18n

. ./include/common.sh
. ./include/tengine.sh
. ./include/php72.sh

Start_Install()
{
    RemoveAmp
    Disable_Selinux
    Install_Deps
    Install_Tengine
    Install_PHP72

    yum clean all
    rm -rf /var/cache/yum/*
    rm -rf /tmp/pear
}

Start_Install 2>&1 | tee ./install.log

netstat -nltp

exit 1


