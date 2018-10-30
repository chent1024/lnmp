#!/bin/bash
if [ ! $USER = root ];then
	echo "Please run this script as root."
	exit 1
fi

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#配置
WORK_DIR=$(pwd)

INSTALL_DIR_PHP71=/opt/app/php7.1
INSTALL_DIR_PHP56=/opt/app/php5.6
INSTALL_DIR_NGINX=/opt/app/nginx
LUA_SRC_DIR=/opt/app/lua
INSTALL_DIR_MYSQL=/opt/app/mysql
INSTALL_DIR_ES=/opt/app/elasticsearch

ELASTIC_USER=es
ELASTIC_PWD=ikuaiping123

MYSQL_USER=mysql
MYSQL_ROOT=root
MYSQL_PWD=ikuaiping123

HTTP_USER=www

# 添加www
groupadd $HTTP_USER
useradd -s /sbin/nologin -g $HTTP_USER $HTTP_USER

# echo 'LANG="en_US.UTF-8"' > /etc/sysconfig/i18n

. ./include/common.sh
. ./include/tengine.sh
. ./include/php71.sh
. ./include/php56.sh
. ./include/elasticsearch.sh
. ./include/mysql.sh

Start_Install()
{
    RemoveAmp
    Disable_Selinux
    Install_Deps
    Install_Tengine
    Install_PHP71
    Install_PHP56
    Install_Es
    Install_Mysql
}

Start_Install 2>&1 | tee ./install.log

netstat -nltp


