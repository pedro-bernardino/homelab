# NUT Client Config
```bash
sudo apt update
sudo apt install nut-client
```

## Configs
Open "upsmon.conf" file:
```bash
sudo cp /etc/nut/upsmon.conf /etc/nut/upsmon.conf.save
sudo nano /etc/nut/upsmon.conf
```
Change Server IP and password and copy the following to "upsmon.conf" :
```
RUN_AS_USER root

MONITOR APC@xx.xx.xx.xx 1 monuser <password> secondary

MINSUPPLIES 1  
SHUTDOWNCMD "/sbin/shutdown -h +0"  
NOTIFYCMD /usr/sbin/upssched  
POLLFREQ 5  
POLLFREQALERT 5  
DEADTIME 15  
POWERDOWNFLAG /etc/killpower

NOTIFYMSG ONLINE        "UPS %s on line power"  
NOTIFYMSG ONBATT        "UPS %s on battery"  
NOTIFYMSG LOWBATT       "UPS %s battery is low"  
NOTIFYMSG FSD           "UPS %s: forced shutdown in progress"  
NOTIFYMSG COMMOK        "Communications with UPS %s established"  
NOTIFYMSG COMMBAD       "Communications with UPS %s lost"  
NOTIFYMSG SHUTDOWN      "Auto logout and shutdown proceeding"  
NOTIFYMSG REPLBATT      "UPS %s battery needs to be replaced"  
NOTIFYMSG NOCOMM        "UPS %s is unavailable"  
NOTIFYMSG NOPARENT      "upsmon parent process died - shutdown impossible"

#ONLINE   : UPS is back online  
#ONBATT   : UPS is on battery  
#LOWBATT  : UPS has a low battery (if also on battery, it's "critical")  
#FSD      : UPS is being shutdown by the primary (FSD = "Forced Shutdown")  
#COMMOK   : Communications established with the UPS  
#COMMBAD  : Communications lost to the UPS  
#SHUTDOWN : The system is being shutdown  
#REPLBATT : The UPS battery is bad and needs to be replaced  
#NOCOMM   : A UPS is unavailable (can't be contacted for monitoring)  
#NOPARENT : The process that shuts down the system has died (shutdown impossible)

NOTIFYFLAG ONLINE       SYSLOG+WALL  
NOTIFYFLAG ONBATT       SYSLOG+WALL  
NOTIFYFLAG LOWBATT      SYSLOG+WALL  
NOTIFYFLAG FSD          SYSLOG+WALL  
NOTIFYFLAG COMMOK       SYSLOG+WALL  
NOTIFYFLAG COMMBAD      SYSLOG+WALL  
NOTIFYFLAG SHUTDOWN     SYSLOG+WALL  
NOTIFYFLAG REPLBATT     SYSLOG+WALL  
NOTIFYFLAG NOCOMM       SYSLOG+WALL  
NOTIFYFLAG NOPARENT     SYSLOG+WALL  
  
RBWARNTIME 43200

NOCOMMWARNTIME 300

FINALDELAY 5
```
Open "nut.conf" file:
```bash
sudo cp /etc/nut/nut.conf /etc/nut/nut.conf.save
sudo nano /etc/nut/nut.conf
```
Copy the following to "nut.conf":
```
MODE=netclient
```
Open "upssched.conf" file:
```bash
sudo cp /etc/nut/upssched.conf /etc/nut/upssched.conf.save
sudo nano /etc/nut/upssched.conf
```
Copy the following to "upssched.conf":
```
CMDSCRIPT /etc/nut/upssched-cmd
PIPEFN /run/nut/upssched.pipe
LOCKFN /run/nut/upssched.lock

#Online
#AT ONLINE * CANCEL-TIMER earlyshutdown

#On Battery
AT ONBATT * EXECUTE onbatt
AT LOWBATT * EXECUTE shutdowncritical

#Comunications
AT COMMBAD * START-TIMER commbad 30
AT COMMOK * CANCEL-TIMER commbad commok
AT NOCOMM * EXECUTE commbad

#On Shutdown
AT SHUTDOWN * EXECUTE powerdown
```
Open "upssched-cmd" file:
```bash
sudo nano /etc/nut/upssched-cmd
```
Copy the following to "upssched-cmd":
```
#!/bin/sh

case $1 in

    onbatt)

        logger -t upssched-cmd “UPS running on battery”
        ;;

    earlyshutdown)

        logger -t upssched-cmd “UPS on battery too long, early shutdown”
        /usr/sbin/upsmon -c fsd
        ;;

    shutdowncritical)

        logger -t upssched-cmd "UPS on battery critical, forced shutdown"
        /usr/sbin/upsmon -c fsd
        ;;

    upsgone)

        logger -t upssched-cmd “UPS has been gone too long, can't reach”
        ;;

    *)

        logger -t upssched-cmd "Unrecognized command: $1"
        ;;

esac
```
Making "upssched-cmd" executable and creating "upssched" folder:
```bash
chmod +x /etc/nut/upssched-cmd  
mkdir /etc/nut/upssched/
```

**RESTART SERVICES:**
```bash
systemctl restart nut-client
```

**TEST SERVICES:**  
```bash
upsc APC@xx.xx.xx.xx
```