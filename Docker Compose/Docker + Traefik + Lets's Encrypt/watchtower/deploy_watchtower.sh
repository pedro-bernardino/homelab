#!/bin/sh

###############################################################
#                       EDIT THIS VALUES
###############################################################

DOMAIN='your_dynu_domain'

###############################################################
#                         SCRIPT CODE
###############################################################

#creating .env
echo "creating .env"
echo "DOMAIN='$DOMAIN'" > .env

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  watchtower:
    image: containrrr/watchtower:latest
    container_name: watchtower
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - WATCHTOWER_CLEANUP=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      proxy:
networks:
  proxy:
    external: true

EOM

#Depoying the watchtower container
echo "Depoying the watchtower container"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/watchtower$
echo ""
sudo docker compose logs --follow