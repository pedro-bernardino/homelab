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
  vaultwarden:
    
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - ./data:/data/
    networks:
      proxy:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.vaultwarden.entrypoints=http"
      - "traefik.http.routers.vaultwarden.rule=Host(\`vaultwarden.\${DOMAIN}\`)"
      - "traefik.http.middlewares.vaultwarden-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.vaultwarden.middlewares=vaultwarden-https-redirect"
      - "traefik.http.routers.vaultwarden-secure.entrypoints=https"
      - "traefik.http.routers.vaultwarden-secure.rule=Host(\`vaultwarden.\${DOMAIN}\`)"
      - "traefik.http.routers.vaultwarden-secure.tls=true"
      - "traefik.http.routers.vaultwarden-secure.service=vaultwarden"
      - "traefik.http.services.vaultwarden.loadbalancer.server.port=80"
      - "traefik.docker.network=proxy"

networks:
  proxy:
    external: true

EOM

#Depoying the vaultwarden container
echo "================================"
echo "Depoying the vaultwarden container"
echo "vaultwarden.${DOMAIN}"
echo "================================"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/vaultwarden$
sudo docker compose logs --follow

