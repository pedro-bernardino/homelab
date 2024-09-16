#!/bin/sh
#

###############################################################
#                       EDIT THIS VALUES
###############################################################

# SAMBA share config
# I have Samba share in my Truenas to save the restic backups files outside of docker proxmox VM
# This script will configure automatic the samba share mount to the docker host, and mount the share to the container
# You need to create the samba share (in your nas or another server) before running the script
SAMBA_USER=your-samba-user
SAMBA_PASSWORD=your-samba-password
SAMBA_SERVER_SHARE_PATH='//xx.xx.xx.xx/Restic-Docker-Backups'

# Restic vars
RESTIC_TAG=restic-docker
RESTIC_KEEP_LAST=5    #this is: keep the last 5 backups
RESTIC_KEEP_DAILY=0   #this is: since the backups are daily, and the last 5 days are saved, we dont need this
RESTIC_KEEP_WEEKLY=1  #this is: keep 1 weekly backup
RESTIC_KEEP_MONTHLY=1 #this is: keep 1 monthly backup
# With this config, you will have at all times:
#       - the last 5 backups (last 5 days)
#       - 1 backup from the last week
#       - 1 backup from the last month
# You can change this setting. Remember, the more backups you have the more disk space you will need.
RESTIC_BACKUP_CRON="0 4 * * *"  #this is daily, At 04:00 AM
RESTIC_PRUNE_CRON="0 5 * * *"   #this is daily, At 05:00 AM
RESTIC_CHECK_CRON="0 6 * * *"   #this is daily, At 06:00 AM

#change to where you have the docker compose files.
RESTIC_BACKUP_SOURCE=${HOME}/Docker
#change to where you want to store the backups. As you can see I'm storing it on my NAS that is mounted to the host /mnt/restic (SAMBA SHARE)
RESTIC_BACKUP_LOCATION='/mnt/restic' 

###############################################################
#                         SCRIPT CODE
###############################################################


# Install cifs-utils for Samba share mount
echo "Installing cifs-utils"
sudo apt update
sudo apt install cifs-utils -y

# Create .smbcreds file to store user:password 
if [ ! -e "/etc/samba/.smbcreds" ]
then
echo "creating .smbcreds"
sudo mkdir /etc/samba
/bin/cat <<EOM | sudo tee /etc/samba/.smbcreds
username=$SAMBA_USER
password=$SAMBA_PASSWORD
EOM
sudo chmod 400 /etc/samba/.smbcreds
else
echo ".smbcreds file exist. skipping..."
fi

# Config Samba mount in fstab
if ! grep -q 'Samba Share for Restic' /etc/fstab
then
sudo su -c "echo '' >> /etc/fstab"
sudo su -c "echo '# Samba Share for Restic' >> /etc/fstab"
sudo su -c "echo '$SAMBA_SERVER_SHARE_PATH $RESTIC_BACKUP_LOCATION cifs vers=3.0,credentials=/etc/samba/.smbcreds,uid=34,gid=34,defaults 0 0' >> /etc/fstab"
sudo systemctl daemon-reload
sudo sudo mount -a
else
echo "Samba Share for Restic already added. skipping..."
fi

#creating .env
echo "creating .env"
if [ ! -e ".env" ]
then
    echo "RESTIC_PASSWORD='$(openssl rand -base64 60 | tr -d '\n')'" > .env  # this generate a big password
else
    echo ".env file exist. skipping..."
fi

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  backup:
    image: mazzolino/restic
    container_name: restic
    hostname: restic
    restart: unless-stopped
    environment:
      RUN_ON_STARTUP: "true" #change as you wish
      BACKUP_CRON: ${RESTIC_BACKUP_CRON}
      RESTIC_REPOSITORY: /restic
      RESTIC_PASSWORD: \${RESTIC_PASSWORD}
      RESTIC_BACKUP_SOURCES: /mnt/volumes
      RESTIC_COMPRESSION: auto 
      RESTIC_BACKUP_ARGS: >- #add tags, whatever you need to mark backups
        --tag ${RESTIC_TAG} 
        --verbose
      RESTIC_FORGET_ARGS: >- #change as required
        --keep-last ${RESTIC_KEEP_LAST}
        --keep-daily ${RESTIC_KEEP_DAILY}
        --keep-weekly ${RESTIC_KEEP_WEEKLY}
        --keep-monthly ${RESTIC_KEEP_MONTHLY}
      TZ: Europe/Lisbon
    volumes:
      - ${RESTIC_BACKUP_LOCATION}/backups:/restic 
      - ${RESTIC_BACKUP_LOCATION}/tmp-for-restore:/tmp-for-restore #USE THIS FOLDER FOR RESTORE - CAN VIEW EACH CONTAINER
      - ${RESTIC_BACKUP_SOURCE}:/mnt/volumes:ro
    security_opt:
      - no-new-privileges:true

  prune:
    image: mazzolino/restic
    container_name: restic-prune
    hostname: restic
    restart: unless-stopped
    environment:
      RUN_ON_STARTUP: "true"
      PRUNE_CRON: ${RESTIC_PRUNE_CRON}
      RESTIC_REPOSITORY: /restic
      RESTIC_PASSWORD: \${RESTIC_PASSWORD}
      TZ: Europe/Lisbon
    security_opt:
      - no-new-privileges:true

  check:
    image: mazzolino/restic
    container_name: restic-check
    hostname: restic
    restart: unless-stopped
    environment:
      RUN_ON_STARTUP: "false"
      CHECK_CRON: ${RESTIC_CHECK_CRON}
      RESTIC_CHECK_ARGS: >-
        --read-data-subset=10%
      RESTIC_REPOSITORY: /restic
      RESTIC_PASSWORD: \${RESTIC_PASSWORD}
      TZ: Europe/Lisbon
    security_opt:
      - no-new-privileges:true
EOM

#Depoying the restic container
echo "=============================="
echo "Depoying the restic container"
echo "   restic dont have a GUI"
echo "=============================="
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/restic$
sudo docker compose logs --follow