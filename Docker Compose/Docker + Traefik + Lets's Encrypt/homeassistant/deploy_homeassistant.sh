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
/bin/cat <<EOM > compose.yaml
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: homeassistant
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    # ports:
    #   - 8123:8123
    environment:
      # - PUID=1000
      # - PGID=1000
      - TZ=Europe/Lisbon
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./config:/config
    privileged: true
    labels:
      - traefik.enable=true
      - traefik.http.routers.homeassistant.entrypoints=http
      - traefik.http.routers.homeassistant.rule=Host(\`homeassistant.\${DOMAIN}\`)
      - traefik.http.middlewares.homeassistant-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.homeassistant.middlewares=homeassistant-https-redirect
      - traefik.http.routers.homeassistant-secure.entrypoints=https
      - traefik.http.routers.homeassistant-secure.rule=Host(\`homeassistant.\${DOMAIN}\`)
      - traefik.http.routers.homeassistant-secure.tls=true
      - traefik.http.routers.homeassistant-secure.service=homeassistant
      - traefik.http.services.homeassistant.loadbalancer.server.scheme=http
      - traefik.http.services.homeassistant.loadbalancer.server.port=8123
      - traefik.docker.network=proxy
    networks:
      proxy:
networks:
  proxy:
    external: true
EOM

#Stopping homeassistant container
echo "Stopping homeassistant container"
sudo docker compose down

#Depoying homeassistant container
echo "Depoying homeassistant container"
sudo docker compose up -d --force-recreate

if [ $(cat ./config/configuration.yaml | grep -c "use_x_forwarded_for") -eq 0 ]
then
/bin/cat <<EOM | sudo tee config/configuration.yaml
# Loads default set of integrations. Do not remove.
default_config:

# Load frontend themes from the themes folder
frontend:
  themes: !include_dir_merge_named themes

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.50.10.1 #traefik ip
EOM
sudo docker compose down
sudo docker compose up -d --force-recreate
fi

sudo docker ps -a --no-trunc --filter name=^/homeassistant$
sudo docker compose logs --follow




