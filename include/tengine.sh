#!/bin/bash

Install_Tengine()
{
    echo "============================Tengine Install start=================================="
    if [ -d $INSTALL_DIR_NGINX/sbin ];then
        echo "tengine has been installed"
        return 0
    fi

    tengine_url=http://tengine.taobao.org/download/tengine-2.3.2.tar.gz

    if [ ! -d $WORK_DIR/tmp ];then
        mkdir -p $WORK_DIR/tmp
    fi
    
    cd $WORK_DIR/tmp

    Download $tengine_url tengine.tar.gz
    Targz ./tengine.tar.gz ./tengine

    cd $WORK_DIR/tmp/tengine
    ./configure \
        --prefix=$INSTALL_DIR_NGINX \
        --user=www \
        --group=www \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_realip_module \
        --with-http_sub_module \
        --with-http_stub_status_module \
        --with-pcre-jit \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_auth_request_module \
        --with-threads \
        --with-http_slice_module \
        --with-file-aio \
        --with-http_v2_module
    make -j4 && make install

    #配置
    rm -f $INSTALL_DIR_NGINX/conf/nginx.conf
    cp $WORK_DIR/conf/nginx.conf $INSTALL_DIR_NGINX/conf/nginx.conf
    mkdir -p $INSTALL_DIR_NGINX/conf/vhosts

    #启动
    $INSTALL_DIR_NGINX/sbin/nginx -s stop
    $INSTALL_DIR_NGINX/sbin/nginx -t
    $INSTALL_DIR_NGINX/sbin/nginx

    echo "============================Tengine Install end=================================="
    cd $WORK_DIR/tmp
}