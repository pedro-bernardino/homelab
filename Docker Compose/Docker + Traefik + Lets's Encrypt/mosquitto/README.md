# Mosquitto
[Mosquitto](https://github.com/eclipse/mosquitto) is an open source implementation of a server for version 5.0, 3.1.1, and 3.1 of the MQTT protocol. It also includes a C and C++ client library, and the mosquitto_pub and mosquitto_sub utilities for publishing and subscribing.

# Usage
+ Create a folder for the mosquitto files 
  + ```mkdir mosquitto```
+ Open mosquitto folder
  + ```cd mosquitto```
+ Copy [deploy_mosquitto.sh](deploy_mosquitto.sh) to your mosquitto folder
+ Edit [deploy_mosquitto.sh](deploy_mosquitto.sh) and change the values with your info
+ Make [deploy_mosquitto.sh](deploy_mosquitto.sh) executable
  + ```sudo chmod +x deploy_mosquitto.sh```
+ Run the script to deploy mosquitto
  + ```./deploy_mosquitto.sh```
+ Add domain to pihole local dns
  + Domain: https://mosquitto.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open mosquitto dashboard
  + https://mosquitto.YOUR-DOMAIN-COM