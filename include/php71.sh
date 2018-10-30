#!/bin/bash

Install_PHP71()
{
    echo "============================PHP71 Install start=================================="
    if [ -d $INSTALL_DIR_PHP71/sbin ];then
        echo "php71 has been installed"
        return 0
    fi

    libmcrypt_url=https://cytranet.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
    iconv_url=https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
    php71_url=http://cn2.php.net/get/php-7.1.23.tar.gz/from/this/mirror

    if [ ! -d $WORK_DIR/tmp/libmcrypt ]; then \
        mkdir -p $WORK_DIR/tmp/libmcrypt
    fi

    if [ ! -d $WORK_DIR/tmp/iconv ]; then \
        mkdir -p $WORK_DIR/tmp/iconv
    fi

    if [ ! -d $WORK_DIR/tmp/php71 ]; then \
        mkdir -p $WORK_DIR/tmp/php71
    fi

    cd $WORK_DIR/tmp

    if [ ! -f libmcrypt.tar.gz ];then
        wget --progress=bar:force -O libmcrypt.tar.gz $libmcrypt_url
    fi
    tar -xf ./libmcrypt.tar.gz -C ./libmcrypt --strip-components=1

    if [ ! -f iconv.tar.gz ];then
        wget --progress=bar:force -O iconv.tar.gz $iconv_url
    fi
    tar -xf ./iconv.tar.gz -C ./iconv --strip-components=1

    if [ ! -f php71.tar.gz ];then
        wget --progress=bar:force -O php71.tar.gz $php71_url
    fi
    tar -xf ./php71.tar.gz -C ./php71 --strip-components=1
    
    cd $WORK_DIR/tmp/libmcrypt
    ./configure
    make && make install

    cd $WORK_DIR/tmp/iconv
    ./configure --enable-static
    make && make install

    cd $WORK_DIR/tmp/php71
    ./configure \
        --prefix=$INSTALL_DIR_PHP71 \
        --enable-fpm \
        --with-fpm-user=$HTTP_USER \
        --with-fpm-group=$HTTP_USER \
        --with-config-file-path=$INSTALL_DIR_PHP71/etc \
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
    cp $WORK_DIR/conf/php71.ini $INSTALL_DIR_PHP71/etc/php.ini
    cp $WORK_DIR/conf/php71-fpm.conf $INSTALL_DIR_PHP71/etc/php-fpm.conf
    cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm71
    chmod u+x /etc/init.d/php-fpm71
    chkconfig --add php-fpm71
     
    #安装扩展
    $INSTALL_DIR_PHP71/bin/pecl channel-update pecl.php.net
    $INSTALL_DIR_PHP71/bin/pecl install lzf
    $INSTALL_DIR_PHP71/bin/pecl install igbinary
    $INSTALL_DIR_PHP71/bin/pecl install redis

    #PHP环境变量
    echo 'if [ -d "$INSTALL_DIR_PHP71" ] ; then
        PATH=$PATH:$INSTALL_DIR_PHP71
        export PATH
    fi' > env_php.sh
    sudo mv env_php.sh /etc/profile.d/env_php.sh

    #启动
    service php-fpm71 restart

    #composer
    wget https://getcomposer.org/composer.phar
    mv composer.phar /usr/bin/composer
    chmod a+x /usr/bin/composer
    #composer 设置中国全量镜像
    composer config -g repo.packagist composer https://packagist.phpcomposer.com

    echo "============================PHP71 Install end=================================="
    cd $WORK_DIR
}

