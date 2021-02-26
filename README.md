This script create redis-sentinel structure by given <MASTER_IP> params.
# INSTALL PROGRAM
``` 
sh install_redis <MASTER_IP> <CURRENT_SYSTEM_IP>
```
# SETTINGS
Master redis configuration file is in *conf->redis->master* folder
Slave redis configuration file is in *conf->redis->slave* folder
If **eth0** or **eth1** ip address equals to **<MASTER_IP>** then currently machine is master machine
else currently machine is slave machine.
