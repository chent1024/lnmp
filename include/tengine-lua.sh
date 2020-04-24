#!/bin/bash

Install_Tengine()
{
    echo "============================Tengine Install start=================================="
    if [ -d $INSTALL_DIR_NGINX/sbin ];then
        echo "tengine has been installed"
        return 0
    fi

    tengine_url=http://tengine.taobao.org/download/tengine-2.3.2.tar.gz
    lua_url=http://luajit.org/download/LuaJIT-2.0.5.tar.gz
    devel_kit_url=https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz
    lua_nginx_module_url=https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz

    if [ ! -d $WORK_DIR/tmp ];then
        mkdir -p $WORK_DIR/tmp
    fi
    
    cd $WORK_DIR/tmp

    Download $tengine_url tengine.tar.gz
    Targz ./tengine.tar.gz ./tengine

    # Download $lua_url lua.tar.gz
    Targz $WORK_DIR/lua.tar.gz ./lua

    Download $devel_kit_url devel_kit.tar.gz
    Targz ./devel_kit.tar.gz ./devel_kit

    Download $lua_nginx_module_url lua_model.tar.gz
    Targz ./lua_model.tar.gz ./lua_model

    cd $WORK_DIR/tmp/lua
    make PREFIX=/usr/local/luajit
    make install PREFIX=/usr/local/luajit

    export LUAJIT_LIB=/usr/local/luajit/lib
    export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0

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
        --with-http_v2_module \
        --with-ld-opt=-ljemalloc \
        --with-ld-opt=-Wl,-rpath,/usr/local/luajit/lib \
        --add-module=../devel_kit \
        --add-module=../lua_model
    make -j4 && make install

    #配置
    rm -f $INSTALL_DIR_NGINX/conf/nginx.conf
    cp $WORK_DIR/conf/nginx.conf $INSTALL_DIR_NGINX/conf/nginx.conf
    mkdir -p $INSTALL_DIR_NGINX/conf/vhosts
    mkdir -p $LUA_SRC_DIR

    #启动
    $INSTALL_DIR_NGINX/sbin/nginx -s stop
    $INSTALL_DIR_NGINX/sbin/nginx -t
    $INSTALL_DIR_NGINX/sbin/nginx

    echo "============================Tengine Install end=================================="
    cd $WORK_DIR/tmp
}