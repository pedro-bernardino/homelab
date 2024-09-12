# Mosquitto
[Mosquitto](https://github.com/eclipse/mosquitto) is an open source implementation of a server for version 5.0, 3.1.1, and 3.1 of the MQTT protocol. It also includes a C and C++ client library, and the mosquitto_pub and mosquitto_sub utilities for publishing and subscribing.

# Usage
+ Copy the [compose.yaml](/DockerCompose/mosquito/compose.yaml) to your docker server (change port if needed)
  + run the command (inside the **compose.yaml** folder):
    + ***sudo docker compose up -d***