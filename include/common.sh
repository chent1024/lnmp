#!/bin/bash

Disable_Selinux()
{
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

Install_Deps()
{
    echo "[-] Yum install deps packages ..."
    yum -y update
    yum -y install wget git ca-certificates \
        make cmake gcc autoconf gcc-c++ file pcre-devel libaio m4 \
        libtool libtool-libs \
        libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel \
        libxml2 libxml2-devel \
        zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel \
        libevent libevent-devel \
        ncurses ncurses-devel curl curl-devel libcurl-devel \
        openssl openssl-devel \
        gettext gettext-devel gmp-devel pspell-devel unzip

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

Download()
{
    local URL=$1
    local FileName=$2
    echo ${URL}
    echo ${FileName}
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "wget"
        wget --progress=bar:force -O ${FileName} ${URL}
    fi
}

Targz()
{
    local Filename=$1
    local Target=$2
    if [ ! -d ${Target} ]; then
        mkdir -p ${Target}
    fi

    tar -xf ${Filename} -C ${Target} --strip-components=1
}