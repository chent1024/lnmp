#!/bin/bash
if [ ! $USER = root ];then
	echo "Please run this script as root."
	exit 1
fi

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear
echo ""
echo "+------------------------------------------------------------------------+"
echo "|                                 LNMP                                   |"
echo "|                    tengine-lua_module+php7.1.23                        |"
echo "|                                                                        |"
echo "|                         Author: chent                                  |"
echo "|                                                                        |"
echo "|                     Last Modified: 2018-10-29                          |"
echo "|                                                                        |"
echo "+------------------------------------------------------------------------+"
echo "|                 Auto-compile & install LNMP on CentOs                  |"
echo "+------------------------------------------------------------------------+"
echo ""

#配置
WORK_DIR=$(pwd)
INSTALL_DIR_PHP71=/opt/app/php7.1
INSTALL_DIR_NGINX=/opt/app/nginx
LUA_SRC_DIR=/opt/app/lua

# 添加www
groupadd www
useradd -s /sbin/nologin -g www www

# echo 'LANG="en_US.UTF-8"' > /etc/sysconfig/i18n

. ./include/common.sh
. ./include/php71.sh
. ./include/tengine.sh

Start_Install()
{
    RemoveAmp
    Disable_Selinux
    Install_Deps
    Install_Tengine
    Install_PHP71

}

Start_Install 2>&1 | tee ./lnmp-install.log



