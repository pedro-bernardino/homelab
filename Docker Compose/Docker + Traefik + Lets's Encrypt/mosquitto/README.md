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
+ Mosquitto don't have a user interface. Use [MQTT Explorer](https://mqtt-explorer.com) to test the container.
  + Protocol: ```ws://```
  + Host: ```mosquitto.YOUR-DOMAIN-COM```
  + Post: ```8083```
  + Basepath: ```ws```
  + Username: ```your-mosquito-user```
  + Password: ```your-secure-password```

