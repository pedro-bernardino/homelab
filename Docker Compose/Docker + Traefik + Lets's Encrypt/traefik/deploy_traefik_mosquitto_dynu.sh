#!/bin/sh


###############################################################
#                       EDIT THIS VALUES
###############################################################

DNS_PROVIDER='dynu'
EMAIL='your-email@server.com'
DOMAIN='your_dynu_domain'
DNS_TOKEN='your_dynu_token'

# disable the dashboard after everithing is working, there is no encryption in the dashboard.
TRAEFIK_DASHBOARD=true

# disable the debug after everithing is working
TRAEFIK_DEBUG=true

# change to false only when everything works fine. 
# Make shure you got a staging certificate first!
USE_LETS_ENCRYPT_STAGING=true 

###############################################################
#                         SCRIPT CODE
###############################################################

# creating data folder
echo "creating data folder"
mkdir data

#creating .env
echo "creating .env"
echo "ACME_PROVIDER='$DNS_PROVIDER'" >> .env
echo "ACME_EMAIL='$EMAIL'" >> .env
echo "DOMAIN='$DOMAIN'" >> .env
echo "DYNU_API_KEY='$DNS_TOKEN'" >> .env

#creating acme.json
echo "creating acme.json"
if [ ! -e "data/acme.json" ]
then
    touch data/acme.json
    chmod 600 data/acme.json
else
    echo "acme.json file exist. skipping..."
fi

#creating proxy network
sudo docker network create \
  --driver=bridge \
  --subnet=10.50.10.0/24 \
  --gateway=10.50.10.254 \
  proxy

#preparing lets encrypt resolver variable
if [ $USE_LETS_ENCRYPT_STAGING = 'true' ]; then
	USE_LETS_ENCRYPT_RESOLVER='https://acme-staging-v02.api.letsencrypt.org/directory'
else
	USE_LETS_ENCRYPT_RESOLVER='https://acme-v02.api.letsencrypt.org/directory'
fi

#preparing log type variable
if [ $TRAEFIK_DEBUG = 'true' ]; then
	TRAEFIK_DEBUG_TYPE='DEBUG'
else
	TRAEFIK_DEBUG_TYPE='ERROR'
fi

#creating traefik.yml
echo "creating traefik.yml"
/bin/cat <<EOM >"./data/traefik.yml"
api:
  dashboard: $TRAEFIK_DASHBOARD  # Optional can be disabled
  insecure: $TRAEFIK_DASHBOARD   # Optional can be disabled
  debug: $TRAEFIK_DEBUG     # Optional can be Enabled if needed for troubleshooting 

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
  https:
    address: ":443"
  mqtt:
    address: ":8883"
  websock:
    address: ":8083"

log:
  level: $TRAEFIK_DEBUG_TYPE

serversTransport:
  insecureSkipVerify: true

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: proxy # Optional; Only use the "proxy" Docker network, even if containers are on multiple networks.
  # file:
  #   filename: /config.yml

certificatesResolvers:
  letsencrypt:
    acme:
      email: $EMAIL
      storage: acme.json
      caServer: $USE_LETS_ENCRYPT_RESOLVER
      # caServer: https://acme-v02.api.letsencrypt.org/directory # prod (default)
      # caServer: https://acme-staging-v02.api.letsencrypt.org/directory # staging
      dnsChallenge:
        provider: $DNS_PROVIDER
        #disablePropagationCheck: true # uncomment this if you have issues pulling certificates, By setting this flag to true disables the need to wait for the propagation of the TXT record to all authoritative name servers.
        #delayBeforeCheck: 120s # uncomment along with disablePropagationCheck if needed to ensure the TXT record is ready before verification is attempted 
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
EOM

#creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM >compose.yaml
services:
  traefik:
    image: traefik:latest
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    ports:
      # Traefik Ports
      - 80:80      #The HTTP port (disabled because using tlschallenge)
      - 443:443     #The HTTPS port
      # - 8080:8080   #The Web UI (if enabled by --api.insecure=true)

      # MQTT Ports
      #- 1883:1883  #The mqtt port (non TLS - disabled)
      - 8883:8883   #The mqtt TLS port
      - 8083:8083   #The mqtt websocket port (TLS)
    environment:
      - TZ=Europe/Lisbon
      - DYNU_API_KEY=\${DYNU_API_KEY}
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data/traefik.yml:/traefik.yml:ro
      - ./data/acme.json:/acme.json
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=http"
      - "traefik.http.routers.traefik.rule=Host(\`traefik.\${DOMAIN}\`)"
      - "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
      - "traefik.http.routers.traefik-secure.entrypoints=https"
      - "traefik.http.routers.traefik-secure.rule=Host(\`traefik.\${DOMAIN}\`)"
      - "traefik.http.routers.traefik-secure.tls=true"
      - "traefik.http.routers.traefik-secure.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik-secure.tls.domains[0].main=\${DOMAIN}"
      - "traefik.http.routers.traefik-secure.tls.domains[0].sans=*.\${DOMAIN}"
      - "traefik.http.routers.traefik-secure.service=api@internal"
    networks:
      proxy:
        ipv4_address: 10.50.10.1
networks:
  proxy:
    external: true
EOM

#Depoying the traefik container
echo "================================"
echo "Depoying the traefik container"
echo "traefik.${DOMAIN}"
echo "================================"
sudo docker compose down
sudo docker compose up -d --force-recreate
sudo docker ps -a --no-trunc --filter name=^/traefik$
sudo docker compose logs --follow
