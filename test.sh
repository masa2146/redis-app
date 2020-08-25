#!/bin/bash

if [ -z "$1" ]
then
           echo " 
======================================================
Master IP is NULL!. You must give master ip with params. 
Example: './install-redis.sh 192.168.83.142' 
====================================================== "
else
      echo "\nvar is NOT empty"
              masterMachineIp=$1
        currentDir=$(pwd)
        currentMachineIP=$(ipconfig getifaddr en0)
        if [ $masterMachineIp == $currentMachineIP ]
        then
        echo "MASTER EQUALS TO CURRENT"
        else
        echo "MASTER NOT EQUALS TO CURRENT"
        fi
fi