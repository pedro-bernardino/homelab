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
  heimdall:
    image: ghcr.io/linuxserver/heimdall:latest
    container_name: heimdall
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Lisbon
    volumes:
      - ./config:/config
    # ports:
    #   - 8088:80
    #   - 4433:443
    labels:
      - traefik.enable=true
      - traefik.http.routers.heimdall.entrypoints=http
      - traefik.http.routers.heimdall.rule=Host(\`\${DOMAIN}\`)
      - traefik.http.middlewares.heimdall-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.heimdall.middlewares=heimdall-https-redirect
      - traefik.http.routers.heimdall-secure.entrypoints=https
      - traefik.http.routers.heimdall-secure.rule=Host(\`\${DOMAIN}\`)
      - traefik.http.routers.heimdall-secure.tls=true
      - traefik.http.routers.heimdall-secure.service=heimdall
      - traefik.http.services.heimdall.loadbalancer.server.scheme=https
      - traefik.http.services.heimdall.loadbalancer.server.port=443
      - traefik.docker.network=proxy
    networks:
      proxy:
networks:
  proxy:
    external: true

EOM

#Depoying the heimdall container
echo "Depoying the heimdall container"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps
sudo docker logs --follow heimdall