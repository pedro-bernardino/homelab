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

# creating config and lib folders
echo "creating config and lib folders"
mkdir config
mkdir lib

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  motioneye:
    image: ccrisan/motioneye:master-amd64
    container_name: motioneye
    hostname: motioneye
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
    # ports:
    #   - 8765:8765
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./config:/etc/motioneye
      - ./lib:/var/lib/motioneye
    labels:
      - traefik.enable=true
      - traefik.http.routers.motioneye.entrypoints=http
      - traefik.http.routers.motioneye.rule=Host(\`motioneye.\${DOMAIN}\`)
      - traefik.http.middlewares.motioneye-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.motioneye.middlewares=motioneye-https-redirect
      - traefik.http.routers.motioneye-secure.entrypoints=https
      - traefik.http.routers.motioneye-secure.rule=Host(\`motioneye.\${DOMAIN}\`)
      - traefik.http.routers.motioneye-secure.tls=true
      - traefik.http.routers.motioneye-secure.service=motioneye
      - traefik.http.services.motioneye.loadbalancer.server.scheme=http
      - traefik.http.services.motioneye.loadbalancer.server.port=8765
      - traefik.docker.network=proxy
    networks:
      proxy:
networks:
  proxy:
    external: true

EOM

#Depoying the motioneye container
echo ""
echo "================================"
echo "Depoying the motioneye container"
echo "motioneye.${DOMAIN}"
echo "default login:"
echo "user: admin"
echo "pass: <empty>"
echo "================================"
echo ""
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/motioneye$
echo ""
sudo docker compose logs --follow