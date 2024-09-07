# Configuring etherwake for WOL
## install etherwake
```bash
apt install etherwake
```

## create python script
```bash
nano ~/wol.py
```

> [!NOTE]
>edit and copy wol.py contents

## Create service
```bash
sudo nano /etc/systemd/system/wol.service
```
Copy the following (make sure you change \<user\>! You can find out the path with the command "pwd")
```
[Unit]
Description=UPS Tracker

[Service]
User=root
Group=root
ExecStart=/usr/bin/python3 /home/<user>/wol.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## Enable service
```bash
sudo systemctl enable wol
sudo systemctl start wol
```

## Create Timer
```bash
sudo nano /etc/systemd/system/wol.timer
```
Copy the following:
```
[Unit]
Description="Timer for wol.service"

[Timer]
Unit=wol.service
OnBootSec=5min
OnUnitActiveSec=1min

[Install]
WantedBy=timers.target
```


## Restart Services and timers
```bash
sudo systemctl enable wol.timer  
sudo systemctl start wol.timer  
sudo systemctl status wol.service
```

## Manual run the script
```bash
python3 ~/wol.py
```

## Manual WOL server
```bash
etherwake -b xx:xx:xx:xx:xx:xx
```

# Change battery.charge.low to 20
In my case i wanted to change the original ups value "battery.charge.low" from 30 to 20

Edit the upsd.users
```bash
sudo nano /etc/nut/upsd.users
```
To that efect, i granted temporary permitions to the user to edit the ups values. For that add "actions = set" to the file.
```
[monuser]
        actions = set
        password = <password>
        upsmon primary
```
To change the ups value, run this command over ssh on the server
```bash
upsrw -s battery.charge.low=20 -u monuser -p <password> <UPS-NAME>
```

## Remove permitions:
After changing the values you need, remove the permitions from the user.

Remove "actions = set" from upsd.users
```bash
sudo nano /etc/nut/upsd.users
```

# TODO
- [ ] Shut off ups from the nut-server after all servers are off