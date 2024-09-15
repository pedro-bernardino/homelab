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

# creating data folder
echo "creating data folder"
mkdir data

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptimekuma
    restart: unless-stopped
    volumes:
      - ./data:/app/data
    # ports:
    #   - 3001:3001
    labels:
      - traefik.enable=true
      - traefik.http.routers.uptimekuma.entrypoints=http
      - traefik.http.routers.uptimekuma.rule=Host(\`uptimekuma.\${DOMAIN}\`)
      - traefik.http.middlewares.uptimekuma-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.uptimekuma.middlewares=uptimekuma-https-redirect
      - traefik.http.routers.uptimekuma-secure.entrypoints=https
      - traefik.http.routers.uptimekuma-secure.rule=Host(\`uptimekuma.\${DOMAIN}\`)
      - traefik.http.routers.uptimekuma-secure.tls=true
      - traefik.http.routers.uptimekuma-secure.service=uptimekuma
      - traefik.http.services.uptimekuma.loadbalancer.server.scheme=http
      - traefik.http.services.uptimekuma.loadbalancer.server.port=3001
      - traefik.docker.network=proxy
    networks:
      proxy:
networks:
  proxy:
    external: true

EOM

#Depoying the uptimekuma container
echo "Depoying the uptimekuma container"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/uptimekuma$
echo ""
sudo docker compose logs --follow