#!/bin/bash

Install_PHP56(){
    echo "============================PHP56 Install start=================================="
    if [ -d $INSTALL_DIR_PHP56/sbin ];then
        echo "php56 has installed"
        return 0
    fi

    imagick_url=https://github.com/ImageMagick/ImageMagick6/archive/6.9.10-13.tar.gz
    php56_url=http://cn2.php.net/get/php-5.6.38.tar.gz/from/this/mirror

    if [ ! -d tmp/php56 ];then
        mkdir -p $WORK_DIR/tmp/php56
    fi
    
    if [ ! -d tmp/imagick ];then
        mkdir -p $WORK_DIR/tmp/imagick
    fi

    cd $WORK_DIR/tmp

    if [ ! -f php56.tar.gz ];then
        wget --progress=bar:force -O php56.tar.gz $php56_url
    fi
    tar -xf ./php56.tar.gz -C ./php56 --strip-components=1

    cd $WORK_DIR/tmp/php56
    ./configure \
        --prefix=$INSTALL_DIR_PHP56 \
        --enable-fpm \
        --with-fpm-user=www \
        --with-fpm-group=www \
        --with-config-file-path=$INSTALL_DIR_PHP56/etc \
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
    cp $WORK_DIR/conf/php56.ini $INSTALL_DIR_PHP56/etc/php.ini
    cp $WORK_DIR/conf/php56-fpm.conf $INSTALL_DIR_PHP56/etc/php-fpm.conf
    cp sapi/fpm/init.d.php-fpm /etc/init.d/php-php56
    chmod u+x /etc/init.d/php-php56
    chkconfig --add php-php56
     
    #安装扩展
    $INSTALL_DIR_PHP56/bin/pecl channel-update pecl.php.net
    $INSTALL_DIR_PHP56/bin/pecl install lzf
    $INSTALL_DIR_PHP56/bin/pecl install igbinary
    $INSTALL_DIR_PHP56/bin/pecl install redis
    $INSTALL_DIR_PHP56/bin/pecl install swoole-1.9.0
    $INSTALL_DIR_PHP56/bin/pecl install mongodb
    $INSTALL_DIR_PHP56/bin/pecl install pthreads-2.0.10
    
    cd $WORK_DIR/tmp

    if [ ! -f imagick.tar.gz ];then
        wget --progress=bar:force -O imagick.tar.gz $imagick_url
    fi
    tar -xf ./imagick.tar.gz -C ./imagick --strip-components=1

    cd $WORK_DIR/tmp/imagick
    ./configure
    make -j4 && make install
    $INSTALL_DIR_PHP56/bin/pecl install imagick

    #启动
    service php-php56 restart

    echo "============================PHP56 Install end=================================="
    cd $WORK_DIR/tmp


}