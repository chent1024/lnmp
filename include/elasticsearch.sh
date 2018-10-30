#!/bin/bash

Install_Es()
{
    echo "============================Elasticsearch Install start=================================="
    if [ -d $INSTALL_DIR_ES/bin ];then
        echo "elasticsearch has been installed"
        return 0
    fi

    elastic_url=https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.tar.gz
    elastic_passwd='ikuaiping#520***'
    

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
    yum install -y java-1.8.0-openjdk sshpass

    # config
    sed -i -e 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' $INSTALL_DIR_ES/config/elasticsearch.yml
    sed -i -e 's/#http.port: 9200/http.port: 9200/g' $INSTALL_DIR_ES/config/elasticsearch.yml

    groupadd es
    useradd es -g es

    echo $elastic_passwd | sudo passwd es --stdin  &>/dev/null
    if [ $? -eq 0 ];then
        echo "es's password is set successfully"
    else
        echo "es's password is set failly!!!"
    fi
    
    echo "check limits.conf..."
    grep -w 'es.*soft.*nofile.*$' /etc/security/limits.conf > /dev/null
    if [ $? -ne 0 ]; then
        echo "add es limits config ..."
        echo "es soft nofile 65536" >> /etc/security/limits.conf
        echo "es hard nofile 131072" >> /etc/security/limits.conf
        echo "es soft nproc 4096" >> /etc/security/limits.conf
        echo "es hard nproc 4096" >> /etc/security/limits.conf
        sed -ir 's/\(\*.*soft.*nproc\).*$/\1 4096/g' /etc/security/limits.d/20-nproc.conf
        sed -ir 's/\(\*.*soft.*nproc\).*$/\1 4096/g' /etc/security/limits.d/90-nproc.conf
        echo "vm.max_map_count=262144" >> /etc/sysctl.conf
        sysctl -p > /dev/null
        
        echo "add es limits config success"
    else
        echo "es limits config has changed"
    fi

    chown -Rf es.es $INSTALL_DIR_ES

    sshpass -p $elastic_passwd ssh es@localhost "$INSTALL_DIR_ES/bin/elasticsearch -d"

    echo "============================Elasticsearch Install end=================================="
    cd $WORK_DIR/tmp
}
