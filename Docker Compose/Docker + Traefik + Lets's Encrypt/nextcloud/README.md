# Nextcloud
[Nextcloud](https://github.com/nextcloud/docker), a safe home for all your data. Access & share your files, calendars, contacts, mail & more from any device, on your terms.

# Usage
+ Create a folder for the nextcloud files 
  + ```mkdir nextcloud```
+ Open nextcloud folder
  + ```cd nextcloud```
+ Copy [deploy_nextcloud.sh](deploy_nextcloud.sh) to your nextcloud folder
+ Edit [deploy_nextcloud.sh](deploy_nextcloud.sh) and change the values with your info
+ Make [deploy_nextcloud.sh](deploy_nextcloud.sh) executable
  + ```sudo chmod +x deploy_nextcloud.sh```
+ Run the script to deploy nextcloud
  + ```./deploy_nextcloud.sh```
+ Add domain to pihole local dns
  + Domain: https://nextcloud.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open nextcloud dashboard
  + https://nextcloud.YOUR-DOMAIN-COM
+ Create admin account
  + Login: ```<your user name>```
  + Password: ```<your strong password>```
  + Data folder: ```/data```
  + Configure the database: ```MySQL/MariaDB```

    + Database account: open **.env** and copy the generated string for **MYSQL_USER**
    + Database password: open **.env** and copy the generated token for **MYSQL_PASSWORD**
    + Database name: open **.env** and copy the generated string for **MYSQL_DATABASE**
    + Database host: ```db```