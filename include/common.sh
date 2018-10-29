#!/bin/bash

Disable_Selinux()
{
    # if [ -s /etc/selinux/config ]; then
    #     sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    # fi

    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

Install_Deps()
{
    echo "[-] Yum install deps packages ..."
    yum -y update
    yum -y install wget lrzsz ca-certificates \
        make cmake gcc autoconf gcc-c++ gcc-g77 file pcre-devel \
        libtool libtool-libs \
        libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel \
        libxml2 libxml2-devel \
        zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel \
        libevent libevent-devel \
        ncurses ncurses-devel curl curl-devel libcurl-devel \
        e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel \
        openssl openssl-devel \
        gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip

    sh -c 'echo /usr/local/lib > /etc/ld.so.conf.d/local.conf'
    ldconfig -v
}

RemoveAmp()
{
    echo "[-] Yum remove packages ..."
    ###移除系统自带lnmp包
    rpm -qa|grep mysql
    rpm -e mysql
    rpm -qa|grep php
    rpm -e php
    ###删除系统默认安装lnmp
    yum -y remove php*
    yum -y remove mysql-server mysql
    yum -y remove php-mysql
    yum clean all
}