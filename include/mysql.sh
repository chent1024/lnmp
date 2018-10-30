#!/bin/bash

Install_Mysql()
{
    echo "============================Mysql Install start=================================="
    if [ -d $INSTALL_DIR_MYSQL/bin ];then
        echo "mysql has been installed"
        return 0
    fi

    mysql_url=http://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.24.tar.gz

    if [ ! -d $WORK_DIR/tmp/mysql ];then
        mkdir -p $WORK_DIR/tmp/mysql
    fi

    cd $WORK_DIR/tmp
    if [ ! -f mysql.tar.gz ];then
        wget --progress=bar:force -O mysql.tar.gz $mysql_url
    fi
    tar -xf ./mysql.tar.gz -C $INSTALL_DIR_MYSQL --strip-components=1
    
    rm -f /etc/my.cnf
    cd $WORK_DIR/tmp/mysql
    cmake .
    make -j4
    make install

    groupadd $MYSQL_USER
    useradd -s /sbin/nologin -g $MYSQL_USER $MYSQL_USER

    scripts/mysql_install_db --basedir=$INSTALL_DIR_MYSQL --user=$MYSQL_USER

    #启动项
    cp support-files/mysql.server /etc/init.d/mysql
    chmod u+x /etc/init.d/mysql
    chkconfig --add mysql

    chown -Rf $MYSQL_USER.MYSQL_USER $INSTALL_DIR_MYSQL/data

    cp support-files/my-default.cnf /etc/my.cnf

    #启动
    service mysql start
    $INSTALL_DIR_MYSQL/bin/mysqladmin -u $MYSQL_ROOT password $MYSQL_PWD
    
    echo "============================Mysql Install end=================================="
    cd $WORK_DIR
}