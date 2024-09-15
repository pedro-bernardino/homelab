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

# creating config folder
echo "creating config folder"
mkdir config

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  esphome:
    image: esphome/esphome:latest
    container_name: esphome
    restart: unless-stopped
    privileged: true
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Lisbon
      - ESPHOME_DASHBOARD_USE_PING=true
    #ports:
    #  - 6052:6052
    #  - 6123:6123
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./config:/config
    labels:
      - traefik.enable=true
      - traefik.http.routers.esphome.entrypoints=http
      - traefik.http.routers.esphome.rule=Host(\`esphome.\${DOMAIN}\`)
      - traefik.http.middlewares.esphome-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.esphome.middlewares=esphome-https-redirect
      - traefik.http.routers.esphome-secure.entrypoints=https
      - traefik.http.routers.esphome-secure.rule=Host(\`esphome.\${DOMAIN}\`)
      - traefik.http.routers.esphome-secure.tls=true
      - traefik.http.routers.esphome-secure.service=esphome
      - traefik.http.services.esphome.loadbalancer.server.scheme=http
      - traefik.http.services.esphome.loadbalancer.server.port=6052
      - traefik.docker.network=proxy
    networks:
      proxy:
networks:
  proxy:
    external: true

EOM

#Depoying the esphome container
echo "Depoying the esphome container"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps
sudo docker logs --follow esphome