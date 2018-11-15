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
    if [ ! -d $WORK_DIR/tmp ];then
        mkdir -p $WORK_DIR/tmp
    fi
    
    cd $WORK_DIR/tmp

    Download $elastic_url elastic.tar.gz
    Targz ./elastic.tar.gz $INSTALL_DIR_ES

    # jdk
    yum install -y java-1.8.0-openjdk sshpass

    # config
    sed -i -e 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' $INSTALL_DIR_ES/config/elasticsearch.yml
    sed -i -e 's/#http.port: 9200/http.port: 9200/g' $INSTALL_DIR_ES/config/elasticsearch.yml

    groupadd $ELASTIC_USER
    useradd $ELASTIC_USER -g $ELASTIC_USER

    echo $elastic_passwd | sudo passwd $ELASTIC_USER --stdin  &>/dev/null
    if [ $? -eq 0 ];then
        echo "$ELASTIC_USER's password is set successfully"
    else
        echo "$ELASTIC_USER's password is set failly!!!"
    fi
    
    echo "check limits.conf..."
    grep -w '$ELASTIC_USER.*soft.*nofile.*$' /etc/security/limits.conf > /dev/null
    if [ $? -ne 0 ]; then
        echo "add $ELASTIC_USER limits config ..."
        echo "$ELASTIC_USER soft nofile 65536" >> /etc/security/limits.conf
        echo "$ELASTIC_USER hard nofile 131072" >> /etc/security/limits.conf
        echo "$ELASTIC_USER soft nproc 4096" >> /etc/security/limits.conf
        echo "$ELASTIC_USER hard nproc 4096" >> /etc/security/limits.conf
        if [ -e /etc/security/limits.d/20-nproc.conf ];then
            sed -ir 's/\(\*.*soft.*nproc\).*$/\1 4096/g' /etc/security/limits.d/20-nproc.conf
        fi
        if [ -e /etc/security/limits.d/90-nproc.conf ];then
            sed -ir 's/\(\*.*soft.*nproc\).*$/\1 4096/g' /etc/security/limits.d/90-nproc.conf
        fi
        echo "vm.max_map_count=262144" >> /etc/sysctl.conf
        sysctl -p > /dev/null
        
        echo "add $ELASTIC_USER limits config success"
    else
        echo "$ELASTIC_USER limits config has changed"
    fi

    chown -Rf $ELASTIC_USER.$ELASTIC_USER $INSTALL_DIR_ES

    sshpass -p $elastic_passwd ssh $ELASTIC_USER@localhost "$INSTALL_DIR_ES/bin/elasticsearch -d"

    echo "============================Elasticsearch Install end=================================="
    cd $WORK_DIR
}
