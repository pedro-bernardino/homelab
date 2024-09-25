#!/bin/sh
#

###############################################################
#                       EDIT THIS VALUES
###############################################################

DOMAIN='your_dynu_domain'

# Time Zone code see here: https://www.php.net/manual/en/timezones.php
TIMEZONE='Europe/Lisbon'
# Region code see here: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements
REGION='PT'

###############################################################
#                         SCRIPT CODE
###############################################################

#creating .env
echo "creating .env"
if [ ! -e ".env" ]
then
    echo "DOMAIN='$DOMAIN'" > .env
    echo "MYSQL_DATABASE=$(tr -dc A-Za-z </dev/urandom | head -c 6; echo)" >> .env
    echo "MYSQL_USER=$(tr -dc A-Za-z </dev/urandom | head -c 6; echo)" >> .env
    echo "MYSQL_ROOT_PASSWORD=$(openssl rand -base64 60 | tr -d '\n')" >> .env
    echo "MYSQL_PASSWORD=$(openssl rand -base64 60 | tr -d '\n')" >> .env
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
      - traefik.enable=true
      - traefik.http.routers.nextcloud_app.rule=Host(\`nextcloud.\${DOMAIN}\`)
      - traefik.http.routers.nextcloud_app.entrypoints=https
      - traefik.http.routers.nextcloud_app.tls.certresolver=letsencrypt
      - traefik.http.routers.nextcloud_app.middlewares=nextcloud,nextcloud_redirect
      - traefik.http.routers.nextcloud_app.tls=true
      - traefik.http.middlewares.nextcloud.headers.customFrameOptionsValue=ALLOW-FROM https://\${DOMAIN}
      - traefik.http.middlewares.nextcloud.headers.contentSecurityPolicy=frame-ancestors 'self' \${DOMAIN} *.\${DOMAIN}
      - traefik.http.middlewares.nextcloud.headers.stsSeconds=155520011
      - traefik.http.middlewares.nextcloud.headers.stsIncludeSubdomains=true
      - traefik.http.middlewares.nextcloud.headers.stsPreload=true
      - traefik.http.middlewares.nextcloud.headers.customresponseheaders.X-Frame-Options=SAMEORIGIN
      - traefik.http.middlewares.nextcloud_redirect.redirectregex.permanent=true
      - traefik.http.middlewares.nextcloud_redirect.redirectregex.regex=https://(.*)/.well-known/(card|cal)dav
      - traefik.http.middlewares.nextcloud_redirect.redirectregex.replacement=https://\$\${1}/remote.php/dav/
    networks:
      proxy:

networks:
  proxy:
    external: true
EOM


#Depoying the nextcloud container
echo "================================"
echo "Depoying the nextcloud container"
echo "nextcloud.${DOMAIN}"
echo "================================"
sudo docker compose down
sudo docker compose up -d --force-recreate

# fixing db:
sleep 5
sudo docker exec -it nextcloud occ db:add-missing-indices
# Updating config.php Values
sudo docker exec -it nextcloud occ config:system:set logtimezone --value=${TIMEZONE}
sudo docker exec -it nextcloud occ config:system:set default_phone_region --value=${REGION}
sudo docker exec -it nextcloud occ config:system:set overwritehost --value=nextcloud.${DOMAIN}
sudo docker exec -it nextcloud occ config:system:set overwriteprotocol --value=https
sudo docker exec -it nextcloud occ config:system:set maintenance_window_start --value=1
sudo docker exec -it nextcloud occ config:system:set trusted_domains 0 --value=https://nextcloud.${DOMAIN}
sudo docker exec -it nextcloud occ config:system:set trusted_domains 1 --value=https://${DOMAIN}
sudo docker exec -it nextcloud occ config:system:set trusted_domains 2 --value=10.50.10.1
sudo docker exec -it nextcloud occ config:system:set trusted_proxies 0 --value=10.50.10.1

sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/nextcloud$
sudo docker compose logs --follow
