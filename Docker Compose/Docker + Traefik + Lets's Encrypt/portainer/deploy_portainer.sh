#!/bin/sh


###############################################################
#                       EDIT THIS VALUES
###############################################################

DOMAIN='your_dynu_domain'

# change to true if you are having problems
PORTAINER_DEBUG=false

###############################################################
#                         SCRIPT CODE
###############################################################

#creating .env
echo "creating .env"
echo "DOMAIN='$DOMAIN'" > .env

# creating data folder
echo "creating data folder"
mkdir data

#preparing log level string
if [ $PORTAINER_DEBUG = 'true' ]; then
	DEBUG_STRING='command: "--log-level DEBUG"'
else
	DEBUG_STRING='#command: "--log-level DEBUG"'
fi

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    #ports:
    #  - 8000:8000
    #  - 9443:9443
    #  - 9000:9000 # for http
    volumes:
      - ./data:/data
      - /var/run/docker.sock:/var/run/docker.sock
    $DEBUG_STRING
    labels:
      - traefik.enable=true
      - traefik.http.routers.portainer.entrypoints=http
      - traefik.http.routers.portainer.rule=Host(\`portainer.\${DOMAIN}\`)
      - traefik.http.middlewares.portainer-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.portainer.middlewares=portainer-https-redirect
      - traefik.http.routers.portainer-secure.entrypoints=https
      - traefik.http.routers.portainer-secure.rule=Host(\`portainer.\${DOMAIN}\`)
      - traefik.http.routers.portainer-secure.tls=true
      - traefik.http.routers.portainer-secure.service=portainer
      - traefik.http.services.portainer.loadbalancer.server.scheme=https
      - traefik.http.services.portainer.loadbalancer.server.port=9443
      - traefik.docker.network=proxy
    networks:
      proxy:
networks:
  proxy:
    external: true
EOM

#Depoying the traefik container
echo "Depoying the portainer container"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps
sudo docker logs --follow portainer