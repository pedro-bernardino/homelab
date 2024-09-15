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
  trilium:
    image: zadam/trilium
    container_name: trilium
    restart: unless-stopped
    environment:
      - TRILIUM_DATA_DIR=/home/node/trilium-data
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Lisbon
    # ports:
    #   - 8081:8080
    volumes:
      - ./data:/home/node/trilium-data
    labels:
      - traefik.enable=true
      - traefik.http.routers.trilium.entrypoints=http
      - traefik.http.routers.trilium.rule=Host(\`trilium.\${DOMAIN}\`)
      - traefik.http.middlewares.trilium-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.trilium.middlewares=trilium-https-redirect
      - traefik.http.routers.trilium-secure.entrypoints=https
      - traefik.http.routers.trilium-secure.rule=Host(\`trilium.\${DOMAIN}\`)
      - traefik.http.routers.trilium-secure.tls=true
      - traefik.http.routers.trilium-secure.service=trilium
      - traefik.http.services.trilium.loadbalancer.server.scheme=http
      - traefik.http.services.trilium.loadbalancer.server.port=8080
      - traefik.docker.network=proxy
    networks:
      proxy:
networks:
  proxy:
    external: true

EOM

#Depoying the trilium container
echo "Depoying the trilium container"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/trilium$
echo ""
sudo docker compose logs --follow