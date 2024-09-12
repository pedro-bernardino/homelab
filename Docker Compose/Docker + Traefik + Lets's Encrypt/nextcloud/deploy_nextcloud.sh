#!/bin/sh
#

###############################################################
#                       EDIT THIS VALUES
###############################################################

DOMAIN='your_dynu_domain'

###############################################################
#                         SCRIPT CODE
###############################################################

#creating .env
echo "creating .env"
if [ ! -e ".env" ]
then
    echo "DOMAIN='$DOMAIN'" > .env
    echo "MYSQL_DATABASE=$(tr -dc A-Za-z </dev/urandom | head -c 6; echo)" >> .env  # this generate a string
    echo "MYSQL_USER=$(tr -dc A-Za-z </dev/urandom | head -c 6; echo)" >> .env      # this generate a string
    echo "MYSQL_ROOT_PASSWORD=$(openssl rand -base64 60 | tr -d '\n')" >> .env      # this generate a big password
    echo "MYSQL_PASSWORD=$(openssl rand -base64 60 | tr -d '\n')" >> .env           # this generate a big password
else
    echo ".env file exist. skipping..."
fi

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  db:
    image: mariadb:10.6
    container_name: nextcloud-mariadb
    restart: unless-stopped
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    volumes:
      - ./db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=\$MYSQL_ROOT_PASSWORD
      - MYSQL_PASSWORD=\$MYSQL_PASSWORD
      - MYSQL_DATABASE=\$MYSQL_DATABASE
      - MYSQL_USER=\$MYSQL_USER
    networks:
      proxy:

  nextcloud:
    image: lscr.io/linuxserver/nextcloud:latest
    container_name: nextcloud
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Lisbon
      - MYSQL_PASSWORD=\$MYSQL_PASSWORD
      - MYSQL_DATABASE=\$MYSQL_DATABASE
      - MYSQL_USER=\$MYSQL_USER
      - MYSQL_HOST=db
    volumes:
      - ./html:/var/www/html
      - ./config:/config
      - ./data:/data
    depends_on:
      - db
    # ports:
    #  - 443:443
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nextcloud.entrypoints=http"
      - "traefik.http.routers.nextcloud.rule=Host(\`nextcloud.\$DOMAIN\`)"
      - "traefik.http.middlewares.nextcloud-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.nextcloud.middlewares=nextcloud-https-redirect"
      - "traefik.http.routers.nextcloud-secure.entrypoints=https"
      - "traefik.http.routers.nextcloud-secure.rule=Host(\`nextcloud.\$DOMAIN\`)"
      - "traefik.http.routers.nextcloud-secure.tls=true"
      - "traefik.http.routers.nextcloud-secure.service=nextcloud"
      - "traefik.http.services.nextcloud.loadbalancer.server.port=80"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.nextcloud.middlewares=nextcloud_redirectregex"
      - "traefik.http.middlewares.nextcloud_redirectregex.redirectregex.permanent=true"
      - "traefik.http.middlewares.nextcloud_redirectregex.redirectregex.regex=https://(.*)/.well-known/(?:card|cal)dav"
      - "traefik.http.middlewares.nextcloud_redirectregex.redirectregex.replacement=https://\$\${1}/remote.php/dav"
    networks:
      proxy:

networks:
  proxy:
    external: true

EOM

#Depoying the authentik container
echo "Depoying the nextcloud container"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps
sudo docker logs --follow nextcloud

