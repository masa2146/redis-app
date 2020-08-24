#!/bin/bash

machineIp=$1
masterMachineIp=$2

# Download redis files
sudo cd /tmp
sudo curl -O http://download.redis.io/redis-stable.tar.gz
sudo tar xzvf redis-stable.tar.gz
cd redis-stable

# Compile redis sourc
sudo make
sudo make test
sudo cd src/
sudo make test
sudo make install

# Redis Memeory and user config
sudo echo "vm.overcommit_memory=1" >> /etc/sysctl.conf 
sudo echo "net.core.somaxconn=65535" >> /etc/sysctl.conf 
sudo  yes | cp -rf conf/etc/rc.local /etc/
sudo adduser --system --group --no-create-home redis

# Create redis folder and log file for redis and sentinels
# Add permissions for redis folders 
sudo mkdir -p /etc/redis

sudo mkdir -p /var/log/redis/
sudo touch /var/log/redis/redis.log
sudo chown redis:redis /var/log/redis/redis.log

sudo touch /var/log/redis/sentinel.log
sudo chown redis:redis /var/log/redis/sentinel.log

sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis

sudo mkdir /var/lib/redis-sentinel
sudo chown redis:redis /var/lib/redis-sentinel
sudo chmod 770 /var/lib/redis-sentinel


sudo cp conf/service/redis-server.service /etc/systemd/system/redis-server.service
sudo cp conf/service/redis-sentinel.service /etc/systemd/system/redis-sentinel.service

#If master ip equals to current ip then currently machine is master machine
if [ $machineIp = $masterMachineIp ]
then
sudo yes | cp conf/redis/master/redis.conf /etc/redis/redis.conf
sudo yes | cp conf/redis/master/sentinel.conf /etc/redis/sentinel.conf

sudo sed -e "s/&ip_address/$machineIp/g" /etc/redis/redis.conf > temp_redis.conf && mv temp_redis.conf /etc/redis/redis.conf 
sudo sed -e "s/&master_ip/$masterMachineIp/g" /etc/redis/redis.conf > temp_redis.conf && mv temp_redis.conf /etc/redis/redis.conf

sudo sed -e "s/&ip_address/$machineIp/g" /etc/redis/sentinel.conf > temp_sentinel.conf && mv temp_sentinel.conf /etc/redis/sentinel.conf
sudo sed -e "s/&master_ip/$masterMachineIp/g" /etc/redis/sentinel.conf > temp_sentinel.conf && mv temp_sentinel.conf /etc/redis/sentinel.conf

else
sudo yes | cp conf/redis/slave/redis.conf /etc/redis/redis.conf
sudo yes | cp conf/redis/slave/sentinel.conf /etc/redis/sentinel.conf

sudo sed -e "s/&ip_address/$machineIp/g" /etc/redis/redis.conf > temp_redis.conf && mv temp_redis.conf /etc/redis/redis.conf
sudo sed -e "s/&master_ip/$masterMachineIp/g" /etc/redis/redis.conf > temp_redis.conf && mv temp_redis.conf /etc/redis/redis.conf

sudo sed -e "s/&ip_address/$machineIp/g" /etc/redis/sentinel.conf > temp_sentinel.conf && mv temp_sentinel.conf /etc/redis/sentinel.conf
sudo sed -e "s/&master_ip/$masterMachineIp/g" /etc/redis/sentinel.conf > temp_sentinel.conf && mv temp_sentinel.conf /etc/redis/sentinel.conf
fi

sudo chown redis:redis /etc/redis/sentinel.conf
sudo chmod 777 /etc/redis/sentinel.conf

sudo systemctl start redis-server
sudo systemctl status redis-server
sudo systemctl enable redis-server

sudo systemctl start redis-sentinel
sudo systemctl status redis-sentinel
sudo systemctl enable redis-sentinel

echo "IP:" $machineIp
echo "MASTER IP:" $masterMachineIp

reboot