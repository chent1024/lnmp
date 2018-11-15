#!/bin/bash

#Uninstall old versions
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

#Setup repository
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2   
  
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


#Disable edge and test repositories
sudo yum-config-manager --disable docker-ce-edge
sudo yum-config-manager --disable docker-ce-test

#Install docker-ce
sudo yum install -y docker-ce

#Start docker
sudo systemctl start docker

# https://cr.console.aliyun.com
# 针对Docker客户端版本大于1.10.0的用户
# 可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器：
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://xhwdo89k.mirror.aliyuncs.com"]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker

# docker-compose install
sudo curl -L https://github.com/docker/compose/releases/download/1.23.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod a+x /usr/local/bin/docker-compose