#!/bin/bash

Install_Mysql()
{
    echo "============================Mysql Install start=================================="
    if [ -d $INSTALL_DIR_MYSQL/bin ];then
        echo "mysql has been installed"
        return 0
    fi

    mysql_url=https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-boost-5.7.24.tar.gz

    if [ ! -d $WORK_DIR/tmp/mysql ];then
        mkdir -p $WORK_DIR/tmp/mysql
    fi

    cd $WORK_DIR/tmp
    if [ ! -f mysql.tar.gz ];then
        wget --progress=bar:force -O mysql.tar.gz $mysql_url
    fi
    tar -xf ./mysql.tar.gz -C ./mysql --strip-components=1

    rm -f /etc/my.cnf
    cd $WORK_DIR/tmp/mysql
    cp -r boost/boost_1_59_0/ /usr/local/
    cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR_MYSQL \
        -DMYSQL_DATADIR=$INSTALL_DIR_MYSQL/data \
        -DDOWNLOAD_BOOST=1 \
        -DWITH_BOOST=/usr/local/boost_1_59_0 \
        -DSYSCONFDIR=/etc \
        -DEFAULT_CHARSET=utf8 \
        -DDEFAULT_COLLATION=utf8_general_ci \
        -DENABLED_LOCAL_INFILE=1 \
        -DEXTRA_CHARSETS=all
    make -j4
    make install

    groupadd $MYSQL_USER
    useradd -s /sbin/nologin -g $MYSQL_USER $MYSQL_USER

    $INSTALL_DIR_MYSQL/bin/mysqld --initialize-insecure --basedir=$INSTALL_DIR_MYSQL --datadir=$INSTALL_DIR_MYSQL/data --user=$MYSQL_USER

    #启动项
    cp support-files/mysql.server /etc/init.d/mysqld
    chmod u+x /etc/init.d/mysqld
    chkconfig --add mysqld

    chown -Rf $MYSQL_USER.MYSQL_USER $INSTALL_DIR_MYSQL/data

    cp support-files/my-default.cnf /etc/my.cnf

    #启动
    service mysqld start
    $INSTALL_DIR_MYSQL/bin/mysqladmin -u $MYSQL_ROOT password $MYSQL_PWD
    
    echo "============================Mysql Install end=================================="
    cd $WORK_DIR
}