#!/bin/bash

if [ -z "$1" ]
then
           echo " 
======================================================
Master IP is NULL!. You must give master ip with params. 
Example: './install-redis.sh <MASTER_IP> <YOUR_SYSTEM_IP>' 
====================================================== "
elif [ -z "$2" ]
then
           echo " 
======================================================
Your system IP is NULL!. You must give your system ip with params. 
Example: './install-redis.sh <MASTER_IP> <YOUR_SYSTEM_IP>' 
====================================================== "
else
        #machineIp=$2
        masterMachineIp=$1
        currentDir=$(pwd)
        currentMachineIP=$2#$(hostname -I)

        yes | apt-get install build-essential

        # Download redis files
        #cd /tmp
        curl -O http://download.redis.io/redis-stable.tar.gz
        tar xzvf redis-stable.tar.gz
        cd redis-stable

        # Compile redis sourc
        make
        make test
        cd src/
        make test
        make install

        # Redis Memeory and user config
        echo "vm.overcommit_memory=1" >> /etc/sysctl.conf 
        echo "net.core.somaxconn=65535" >> /etc/sysctl.conf 
        cd $currentDir
        yes | cp -rf conf/etc/rc.local /etc/
        adduser --system --group --no-create-home redis

        # Create redis folder and log file for redis and sentinels
        # Add permissions for redis folders 
        mkdir -p /etc/redis

        mkdir -p /var/log/redis/
        touch /var/log/redis/redis.log
        chown redis:redis /var/log/redis/redis.log

        touch /var/log/redis/sentinel.log
        chown redis:redis /var/log/redis/sentinel.log

        mkdir /var/lib/redis
        chown redis:redis /var/lib/redis
        chmod 770 /var/lib/redis

        mkdir /var/lib/redis-sentinel
        chown redis:redis /var/lib/redis-sentinel
        chmod 770 /var/lib/redis-sentinel


        cp conf/service/redis-server.service /etc/systemd/system/redis-server.service
        cp conf/service/redis-sentinel.service /etc/systemd/system/redis-sentinel.service

        #If master ip equals to current ip then currently machine is master machine
        if [ $masterMachineIp == $currentMachineIP ]
        then
        echo "======================================================"
        echo "INSTALLATION WILL BE DONE AS MASTER"
        echo "======================================================"
        yes | cp conf/redis/master/redis.conf /etc/redis/redis.conf
        yes | cp conf/redis/master/sentinel.conf /etc/redis/sentinel.conf

        #sed -e "s/&ip_address/$machineIp/g" /etc/redis/redis.conf > temp_redis.conf && mv temp_redis.conf /etc/redis/redis.conf 
        sed -e "s/&master_ip/$masterMachineIp/g" /etc/redis/redis.conf > temp_redis.conf && mv temp_redis.conf /etc/redis/redis.conf

        #sed -e "s/&ip_address/$machineIp/g" /etc/redis/sentinel.conf > temp_sentinel.conf && mv temp_sentinel.conf /etc/redis/sentinel.conf
        sed -e "s/&master_ip/$masterMachineIp/g" /etc/redis/sentinel.conf > temp_sentinel.conf && mv temp_sentinel.conf /etc/redis/sentinel.conf

        else
        echo "======================================================"
        echo "INSTALLATION WILL BE DONE AS SLAVE"
        echo "======================================================"
        yes | cp conf/redis/slave/redis.conf /etc/redis/redis.conf
        yes | cp conf/redis/slave/sentinel.conf /etc/redis/sentinel.conf

        #sed -e "s/&ip_address/$machineIp/g" /etc/redis/redis.conf > temp_redis.conf && mv temp_redis.conf /etc/redis/redis.conf
        sed -e "s/&master_ip/$masterMachineIp/g" /etc/redis/redis.conf > temp_redis.conf && mv temp_redis.conf /etc/redis/redis.conf

        #sed -e "s/&ip_address/$machineIp/g" /etc/redis/sentinel.conf > temp_sentinel.conf && mv temp_sentinel.conf /etc/redis/sentinel.conf
        sed -e "s/&master_ip/$masterMachineIp/g" /etc/redis/sentinel.conf > temp_sentinel.conf && mv temp_sentinel.conf /etc/redis/sentinel.conf
        fi

        chown redis:redis /etc/redis/sentinel.conf
        chmod 777 /etc/redis/sentinel.conf

        systemctl start redis-server
        #systemctl status redis-server
        systemctl enable redis-server

        systemctl start redis-sentinel
        #systemctl status redis-sentinel
        systemctl enable redis-sentinel

        systemctl daemon-reload

        systemctl restart redis-sentinel
        systemctl restart redis-server

        echo "ETH1:" $currentMachineIP
        echo "MASTER IP:" $masterMachineIp

        #reboot
fi

