#!/bin/bash

Install_PHP72()
{
    echo "============================PHP72 Install start=================================="
    if [ -d $INSTALL_DIR_PHP72/sbin ];then
        echo "php72 has been installed"
        return 0
    fi

    libmcrypt_url=https://cytranet.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
    iconv_url=https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
    php72_url=https://www.php.net/distributions/php-7.2.30.tar.gz
    
    if [ ! -d $WORK_DIR/tmp ];then
        mkdir -p $WORK_DIR/tmp
    fi
    
    cd $WORK_DIR/tmp

    Download $libmcrypt_url libmcrypt.tar.gz
    Targz ./libmcrypt.tar.gz ./libmcrypt

    Download $iconv_url iconv.tar.gz
    Targz ./iconv.tar.gz ./iconv

    Download $php72_url php72.tar.gz
    Targz ./php72.tar.gz ./php72

    cd $WORK_DIR/tmp/libmcrypt
    ./configure
    make && make install

    cd $WORK_DIR/tmp/iconv
    ./configure --enable-static
    make && make install

    cd $WORK_DIR/tmp/php72
    ./configure \
        --prefix=$INSTALL_DIR_PHP72 \
        --enable-fpm \
        --with-fpm-user=$HTTP_USER \
        --with-fpm-group=$HTTP_USER \
        --with-config-file-path=$INSTALL_DIR_PHP72/etc \
        --with-iconv=/usr/local/ \
        --with-mysqli \
        --with-pdo-mysql  \
        --enable-mysqlnd \
        --with-freetype-dir \
        --with-jpeg-dir \
        --with-png-dir \
        --with-zlib \
        --with-libxml-dir=/usr \
        --enable-xml \
        --with-curl \
        --enable-mbregex \
        --enable-mbstring \
        --with-mcrypt \
        --with-gd \
        --with-openssl \
        --with-mhash \
        --enable-pcntl \
        --enable-sockets \
        --with-xmlrpc \
        --enable-zip \
        --enable-soap \
        --with-gettext \
        --enable-fileinfo \
        --enable-maintainer-zts
    make -j4 && make install
    cp $WORK_DIR/conf/php72.ini $INSTALL_DIR_PHP72/etc/php.ini
    cp $WORK_DIR/conf/php72-fpm.conf $INSTALL_DIR_PHP72/etc/php-fpm.conf
    cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm72
    chmod u+x /etc/init.d/php-fpm72
    chkconfig --add php-fpm72
     
    #安装扩展
    $INSTALL_DIR_PHP72/bin/pecl channel-update pecl.php.net
    $INSTALL_DIR_PHP72/bin/pecl install redis

    #PHP环境变量
    sed -i "PATH=\$PATH:$INSTALL_DIR_PHP72/bin
export PATH" /etc/profile
    source /etc/profile

    #启动
    service php-fpm72 restart

    #composer
    # wget --progress=bar:force https://getcomposer.org/composer.phar
    cp $WORK_DIR/composer.phar /usr/bin/composer
    chmod a+x /usr/bin/composer
    #composer 设置中国全量镜像
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
    composer self-update

    echo "============================PHP72 Install end=================================="
    cd $WORK_DIR
}

