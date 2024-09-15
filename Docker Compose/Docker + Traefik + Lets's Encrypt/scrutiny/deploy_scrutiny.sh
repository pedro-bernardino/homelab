#!/bin/sh
#

###############################################################
#                       EDIT THIS VALUES
###############################################################

DOMAIN='your_dynu_domain'
SCRUTINY_NOTIFY_URLS=telegram://xxxx@telegram?channels=xxxxx

###############################################################
#                         SCRIPT CODE
###############################################################

#creating .env
echo "creating .env"
if [ ! -e ".env" ]
then
    echo "DOMAIN='$DOMAIN'" > .env
    echo "INFLUXDB_USERNAME='$(tr -dc A-Za-z </dev/urandom | head -c 6)'" >> .env   # this generate a string
    echo "INFLUXDB_PASSWORD='$(openssl rand -base64 60 | tr -d '\n')'" >> .env      # this generate a big password
    echo "INFLUXDB_BUCKET='$(tr -dc A-Za-z </dev/urandom | head -c 6)'" >> .env     # this generate a string
    echo "INFLUXDB_ADMIN_TOKEN='$(openssl rand -base64 60 | tr -d '\n')'" >> .env   # this generate a big password
    echo "SCRUTINY_NOTIFY_URLS='$SCRUTINY_NOTIFY_URLS'" >> .env
else
    echo ".env file exist. skipping..."
fi

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  influxdb:
    image: influxdb:2.1-alpine
    container_name: scrutiny-influxdb
    restart: unless-stopped
    # ports:
    #   - 8086:8086
    volumes:
      - ./influxdb/db:/var/lib/influxdb2
      - ./influxdb/config:/etc/influxdb2
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=\${INFLUXDB_USERNAME}
      - DOCKER_INFLUXDB_INIT_PASSWORD=\${INFLUXDB_PASSWORD}
      - DOCKER_INFLUXDB_INIT_ORG=homelab
      - DOCKER_INFLUXDB_INIT_BUCKET=\${INFLUXDB_BUCKET}
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=\${INFLUXDB_ADMIN_TOKEN}
    networks:
      proxy:

  scrutiny:
    image: ghcr.io/analogj/scrutiny:master-web
    container_name: scrutiny
    restart: unless-stopped
    # ports:
    #   - 8080:8080
    volumes:
      - ./scrutiny/config:/opt/scrutiny/config
    environment:
      - SCRUTINY_WEB_INFLUXDB_HOST=influxdb
      - SCRUTINY_WEB_INFLUXDB_PORT=8086
      - SCRUTINY_WEB_INFLUXDB_TOKEN=\${INFLUXDB_ADMIN_TOKEN}
      - SCRUTINY_WEB_INFLUXDB_ORG=homelab
      - SCRUTINY_WEB_INFLUXDB_BUCKET=\${INFLUXDB_BUCKET}
      - SCRUTINY_NOTIFY_URLS=\${SCRUTINY_NOTIFY_URLS}
    labels:
      - traefik.enable=true
      - traefik.http.routers.scrutiny.entrypoints=http
      - traefik.http.routers.scrutiny.rule=Host(\`scrutiny.\${DOMAIN}\`)
      - traefik.http.middlewares.scrutiny-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.scrutiny.middlewares=scrutiny-https-redirect
      - traefik.http.routers.scrutiny-secure.entrypoints=https
      - traefik.http.routers.scrutiny-secure.rule=Host(\`scrutiny.\${DOMAIN}\`)
      - traefik.http.routers.scrutiny-secure.tls=true
      - traefik.http.routers.scrutiny-secure.service=scrutiny
      - traefik.http.services.scrutiny.loadbalancer.server.scheme=http
      - traefik.http.services.scrutiny.loadbalancer.server.port=8080
      - traefik.docker.network=proxy
    depends_on:
      - influxdb
    networks:
      proxy:

networks:
  proxy:
    external: true
EOM

#Depoying the scrutiny container
echo "Depoying the scrutiny container"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/scrutiny$
echo ""
sleep 3s
sudo docker compose logs --follow

