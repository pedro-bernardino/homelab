#!/bin/sh

###############################################################
#                       EDIT THIS VALUES
###############################################################

# watchtower dont have an GUI
# DOMAIN='your_dynu_domain'

###############################################################
#                         SCRIPT CODE
###############################################################

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
      # remove old images after update (useful for saving space)
      - WATCHTOWER_CLEANUP=true
      # the below will ignore labels set. It is worth checking out labels as that can be a more scalabe solution (automatic)
      # - WATCHTOWER_DISABLE_CONTAINERS=traefik crowdsec bouncer-traefik deconz frigate home-assistant homeassistant-db
      # the docker host can also be remote by specifying tcp
      # - DOCKER_HOST=tcp://hostname:port
      # how frequently to check for images (default is 24 hours)
      # - WATCHTOWER_POLL_INTERVAL=86400
      # choose whether to restart the containers after updates
      # - WATCHTOWER_INCLUDE_RESTARTING=true
      # choose whether to update stopped and exited containers
      # - WATCHTOWER_INCLUDE_STOPPED=true
      # this will start containers that were stopped or exited if they are updated
      # - WATCHTOWER_REVIVE_STOPPED=true
      # watchtower can behave like DIUN by only notifying, and not updating
      # - WATCHTOWER_MONITOR_ONLY=true
      # you can tell watchtower to do updates and restarts one by one - can be helpful
      - WATCHTOWER_ROLLING_RESTART=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      proxy:
networks:
  proxy:
    external: true

EOM

#Depoying the watchtower container
echo "================================="
echo "Depoying the watchtower container"
echo "  watchtower dont have an GUI"
echo "================================="
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/watchtower$
sudo docker compose logs --follow