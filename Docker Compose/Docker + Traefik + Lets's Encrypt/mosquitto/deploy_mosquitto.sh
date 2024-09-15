#!/bin/sh

###############################################################
#                       EDIT THIS VALUES
###############################################################

DOMAIN='your_dynu_domain'

MOSQUITTO_USER=choose-a-mosquito-user
# You should use a secure password
# run "openssl rand -base64 45" inside the terminal to generate a secure password
MOSQUITTO_PASSWORD=your-secure-password

###############################################################
#                         SCRIPT CODE
###############################################################

#creating .env
echo "creating .env"
echo "DOMAIN='$DOMAIN'" > .env

# creating config, data and log folders
echo "creating config, data and log folders"
mkdir config
mkdir data
mkdir log

# creating pwfile file
echo "creating pwfile file"
if [ ! -e "./config/pwfile" ]
then
    touch ./config/pwfile
    echo "$MOSQUITTO_USER:$MOSQUITTO_PASSWORD" > ./config/pwfile
    sudo chmod 0700 ./config/pwfile
    NEW_INSTALL='true'
else
    NEW_INSTALL='false'
fi


# creating mosquitto.conf
if [ ! -e "./config/mosquitto.conf" ]
then
echo "creating mosquitto.conf"
/bin/cat <<EOM > ./config/mosquitto.conf
# =================================================================
# Default listener
# =================================================================
listener 1883
protocol mqtt
# =================================================================
# Extra listeners
# =================================================================
listener 8083
protocol websockets 
# =================================================================
# Logging
# =================================================================
#log_dest file /mosquitto/log/mosquitto.log
#log_type all
#information
#log_timestamp_format %Y-%m-%dT%H:%M:%S
#log_timestamp true
# =================================================================
# Data persistance
# =================================================================
persistence true
persistence_location /mosquitto/data/
# =================================================================
# Security
# =================================================================
allow_anonymous false
# -----------------------------------------------------------------
# Default authentication and topic access control
# generated using the mosquitto_passwd utility. 
# -----------------------------------------------------------------
password_file /mosquitto/config/pwfile
EOM
fi


# creating compose.yaml
echo "creating compose.yaml"
/bin/cat <<EOM > compose.yaml
services:
  mqtt5:
    image: eclipse-mosquitto:latest
    container_name: mosquitto
    restart: unless-stopped
    # ports:
    #   - 1883:1883 #default mosquitto port
    #   - 9001:9001 #default mosquitto port for websockets
    volumes:
      - ./config:/mosquitto/config:rw
      - ./data:/mosquitto/data:rw
      - ./log:/mosquitto/log:rw
    labels:
      - "traefik.enable=true"
      - "traefik.tcp.routers.mqtt.rule=HostSNI(\`mosquitto.\${DOMAIN}\`)"
      - "traefik.tcp.routers.mqtt.entrypoints=mqtt"
      - "traefik.tcp.routers.mqtt.service=mqttservice"
      - "traefik.tcp.routers.mqtt.tls=true"
      # Because Traefik handles TLS outside Mosquitto internal does not need TLS
      - "traefik.tcp.services.mqttservice.loadbalancer.server.port=1883"
      # Websock uses the http protocol but in combination with a TCP handler on port 8883 for mqtt you need to specify it
      - "traefik.http.routers.websock.rule=Host(\`mosquitto.\${DOMAIN}\`)"
      - "traefik.http.routers.websock.entrypoints=websock"
      - "traefik.http.routers.websock.service=websockservice"
      - "traefik.http.routers.websock.tls=true"
      - "traefik.http.routers.websock.tls.certresolver=letsencrypt"
      # Because Traefik handles https outside Mosquitto so websock internal does not need TLS
      - "traefik.http.services.websockservice.loadbalancer.server.port=8083"
    networks:
      proxy:
networks:
  proxy:
    external: true


EOM

# Depoying the mosquitto container
echo "Depoying the mosquitto container"
sudo docker compose down
sudo docker compose up -d --force-recreate

# Encrypting password
if [ $NEW_INSTALL = 'true' ]
then
    sudo docker exec mosquitto /bin/sh -c "mosquitto_passwd -U /mosquitto/config/pwfile"
    sudo docker compose down
    sudo docker compose up -d --force-recreate
fi

# display logs
sudo docker container ls -a
sudo docker logs mosquitto --follow

