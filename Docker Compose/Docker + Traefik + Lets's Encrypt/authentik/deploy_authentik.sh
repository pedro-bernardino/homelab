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
    echo "PG_PASS='$(openssl rand -base64 60 | tr -d '\n')'" >> .env                # this generate a big password
    echo "PG_USER='$(tr -dc A-Za-z </dev/urandom | head -c 6)'" >> .env             # this generate a string
    echo "PG_DB='$(tr -dc A-Za-z </dev/urandom | head -c 6)'" >> .env               # this generate a string
    echo "AUTHENTIK_SECRET_KEY='$(openssl rand -base64 60 | tr -d '\n')'" >> .env   # this generate a big password
else
    echo ".env file exist. skipping..."
fi

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  postgresql:
    image: docker.io/library/postgres:16-alpine
    container_name: authentik-postgresql
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -d \${PG_DB} -U \${PG_USER}"]
      start_period: 20s
      interval: 30s
      retries: 5
      timeout: 5s
    volumes:
      - ./database:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: \${PG_PASS}
      POSTGRES_USER: \${PG_USER}
      POSTGRES_DB: \${PG_DB}
    networks:
      - proxy
  redis:
    image: docker.io/library/redis:alpine
    container_name: authentik-redis
    command: --save 60 1 --loglevel warning
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "redis-cli ping | grep PONG"]
      start_period: 20s
      interval: 30s
      retries: 5
      timeout: 3s
    volumes:
      - ./redis:/data
    networks:
      - proxy
  server:
    image: ghcr.io/goauthentik/server:2024.8.1
    container_name: authentik
    restart: unless-stopped
    command: server
    environment:
      AUTHENTIK_REDIS__HOST: redis
      AUTHENTIK_POSTGRESQL__HOST: postgresql
      AUTHENTIK_POSTGRESQL__USER: \${PG_USER}
      AUTHENTIK_POSTGRESQL__NAME: \${PG_DB}
      AUTHENTIK_POSTGRESQL__PASSWORD: \${PG_PASS}
      AUTHENTIK_SECRET_KEY: \${AUTHENTIK_SECRET_KEY}
    volumes:
      - ./media:/media
      - ./custom-templates:/templates
    # ports:
    #   - "9000:9000"
    #   - "9443:9443"
    labels:
      - traefik.enable=true
      - traefik.http.routers.authentik.entrypoints=http
      - traefik.http.routers.authentik.rule=Host(\`authentik.\${DOMAIN}\`)
      - traefik.http.middlewares.authentik-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.authentik.middlewares=authentik-https-redirect
      - traefik.http.routers.authentik-secure.entrypoints=https
      - traefik.http.routers.authentik-secure.rule=Host(\`authentik.\${DOMAIN}\`)
      - traefik.http.routers.authentik-secure.tls=true
      - traefik.http.routers.authentik-secure.service=authentik
      - traefik.http.services.authentik.loadbalancer.server.scheme=https
      - traefik.http.services.authentik.loadbalancer.server.port=9443
      - traefik.docker.network=proxy
    depends_on:
      - postgresql
      - redis
    networks:
      - proxy
  worker:
    image: ghcr.io/goauthentik/server:2024.8.1
    container_name: authentik-worker
    restart: unless-stopped
    command: worker
    environment:
      AUTHENTIK_REDIS__HOST: redis
      AUTHENTIK_POSTGRESQL__HOST: postgresql
      AUTHENTIK_POSTGRESQL__USER: \${PG_USER}
      AUTHENTIK_POSTGRESQL__NAME: \${PG_DB}
      AUTHENTIK_POSTGRESQL__PASSWORD: \${PG_PASS}
      AUTHENTIK_SECRET_KEY: \${AUTHENTIK_SECRET_KEY}
    # \`user: root\` and the docker socket volume are optional.
    # See more for the docker socket integration here:
    # https://goauthentik.io/docs/outposts/integrations/docker
    # Removing \`user: root\` also prevents the worker from fixing the permissions
    # on the mounted folders, so when removing this make sure the folders have the correct UID/GID
    # (1000:1000 by default)
    user: root
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./media:/media
      - ./certs:/certs
      - ./custom-templates:/templates
    depends_on:
      - postgresql
      - redis
    networks:
      - proxy

networks:
  proxy:
    external: true

EOM

#Depoying the authentik container
echo "================================"
echo "Depoying the authentik container"
echo "authentik.${DOMAIN}"
echo "================================"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/authentik$
sudo docker compose logs --follow

