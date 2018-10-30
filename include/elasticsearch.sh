#!/bin/bash

Install_Es()
{
    echo "============================Elasticsearch Install start=================================="
    if [ -d $INSTALL_DIR_ES/bin ];then
        echo "elasticsearch has installed"
        return 0
    fi

    elastic_url=https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.tar.gz

    if [ ! -d tmp/elastic ];then
        mkdir -p $WORK_DIR/tmp/elastic
    fi

    if [ ! -d $INSTALL_DIR_ES ];then
        mkdir -p $INSTALL_DIR_ES
    fi

    cd $WORK_DIR/tmp
    if [ ! -f elastic.tar.gz ];then
        wget --progress=bar:force -O elastic.tar.gz $elastic_url
    fi
    tar -xf ./elastic.tar.gz -C $INSTALL_DIR_ES --strip-components=1
    
    # jdk
    yum install -y java-1.8.0-openjdk
    

}
