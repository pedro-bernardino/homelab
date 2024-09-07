# NUT Server Config
SSH into the server
```bash
ssh user@xx.xx.xx.xx -p22
```

Update server
```bash
sudo apt update
sudo apt install nut nut-server nut-client
```

## List USB devices
Find out in what usb the ups is connected
```bash
lsusb
```
in my case 1:6
```bash
lsusb -v -s 1:6
```

## Scanning bus
Scan the driver to use with your ups
```bash
sudo nut-scanner -U
```
Save the output for later...

Output of the command:
```
[nutdev1]
        driver = "usbhid-ups"
        port = "auto"
        vendorid = "051D"
        productid = "0002"
        product = "Back-UPS RS 900G FW:879.L4 .I USB FW:L4"
        serial = "XXXXXXXXXXXXX"
        vendor = "American Power Conversion"
        bus = "001"
```

## Configs
Save original ups.conf
```bash
sudo cp /etc/nut/ups.conf /etc/nut/ups.conf.save
sudo nano /etc/nut/ups.conf
```
Delete all inside the config and add the folowing (with the ups information saved before).
Give a name to the UPS. I choose APC.
```
pollinterval = 1
maxretry = 3

[APC]
        driver = usbhid-ups
        port = auto
        vendorid = 051D
        productid = 0002
        desc = "APC Back-UPS Pro RS 900G"
        serial = XXXXXXXXXXXXX
```
Save original upsmon.conf
```bash
sudo cp /etc/nut/upsmon.conf /etc/nut/upsmon.conf.save
sudo nano /etc/nut/upsmon.conf
```
Delete all inside the config and add the folowing (insert a secure password):
```
RUN_AS_USER root

MONITOR APC@localhost 1 admin <password> master
```

Save original upsd.conf
```bash
sudo  cp /etc/nut/upsd.conf /etc/nut/upsd.conf.save
sudo nano /etc/nut/upsd.conf
```
Delete all inside the config and add the folowing:
```
LISTEN 0.0.0.0 3493
```
Save original nut.conf
```bash
sudo cp /etc/nut/nut.conf /etc/nut/nut.conf.save
sudo nano /etc/nut/nut.conf
```
Delete all inside the config and add the folowing:
```
MODE=netserver
```
Save original upsd.users
```bash
sudo cp /etc/nut/upsd.users /etc/nut/upsd.users.save
sudo nano /etc/nut/upsd.users
```
Delete all inside the config and add the folowing (insert the same password used above):
```
[monuser]
        password = <password>
        upsmon primary
```

## RESTART SERVICES:
Restart all nut services
```bash
sudo service nut-server restart
sudo service nut-client restart
sudo systemctl restart nut-monitor
sudo upsdrvctl stop
sudo upsdrvctl start
```

## TEST SERVICES:
```bash
upsc APC@localhost
upsc APC@xx.xx.xx.xx
```

## Install NUT web UI
Install packages and save original hosts.conf
```bash
sudo apt install apache2 nut-cgi
sudo cp /etc/nut/hosts.conf /etc/nut/hosts.conf.save
sudo nano /etc/nut/hosts.conf
```
Delete all inside the config and add the folowing (choose a description for your ups)
```
MONITOR APC@localhost "APC Back-UPS Pro RS 900G"
```
Restart service and save original upsset.conf
```bash
sudo a2enmod cgi
sudo systemctl restart apache2
sudo cp /etc/nut/upsset.conf /etc/nut/upsset.conf.save
sudo nano /etc/nut/upsset.conf
```
Delete all inside the config and add the folowing:
```
I_HAVE_SECURED_MY_CGI_DIRECTORY
```


## Open web UI
```
http://xx.xx.xx.xx/cgi-bin/nut/upsstats.cgi
```