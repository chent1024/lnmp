#!/bin/bash

Install_Tengine()
{
    echo "============================Tengine Install start=================================="
    if [ -d $INSTALL_DIR_NGINX/sbin ];then
        echo "tengine has installed"
        return 0
    fi

    tengine_url=http://tengine.taobao.org/download/tengine-2.2.2.tar.gz
    lua_url=http://luajit.org/download/LuaJIT-2.0.5.tar.gz
    devel_kit_url=https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz
    lua_nginx_module_url=https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz

    if [ ! -d tmp ]; then \
        mkdir -p $WORK_DIR/tmp/tengine
        mkdir -p $WORK_DIR/tmp/lua
        mkdir -p $WORK_DIR/tmp/devel_kit
        mkdir -p $WORK_DIR/tmp/lua_model
    fi

    cd $WORK_DIR/tmp

    if [ ! -f tengine.tar.gz ];then
        wget --progress=bar:force -O tengine.tar.gz $tengine_url
        wget --progress=bar:force -O lua.tar.gz $lua_url
        wget --progress=bar:force -O devel_kit.tar.gz $devel_kit_url
        wget --progress=bar:force -O lua_model.tar.gz $lua_nginx_module_url
    else
        echo "tengine [found]"
    fi

    tar -xf ./tengine.tar.gz  -C ./tengine --strip-components=1
    tar -xf ./lua.tar.gz  -C ./lua --strip-components=1
    tar -xf ./devel_kit.tar.gz  -C ./devel_kit --strip-components=1
    tar -xf ./lua_model.tar.gz  -C ./lua_model --strip-components=1

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