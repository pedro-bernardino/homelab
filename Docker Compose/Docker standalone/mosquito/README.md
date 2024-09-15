# Mosquitto
[Mosquitto](https://github.com/eclipse/mosquitto) is an open source implementation of a server for version 5.0, 3.1.1, and 3.1 of the MQTT protocol. It also includes a C and C++ client library, and the mosquitto_pub and mosquitto_sub utilities for publishing and subscribing.

# Usage
+ Copy the [compose.yaml](compose.yaml) to your docker server (change port if needed)
+ Copy the [mosquitto.conf](mosquitto.conf) to your docker server
  + create the config folder and move mosquitto.conf
    + ```mkdir config```
    + ```mv ./mosquitto.conf config/```
+ Create the password file
  + ```touch ./config/pwfile```
  + ```echo "<your-user>:<your-strong-passwrod>" > ./config/pwfile```
  + ```chmod 0700 ./config/pwfile```
+ Start the container
  + ```sudo docker compose up -d```
+ Encrypt the password for mosquitto inside the container
  + ```sudo docker exec mosquitto /bin/sh -c "mosquitto_passwd -U /mosquitto/config/pwfile"```
+ Restart the container
  + ```sudo docker compose down```
  + ```sudo docker compose up -d --force-recreate```
+ See the logs for any errors
  + ```sudo docker compose logs --follow```