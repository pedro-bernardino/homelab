# Scrutiny Collector 
This tutorial provides a hybrid configuration where the Hub lives in a Docker instance while the spokes have only Scrutiny Collector installed manually. The Collector periodically send data to the Hub.

I have 2 server:
+ Proxmox server where one VM runs Docker. 
+ Truenas server

The Scrutiny Collector is triggered every 30min to collect data on the drives. The data is sent to the Docker VM, running InfluxDB.

> [!TIP]
>Follow this guide for every server you have with drives that you want to monitor.

## Installing dependencies
```bash
apt install smartmontools -y 
```
## Create directory for the binary
```bash
sudo mkdir -p /opt/scrutiny/bin
```

## Download the binary into that directory
>When downloading Github Release Assests, make sure that you have the correct version. The provided example is with Release v0.8.1.

>The release list can be found [here](https://github.com/analogj/scrutiny/releases).

```bash
sudo \\curl -L https://github.com/AnalogJ/scrutiny/releases/download/v0.8.1/scrutiny-collector-metrics-linux-amd64 > scrutiny-collector-metrics-linux-amd64 
```
## Make it exacutable
```bash
sudo cp scrutiny-collector-metrics-linux-amd64 /opt/scrutiny/bin  
sudo chmod +x /opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64
```
## List the contents of the library for confirmation
```bash
sudo ls -lha /opt/scrutiny/bin
```
## Config yaml (give a name to the machine)
Open "collector.yaml" file:
```bash
sudo mkdir /opt/scrutiny/config  
sudo touch /opt/scrutiny/config/collector.yaml  
sudo nano /opt/scrutiny/config/collector.yaml
```
Copy the following to "collector.yaml" and change the name:
```
host:
 id: “NAME-OF-SERVER”
```

## Create Timer
```bash
sudo nano /usr/local/bin/scrutiny-timer.sh
```
Change the IP with you docker server IP and copy the following to "scrutiny-timer.sh":
```
#!/bin/bash
/opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 run --api-endpoint http://xx.xx.xx.xx:8080
```
Open "scrutiny-timer.service" file:
```bash
sudo chmod +x /usr/local/bin/scrutiny-timer.sh   
sudo nano /etc/systemd/system/scrutiny-timer.service
```
Copy the following to "scrutiny-timer.service":
```
[Unit]
Description="scrutiny updater"
Requires=scrutiny-timer.timer

[Service]
Type=simple
ExecStart=/usr/local/bin/scrutiny-timer.sh
User=root
```
Open "scrutiny-timer.timer" file:
```bash
sudo nano /etc/systemd/system/scrutiny-timer.timer
```
Copy the following to "scrutiny-timer.timer":
```
[Unit]
Description="Timer for the scrutiny-timer.service"

[Timer]
Unit=scrutiny-timer.service
OnBootSec=5min
OnUnitActiveSec=30min

[Install]
WantedBy=timers.target
```

## Enable and start the timer
```bash
sudo systemctl status scrutiny-timer.service && \\  
sudo systemctl enable scrutiny-timer.timer && \\  
sudo systemctl start scrutiny-timer.timer && \\  
sudo systemctl status scrutiny-timer.service  
```

## Manual update

```bash
/opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 run --api-endpoint “http://xx.xx.xx.xx:8080”
```

<!--
S.M.A.R.T. Monitoring with Scrutiny across machines: [https://github.com/AnalogJ/scrutiny/blob/master/docs/INSTALL_HUB_SPOKE.md](https://github.com/AnalogJ/scrutiny/blob/master/docs/INSTALL_HUB_SPOKE.md)

Create Timer: [https://www.howtogeek.com/replace-cron-jobs-with-systemd-timers/](https://www.howtogeek.com/replace-cron-jobs-with-systemd-timers/)
-->